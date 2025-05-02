package controllers

import (
	"log"
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

// GetTasksByDate godoc
// @Summary Get tasks by date
// @Description Get all tasks for a specific date
// @Tags calendar
// @Security ApiKeyAuth
// @Produce json
// @Param date path string true "Date (YYYY-MM-DD)"
// @Success 200 {array} models.Task
// @Failure 400 {object} map[string]string "error: Format tanggal tidak valid"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 500 {object} map[string]string "error: Gagal mengambil data"
// @Router /api/calendar/day/{date} [get]
func GetTasksByDate(c *gin.Context) {
	db := c.MustGet("db").(*gorm.DB)
	userID := c.MustGet("user_id").(uint)
	
	dateStr := c.Param("date")
	if dateStr == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Parameter tanggal diperlukan"})
		return
	}
	
	tasks, err := services.GetTasksByDate(db, dateStr, userID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	
	c.JSON(http.StatusOK, gin.H{
		"date": dateStr,
		"tasks": tasks,
	})
}

// GetTasksBySearch godoc
// @Summary Get tasks by search
// @Description Get all tasks for a specific search
// @Tags calendar
// @Security ApiKeyAuth
// @Produce json
// @Success 200 {array} models.Task
// @Failure 400 {object} map[string]string "error: Nama tidak val"
// @Failure 401 {object} map[string]string "error: Unauthorized"
// @Failure 500 {object} map[string]string "error: Gagal mengambil data"
// @Router /api/tasks/search [get] 
func GetTasksBySearch(c *gin.Context) {
    db := c.MustGet("db").(*gorm.DB)
    userID := c.MustGet("user_id").(uint)

    query := c.Query("search")
    if query == "" {
        c.JSON(http.StatusBadRequest, gin.H{"error": "Search query is required"})
        return
    }

    tasks, err := services.SearchTasks(db, query, userID)
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve tasks"})
        return
    }

    c.JSON(http.StatusOK, gin.H{
        "data": tasks,
        "total": len(tasks),
    })
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

	// Get total tasks
	var totalTasks int64
	db.Model(&models.Task{}).
		Joins("JOIN todos ON tasks.todo_id = todos.id").
		Where("tasks.is_complete = ? AND todos.user_id = ?", true, userID).
		Count(&totalTasks)

	// Calculate week range (Monday to Sunday)
	now := time.Now()
	offset := (int(now.Weekday()) + 6) % 7
	weekStart := now.AddDate(0, 0, -offset)
	weekStart = time.Date(weekStart.Year(), weekStart.Month(), weekStart.Day(), 0, 0, 0, 0, now.Location())
	weekEnd := weekStart.AddDate(0, 0, 7)

	// Debug logging
	log.Printf("Week range: %s to %s", weekStart.Format("2006-01-02"), weekEnd.Format("2006-01-02"))

	// Initialize daily tasks array
	dailyTasks := make([]int, 7)

	// Use a query that's less likely to have issues
	query := `
        WITH dates AS (
            SELECT day::date 
            FROM generate_series(
                $1::timestamp, 
                $2::timestamp - interval '1 day', 
                interval '1 day'
            ) AS day
        )
        SELECT 
            EXTRACT(DOW FROM dates.day)::int as dow,
            COALESCE(COUNT(tasks.id), 0) as task_count
        FROM 
            dates
        LEFT JOIN tasks ON 
            DATE(tasks.updated_at) = dates.day
            AND tasks.is_complete = true
        LEFT JOIN todos ON 
            tasks.todo_id = todos.id
            AND todos.user_id = $3
        GROUP BY 
            dates.day
        ORDER BY 
            dates.day
    `

	rows, err := db.Raw(query, weekStart, weekEnd, userID).Rows()
	if err != nil {
		log.Printf("Error executing query: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "Failed to fetch weekly task stats",
		})
		return
	}
	defer rows.Close()

	// Process results
	for rows.Next() {
		var dow int
		var count int
		if err := rows.Scan(&dow, &count); err != nil {
			log.Printf("Error scanning row: %v", err)
			continue
		}

		// Map PostgreSQL DOW (0=Sunday) to our array (0=Monday)
		dayIndex := (dow + 6) % 7
		log.Printf("Day of week: %d, Index: %d, Count: %d", dow, dayIndex, count)

		if dayIndex >= 0 && dayIndex < 7 {
			dailyTasks[dayIndex] = count
		}
	}

	// Log the final array for debugging
	log.Printf("Daily tasks array: %v", dailyTasks)

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
