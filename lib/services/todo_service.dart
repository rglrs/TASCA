import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TodoService {
  static const String _baseUrl = 'https://api.tascaid.com/api';

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
          return {
            'id': todo['id'],
            'title': todo['title'] ?? 'Unnamed Todo',
            'taskCount': todo['task_count'] ?? 0,
            'color': _getColorForTodo(todo['id']),
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

  // Create a new todo
  static Future<bool> createTodo(Map<String, dynamic> todoData) async {
    try {
      final headers = await _getHeaders();
      
      final response = await http.post(
        Uri.parse('$_baseUrl/todos/'),
        headers: headers,
        body: json.encode({
          'title': todoData['title'],
          'urgency': todoData['urgency'],
          'importance': todoData['importance'],
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

  static String _getColorForTodo(int todoId) {
    final colors = ["#FC0101", "#007BFF", "#FFC107"];
    return colors[todoId % colors.length];
  }
}