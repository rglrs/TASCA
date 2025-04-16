package controllers

import (
	"net/http"
	"fmt"
	"time"

	"tasca/models"
	"tasca/services"
	"tasca/utils"

	"github.com/gin-gonic/gin"
	"github.com/markbates/goth/gothic"
	"gorm.io/gorm"
)

// LinkGoogleAccount godoc
// @Summary Link Google Account
// @Description Link Google account to an existing user profile
// @Tags profile
// @Security ApiKeyAuth
// @Success 200 {object} map[string]string "message: Akun Google berhasil ditautkan"
// @Failure 400 {object} map[string]string "error: Bad request"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Router /api/profile/link-google [post]
func LinkGoogleAccount(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID, _ := c.Get("user_id")

	gothUser, err := gothic.CompleteUserAuth(c.Writer, c.Request)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal autentikasi Google"})
		return
	}

	if err := services.LinkGoogle(db, userID.(uint), gothUser); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Akun berhasil terhubung ke Google"})
}

// UnlinkGoogleAccount godoc
// @Summary Unlink Google Account
// @Description Remove linked Google account from user profile
// @Tags profile
// @Security ApiKeyAuth
// @Success 200 {object} map[string]string "message: Akun Google berhasil dilepaskan"
// @Failure 400 {object} map[string]string "error: Bad request"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Router /api/profile/unlink-google [post]
func UnlinkGoogleAccount(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID, _ := c.Get("user_id")

	if err := services.UnlinkGoogle(db, userID.(uint)); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"message": "Akun berhasil terputus dari Google"})
}

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
			pictureURL = utils.GetS3ObjectURL("nopp.png")
			if pictureURL == "" {
				pictureURL = "https://tascaid-app.s3.ap-southeast-2.amazonaws.com/default.jpg"
			}
		} else {
			pictureURL = utils.GetS3ObjectURL(*user.Picture)
		}
	} else {
		pictureURL = utils.GetS3ObjectURL("nopp.png")
		if pictureURL == "" {
			pictureURL = "https://tascaid-app.s3.ap-southeast-2.amazonaws.com/nopp.png"
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

	var username, name *string
	var phone *string
	var pictureName *string

	if c.ContentType() == "multipart/form-data" {
		if err := c.Request.ParseMultipartForm(10 << 20); err != nil { 
			c.JSON(http.StatusBadRequest, gin.H{"error": "Gagal memproses form data"})
			return
		}
		
		usernameVal := c.PostForm("username")
		if usernameVal != "" {
			username = &usernameVal
		}
		
		nameVal := c.PostForm("name")
		if nameVal != "" {
			name = &nameVal
		}
		
		phoneVal := c.PostForm("phone")
		if phoneVal != "" {
			phone = &phoneVal
		} else if c.PostForm("phone") == "" && c.Request.Form.Has("phone") {
			phone = nil
		}
		
		file, err := c.FormFile("picture")
		if err == nil {
			// Generate a unique filename for S3
			timestamp := time.Now().Unix()
			filename := fmt.Sprintf("profiles/%d_%d_%s", userID, timestamp, file.Filename)
			
			// Upload file to S3
			_, err := utils.UploadFileToS3(file, filename)
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengunggah file ke storage"})
				return
			}
			
			pictureName = &filename
		}
	} else {
		var input struct {
			Username *string `json:"username"`
			Name     *string `json:"name"`
			Phone    *string `json:"phone"`
		}
		
		if err := c.ShouldBindJSON(&input); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
			return
		}
		
		username = input.Username
		name = input.Name
		phone = input.Phone
	}
	
	if username == nil && name == nil && phone == nil && pictureName == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Tidak ada perubahan yang dilakukan"})
		return
	}
	
	if err := services.UpdateUserProfile(db, userID.(uint), username, name, phone, pictureName); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	
	response := gin.H{"message": "Profil berhasil diperbarui"}
	
	if pictureName != nil {
		pictureURL := utils.GetS3ObjectURL(*pictureName)
		response["picture"] = pictureURL
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

	if err := services.DeleteProfilePicture(db, userID.(uint)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	defaultPictureURL := utils.GetS3ObjectURL("nopp.png")
	if defaultPictureURL == "" {
		defaultPictureURL = "https://tascaid-app.s3.ap-southeast-2.amazonaws.com/default.jpg"
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "Foto profil berhasil dihapus", 
		"picture": defaultPictureURL,
	})
}