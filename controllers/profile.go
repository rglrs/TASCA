package controllers

import (
	"net/http"
	"fmt"
	"time"
	"log"
	"strings"

	"tasca/models"
	"tasca/services"
	"tasca/utils"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// DeleteAccount godoc
// @Summary Delete user account
// @Description Delete an authenticated user account
// @Tags profile
// @Security ApiKeyAuth
// @Success 200 {object} map[string]string "message: Akun berhasil dihapus"
// @Failure 400 {object} map[string]string "error: Bad request"
// @Router /api/profile/delete [delete]
func DeleteAccount(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID, _ := c.Get("user_id")

	if err := services.DeleteAccount(db, userID.(uint)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.SetCookie("auth_token", "", -1, "/", "", false, true)
	c.JSON(http.StatusOK, gin.H{"message": "Akun berhasil dihapus"})
}

// LogoutUser godoc
// @Summary Logout user
// @Description Remove authentication token
// @Tags auth
// @Security ApiKeyAuth
// @Success 200 {object} map[string]string "message: Logout berhasil"
// @Router /api/logout [post]
func LogoutUser(c *gin.Context) {
	c.SetCookie("auth_token", "", -1, "/", "", false, true)
	c.JSON(http.StatusOK, gin.H{"message": "Logout berhasil"})
}

// GetUserProfile godoc
// @Summary Get user profile
// @Description Retrieve user profile data
// @Tags profile
// @Security ApiKeyAuth
// @Success 200 {object} models.User
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 404 {object} map[string]string "error: User tidak ditemukan"
// @Router /api/profile [get]
func GetUserProfile(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	userIDUint, ok := userID.(uint)
	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user ID"})
		return
	}

	var user models.User
	if err := db.First(&user, userIDUint).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User tidak ditemukan"})
		return
	}

	var pictureURL string
	if user.Picture != nil && *user.Picture != "" {
		if *user.Picture == "nopp.png" {
			if utils.IsS3Configured() {
				pictureURL = utils.GetS3ObjectURL("nopp.png")
				if pictureURL == "" {
					pictureURL = "https://tascaid-app.s3.ap-southeast-2.amazonaws.com/default.jpg"
				}
			} else {
				pictureURL = "https://tascaid-app.s3.ap-southeast-2.amazonaws.com/default.jpg"
			}
		} else if strings.HasPrefix(*user.Picture, "profiles/") || strings.Contains(*user.Picture, "_") {
			if utils.IsS3Configured() {
				pictureURL = utils.GetS3ObjectURL(*user.Picture)
			} else {
				fileName := *user.Picture
				if strings.HasPrefix(fileName, "profiles/") {
					parts := strings.Split(fileName, "/")
					if len(parts) > 1 {
						fileName = parts[len(parts)-1]
					}
				}
				pictureURL = fmt.Sprintf("https://api.tascaid.com/storage/upload/%s", fileName)
			}
		} else {
			cleanPicturePath := strings.TrimPrefix(*user.Picture, "storage/upload/")
			pictureURL = fmt.Sprintf("https://api.tascaid.com/storage/upload/%s", cleanPicturePath)
		}
	} else {
		if utils.IsS3Configured() {
			pictureURL = utils.GetS3ObjectURL("nopp.png")
			if pictureURL == "" {
				pictureURL = "https://tascaid-app.s3.ap-southeast-2.amazonaws.com/default.jpg"
			}
		} else {
			pictureURL = "https://tascaid-app.s3.ap-southeast-2.amazonaws.com/default.jpg"
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"id":       user.ID,
		"username": user.Username,
		"name":     user.Name,
		"email":    user.Email,
		"phone":    user.Phone,
		"picture":  pictureURL,
	})
}


