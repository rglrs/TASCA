import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class TaskService {
  static const String baseUrl = 'https://api.tascaid.com/api';

  // Helper method to get authentication token
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('No JWT token found');
    }

    return token;
  }

  // Sort tasks by priority and deadline
  List<dynamic> sortTasks(List<dynamic> tasks) {
    // Separate complete and incomplete tasks
    final incompleteTasks =
        tasks.where((task) => !task['is_complete']).toList();
    final completeTasks = tasks.where((task) => task['is_complete']).toList();

    // Sort incomplete tasks by priority first, then by deadline
    incompleteTasks.sort((a, b) {
      // First compare by priority (higher priority comes first)
      final priorityA = a['priority'] ?? 0;
      final priorityB = b['priority'] ?? 0;

      // Reverse comparison for priority (3 comes before 0)
      final priorityComparison = priorityB.compareTo(priorityA);

      // If priorities are different, return that comparison
      if (priorityComparison != 0) {
        return priorityComparison;
      }

      // If priorities are the same, sort by deadline
      final deadlineA =
          a['deadline'] != null
              ? DateTime.parse(a['deadline'].toString()).toLocal()
              : DateTime.now().add(Duration(days: 365));

      final deadlineB =
          b['deadline'] != null
              ? DateTime.parse(b['deadline'].toString()).toLocal()
              : DateTime.now().add(Duration(days: 365));

      return deadlineA.compareTo(deadlineB);
    });

    return [...incompleteTasks, ...completeTasks];
  }

  // Fetch tasks for a specific todo
  Future<List<dynamic>> fetchTodoTasks(int todoId) async {
    try {
      final token = await _getToken();

      debugPrint('Fetching tasks for todo ID: $todoId');

      final response = await http.get(
        Uri.parse('$baseUrl/todos/$todoId/tasks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Tasks API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        debugPrint('Tasks API response: $responseBody');

        // Get tasks and sort them
        final fetchedTasks = responseBody['data'] ?? [];
        final sortedTasks = sortTasks(fetchedTasks);

        return sortedTasks;
      } else {
        throw Exception('Failed to load tasks: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      throw e;
    }
  }

  // Update todo title
  Future<void> updateTodoTitle(int todoId, String newTitle) async {
    if (newTitle.isEmpty) {
      throw Exception('Title cannot be empty');
    }

    // Create a client instance that will be closed later
    final client = http.Client();

    try {
      final token = await _getToken();

      // URL for todo update
      final url = '$baseUrl/todos/$todoId/';
      final requestBody = {'title': newTitle};

      debugPrint('Update Todo - URL: $url');
      debugPrint('Update Todo - Body: ${json.encode(requestBody)}');

      // Create PATCH request
      final request = http.Request('PATCH', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode(requestBody);

      // Send request and get response stream
      final streamedResponse = await client.send(request);

      http.Response response;

      // If we get a redirect, follow it manually maintaining PATCH method
      if (streamedResponse.statusCode == 307) {
        final redirectUrl = streamedResponse.headers['location'];
        if (redirectUrl != null) {
          debugPrint('Redirecting PATCH to: $redirectUrl');

          // Handle absolute and relative URLs
          Uri redirectUri;
          if (redirectUrl.startsWith('http')) {
            // Absolute URL
            redirectUri = Uri.parse(redirectUrl);
          } else {
            // Relative URL - need to combine with base URL
            final baseUri = Uri.parse(url);
            final baseUrl = '${baseUri.scheme}://${baseUri.host}';

            // Remove leading slash if present on both
            final cleanRedirectUrl =
                redirectUrl.startsWith('/')
                    ? redirectUrl.substring(1)
                    : redirectUrl;
            redirectUri = Uri.parse('$baseUrl/$cleanRedirectUrl');
          }

          debugPrint('Full redirect URL: $redirectUri');

          final redirectRequest = http.Request('PATCH', redirectUri);
          redirectRequest.headers['Authorization'] = 'Bearer $token';
          redirectRequest.headers['Content-Type'] = 'application/json';
          redirectRequest.body = json.encode(requestBody);

          final redirectResponse = await client.send(redirectRequest);
          response = await http.Response.fromStream(redirectResponse);
        } else {
          // If no location header, use original response
          response = await http.Response.fromStream(streamedResponse);
        }
      } else {
        // If no redirect, get response
        response = await http.Response.fromStream(streamedResponse);
      }

      debugPrint('Update Todo Response Status: ${response.statusCode}');
      debugPrint('Update Todo Response Body: ${response.body}');

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String errorMessage;
        try {
          if (response.body.isNotEmpty) {
            final responseData = json.decode(response.body);
            errorMessage = responseData['error'] ?? 'Unknown error occurred';
          } else {
            errorMessage = 'Server returned status ${response.statusCode}';
          }
        } catch (e) {
          errorMessage = 'Error: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } finally {
      // Always close the client when done
      client.close();
    }
  }

  // Delete todo
  Future<void> deleteTodo(int todoId) async {
    try {
      final token = await _getToken();

      // Debug print for URL
      final url = '$baseUrl/todos/$todoId/';
      debugPrint('Attempting to delete todo with URL: $url');

      // Create client instance
      final client = http.Client();

      try {
        // Create DELETE request
        final request = http.Request('DELETE', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] = 'application/json';

        // Send request and get response stream
        final streamedResponse = await client.send(request);

        // Get full response
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint('Delete Todo Response Status: ${response.statusCode}');
        debugPrint('Delete Todo Response Body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return; // Success
        } else {
          // Try alternative approach if first method fails
          // Try URL without trailing slash
          final alternativeUrl = '$baseUrl/todos/$todoId';
          debugPrint('Trying alternative URL: $alternativeUrl');

          final alternativeResponse = await http.delete(
            Uri.parse(alternativeUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          debugPrint(
            'Alternative Delete Response Status: ${alternativeResponse.statusCode}',
          );

          if (alternativeResponse.statusCode < 200 ||
              alternativeResponse.statusCode >= 300) {
            throw Exception(
              'Failed to delete todo: Status ${response.statusCode}, ${response.body}',
            );
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('Error deleting todo: $e');
      throw e;
    }
  }

  // Toggle task completion status
  Future<void> toggleTaskCompletion(
    int todoId,
    int taskId,
    bool currentStatus,
  ) async {
    try {
      final token = await _getToken();

      final response = await http.patch(
        Uri.parse('$baseUrl/todos/$todoId/tasks/$taskId/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'is_complete': !currentStatus}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update task: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
      throw e;
    }
  }

  // Delete task
  Future<void> deleteTask(int todoId, int taskId) async {
    try {
      final token = await _getToken();

      // Debug print for URL
      final url = '$baseUrl/todos/$todoId/tasks/$taskId/';
      debugPrint('Attempting to delete task with URL: $url');

      // Create client instance
      final client = http.Client();

      try {
        // Create DELETE request
        final request = http.Request('DELETE', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] = 'application/json';

        // Send request and get response stream
        final streamedResponse = await client.send(request);

        // Get full response
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint('Delete Task Response Status: ${response.statusCode}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return; // Success
        } else {
          // Try alternative approach if first method fails
          // Try URL without trailing slash
          final alternativeUrl = '$baseUrl/todos/$todoId/tasks/$taskId';
          debugPrint(
            'Trying alternative URL for task deletion: $alternativeUrl',
          );

          final alternativeResponse = await http.delete(
            Uri.parse(alternativeUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          debugPrint(
            'Alternative Delete Response Status: ${alternativeResponse.statusCode}',
          );

          if (alternativeResponse.statusCode < 200 ||
              alternativeResponse.statusCode >= 300) {
            throw Exception(
              'Failed to delete task: Status ${response.statusCode}',
            );
          }
        }
      } finally {
        // Always close client when done
        client.close();
      }
    } catch (e) {
      debugPrint('Error deleting task: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getCompletedTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('No authentication token found');
        return Future.error('Unauthorized access');
      }

      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/tasks/complete'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        return responseData['data'] ?? [];
      } else if (response.statusCode == 401) {
        return Future.error('Unauthorized access');
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching completed tasks: $e');
      return [];
    }
  }

  Future<List<int>> getWeeklyCompletedTaskCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('No authentication token found');
        return Future.error('Unauthorized access');
      }

      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/tasks/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        List<int> dailyTasks =
            (responseData['daily_tasks'] as List?)
                ?.map((e) => int.tryParse(e.toString()) ?? 0)
                .toList() ??
            [];

        while (dailyTasks.length < 7) {
          dailyTasks.insert(0, 0);
        }

        if (dailyTasks.length > 7) {
          dailyTasks = dailyTasks.sublist(dailyTasks.length - 7);
        }

        return dailyTasks;
      } else if (response.statusCode == 401) {
        return Future.error('Unauthorized access');
      } else {
        return [0, 0, 0, 0, 0, 0, 0];
      }
    } catch (e) {
      return [0, 0, 0, 0, 0, 0, 0];
    }
  }
}
