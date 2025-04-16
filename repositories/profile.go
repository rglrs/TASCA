package repositories

import (
	"gorm.io/gorm"
	"tasca/models"
)

func UpdateUser(db *gorm.DB, user *models.User) error {
	return db.Save(user).Error
}

func DeleteUser(db *gorm.DB, user *models.User) error {
	return db.Select("Todos.Tasks").Delete(user).Error
}