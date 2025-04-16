package models

import "time"

type Task struct {
	ID          uint      `gorm:"primaryKey" json:"id"`
	Title       string    `gorm:"not null" json:"title"`
	TodoID      uint      `json:"todo_id"`
	Todo        *Todo     `gorm:"foreignKey:TodoID" json:"todo,omitempty"`
	Description string    `json:"description"`
	Priority    int       `json:"priority"` // 0=rendah, 1=sedang, 2=tinggi,3=paling tinggi
	IsComplete  bool      `gorm:"default:false" json:"is_complete"`
	Deadline    time.Time `json:"deadline"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}