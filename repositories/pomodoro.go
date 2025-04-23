package repositories

import (
	"time"
	"log"
	
	"gorm.io/gorm"

	"tasca/models"
)

func GetTodaySession(db *gorm.DB, userID uint) (*models.Pomodoro, error) {
	var session models.Pomodoro
	today := time.Now().Format("2006-01-02")

	err := db.Where("user_id = ? AND date = ?", userID, today).First(&session).Error
	if err != nil {
		return nil, err
	}

	return &session, nil
}

func SaveSession(db *gorm.DB, userID uint, duration int) error {
	var existingSession models.Pomodoro
	today := time.Now().Format("2006-01-02")

	result := db.Where("user_id = ? AND DATE(date) = ?", userID, today).First(&existingSession)

	if result.Error != nil {
		newSession := models.Pomodoro{
			UserID:   userID,
			Date:     time.Now(),
			Duration: duration,
		}
		return db.Create(&newSession).Error
	}
	return db.Model(&existingSession).Update("duration", existingSession.Duration+duration).Error
}

func GetDailyStats(db *gorm.DB, userID uint, date time.Time) (int, error) {
	var totalDuration int
	err := db.Model(&models.Pomodoro{}).
		Where("user_id = ? AND DATE(date) = ?", userID, date.Format("2006-01-02")).
		Select("COALESCE(SUM(duration), 0)").Scan(&totalDuration).Error

	if err != nil {
		return 0, err
	}

	return totalDuration, nil
}

func GetWeeklyStats(db *gorm.DB, userID uint) (map[string]interface{}, error) {
    var dailyDurations []struct {
        Date     time.Time
        Duration int
    }

    now := time.Now()
    weekStart := now.AddDate(0, 0, -int(now.Weekday()))
    if now.Weekday() == time.Sunday {
        weekStart = weekStart.AddDate(0, 0, -7)
    }
    weekEnd := weekStart.AddDate(0, 0, 6)

    err := db.Raw(`
        WITH date_series AS (
            SELECT generate_series(
                date_trunc('day', $1::timestamp), 
                date_trunc('day', $2::timestamp), 
                '1 day'::interval
            ) AS day
        )
        SELECT 
            date_series.day AS date, 
            COALESCE(SUM(p.duration), 0) AS duration
        FROM 
            date_series
        LEFT JOIN 
            pomodoros p ON p.user_id = $3 
            AND DATE(p.date) = DATE(date_series.day)
        GROUP BY 
            date_series.day
        ORDER BY 
            date_series.day
    `, weekStart, weekEnd, userID).Scan(&dailyDurations).Error

    if err != nil {
        return nil, err
    }

    focusDurations := make([]int, 7)
    for i, entry := range dailyDurations {
        if i < 7 {
            focusDurations[i] = entry.Duration
            log.Printf("Entry: Date=%v, Duration=%d", 
                entry.Date, entry.Duration)
        }
    }

    totalFocused := 0
    for _, duration := range focusDurations {
        totalFocused += duration
    }

    return map[string]interface{}{
        "daily_focus_times": focusDurations,
        "focused":           totalFocused,
    }, nil
}