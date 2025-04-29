import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService { 
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
