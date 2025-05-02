package services

import (
	"errors"

	"gorm.io/gorm"
	"tasca/models"
	"tasca/repositories"
	"tasca/utils"
)

func RegisterUser(db *gorm.DB, user *models.User) error {
	if !utils.IsValidEmail(user.Email) {
		return errors.New("format email tidak valid")
	}

	if !utils.IsValidUsername(user.Username) {
		return errors.New("username harus minimal 4 karakter")
	}

	if !utils.IsValidPassword(user.Password) {
		return errors.New("password harus minimal 8 karakter, mengandung huruf besar, kecil, dan angka")
	}

	hashedPassword, err := utils.HashPassword(user.Password)
	if err != nil {
		return errors.New("gagal membuat akun")
	}
	user.Password = hashedPassword

	if user.Picture == nil || *user.Picture == "" {
		defaultPic := "storage/upload/default.jpg"
		user.Picture = &defaultPic
	}

	return repositories.CreateUser(db, user)
}

func LoginUser(db *gorm.DB, login, password string) (string, error) {
	user, err := repositories.GetUserByLogin(db, login)
	if err != nil {
		return "", errors.New("user tidak ditemukan")
	}

	if !utils.CheckPassword(password, user.Password) {
		return "", errors.New("password salah")
	}

	token, err := utils.GenerateJWT(*user)
	if err != nil {
		return "", err
	}

	return token, nil
}