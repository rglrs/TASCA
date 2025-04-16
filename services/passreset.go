package services

import (
	"crypto/rand"
	"io"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"errors"
	"bytes"
	"fmt"
	"log"
	"os"
	"time"

	"tasca/models"
	"tasca/repositories"
	"tasca/utils"

	"github.com/joho/godotenv"
	"gorm.io/gorm"
)

func init() {
	_ = godotenv.Load()
}

func RequestPasswordReset(db *gorm.DB, email string) error {
	user, err := repositories.GetUserByEmail(db, email)
	if err != nil {
		return errors.New("email tidak terdaftar")
	}

	if user.ResetTokenExpiry != nil && time.Now().Before(*user.ResetTokenExpiry) {
		return errors.New("permintaan reset sudah dilakukan, coba lagi setelah beberapa menit")
	}

	token, err := GenerateResetToken()
	if err != nil {
		return err
	}

	expiry := time.Now().Add(30 * time.Minute)
	err = db.Model(&user).Updates(map[string]interface{}{
		"reset_token":        token,
		"reset_token_expiry": expiry,
	}).Error
	if err != nil {
		return errors.New("gagal menyimpan token reset")
	}

	go func() {
		if err := SendBrevoEmail(user.Email, user.Name, token); err != nil {
			log.Printf("Gagal mengirim email untuk %s: %v", user.Email, err)
		}
	}()

	return nil
}

func GenerateResetToken() (string, error) {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		return "", err
	}
	return hex.EncodeToString(bytes), nil
}

type BrevoEmailContact struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

type BrevoEmailRequest struct {
	Sender      BrevoEmailContact   `json:"sender"`
	To          []BrevoEmailContact `json:"to"`
	Subject     string              `json:"subject"`
	HtmlContent string              `json:"htmlContent"`
}

func SendBrevoEmail(email, name, token string) error {
	apiKey := os.Getenv("BREVO_API_KEY")
	if apiKey == "" {
		return errors.New("BREVO_API_KEY tidak ditemukan di environment")
	}

	resetURL := fmt.Sprintf("https://tascaid.site/forgot-password?token=%s", token)

	// Create the email request
	emailReq := BrevoEmailRequest{
		Sender: BrevoEmailContact{
			Name:  "Tim Support Tasca",
			Email: "tascakap@gmail.com",
		},
		To: []BrevoEmailContact{
			{
				Name:  name,
				Email: email,
			},
		},
		Subject: "Reset Password",
		HtmlContent: fmt.Sprintf(`
			<p>Halo, <strong>%s</strong>,</p>
			<p>Kami menerima permintaan untuk mengatur ulang password Anda.</p>
			<p>Silakan Klik tombol di bawah untuk mereset password Anda:</p>
			<p style="text-align: center;">
			<a href="%s" style="background-color: #007bff; color: #ffffff; padding: 10px 20px;
			text-decoration: none; border-radius: 5px; display: inline-block;">
			Reset Password
			</a>
			</p>
			<p><b>Catatan:</b> Link ini hanya berlaku selama 30 menit. Jika Anda tidak meminta reset
			password, abaikan email ini.</p>
			<p>Terima kasih,</p>
			<p><b>Tim Support Tasca</b></p>
		`, name, resetURL),
	}

	payload, err := json.Marshal(emailReq)
	if err != nil {
		return fmt.Errorf("gagal membuat request email: %v", err)
	}

	req, err := http.NewRequest("POST", "https://api.brevo.com/v3/smtp/email", bytes.NewBuffer(payload))
	if err != nil {
		return fmt.Errorf("gagal membuat HTTP request: %v", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("api-key", apiKey)

	client := &http.Client{Timeout: 10 * time.Second}
	log.Printf("Mengirim email reset ke %s via Brevo", email)
	
	resp, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("gagal mengirim email: %v", err)
	}
	defer resp.Body.Close()

	respBody, _ := io.ReadAll(resp.Body)

	if resp.StatusCode >= 200 && resp.StatusCode < 300 {
		log.Printf("Berhasil mengirim email reset ke %s", email)
		return nil
	}

	log.Printf("Gagal mengirim email: Status: %d, Response: %s", resp.StatusCode, string(respBody))
	return fmt.Errorf("gagal mengirim email: status code %d", resp.StatusCode)
}

func ResetPassword(db *gorm.DB, token, newPassword string) error {
	var user models.User
	if err := db.Where("reset_token = ?", token).First(&user).Error; err != nil {
		return errors.New("token tidak valid")
	}

	if user.ResetTokenExpiry.Before(time.Now()) {
		return errors.New("token sudah kadaluarsa")
	}

	if !utils.IsValidPassword(newPassword) {
		return errors.New("password harus minimal 8 karakter dan hanya boleh mengandung huruf serta angka")
	}

	hashedPassword, err := utils.HashPassword(newPassword)
	if err != nil {
		return err
	}

	err = db.Model(&user).Updates(map[string]interface{}{
		"password":           hashedPassword,
		"reset_token":        nil,
		"reset_token_expiry": nil,
	}).Error
	if err != nil {
		return errors.New("gagal memperbarui password")
	}

	return nil
}

func ValidateResetToken(db *gorm.DB, token string) (bool, error) {
    log.Printf("Token yang diterima: '%s'", token)
    log.Printf("Panjang token: %d", len(token))

    var user models.User
    result := db.Where("reset_token = ?", token).First(&user)
    
    if result.Error != nil {
        log.Printf("Error pencarian token: %v", result.Error)
        return false, errors.New("token tidak valid")
    }

    log.Printf("Token ditemukan untuk pengguna: %s", user.Email)
    return true, nil
}