package services

import (
	"errors"

	"gorm.io/gorm"
	"tasca/models"
	"tasca/repositories"
)

func GetTodos(db *gorm.DB, userID uint) ([]models.Todo, error) {
	todos, err := repositories.GetTodos(db, userID)
	if err != nil {
		return nil, err
	}
	return todos, nil
}

func GetTodoByID(db *gorm.DB, userID uint, id uint) (*models.Todo, error) {
	return repositories.GetTodoByID(db, userID, id)
}

func CreateTodo(db *gorm.DB, userID uint, todo *models.Todo) error {
	if todo.Title == "" {
		return errors.New("judul tidak boleh kosong")
	}
	todo.UserID = userID

	result := db.Create(todo)
	if result.Error != nil {
		return result.Error
	}

	return nil
}

func UpdateTodo(db *gorm.DB, todoID uint, updateData map[string]interface{}) error {
	delete(updateData, "is_complete")
	return repositories.UpdateTodo(db, todoID, updateData)
}

func DeleteTodo(db *gorm.DB, userID uint, id uint) error {
	var todo models.Todo
	if err := db.First(&todo, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return errors.New("todo tidak ditemukan")
		}
		return err
	}

	if todo.UserID != userID {
		return errors.New("unauthorized: hanya user yang bisa menghapus todo")
	}

	return repositories.DeleteTodo(db, id, userID)
}

func IsTodoOwner(db *gorm.DB, todoID uint, userID uint) bool {
	var todo models.Todo
	err := db.Where("id = ? AND user_id = ?", todoID, userID).First(&todo).Error
	return err == nil
}
