package controllers

import (
	"net/http"
	"strconv"
	"tasca/models"
	"tasca/services"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// GetTasksByTodoID godoc
// @Summary Get tasks by todo ID
// @Description Get all tasks for a specific todo
// @Tags tasks
// @Security ApiKeyAuth
// @Produce json
// @Param id path int true "Todo ID"
// @Success 200 {object} map[string]interface{} "data: []models.Task, id: Todo ID"
// @Failure 400 {object} map[string]string "error: Todo ID tidak valid"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 403 {object} map[string]string "error: Tidak memiliki akses ke todo ini"
// @Failure 500 {object} map[string]string "error: Gagal mengambil data"
// @Router /api/todos/{id}/tasks [get]
func GetTasksByTodoID(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	todoID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Todo ID tidak valid"})
		return
	}

	isOwner := services.IsTodoOwner(db, uint(todoID), userID)
	if !isOwner {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki akses ke todo ini"})
		return
	}

	tasks, err := services.GetTasksByTodoID(db, uint(todoID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": tasks, "id": todoID})
}

// GetTaskByID godoc
// @Summary Get task by ID
// @Description Get a specific task by ID
// @Tags tasks
// @Security ApiKeyAuth
// @Produce json
// @Param id path int true "Todo ID"
// @Param task_id path int true "Task ID"
// @Success 200 {object} map[string]interface{} "data: models.Task, id: Todo ID"
// @Failure 400 {object} map[string]string "error: Task ID tidak valid"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 403 {object} map[string]string "error: Tidak memiliki akses ke task ini"
// @Failure 404 {object} map[string]string "error: Task tidak ditemukan"
// @Router /api/todos/{id}/tasks/{task_id} [get]
func GetTaskByID(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	taskID, err := strconv.Atoi(c.Param("task_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Task ID tidak valid"})
		return
	}

	task, err := services.GetTaskByID(db, uint(taskID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task tidak ditemukan"})
		return
	}

	isOwner := services.IsTodoOwner(db, task.TodoID, userID)
	if !isOwner {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki akses ke task ini"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": task, "id": task.TodoID})
}

// GetIncompleteTasks godoc
// @Summary Get incomplete tasks
// @Description Get all incomplete tasks (is_complete = false) with only ID and title
// @Tags tasks
// @Security ApiKeyAuth
// @Produce json
// @Success 200 {object} map[string]interface{} "data: []map[string]interface{}"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 500 {object} map[string]string "error: Gagal mengambil data"
// @Router /api/tasks/incomplete [get]
func GetIncompleteTasks(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	
	// Get the user ID from the JWT token context
	userID := c.MustGet("user_id").(uint)

	incompleteTasks, err := services.GetIncompleteTasks(db, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": incompleteTasks})
}

// GetCompleteTasks godoc
// @Summary Get incomplete tasks
// @Description Get all complete tasks (is_complete = true) with only ID and title
// @Tags tasks
// @Security ApiKeyAuth
// @Produce json
// @Success 200 {object} map[string]interface{} "data: []map[string]interface{}"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 500 {object} map[string]string "error: Gagal mengambil data"
// @Router /api/tasks/complete [get]
func GetCompleteTasks(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	
	userID := c.MustGet("user_id").(uint)

	CompleteTask, err := services.GetCompleteTasks(db, userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": CompleteTask})
}

// CreateTask godoc
// @Summary Create task
// @Description Create a new task for a todo
// @Tags tasks
// @Security ApiKeyAuth
// @Accept json
// @Produce json
// @Param id path int true "Todo ID"
// @Param task body models.Task true "Task data"
// @Success 201 {object} map[string]interface{} "message: Task berhasil dibuat, id: Todo ID, data: Task"
// @Failure 400 {object} map[string]string "error: Input tidak valid"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 403 {object} map[string]string "error: Tidak memiliki akses ke todo ini"
// @Router /api/todos/{id}/tasks [post]
func CreateTask(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	todoID, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Todo ID tidak valid"})
		return
	}

	isOwner := services.IsTodoOwner(db, uint(todoID), userID)
	if !isOwner {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki akses ke todo ini"})
		return
	}

	var task models.Task
	if err := c.ShouldBindJSON(&task); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Input tidak valid"})
		return
	}

	task.TodoID = uint(todoID)

	if err := services.CreateTask(db, &task); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"message": "Task berhasil dibuat", "id": todoID, "data": task})
}

// UpdateTask godoc
// @Summary Update task
// @Description Update an existing task
// @Tags tasks
// @Security ApiKeyAuth
// @Accept json
// @Produce json
// @Param id path int true "Todo ID"
// @Param task_id path int true "Task ID"
// @Param task body object true "Task update data"
// @Success 200 {object} map[string]interface{} "message: Task updated successfully, todo_id: Todo ID"
// @Failure 400 {object} map[string]string "error: Invalid task ID"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 403 {object} map[string]string "error: Tidak memiliki akses ke task ini"
// @Failure 404 {object} map[string]string "error: Task tidak ditemukan"
// @Failure 500 {object} map[string]string "error: Update failed"
// @Router /api/todos/{id}/tasks/{task_id} [patch]
func UpdateTask(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	taskID, err := strconv.ParseUint(c.Param("task_id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid task ID"})
		return
	}

	task, err := services.GetTaskByID(db, uint(taskID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task tidak ditemukan"})
		return
	}

	isOwner := services.IsTodoOwner(db, task.TodoID, userID)
	if !isOwner {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki akses ke task ini"})
		return
	}

	var updateData map[string]interface{}
	if err := c.ShouldBindJSON(&updateData); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	delete(updateData, "is_complete")

	if err := services.UpdateTask(db, uint(taskID), updateData); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Task updated successfully", "todo_id": task.TodoID})
}

