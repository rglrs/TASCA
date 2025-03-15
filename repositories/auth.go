package repositories

import (
	"gorm.io/gorm"
	"tasca/models"
)

func GetUserByLogin(db *gorm.DB, login string) (*models.User, error) {
	var user models.User
	err := db.Where("email = ? OR username = ?", login, login).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func GetUserByEmail(db *gorm.DB, email string) (*models.User, error) {
	var user models.User
	err := db.Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func GetUserByUsername(db *gorm.DB, username string) (*models.User, error) {
	var user models.User
	err := db.Where("username = ?", username).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

func GetUserByID(db *gorm.DB, userID uint) (*models.User, error) {
	var user models.User
	if err := db.First(&user, userID).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func GetUserByPhone(db *gorm.DB, phone string) (*models.User, error) {
    var user models.User
    err := db.Where("phone = ?", phone).First(&user).Error
    if err != nil {
        return nil, err
    }
    return &user, nil
}

func GetUserByGoogleID(db *gorm.DB, googleID string) (*models.User, error) {
	var user models.User
	if err := db.Where("google_id = ?", googleID).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func CreateUser(db *gorm.DB, user *models.User) error {
	return db.Create(user).Error
}