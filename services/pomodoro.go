package services

import (
	"time"

	"gorm.io/gorm"
	
	"tasca/repositories"
)

func CompleteSession(db *gorm.DB, userID uint, duration int) error {
	return repositories.SaveSession(db, userID, duration)
}

func GetDailyStats(db *gorm.DB, userID uint, date time.Time) (int, error) {
	return repositories.GetDailyStats(db, userID, date)
}

func GetWeeklySummary(db *gorm.DB, userID uint) (map[string]interface{}, error) {
	weeklyPomodoroStats, err := repositories.GetWeeklyStats(db, userID)
	if err != nil {
		return nil, err
	}

	return weeklyPomodoroStats, nil
}