import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoService {
  static const String _baseUrl = 'https://api.tascaid.com/api';

  // Function untuk debug color - bisa dipanggil dari UI
  static String debugGetColor(int priority) {
    String color = _getColorFromPriority(priority);
    debugPrint('DEBUG: Priority $priority should be color $color');
    return color;
  }
  
  // Function untuk test semua priority colors
  static void testAllColors() {
    debugPrint('=== TESTING ALL PRIORITY COLORS ===');
    debugPrint('Priority 0: ${_getColorFromPriority(0)}'); // Should be green
    debugPrint('Priority 1: ${_getColorFromPriority(1)}'); // Should be yellow  
    debugPrint('Priority 2: ${_getColorFromPriority(2)}'); // Should be red
    debugPrint('=====================================');
  }

  // Get auth token from SharedPreferences
  static Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Check if token is valid, return null if valid, otherwise return a message
  static Future<String?> _validateToken(String? token) {
    if (token == null) {
      return Future.value('No JWT token found');
    }
    return Future.value(null);
  }

  // Get headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getAuthToken();
    final tokenError = await _validateToken(token);
    
    if (tokenError != null) {
      throw Exception(tokenError);
    }
    
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // Fetch todos
  static Future<List<Map<String, dynamic>>> fetchTodos() async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/todos/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> todosData = responseBody['data'];

        return todosData.map((todo) {
          // Explicit handling untuk priority - pastikan 0 tidak dianggap null
          int priority = 0; // Default priority
          if (todo['priority'] != null) {
            priority = todo['priority'] as int;
          }
          
          debugPrint('Todo ID: ${todo['id']}, Priority: $priority'); // Debug log
          
          String todoColor = _getColorForTodo(todo['id'], priority: priority);
          debugPrint('Final color for Todo ${todo['id']}: $todoColor'); // Debug final color
          
          return {
            'id': todo['id'],
            'title': todo['title'] ?? 'Unnamed Todo',
            'taskCount': todo['task_count'] ?? 0,
            'color': todoColor,
            'priority': priority,
          };
        }).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load todos: ${response.body}');
      }
    } on SocketException {
      throw Exception('Kesalahan Koneksi: Periksa koneksi internet Anda.');
    } catch (e) {
      throw Exception('Error fetching todos: $e');
    }
  }

  // Fetch tasks for a specific todo
  static Future<List<Map<String, dynamic>>> fetchTasksForTodo(int todoId, String todoTitle, String todoColor) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/todos/$todoId/tasks'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> tasksData = responseBody['data'] ?? [];

        return tasksData.map((task) {
          return {
            'id': task['id'],
            'title': task['title'] ?? 'Unnamed Task',
            'description': task['description'] ?? '',
            'is_complete': task['is_complete'] ?? false,
            'todo_id': todoId,
            'todo_title': todoTitle,
            'todo_color': todoColor,
          };
        }).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load tasks: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks for todo $todoId: $e');
    }
  }

  // Fetch all tasks across all todos for search functionality
  static Future<List<Map<String, dynamic>>> fetchAllTasks() async {
    List<Map<String, dynamic>> allTasks = [];
    
    try {
      final todos = await fetchTodos();
      
      for (var todo in todos) {
        try {
          final tasks = await fetchTasksForTodo(
            todo['id'], 
            todo['title'], 
            todo['color']
          );
          allTasks.addAll(tasks);
        } catch (e) {
          debugPrint('Error fetching tasks for todo ${todo['id']}: $e');
        }
      }
      
      return allTasks;
    } catch (e) {
      throw Exception('Error fetching all tasks: $e');
    }
  }

  // Create a new todo - Updated to use priority system
  static Future<bool> createTodo(Map<String, dynamic> todoData) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/todos/'),
        headers: headers,
        body: json.encode({
          'title': todoData['title'],
          'priority': todoData['priority'], // Kirim priority sebagai integer
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to create todo: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating todo: $e');
    }
  }

  static Future<bool> deleteTodo(int todoId) async {
    try {
      final headers = await _getHeaders();
      final client = http.Client();
      
      try {
        final request = http.Request(
          'DELETE',
          Uri.parse('$_baseUrl/todos/$todoId/'),
        );
        request.headers.addAll(headers);

        final streamedResponse = await client.send(request);
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return true;
        } else {
          // Try alternative endpoint without trailing slash
          final alternativeResponse = await http.delete(
            Uri.parse('$_baseUrl/todos/$todoId'),
            headers: headers,
          );

          if (alternativeResponse.statusCode >= 200 && alternativeResponse.statusCode < 300) {
            return true;
          } else {
            throw Exception('Failed to delete todo: Status ${response.statusCode}');
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      throw Exception('Error deleting todo: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteMultipleTodos(List<int> todoIds) async {
    if (todoIds.isEmpty) {
      return {'success': 0, 'failed': 0, 'failedIds': []};
    }

    try {
      final headers = await _getHeaders();
      final client = http.Client();
      int successCount = 0;
      List<int> failedIds = [];

      try {
        for (int todoId in todoIds) {
          try {
            final request = http.Request(
              'DELETE',
              Uri.parse('$_baseUrl/todos/$todoId/'),
            );
            request.headers.addAll(headers);

            final streamedResponse = await client.send(request);
            final response = await http.Response.fromStream(streamedResponse);

            if (response.statusCode >= 200 && response.statusCode < 300) {
              successCount++;
            } else {
              final alternativeResponse = await http.delete(
                Uri.parse('$_baseUrl/todos/$todoId'),
                headers: headers,
              );

              if (alternativeResponse.statusCode >= 200 && alternativeResponse.statusCode < 300) {
                successCount++;
              } else {
                failedIds.add(todoId);
              }
            }
          } catch (e) {
            failedIds.add(todoId);
          }
        }
      } finally {
        client.close();
      }

      return {
        'success': successCount,
        'failed': failedIds.length,
        'failedIds': failedIds,
      };
    } catch (e) {
      throw Exception('Error deleting todos: $e');
    }
  }

  // Updated to use priority-based color system
  static String _getColorForTodo(int todoId, {int? priority}) {
    debugPrint('_getColorForTodo called with todoId: $todoId, priority: $priority'); // Debug log
    
    // Jika priority tersedia dari API response, gunakan itu
    if (priority != null) {
      debugPrint('Using priority-based color for priority: $priority'); // Debug log
      return _getColorFromPriority(priority);
    }
    
    debugPrint('Priority is null, using fallback color system'); // Debug log
    // Fallback ke sistem lama jika priority tidak tersedia
    final colors = ["#28A745", "#FFC107", "#FC0101"]; // Hijau, Kuning, Merah (index 0, 1, 2)
    return colors[todoId % colors.length];
  }
  
  // Helper function untuk mendapatkan warna berdasarkan priority level
  static String _getColorFromPriority(int priority) {
    debugPrint('Getting color for priority: $priority'); // Debug log
    String color;
    
    // Explicit check untuk priority 0 agar pasti hijau
    if (priority == 0) {
      color = "#28A745"; // HIJAU - Low Priority (Not important + Not urgently)
      debugPrint('Priority 0 detected - FORCING GREEN: $color');
    } else if (priority == 1) {
      color = "#FFC107"; // Kuning - Medium Priority
    } else if (priority == 2) {
      color = "#FC0101"; // Merah - High Priority
    } else {
      debugPrint('Unknown priority: $priority, returning grey'); // Debug log
      color = "#808080"; // Abu-abu - Default/Unknown priority
    }
    
    debugPrint('Returning color: $color for priority: $priority'); // Debug log
    return color;
  }
}