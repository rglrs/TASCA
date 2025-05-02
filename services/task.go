package services

import (
	"errors"
	"time"
	"tasca/models"
	"tasca/repositories"

	"gorm.io/gorm"
)

func GetTasksByTodoID(db *gorm.DB, todoID uint) ([]models.Task, error) {
	tasks, err := repositories.GetTasksByTodoID(db, todoID)
	if err != nil {
		return nil, err
	}
	return tasks, nil
}

func GetIncompleteTasks(db *gorm.DB, userID uint) ([]map[string]interface{}, error) {
	return repositories.GetIncompleteTasks(db, userID)
}

func GetCompleteTasks(db *gorm.DB, userID uint) ([]map[string]interface{}, error) {
	return repositories.GetCompleteTasks(db, userID)
}

func GetTaskByID(db *gorm.DB, id uint) (*models.Task, error) {
	return repositories.GetTaskByID(db, id)
}

func GetTasksByDate(db *gorm.DB, dateStr string, userID uint) ([]models.Task, error) {
	date, err := time.Parse("2006-01-02", dateStr)
	if err != nil {
		return nil, errors.New("format tanggal tidak valid, gunakan YYYY-MM-DD")
	}
	
	tasks, err := repositories.GetTasksByDate(db, date, userID)
	if err != nil {
		return nil, err
	}
	
	return tasks, nil
}

func CreateTask(db *gorm.DB, task *models.Task) error {
	if task.Title == "" {
		return errors.New("judul tidak boleh kosong")
	}

	if task.Priority < 0 || task.Priority > 3 {
		return errors.New("prioritas harus bernilai antara 0 dan 3")
	}

	return repositories.CreateTask(db, task)
}

func UpdateTask(db *gorm.DB, taskID uint, updateData map[string]interface{}) error {
	return repositories.UpdateTask(db, taskID, updateData)
}

func TaskConplete(db *gorm.DB, taskID uint, isComplete bool) error {
	var task models.Task
	if err := db.First(&task, taskID).Error; err != nil {
		return err
	}

	if task.IsComplete == isComplete {
		return nil
	}

	if err := repositories.TaskComplete(db, taskID, isComplete); err != nil {
		return err
	}

	todo, err := repositories.GetTodoWithTasks(db, task.TodoID)
	if err != nil {
		return err
	}
	todo.CalculateProgress()

	updateTodoData := map[string]interface{}{
		"is_complete": todo.IsComplete,
	}

	return repositories.UpdateTodo(db, todo.ID, updateTodoData)
}

func SearchTasks(db *gorm.DB, query string, userID uint) ([]map[string]interface{}, error) {
    if query == "" {
        return nil, nil
    }
    return repositories.SearchTasks(db, query, userID)
}

func DeleteTask(db *gorm.DB, id uint) error {
	return repositories.DeleteTask(db, id)
}