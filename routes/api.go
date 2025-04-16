package routes

import (
	"tasca/controllers"
	"tasca/middleware"

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
		api.POST("/forgot-password", controllers.ForgotPassword)
		api.POST("/reset-password", controllers.ResetPassword)
		api.POST("/validate-token", controllers.ValidateToken)

		auth := api.Group("/")
		auth.Use(middleware.AuthMiddleware())
		{
			auth.POST("/logout", controllers.LogoutUser)

			profile := auth.Group("/profile")
			{
				profile.GET("/", controllers.GetUserProfile)
				profile.POST("/link-google", controllers.LinkGoogleAccount)
				profile.PATCH("/unlink-google", controllers.UnlinkGoogleAccount)
				profile.PATCH("/change-password", controllers.ChangePassword)
				profile.PATCH("/update", controllers.UpdateProfile)
				profile.DELETE("/delete-picture", controllers.DeleteProfilePicture)
				profile.DELETE("/", controllers.DeleteAccount)
			}

			// Todo
			todo := auth.Group("/todos")
			{
				todo.GET("/", controllers.GetTodos)
				todo.GET("/:id", controllers.GetTodoByID)
				todo.POST("/", controllers.CreateTodo)
				todo.PATCH("/:id", controllers.UpdateTodo)
				todo.DELETE("/:id", controllers.DeleteTodo)

				// Task
				task := todo.Group("/:id/tasks")
				{
					task.GET("/", controllers.GetTasksByTodoID)
					task.GET("/incomplete", controllers.GetIncompleteTasks)
					task.GET("/:task_id", controllers.GetTaskByID)
					task.PATCH("/:task_id/complete", controllers.TaskComplete)
					task.POST("/", controllers.CreateTask)
					task.PATCH("/:task_id", controllers.UpdateTask)
					task.DELETE("/:task_id", controllers.DeleteTask)
				}
			}
		}
	}
	return r
}
