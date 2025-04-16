package controllers

import (
	"net/http"

	"tasca/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// ForgotPassword godoc
// @Summary Request password reset
// @Description Send a password reset email to the user
// @Tags auth
// @Accept json
// @Produce json
// @Param email body object true "Email for password reset"
// @Success 200 {object} map[string]string "message: Link reset password telah dikirim ke email Anda"
// @Failure 400 {object} map[string]string "error: Format email tidak valid"
// @Router /api/forgot-password [post]
func ForgotPassword(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)

	var input struct {
		Email string `json:"email"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Format email tidak valid"})
		return
	}

	err := services.RequestPasswordReset(db, input.Email)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Link reset password telah dikirim ke email Anda"})
}

// ResetPassword godoc
// @Summary Reset password
// @Description Reset user password using token from email
// @Tags auth
// @Accept json
// @Produce json
// @Param reset body object true "Password reset data"
// @Success 200 {object} map[string]interface{} "message: Password berhasil diperbarui, silakan login kembali, redirect: /login"
// @Failure 400 {object} map[string]string "error: Input tidak valid"
// @Router /api/reset-password [post]
func ResetPassword(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)

	var input struct {
		Token           string `json:"token"`
		NewPassword     string `json:"new_password"`
		ConfirmPassword string `json:"confirm_password"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	if input.NewPassword != input.ConfirmPassword {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Konfirmasi password tidak sesuai"})
		return
	}

	err := services.ResetPassword(db, input.Token, input.NewPassword)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password berhasil diperbarui, silakan login kembali", "redirect": "/login"})
}


// ValidateToken godoc
// @Summary Validate reset token
// @Description Validate if a password reset token is valid and not expired
// @Tags auth
// @Accept json
// @Produce json
// @Param token body object true "Token to validate"
// @Success 200 {object} map[string]string "message: Token valid"
// @Failure 400 {object} map[string]string "error: Token tidak valid"
// @Router /api/validate-token [post]
func ValidateToken(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)

	var input struct {
		Token string `json:"token" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Token tidak valid"})
		return
	}

	isValid, err := services.ValidateResetToken(db, input.Token)
	if err != nil || !isValid {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Token tidak valid atau sudah kadaluarsa"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Token valid"})
}