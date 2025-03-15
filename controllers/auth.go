package controllers

import (
	"net/http"
	"tasca/models"
	"tasca/services"

	"github.com/gin-gonic/gin"
	"github.com/markbates/goth/gothic"
	"gorm.io/gorm"
)

type Register struct {
	Username        string  `json:"username" binding:"required"`
	Name            string  `json:"name,omitempty"`
	Email           string  `json:"email" binding:"required"`
	Phone           *string `json:"phone,omitempty"`
	Password        string  `json:"password" binding:"required"`
	ConfirmPassword string  `json:"confirm_password" binding:"required"`
}

// RegisterUser godoc
// @Summary Register user
// @Description Register a new user with username, email, and password
// @Tags auth
// @Accept json
// @Produce json
// @Param user body models.User true "User Data"
// @Success 201 {object} map[string]string "message: Registrasi berhasil"
// @Failure 400 {object} map[string]string "error: Invalid input"
// @Router /api/register [post]
func RegisterUser(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)

	var req Register
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	if req.Password != req.ConfirmPassword {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Password dan konfirmasi password tidak cocok"})
		return
	}

	user := models.User{
		Username: req.Username,
		Name:     req.Name,
		Email:    req.Email,
		Phone:    req.Phone,
		Password: req.Password,
		Provider: "local",
	}

	defaultPic := "storage/upload/profile_picture/default.jpg"
	user.Picture = &defaultPic

	if err := services.RegisterUser(db, &user); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "Registrasi berhasil",
		"user": gin.H{
			"id":       user.ID,
			"username": user.Username,
			"name":     user.Name,
			"email":    user.Email,
			"phone":    user.Phone,
			"picture":  user.Picture,
		},
	})
}

// LoginUser godoc
// @Summary Login user
// @Description Authenticate user and return a token
// @Tags auth
// @Accept json
// @Produce json
// @Param login body map[string]string true "Login Credentials"
// @Success 200 {object} map[string]string "token: JWT Token"
// @Failure 400 {object} map[string]string "error: Input tidak valid"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Router /api/login [post]
func LoginUser(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)

	var input struct {
		Email    string `json:"email"`
		Username string `json:"username"`
		Password string `json:"password" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	if input.Email == "" && input.Username == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Email atau Username harus diisi"})
		return
	}

	loginIdentifier := input.Email
	if loginIdentifier == "" {
		loginIdentifier = input.Username
	}

	token, err := services.LoginUser(db, loginIdentifier, input.Password)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}

// GoogleLogin godoc
// @Summary Google Login
// @Description Redirect user to Google authentication page
// @Tags auth
// @Router /api/google/login [get]
func GoogleLogin(c *gin.Context) {
	gothic.BeginAuthHandler(c.Writer, c.Request)
}

// GoogleCallback godoc
// @Summary Google Authentication Callback
// @Description Handle callback from Google OAuth
// @Tags auth
// @Success 200 {object} map[string]string "message: Login berhasil"
// @Failure 500 {object} map[string]string "error: Failed to authenticate"
// @Router /api/google/callback [get]
func GoogleCallback(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)

	gothUser, err := gothic.CompleteUserAuth(c.Writer, c.Request)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to authenticate"})
		return
	}

	token, err := services.AuthenticateGoogleUser(db, gothUser)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.SetCookie("auth_token", token, 3600, "/", "", false, true)

	c.JSON(http.StatusOK, gin.H{"message": "Login berhasil", "token": token})
}