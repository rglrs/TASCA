package main

import (
	"log"
	"os"
	_ "tasca/docs"
	"github.com/joho/godotenv"
	"github.com/markbates/goth"
	"github.com/markbates/goth/providers/google"
	"tasca/config"
	"tasca/routes"
)

// @title Tag Tasca API
// @version 1.0
// @description API untuk aplikasi Tasca A4 AGILE menggunakan gin
// @host localhost:8080
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

	// init router
	router := routes.SetupRouter(db)

	// init goth providers
	goth.UseProviders(
		google.New(
			os.Getenv("GOOGLE_CLIENT_ID"),
			os.Getenv("GOOGLE_CLIENT_SECRET"),
			os.Getenv("GOOGLE_REDIRECT_URL"),
		),
	)

	router.Run(":" + os.Getenv("PORT"))
}