package services

import (
	"tasca/models"
	"tasca/repositories"
	"gorm.io/gorm"
)

func RegisterDeviceToken(db *gorm.DB, userID uint, token string, platform string) error {
	deviceToken := &models.DeviceToken{
		UserID:   userID,
		Token:    token,
		Platform: platform,
	}
	return repositories.SaveDeviceToken(db, deviceToken)
}

func UnregisterDeviceToken(db *gorm.DB, userID uint, token string) error {
	return repositories.DeleteDeviceToken(db, userID, token)
}

func GetUserDeviceTokens(db *gorm.DB, userID uint) ([]models.DeviceToken, error) {
	return repositories.GetUserDeviceTokens(db, userID)
}