// TaskComplete godoc
// @Summary Update task completion
// @Description Mark a task as complete or incomplete
// @Tags tasks
// @Security ApiKeyAuth
// @Accept json
// @Produce json
// @Param id path int true "Todo ID"
// @Param task_id path int true "Task ID"
// @Param completion body object true "Completion status"
// @Success 200 {object} map[string]interface{} "message: Task completion status updated, todo_id: Todo ID"
// @Failure 400 {object} map[string]string "error: Invalid task ID"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 403 {object} map[string]string "error: Tidak memiliki akses ke task ini"
// @Failure 404 {object} map[string]string "error: Task tidak ditemukan"
// @Failure 500 {object} map[string]string "error: Update failed"
// @Router /api/todos/{id}/tasks/{task_id}/complete [patch]
func TaskComplete(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	taskID, err := strconv.ParseUint(c.Param("task_id"), 10, 64)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid task ID"})
		return
	}

	task, err := services.GetTaskByID(db, uint(taskID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task tidak ditemukan"})
		return
	}

	isOwner := services.IsTodoOwner(db, task.TodoID, userID)
	if !isOwner {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki akses ke task ini"})
		return
	}

	var request struct {
		IsComplete bool `json:"is_complete"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := services.TaskConplete(db, uint(taskID), request.IsComplete); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Task completion status updated", "todo_id": task.TodoID})
}

// TaskComplete godoc
// @Summary Get task completion
// @Description Mark a task as complete or incomplete
// @Tags tasks
// @Security ApiKeyAuth
// @Accept json
// @Produce json
// @Param id path int true "Todo ID"
// @Param task_id path int true "Task ID"
// @Param completion body object true "Completion status"
// @Success 200 {object} map[string]interface{} "message: Task completion status updated, todo_id: Todo ID"
// @Failure 400 {object} map[string]string "error: Invalid task ID"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 403 {object} map[string]string "error: Tidak memiliki akses ke task ini"
// @Failure 404 {object} map[string]string "error: Task tidak ditemukan"
// @Failure 500 {object} map[string]string "error: Update failed"
// @Router /api/tasks/weekly-stats [patch]
func GetWeeklyTaskStats(c *gin.Context) {
    db := c.MustGet("db").(*gorm.DB)
    userID := c.MustGet("user_id").(uint)

    var totalTasks int64
    db.Model(&models.Task{}).
        Joins("JOIN todos ON tasks.todo_id = todos.id").
        Where("tasks.is_complete = ? AND todos.user_id = ?", true, userID).
        Count(&totalTasks)

    now := time.Now()
    weekStart := now.AddDate(0, 0, -int(now.Weekday()+6)%7)
    weekStart = time.Date(weekStart.Year(), weekStart.Month(), weekStart.Day(), 0, 0, 0, 0, now.Location())
    weekEnd := weekStart.AddDate(0, 0, 7)

    var dailyTasks []int
    rows, err := db.Raw(`
        WITH date_series AS (
            SELECT generate_series(
                date_trunc('day', $1::timestamp), 
                date_trunc('day', $2::timestamp), 
                '1 day'::interval
            ) AS day
        )
        SELECT 
            date_series.day,
            COALESCE(COUNT(tasks.id), 0) as task_count
        FROM 
            date_series
        LEFT JOIN tasks ON 
            date_trunc('day', tasks.created_at) = date_series.day
        JOIN todos ON tasks.todo_id = todos.id
        WHERE 
            tasks.is_complete = true 
            AND todos.user_id = $3
            AND tasks.created_at BETWEEN $1 AND $2
        GROUP BY 
            date_series.day
        ORDER BY 
            date_series.day
    `, weekStart, weekEnd, userID).Rows()

    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{
            "error": "Failed to fetch weekly task stats",
        })
        return
    }
    defer rows.Close()

    dailyTasks = make([]int, 7)

    for rows.Next() {
        var taskCount int
        var dayDate time.Time
        rows.Scan(&dayDate, &taskCount)
        
        dayIndex := int((dayDate.Weekday() + 6) % 7)
        dailyTasks[dayIndex] = taskCount
    }

    c.JSON(http.StatusOK, gin.H{
        "total_tasks": totalTasks,
        "daily_tasks": dailyTasks,
    })
}

// DeleteTask godoc
// @Summary Delete task
// @Description Delete a task
// @Tags tasks
// @Security ApiKeyAuth
// @Produce json
// @Param id path int true "Todo ID"
// @Param task_id path int true "Task ID"
// @Success 200 {object} map[string]string "message: Task berhasil dihapus"
// @Failure 400 {object} map[string]string "error: Task ID tidak valid"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 403 {object} map[string]string "error: Tidak memiliki akses ke task ini"
// @Failure 404 {object} map[string]string "error: Task tidak ditemukan"
// @Router /api/todos/{id}/tasks/{task_id} [delete]
func DeleteTask(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)

	taskID, err := strconv.Atoi(c.Param("task_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Task ID tidak valid"})
		return
	}

	task, err := services.GetTaskByID(db, uint(taskID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Task tidak ditemukan"})
		return
	}

	isOwner := services.IsTodoOwner(db, task.TodoID, userID)
	if !isOwner {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak memiliki akses ke task ini"})
		return
	}

	if err := services.DeleteTask(db, uint(taskID)); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Task berhasil dihapus"})
}