import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Todo {
  final int id;
  final String name;

  Todo({required this.id, required this.name});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(id: json['id'], name: json['name'] ?? '');
  }
}

class Task {
  final int id;
  final String title;
  final int? todoId;
  final Todo? todo;
  final String description;
  final int priority;
  final bool isComplete;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.todoId,
    this.todo,
    required this.description,
    required this.priority,
    required this.isComplete,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final DateTime utcDeadline = DateTime.parse(json['deadline']);

    final DateTime localDeadline = utcDeadline.toLocal();

    return Task(
      id: json['id'],
      title: json['title'],
      todoId: json['todo_id'],
      description: json['description'] ?? '',
      priority: json['priority'] ?? 0,
      isComplete: json['is_complete'] ?? false,
      deadline: localDeadline,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      updatedAt: DateTime.parse(json['updated_at']).toLocal(),
    );
  }
}

class CalendarService {
  static const String _baseUrl = 'https://api.tascaid.com';
  static final Map<String, List<Task>> _taskCache = {};

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  List<Task>? getCachedTasks(DateTime date) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return _taskCache[formattedDate];
  }

  Future<List<Task>> fetchTasksByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    // Check if tasks are already in cache
    if (_taskCache.containsKey(formattedDate)) {
      return _taskCache[formattedDate]!;
    }

    final url = Uri.parse('$_baseUrl/api/tasks/$formattedDate');
    final token = await _getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> tasksJson = jsonResponse['tasks'];
        final tasks = tasksJson.map((json) => Task.fromJson(json)).toList();

        // Cache the tasks
        _taskCache[formattedDate] = tasks;
        return tasks;
      } else if (response.statusCode == 400) {
        throw Exception('Invalid date format or parameter: ${response.body}');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or missing token');
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tasks: $e');
    }
  }

  Future<Map<DateTime, List<Task>>> fetchTasksForMonth(DateTime month) async {
    Map<DateTime, List<Task>> tasksByDate = {};
    final days = _getDaysInMonth(month);

    for (var day in days) {
      try {
        final tasksForDay = await fetchTasksByDate(day);
        if (tasksForDay.isNotEmpty) {
          tasksByDate[day] = tasksForDay;
        }
      } catch (e) {
        // Silently handle errors for individual days
        debugPrint(
          'Error fetching tasks for ${DateFormat('yyyy-MM-dd').format(day)}: $e',
        );
      }
    }

    return tasksByDate;
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final firstDayWeekday = firstDayOfMonth.weekday % 7;

    final previousMonth = DateTime(month.year, month.month - 1, 1);
    final daysInPreviousMonth = DateUtils.getDaysInMonth(
      previousMonth.year,
      previousMonth.month,
    );

    List<DateTime> days = [];

    // Add days from previous month
    for (int i = 0; i < firstDayWeekday; i++) {
      days.add(
        DateTime(
          previousMonth.year,
          previousMonth.month,
          daysInPreviousMonth - firstDayWeekday + i + 1,
        ),
      );
    }

    // Add days of current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    // Add days from next month
    final remainingDays = 42 - days.length;
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(nextMonth.year, nextMonth.month, i));
    }

    return days;
  }

  // Method baru untuk menghapus semua cache
  void clearCache() {
    _taskCache.clear();
    debugPrint('CalendarService: Semua cache task telah dihapus');
  }
}

class DateUtils {
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
