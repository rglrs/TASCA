package models

import "time"

type Todo struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	Title      string    `gorm:"not null" json:"title"`
	UserID     uint      `json:"user_id"`
	User       User      `gorm:"foreignKey:UserID" json:"user"`
	Tasks      []Task    `gorm:"foreignKey:TodoID;constraint:OnDelete:CASCADE" json:"tasks"`
	Priority   int       `json:"priority"` // 0=rendah, 1=sedang, 2=tinggi,3=paling tinggi
	IsComplete bool      `gorm:"default:false" json:"is_complete"`
	Progress   int       `gorm:"-" json:"progress"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

func (t *Todo) CalculateProgress() {
	totalTasks := len(t.Tasks)
	if totalTasks == 0 {
		t.Progress = -1
		t.IsComplete = false
		return
	}

	completedTasks := 0
	for _, task := range t.Tasks {
		if task.IsComplete {
			completedTasks++
		}
	}

	t.Progress = (completedTasks * 100) / totalTasks
	t.IsComplete = completedTasks == totalTasks
}