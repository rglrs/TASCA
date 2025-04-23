package models

import "time"

type Pomodoro struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	UserID    uint      `json:"user_id"`
	User      *User     `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
	Date      time.Time `gorm:"uniqueIndex:user_date" json:"date"`
	Duration  int       `json:"duration"`
	CreatedAt time.Time `json:"created_at"`
}