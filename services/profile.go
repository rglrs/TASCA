package services

import (
	"errors"
	"log"

	"github.com/markbates/goth"
	"gorm.io/gorm"
	"tasca/models"
	"tasca/repositories"
	"tasca/utils"
)

func LinkGoogle(db *gorm.DB, userID uint, gothUser goth.User) error {
	currentUser, err := repositories.GetUserByID(db, userID)
	if err != nil {
		return errors.New("user tidak ditemukan")
	}

	if currentUser.Email != gothUser.Email {
		return errors.New("email tidak cocok")
	}

	if existingUser, _ := repositories.GetUserByGoogleID(db, gothUser.UserID); existingUser != nil {
		return errors.New("akun google sudah terhubung dengan akun lain")
	}

	currentUser.GoogleID = &gothUser.UserID
	currentUser.Picture = &gothUser.AvatarURL
	currentUser.Provider = "both"

	return repositories.UpdateUser(db, currentUser)

}

func UnlinkGoogle(db *gorm.DB, userID uint) error {
	currentUser, err := repositories.GetUserByID(db, userID)
	if err != nil {
		return errors.New("user tidak ditemukan")
	}

	if currentUser.GoogleID == nil || (currentUser.Provider != "google" && currentUser.Provider != "both") {
		return errors.New("akun tidak terhubung google")
	}

	if currentUser.Password == "" && currentUser.Provider == "google" {
		return errors.New("akun tidak bisa dihapus")
	}
	currentUser.GoogleID = nil
	currentUser.Provider = "local"
	return repositories.UpdateUser(db, currentUser)
}

func DeleteAccount(db *gorm.DB, userID uint) error {
	user, err := repositories.GetUserByID(db, userID)
	if err != nil {
		return errors.New("user tidak ditemukan")
	}
	return repositories.DeleteUser(db, user)
}

func GetUserProfile(db *gorm.DB, userID uint) (*models.User, error) {
	return repositories.GetUserByID(db, userID)
}

func ChangePassword(db *gorm.DB, userID uint, currentPassword, newPassword string) error {
	user, err := repositories.GetUserByID(db, userID)
	if err != nil {
		return errors.New("user tidak ditemukan")
	}

	if !utils.CheckPassword(currentPassword, user.Password) {
		return errors.New("password saat ini salah")
	}

	if !utils.IsValidPassword(newPassword) {
		return errors.New("password baru harus minimal 8 karakter dan hanya boleh mengandung huruf serta angka")
	}

	hashedPassword, err := utils.HashPassword(newPassword)
	if err != nil {
		return err
	}

	user.Password = hashedPassword
	return repositories.UpdateUser(db, user)
}

// func UpdateUserProfile(db *gorm.DB, userID uint, username, name *string, phone *string, newPicture *string) error {
// 	tx := db.Begin()
// 	defer func() {
// 		if r := recover(); r != nil {
// 			tx.Rollback()
// 		}
// 	}()

// 	user, err := repositories.GetUserByID(tx, userID)
// 	if err != nil {
// 		tx.Rollback()
// 		return errors.New("user tidak ditemukan")
// 	}

// 	if username != nil && *username != "" && *username != user.Username {
// 		existingUser, _ := repositories.GetUserByUsername(tx, *username)
// 		if existingUser != nil {
// 			tx.Rollback()
// 			return errors.New("username sudah digunakan")
// 		}
// 		user.Username = *username
// 	}

// 	if name != nil {
// 		user.Name = *name
// 	}

// 	if phone != nil {
// 		user.Phone = phone
// 	}

// 	if newPicture != nil {
// 		if user.Picture != nil && *user.Picture != "" && *user.Picture != "nopp.png" {
// 			oldPath := fmt.Sprintf("/var/www/tasca/Tasca/storage/upload/%s", *user.Picture)
// 			_ = os.Remove(oldPath)
// 		}

// 		user.Picture = newPicture
// 	}

// 	if err := tx.Save(user).Error; err != nil {
// 		tx.Rollback()
// 		return err
// 	}

// 	return tx.Commit().Error
// }

// func DeleteProfilePicture(db *gorm.DB, userID uint) error {
// 	user, err := repositories.GetUserByID(db, userID)
// 	if err != nil {
// 		return err
// 	}

// 	noppPic := "nopp.png"
// 	user.Picture = &noppPic

// 	return repositories.UpdateUser(db, user)
// }

func UpdateUserProfile(db *gorm.DB, userID uint, username, name *string, phone *string, newPicture *string) error {
	tx := db.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	user, err := repositories.GetUserByID(tx, userID)
	if err != nil {
		tx.Rollback()
		return errors.New("user tidak ditemukan")
	}

	if username != nil && *username != "" && *username != user.Username {
		existingUser, _ := repositories.GetUserByUsername(tx, *username)
		if existingUser != nil {
			tx.Rollback()
			return errors.New("username sudah digunakan")
		}
		user.Username = *username
	}

	if name != nil {
		user.Name = *name
	}

	if phone != nil {
		user.Phone = phone
	}

	if newPicture != nil {
		if user.Picture != nil && *user.Picture != "" && *user.Picture != "nopp.png" {
			err := utils.DeleteFileFromS3(*user.Picture)
			if err != nil {
				log.Printf("Error deleting old profile picture from S3: %v", err)
			}
		}

		user.Picture = newPicture
	}

	if err := tx.Save(user).Error; err != nil {
		tx.Rollback()
		return err
	}

	return tx.Commit().Error
}

func DeleteProfilePicture(db *gorm.DB, userID uint) error {
	user, err := repositories.GetUserByID(db, userID)
	if err != nil {
		return err
	}

	if user.Picture != nil && *user.Picture != "" && *user.Picture != "nopp.png" {
		err := utils.DeleteFileFromS3(*user.Picture)
		if err != nil {
			log.Printf("Error deleting profile picture from S3: %v", err)
		}
	}

	noppPic := "nopp.png"
	user.Picture = &noppPic

	return repositories.UpdateUser(db, user)
}
