package services

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os/exec"
	"tasca/models"
)

// Fungsi untuk menjalankan AI Sorting
func runAISorting(inputData map[string]interface{}) ([]byte, error) {
	jsonData, err := json.Marshal(inputData)
	if err != nil {
		return nil, err
	}

	cmd := exec.Command("python3", "./AI/sorting.py") // Pastikan path benar
	cmd.Stdin = bytes.NewReader(jsonData)

	var out bytes.Buffer
	var stderr bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &stderr

	err = cmd.Run()
	if err != nil {
		return nil, fmt.Errorf("AI sorting failed: %v, stderr: %s", err, stderr.String())
	}

	return out.Bytes(), nil
}

// Sorting Todos menggunakan AI
func SortTodosWithAI(todos []models.Todo) ([]models.Todo, error) {
	output, err := runAISorting(map[string]interface{}{"todos": todos})
	if err != nil {
		return nil, err
	}

	var sortedTodos []models.Todo
	err = json.Unmarshal(output, &sortedTodos)
	if err != nil {
		return nil, err
	}

	return sortedTodos, nil
}

// Sorting Tasks menggunakan AI
func SortTasksWithAI(tasks []models.Task) ([]models.Task, error) {
	output, err := runAISorting(map[string]interface{}{"tasks": tasks})
	if err != nil {
		return nil, err
	}

	var sortedTasks []models.Task
	err = json.Unmarshal(output, &sortedTasks)
	if err != nil {
		return nil, err
	}

	return sortedTasks, nil
}