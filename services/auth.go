package services

import (
	"errors"

	"github.com/markbates/goth"
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
		return errors.New("username harus minimal 3 karakter dan hanya boleh mengandung huruf")
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
		defaultPic := "storage/upload/profile_picture/default.jpg"
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

func AuthenticateGoogleUser(db *gorm.DB, gothUser goth.User) (string, error) {
	existingUser, err := repositories.GetUserByGoogleID(db, gothUser.UserID)
	if err != nil && err != gorm.ErrRecordNotFound {
		return "", err
	}

	existingEmailUser, _ := repositories.GetUserByEmail(db, gothUser.Email)
	if existingEmailUser != nil {
		if existingEmailUser.Provider == "google" {
			existingUser = existingEmailUser
		} else {
			return "", errors.New("silahkan link akun ke google")
		}
	}

	if existingUser == nil {
		newUser := &models.User{
			GoogleID: &gothUser.UserID,
			Email:    gothUser.Email,
			Name:     gothUser.Name,
			Provider: "google",
		}
		
		if gothUser.AvatarURL != "" {
			newUser.Picture = &gothUser.AvatarURL
		} else {
			defaultPic := "storage/upload/profile_picture/default.jpg"
			newUser.Picture = &defaultPic
		}

		if err := repositories.CreateUser(db, newUser); err != nil {
			return "", err
		}
		existingUser = newUser
	}

	token, err := utils.GenerateJWT(*existingUser)
	if err != nil {
		return "", errors.New("failed to generate JWT")
	}

	return token, nil
}