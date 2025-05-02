package main

import (
	"log"
	"os"
	_ "tasca/docs"
	"time"

	"tasca/config"
	"tasca/services"
	"tasca/routes"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

// @title Tag Tasca API
// @version 1.0
// @description API untuk aplikasi Tasca A4 AGILE menggunakan gin
// @host api.tascaid.com
// @BasePath /api
func main() {
	// get .env file
	if err := godotenv.Load(".env"); err != nil {
		log.Fatal("Error loading .env file")
	}

	// init database
	db, err := config.InitDB()
	if err != nil {
		log.Fatal(err)
	}

	// s3
	if err := config.InitS3(); err != nil {
		log.Printf("Warning: Failed to initialize S3 client: %v", err)
		log.Println("Continuing without S3 functionality. Profile pictures will use local storage fallback.")
	}

	// init router
	router := routes.SetupRouter(db)

	if os.Getenv("ONESIGNAL_APP_ID") != "" && os.Getenv("ONESIGNAL_REST_API_KEY") != "" {
		// Mulai scheduler untuk notifikasi deadline
		log.Println("Starting notification scheduler for task deadlines...")
		services.StartNotificationScheduler(db)
	} else {
		log.Println("WARNING: OneSignal credentials not found in environment. Notification features will be disabled.")
	}

	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"https://tascaid.site", "http://localhost:3000", "http://localhost:5173", "http://localhost:5174", "http://localhost:8000"},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
		MaxAge:           12 * time.Hour,
	}))

	router.Use(func(c *gin.Context) {
		c.Writer.Header().Set("Access-Control-Allow-Origin", "https://tascaid.site")
		c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
		c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
		c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE")

		if c.Request.Method == "OPTIONS" {
			c.AbortWithStatus(204)
			return
		}

		c.Next()
	})

	router.OPTIONS("/api/validate-token", func(c *gin.Context) {
		c.Header("Access-Control-Allow-Origin", "https://tascaid.site")
		c.Header("Access-Control-Allow-Methods", "POST, OPTIONS")
		c.Header("Access-Control-Allow-Headers", "Content-Type, Authorization")
		c.Header("Access-Control-Allow-Credentials", "true")
		c.Status(200)
	})

	router.Run(":" + os.Getenv("PORT"))
}
