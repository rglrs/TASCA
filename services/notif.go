package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"tasca/models"
	"tasca/repositories"

	"gorm.io/gorm"
)

type OneSignalNotification struct {
	AppID            string                 `json:"app_id"`
	IncludePlayerIDs []string               `json:"include_player_ids"`
	Headings         map[string]string      `json:"headings"`
	Contents         map[string]string      `json:"contents"`
	Data             map[string]interface{} `json:"data,omitempty"`
	AndroidChannelID string `json:"android_channel_id,omitempty"`
	Priority         int    `json:"priority,omitempty"`
	TTL              int    `json:"ttl,omitempty"`
	ContentAvailable bool   `json:"content_available,omitempty"`
}

func SendTaskDeadlineNotification(db *gorm.DB, task *models.Task, userID uint) error {
    devices, err := repositories.GetUserDeviceTokens(db, userID)
    if err != nil {
        return err
    }

    if len(devices) == 0 {
        return nil // Tidak ada device yang terdaftar
    }

    // Dapatkan todo - perhatikan parameter userID ditambahkan
    todo, err := repositories.GetTodoByID(db, userID, task.TodoID)
    if err != nil {
        return err
    }

    // Buat array player IDs
    playerIDs := make([]string, len(devices))
    for i, device := range devices {
        playerIDs[i] = device.Token
    }

    notification := OneSignalNotification{
        AppID:            os.Getenv("ONESIGNAL_APP_ID"),
        IncludePlayerIDs: playerIDs,
        Headings: map[string]string{
            "en": "Deadline Mendekat",
            "id": "Deadline Mendekat",
        },
        Contents: map[string]string{
            "en": fmt.Sprintf("Task '%s' di Todo '%s' akan berakhir besok! Ayo jangan lupa dikerjakan ya:)", task.Title, todo.Title),
            "id": fmt.Sprintf("Task '%s' di Todo '%s' akan berakhir besok! Ayo jangan lupa dikerjakan ya:)", task.Title, todo.Title),
        },
        Data: map[string]interface{}{
            "task_id": task.ID,
            "todo_id": task.TodoID,
        },
        Priority:         10,
        TTL:              86400, // 24 jam
        ContentAvailable: true,
    }

    // Kirim notifikasi melalui OneSignal API
    return sendOneSignalNotification(notification)
}

func sendOneSignalNotification(notification OneSignalNotification) error {
    url := "https://onesignal.com/api/v1/notifications"
    jsonData, err := json.Marshal(notification)
    if err != nil {
        return err
    }

    // Log request for debugging
    log.Printf("OneSignal request payload: %s", string(jsonData))

    req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
    if err != nil {
        return err
    }

    // Ambil API key dari variabel lingkungan
    apiKey := os.Getenv("ONESIGNAL_REST_API_KEY")

    // Set header dengan format yang benar untuk API OneSignal V2
    req.Header.Set("Content-Type", "application/json; charset=utf-8")
    req.Header.Set("Authorization", "Bearer " + apiKey)
    
    client := &http.Client{}
    resp, err := client.Do(req)
    if err != nil {
        return err
    }
    defer resp.Body.Close()

    // Baca response body
    respBody, _ := ioutil.ReadAll(resp.Body)

    if resp.StatusCode >= 400 {
        log.Printf("OneSignal error response: %d - %s", resp.StatusCode, string(respBody))
        return fmt.Errorf("one signal response error: %d - %s", resp.StatusCode, string(respBody))
    }

    log.Printf("OneSignal success response: %s", string(respBody))
    return nil
}

func SendTodayTaskDeadlineNotification(db *gorm.DB, task *models.Task, userID uint) error {
    devices, err := repositories.GetUserDeviceTokens(db, userID)
    if err != nil {
        return err
    }

    if len(devices) == 0 {
        return nil // Tidak ada device yang terdaftar
    }

    // Dapatkan todo - perhatikan parameter userID ditambahkan
    todo, err := repositories.GetTodoByID(db, userID, task.TodoID)
    if err != nil {
        return err
    }

    // Buat array player IDs
    playerIDs := make([]string, len(devices))
    for i, device := range devices {
        playerIDs[i] = device.Token
    }

    notification := OneSignalNotification{
        AppID:            os.Getenv("ONESIGNAL_APP_ID"),
        IncludePlayerIDs: playerIDs,
        Headings: map[string]string{
            "en": "Deadline Hari Ini!",
            "id": "Deadline Hari Ini!",
        },
        Contents: map[string]string{
            "en": fmt.Sprintf("Kamu lupa ya dengan Task '%s' di Todo '%s'? Deadline hari ini lhoo. Ayo selesaikan sekarang", task.Title, todo.Title),
            "id": fmt.Sprintf("Kamu lupa ya dengan Task '%s' di Todo '%s'? Deadline hari ini lhoo. Ayo selesaikan sekarang", task.Title, todo.Title),
        },
        Data: map[string]interface{}{
            "task_id": task.ID,
            "todo_id": task.TodoID,
        },
        Priority:         10,
        TTL:              43200, // 12 jam
        ContentAvailable: true,
    }

    // Kirim notifikasi melalui OneSignal API
    return sendOneSignalNotification(notification)
}