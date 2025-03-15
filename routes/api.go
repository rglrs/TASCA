package routes

import (
	"tasca/controllers"

	"github.com/gin-gonic/gin"
	"github.com/swaggo/files"
	"github.com/swaggo/gin-swagger"
	"gorm.io/gorm"
)

func SetupRouter(db *gorm.DB) *gin.Engine {
	r := gin.Default()

	r.GET("/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	r.Use(func(c *gin.Context) {
		if db == nil {
			c.AbortWithStatusJSON(500, gin.H{"error": "Database connection error"})
			return
		}
		c.Set("db", db)
		c.Next()
	})

	api := r.Group("/api")
	{
		// Auth
		api.POST("/register", controllers.RegisterUser)
		api.POST("/login", controllers.LoginUser)
		api.GET("/google/login", controllers.GoogleLogin)
		api.GET("/google/callback", controllers.GoogleCallback)
	}
	return r
}
