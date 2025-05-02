package controllers

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"tasca/models"
	"tasca/services"
)

// GetTodos godoc
// @Summary Get all todos
// @Description Get all todos for the authenticated user
// @Tags todos
// @Security ApiKeyAuth
// @Produce json
// @Success 200 {object} map[string]interface{} "data: []models.Todo"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 500 {object} map[string]string "error: Gagal fetch data"
// @Router /api/todos [get]
func GetTodos(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	todos, err := services.GetTodos(db, uint(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal fetch data"})
		return
	}

	todosResponse := []gin.H{}
	for _, todo := range todos {
		taskCount := len(todo.Tasks)

		todo.CalculateProgress()

		todosResponse = append(todosResponse, gin.H{
			"id":          todo.ID,
			"title":       todo.Title,
			"task_count":  taskCount,
			"progress":    todo.Progress,
			"is_complete": todo.IsComplete,
		})
	}

	c.JSON(http.StatusOK, gin.H{"data": todosResponse})
}

// GetTodoByID godoc
// @Summary Get todo by ID
// @Description Get a specific todo by ID
// @Tags todos
// @Security ApiKeyAuth
// @Produce json
// @Param id path int true "Todo ID"
// @Success 200 {object} map[string]interface{} "data: models.Todo"
// @Failure 400 {object} map[string]string "error: ID tidak valid"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 404 {object} map[string]string "error: Todo tidak ditemukan"
// @Router /api/todos/{id} [get]
func GetTodoByID(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	idParam := c.Param("id")
	if idParam == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak boleh kosong"})
		return
	}

	id, err := strconv.ParseUint(idParam, 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	todo, err := services.GetTodoByID(db, userID, uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Todo tidak ditemukan"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": todo})
}

// CreateTodo godoc
// @Summary Create todo
// @Description Create a new todo
// @Tags todos
// @Security ApiKeyAuth
// @Accept json
// @Produce json
// @Param todo body models.Todo true "Todo data"
// @Success 201 {object} map[string]string "message: Todo berhasil dibuat"
// @Failure 400 {object} map[string]string "error: Input tidak valid"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Router /api/todos [post]
func CreateTodo(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	var todo models.Todo
	if err := c.ShouldBindJSON(&todo); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	if todo.Priority < 0 || todo.Priority > 3 {
		todo.Priority = 0
	}

	if err := services.CreateTodo(db, userID, &todo); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Todo berhasil dibuat"})
}

// UpdateTodo godoc
// @Summary Update todo
// @Description Update an existing todo
// @Tags todos
// @Security ApiKeyAuth
// @Accept json
// @Produce json
// @Param id path int true "Todo ID"
// @Param todo body object true "Todo update data"
// @Success 200 {object} map[string]string "message: Todo updated successfully"
// @Failure 400 {object} map[string]string "error: Invalid todo ID"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 403 {object} map[string]string "error: Tidak memiliki akses ke todo ini"
// @Failure 500 {object} map[string]string "error: Update failed"
// @Router /api/todos/{id} [patch]
func UpdateTodo(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	todoID, err := strconv.ParseUint(c.Param("id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid todo ID"})
		return
	}

	isOwner := services.IsTodoOwner(db, uint(todoID), userID)
	if !isOwner {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki akses ke todo ini"})
		return
	}

	var updateData map[string]interface{}
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data"})
		return
	}

	delete(updateData, "is_complete")
	delete(updateData, "progress")

	err = services.UpdateTodo(db, uint(todoID), updateData)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Todo updated successfully"})
}

// DeleteTodo godoc
// @Summary Delete todo
// @Description Delete a todo
// @Tags todos
// @Security ApiKeyAuth
// @Produce json
// @Param id path int true "Todo ID"
// @Success 200 {object} map[string]string "message: Todo berhasil dihapus"
// @Failure 400 {object} map[string]string "error: ID tidak valid"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 404 {object} map[string]string "error: Todo tidak ditemukan atau bukan milik Anda"
// @Router /api/todos/{id} [delete]
func DeleteTodo(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	idParam := c.Param("id")
	if idParam == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak boleh kosong"})
		return
	}

	id, err := strconv.Atoi(idParam)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	userID := c.MustGet("user_id").(uint)

	err = services.DeleteTodo(db, userID, uint(id))
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.JSON(http.StatusNotFound, gin.H{"error": "Todo tidak ditemukan atau bukan milik Anda"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Todo berhasil dihapus"})
}