// ChangePassword godoc
// @Summary Change user password
// @Description Allow authenticated user to change password
// @Tags profile
// @Security ApiKeyAuth
// @Accept json
// @Produce json
// @Param password body map[string]string true "Password Update"
// @Success 200 {object} map[string]string "message: Password berhasil diubah"
// @Failure 400 {object} map[string]string "error: Bad request"
// @Router /api/profile/change-password [post]
func ChangePassword(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID, _ := c.Get("user_id")

	var input struct {
		CurrentPassword string `json:"current_password" binding:"required"`
		NewPassword     string `json:"new_password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	if err := services.ChangePassword(db, userID.(uint), input.CurrentPassword, input.NewPassword); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Password berhasil diubah"})
}

// UpdateProfil godoc
// @Summary Update user profile
// @Description Upload and update user's profile
// @Tags profile
// @Security ApiKeyAuth
// @Accept multipart/form-data
// @Produce json
// @Success 200 {object} map[string]string "message: Foto profil berhasil diperbarui,: filename"
// @Failure 400 {object} map[string]string "error: File tidak ditemukan"
// @Failure 401 {object} map[string]string "error: User tidak ditemukan"
// @Failure 500 {object} map[string]string "error: Gagal menyimpan file"
// @Router /api/profile/update [post]
func UpdateProfile(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID, exists := c.Get("user_id")
	
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	log.Printf("UpdateProfile called for user ID: %v", userID)

	var username, name *string
	var phone *string
	var pictureName *string

	if c.ContentType() == "multipart/form-data" {
		if err := c.Request.ParseMultipartForm(10 << 20); err != nil { 
			log.Printf("Error parsing multipart form: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal memproses form data: " + err.Error()})
			return
		}
		
		log.Printf("Form parsed, fields: %v", c.Request.PostForm)
		
		usernameVal := c.PostForm("username")
		if usernameVal != "" {
			username = &usernameVal
			log.Printf("Username update: %s", usernameVal)
		}
		
		nameVal := c.PostForm("name")
		if nameVal != "" {
			name = &nameVal
			log.Printf("Name update: %s", nameVal)
		}
		
		phoneVal := c.PostForm("phone")
		if phoneVal != "" {
			phone = &phoneVal
			log.Printf("Phone update: %s", phoneVal)
		} else if c.PostForm("phone") == "" && c.Request.Form.Has("phone") {
			phone = nil
			log.Printf("Phone set to nil")
		}
		
		file, err := c.FormFile("picture")
		if err == nil {
			log.Printf("Received file: %s, size: %d", file.Filename, file.Size)
			
			timestamp := time.Now().Unix()
			filename := fmt.Sprintf("%d_%d_%s", userID, timestamp, file.Filename)
			
			var pictureURL string
			
			if utils.IsS3Configured() {
				s3FileName := fmt.Sprintf("profiles/%s", filename)
				pictureURL, err = utils.UploadFileToS3(file, s3FileName)
				
				if err != nil {
					log.Printf("S3 upload failed: %v", err)
					c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengunggah file ke storage: " + err.Error()})
					return
				}
				
				pictureName = &s3FileName
				log.Printf("File berhasil disimpan di S3: %s dengan nama: %s", pictureURL, *pictureName)
			} else {
				log.Printf("S3 not configured, returning error")
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Storage S3 tidak tersedia"})
				return
			}
		} else if err != http.ErrMissingFile {
			log.Printf("Error getting form file: %v", err)
		}
	} else {
		var input struct {
			Username *string `json:"username"`
			Name     *string `json:"name"`
			Phone    *string `json:"phone"`
		}
		
		if err := c.ShouldBindJSON(&input); err != nil {
			log.Printf("Error binding JSON: %v", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid: " + err.Error()})
			return
		}
		
		username = input.Username
		name = input.Name
		phone = input.Phone
		
		log.Printf("JSON update request: username=%v, name=%v, phone=%v", 
			valueOrNil(username), valueOrNil(name), valueOrNil(phone))
	}
	
	if username == nil && name == nil && phone == nil && pictureName == nil {
		log.Printf("No changes requested")
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tidak ada perubahan yang dilakukan"})
		return
	}
	
	log.Printf("Updating profile for user ID: %v, username: %v, name: %v, phone: %v, picture: %v", 
		userID, valueOrNil(username), valueOrNil(name), valueOrNil(phone), valueOrNil(pictureName))
	
	if err := services.UpdateUserProfile(db, userID.(uint), username, name, phone, pictureName); err != nil {
		log.Printf("Error updating profile: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	
	response := gin.H{"message": "Profil berhasil diperbarui"}
	
	if pictureName != nil {
		pictureURL := utils.GetS3ObjectURL(*pictureName)
		response["picture"] = pictureURL
		log.Printf("Profile updated successfully with new picture URL: %s", pictureURL)
	} else {
		log.Printf("Profile updated successfully (no picture change)")
	}
	
	c.JSON(http.StatusOK, response)
}


// DeleteProfilePicture godoc
// @Summary Delete user profile picture
// @Description Remove user's profile picture and set to default
// @Tags profile
// @Security ApiKeyAuth
// @Produce json
// @Success 200 {object} map[string]string "message: Foto profil berhasil dihapus, picture: nopp.png"
// @Failure 401 {object} map[string]string "error: User tidak ditemukan"
// @Failure 500 {object} map[string]string "error: Gagal menghapus foto profil"
// @Router /api/profile/delete-picture [delete]
func DeleteProfilePicture(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)

	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User tidak ditemukan"})
		return
	}

	log.Printf("Deleting profile picture for user ID: %v", userID)

	if err := services.DeleteProfilePicture(db, userID.(uint)); err != nil {
		log.Printf("Error deleting profile picture: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	var defaultPictureURL string
	if utils.IsS3Configured() {
		defaultPictureURL = utils.GetS3ObjectURL("nopp.png")
		if defaultPictureURL == "" {
			defaultPictureURL = "https://api.tascaid.com/storage/upload/default.png"
		}
	} else {
		defaultPictureURL = "https://api.tascaid.com/storage/upload/default.png"
	}

	log.Printf("Profile picture deleted, default picture URL: %s", defaultPictureURL)

	c.JSON(http.StatusOK, gin.H{
		"message": "Foto profil berhasil dihapus", 
		"picture": defaultPictureURL,
	})
}

func valueOrNil(s *string) string {
	if s == nil {
		return "nil"
	}
	return *s
}
