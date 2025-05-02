package services

import (
    "log"
    "tasca/repositories"
    "time"

    "gorm.io/gorm"
)

func StartNotificationScheduler(db *gorm.DB) {
    checkTaskDeadlines(db)    
    ticker := time.NewTicker(6 * time.Hour)
    go func() {
        for {
            <-ticker.C
            checkTaskDeadlines(db)
        }
    }()
    
    log.Println("Task deadline notification scheduler started")
}

func checkTaskDeadlines(db *gorm.DB) {
    log.Println("Running scheduled task deadline check...")

    now := time.Now()

    today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
    tomorrow := today.AddDate(0, 0, 1)

    startOfToday := today
    endOfToday := time.Date(today.Year(), today.Month(), today.Day(), 23, 59, 59, 999999999, today.Location())
    startOfTomorrow := tomorrow
    endOfTomorrow := time.Date(tomorrow.Year(), tomorrow.Month(), tomorrow.Day(), 23, 59, 59, 999999999, tomorrow.Location())

    log.Printf("Checking for tasks with deadline today and tomorrow")

    // For tomorrow's tasks - no changes needed
    checkAndNotifyTasks(db, startOfTomorrow, endOfTomorrow, false, "tomorrow")

    // For today's tasks - use the current time for filtering
    checkAndNotifyTodayTasks(db, startOfToday, endOfToday, now)
}

// New function specifically for today's tasks that considers current time
func checkAndNotifyTodayTasks(db *gorm.DB, startDate, endDate time.Time, now time.Time) {
    var tasks []struct {
        TaskID     uint      `gorm:"column:task_id"`
        TaskTitle  string    `gorm:"column:task_title"`
        TodoID     uint      `gorm:"column:todo_id"`
        UserID     uint      `gorm:"column:user_id"`
        Deadline   time.Time `gorm:"column:deadline"`
    }

    // Find tasks with deadline in the specified date range
    err := db.Table("tasks").
        Select("tasks.id as task_id, tasks.title as task_title, tasks.todo_id, todos.user_id, tasks.deadline").
        Joins("JOIN todos ON tasks.todo_id = todos.id").
        Where("DATE(tasks.deadline) = DATE(?) AND tasks.is_complete = ?", startDate, false).
        Find(&tasks).Error

    if err != nil {
        log.Printf("Error checking task deadlines for today: %v", err)
        return
    }

    log.Printf("Found %d incomplete tasks with deadline today", len(tasks))

    for _, task := range tasks {
        // Skip notification if the deadline time has already passed
        if task.Deadline.Before(now) {
            log.Printf("Skipping notification for task ID %d: '%s' as deadline (%s) has already passed (current time: %s)", 
                      task.TaskID, task.TaskTitle, task.Deadline.Format("15:04"), now.Format("15:04"))
            continue
        }

        taskObj, err := repositories.GetTaskByID(db, task.TaskID)
        if err != nil {
            log.Printf("Error getting task %d: %v", task.TaskID, err)
            continue
        }

        err = SendTodayTaskDeadlineNotification(db, taskObj, task.UserID)
        if err != nil {
            log.Printf("Error sending notification for task %d: %v", task.TaskID, err)
        } else {
            log.Printf("Sent today deadline notification for task: %s to user: %d", task.TaskTitle, task.UserID)
        }
    }
}

// Keep the original function for tomorrow's tasks
func checkAndNotifyTasks(db *gorm.DB, startDate, endDate time.Time, isToday bool, dateType string) {
    // This function will only be used for tomorrow's tasks now
    // Since isToday will always be false here, we could simplify it
    var tasks []struct {
        TaskID    uint   `gorm:"column:task_id"`
        TaskTitle string `gorm:"column:task_title"`
        TodoID    uint   `gorm:"column:todo_id"`
        UserID    uint   `gorm:"column:user_id"`
    }

    // Find tasks with deadline in the specified date range
    err := db.Table("tasks").
        Select("tasks.id as task_id, tasks.title as task_title, tasks.todo_id, todos.user_id").
        Joins("JOIN todos ON tasks.todo_id = todos.id").
        Where("DATE(tasks.deadline) = DATE(?) AND tasks.is_complete = ?", startDate, false).
        Find(&tasks).Error

    if err != nil {
        log.Printf("Error checking task deadlines for %s: %v", dateType, err)
        return
    }

    log.Printf("Found %d incomplete tasks with deadline %s", len(tasks), dateType)

    for _, task := range tasks {
        taskObj, err := repositories.GetTaskByID(db, task.TaskID)
        if err != nil {
            log.Printf("Error getting task %d: %v", task.TaskID, err)
            continue
        }

        err = SendTaskDeadlineNotification(db, taskObj, task.UserID)

        if err != nil {
            log.Printf("Error sending notification for task %d: %v", task.TaskID, err)
        } else {
            log.Printf("Sent %s deadline notification for task: %s to user: %d", dateType, task.TaskTitle, task.UserID)
        }
    }
}