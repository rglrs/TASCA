package utils

import (
	"regexp"
	"strings"
	"golang.org/x/crypto/bcrypt"
)

func IsValidEmail(email string) bool {
	emailRegex := `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
	re := regexp.MustCompile(emailRegex)
	return re.MatchString(email)
}

func IsValidPassword(password string) bool {
	hasUpper := regexp.MustCompile(`[A-Z]`).MatchString(password)
    hasLower := regexp.MustCompile(`[a-z]`).MatchString(password)
    hasNumber := regexp.MustCompile(`[0-9]`).MatchString(password)
    hasMinLength := len(password) >= 8
    
    return hasUpper && hasLower && hasNumber && hasMinLength
}

func IsValidUsername(username string) bool {
	usernameRegex := `^[A-Za-z0-9 ]{4,}$`
	re := regexp.MustCompile(usernameRegex)
	return re.MatchString(username) && strings.TrimSpace(username) != ""
}

func IsValidPhone(phone string) bool {
    phoneRegex := `^\+?[0-9]{8,15}$`
    re := regexp.MustCompile(phoneRegex)
    return re.MatchString(phone)
}

func HashPassword(password string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(hash), err
}

func CheckPassword(password, hash string) bool {
	err := bcrypt.CompareHashAndPassword([]byte(hash), []byte(password))
	return err == nil
}