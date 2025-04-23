package repositories

import (
	"errors"
	"tasca/models"
	"gorm.io/gorm"
)

func GetIncompleteTasks(db *gorm.DB, userID uint) ([]map[string]interface{}, error) {
	var results []map[string]interface{}
	
	err := db.Table("tasks").
		Select("tasks.id, tasks.title").
		Joins("JOIN todos ON tasks.todo_id = todos.id").
		Where("tasks.is_complete = ? AND todos.user_id = ?", false, userID).
		Find(&results).Error
	
	return results, err
}

func GetCompleteTasks(db *gorm.DB, userID uint) ([]map[string]interface{}, error) {
	var results []map[string]interface{}
	
	err := db.Table("tasks").
		Select("tasks.id, tasks.title").
		Joins("JOIN todos ON tasks.todo_id = todos.id").
		Where("tasks.is_complete = ? AND todos.user_id = ?", true, userID).
		Find(&results).Error
	
	return results, err
}

func GetTasksByTodoID(db *gorm.DB, todoID uint) ([]models.Task, error) {
	var tasks []models.Task
	err := db.Where("todo_id = ?", todoID).Find(&tasks).Error
	return tasks, err
}

func GetTaskByID(db *gorm.DB, id uint) (*models.Task, error) {
	var task models.Task
	err := db.First(&task, id).Error
	if err != nil {
		return nil, err
	}
	return &task, nil
}

func CreateTask(db *gorm.DB, task *models.Task) error {
	return db.Create(task).Error
}

func UpdateTask(db *gorm.DB, taskID uint, updateData map[string]interface{}) error {
	delete(updateData, "is_complete")
	return db.Model(&models.Task{}).Where("id = ?", taskID).Updates(updateData).Error
}

func TaskComplete(db *gorm.DB, taskID uint, isComplete bool) error {
	return db.Model(&models.Task{}).Where("id = ?", taskID).Update("is_complete", isComplete).Error
}

func DeleteTask(db *gorm.DB, id uint) error {
	result := db.Delete(&models.Task{}, id)
	if result.RowsAffected == 0 {
		return errors.New("task tidak ditemukan")
	}
	return result.Error
}