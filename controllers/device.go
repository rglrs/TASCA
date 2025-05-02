package controllers

import (
	"net/http"
	"tasca/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func RegisterDevice(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	var input struct {
		Token    string `json:"token" binding:"required"`
		Platform string `json:"platform" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	if err := services.RegisterDeviceToken(db, userID, input.Token, input.Platform); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mendaftarkan device"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Device berhasil didaftarkan"})
}

func UnregisterDevice(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	var input struct {
		Token string `json:"token" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	if err := services.UnregisterDeviceToken(db, userID, input.Token); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal menghapus device"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Device berhasil dihapus"})
}