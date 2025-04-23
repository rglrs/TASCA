package controllers

import (
	"net/http"
	"time"
	"log"
	"fmt"

	"tasca/services"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// CompletePomodoro godoc
// @Summary Complete pomodoro session
// @Description Record a completed pomodoro session
// @Tags pomodoro
// @Security ApiKeyAuth
// @Accept json
// @Produce json
// @Param session body object true "Session details"
// @Success 200 {object} map[string]string "message: Session completed"
// @Failure 400 {object} map[string]string "error: Invalid request"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 500 {object} map[string]string "error: Failed to save session"
// @Router /api/pomodoro/complete [post]
func CompletePomodoroSession(c *gin.Context) {
    db := c.MustGet("db").(*gorm.DB)
    userID := c.MustGet("user_id").(uint)

    var req struct {
        Duration  int    `json:"duration" binding:"required,min=1"`
        Timestamp string `json:"timestamp" binding:"required"`
    }

    if err := c.ShouldBindJSON(&req); err != nil {
        c.JSON(http.StatusBadRequest, gin.H{
            "error": "Invalid request",
            "details": err.Error(),
        })
        return
    }

    // Parse timestamp
    timestamp, err := time.Parse(time.RFC3339, req.Timestamp)
    if err != nil {
        // Coba parsing alternatif jika gagal
        timestamp, err = time.Parse("2006-01-02T15:04:05.999999", req.Timestamp)
        if err != nil {
            log.Printf("Failed to parse timestamp: %s, Error: %v", req.Timestamp, err)
            c.JSON(http.StatusBadRequest, gin.H{
                "error": "Invalid timestamp format",
                "details": fmt.Sprintf("Cannot parse timestamp: %s", req.Timestamp),
            })
            return
        }
    }

    // Konversi ke UTC
    timestamp = timestamp.UTC()

    query := `
        INSERT INTO pomodoros (user_id, date, duration, created_at)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (user_id, DATE(date)) 
        DO UPDATE SET 
            duration = pomodoros.duration + $5
    `

    result := db.Exec(query, 
        userID, 
        timestamp, 
        req.Duration, 
        timestamp, 
        req.Duration,
    )

    if result.Error != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to save pomodoro session",
            "details": result.Error.Error(),
        })
        return
    }

    // Tambahkan query untuk mendapatkan total durasi setelah update
    var totalDuration int
    err = db.Raw(`
        SELECT duration 
        FROM pomodoros 
        WHERE user_id = $1 AND DATE(date) = DATE($2)
    `, userID, timestamp).Scan(&totalDuration).Error

    if err != nil {
        log.Printf("Error fetching total duration: %v", err)
    }

    log.Printf("Total Pomodoro Duration for User %d on %s: %d minutes", 
        userID, timestamp.Format("2006-01-02"), totalDuration)

    c.JSON(http.StatusOK, gin.H{
        "message": "Pomodoro session completed",
        "total_duration": totalDuration,
    })
}

// GetDailyStats godoc
// @Summary Get daily pomodoro stats
// @Description Get daily pomodoro statistics for a user
// @Tags pomodoro
// @Security ApiKeyAuth
// @Produce json
// @Param date query string false "Date (YYYY-MM-DD)"
// @Success 200 {object} map[string]interface{} "date: Date, total_minutes: Total focus minutes"
// @Failure 400 {object} map[string]string "error: Invalid date format"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 500 {object} map[string]string "error: Failed to fetch data"
// @Router /api/pomodoro/stats [get]
func GetDailyStats(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	dateParam := c.Query("date")
	var date time.Time
	var err error

	if dateParam == "" {
		date = time.Now()
	} else {
		date, err = time.Parse("2006-01-02", dateParam)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid date format"})
			return
		}
	}

	totalDuration, err := services.GetDailyStats(db, userID, date)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"date":          date.Format("2006-01-02"),
		"total_minutes": totalDuration,
	})
}

// GetWeeklyStats godoc
// @Summary Get weekly pomodoro stats
// @Description Get weekly pomodoro and task statistics for a user
// @Tags pomodoro
// @Security ApiKeyAuth
// @Produce json
// @Success 200 {object} map[string]interface{} "task_done: Number of completed tasks, focused: Total focus time"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 500 {object} map[string]string "error: Failed to fetch weekly summary"
// @Router /api/pomodoro/stats/weekly [get]
func GetWeeklyStats(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	summary, err := services.GetWeeklySummary(db, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch weekly summary"})
		return
	}

	c.JSON(http.StatusOK, summary)
}