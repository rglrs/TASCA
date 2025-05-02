package repositories

import (
	"tasca/models"
	"gorm.io/gorm"
)

func SaveDeviceToken(db *gorm.DB, deviceToken *models.DeviceToken) error {
	var existingToken models.DeviceToken
	result := db.Where("user_id = ? AND token = ?", deviceToken.UserID, deviceToken.Token).First(&existingToken)
	
	if result.Error == nil {
		return db.Model(&existingToken).Updates(map[string]interface{}{
			"platform": deviceToken.Platform,
		}).Error
	}
	
	return db.Create(deviceToken).Error
}

func DeleteDeviceToken(db *gorm.DB, userID uint, token string) error {
	return db.Where("user_id = ? AND token = ?", userID, token).Delete(&models.DeviceToken{}).Error
}

func GetUserDeviceTokens(db *gorm.DB, userID uint) ([]models.DeviceToken, error) {
	var tokens []models.DeviceToken
	err := db.Where("user_id = ?", userID).Find(&tokens).Error
	return tokens, err
}

func GetAllActiveDeviceTokens(db *gorm.DB) ([]models.DeviceToken, error) {
	var tokens []models.DeviceToken
	err := db.Find(&tokens).Error
	return tokens, err
}