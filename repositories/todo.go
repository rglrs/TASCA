package repositories

import (
	"errors"
	"tasca/models"
	"gorm.io/gorm"
)

func GetTodos(db *gorm.DB, userID uint) ([]models.Todo, error) {
	var todos []models.Todo
	err := db.Preload("User").Preload("Tasks").Where("user_id = ?", userID).Find(&todos).Error
	if err != nil {
		return nil, err
	}

	for i := range todos {
		todos[i].CalculateProgress()
	}

	return todos, nil
}

func GetTodoByID(db *gorm.DB, userID uint, id uint) (*models.Todo, error) {
    var todo models.Todo
    result := db.Preload("User").Where("id = ? AND user_id = ?", id, userID).First(&todo)
    if errors.Is(result.Error, gorm.ErrRecordNotFound) {
        return nil, errors.New("todo tidak ditemukan")
    }
    return &todo, result.Error
}

func CreateTodo(db *gorm.DB, todo *models.Todo) error {
	return db.Create(todo).Error
}

func GetTodoWithTasks(db *gorm.DB, todoID uint) (*models.Todo, error) {
	var todo models.Todo
	if err := db.Preload("Tasks").First(&todo, todoID).Error; err != nil {
		return nil, err
	}
	return &todo, nil
}

func UpdateTodo(db *gorm.DB, todoID uint, updateData map[string]interface{}) error {
	return db.Model(&models.Todo{}).Where("id = ?", todoID).Updates(updateData).Error
}

func DeleteTodo(db *gorm.DB, todoID uint, userID uint) error {
    return db.Transaction(func(tx *gorm.DB) error {
        if err := tx.Where("todo_id = ?", todoID).Delete(&models.Task{}).Error; err != nil {
            return err
        }

        result := tx.Where("id = ? AND user_id = ?", todoID, userID).Delete(&models.Todo{})
        if result.Error != nil {
            return result.Error
        }
        if result.RowsAffected == 0 {
            return gorm.ErrRecordNotFound
        }

        return nil
    })
}