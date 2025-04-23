import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  // Normalisasi data harian untuk memastikan 7 elemen
  List<int> _normalizeDailyTasks(dynamic dailyTasks) {
    if (dailyTasks == null) return [0, 0, 0, 0, 0, 0, 0];

    // Pastikan dailyTasks adalah list
    List<dynamic> taskList = dailyTasks is List ? dailyTasks : [dailyTasks];

    // Pastikan memiliki 7 elemen
    while (taskList.length < 7) {
      taskList.add(0);
    }

    // Konversi ke list integer
    return taskList
        .take(7)
        .map((e) => int.tryParse(e.toString()) ?? 0)
        .toList();
  }

  // Ambil daftar tugas yang diselesaikan
  Future<List<dynamic>> getCompletedTasks() async {
    try {
      // Ambil token dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('No authentication token found');
        return [];
      }

      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/tasks/complete'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Parse respons JSON
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Kembalikan daftar tugas yang diselesaikan
        return responseData['data'] ?? [];
      } else {
        print('Failed to fetch completed tasks: ${response.body}');
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
        return [0, 0, 0, 0, 0, 0, 0];
      }

      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/tasks/stats'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Normalisasi data task harian dengan perbaikan urutan hari
        List<int> dailyTasks =
            (responseData['daily_tasks'] as List?)
                ?.map((e) => int.tryParse(e.toString()) ?? 0)
                .toList() ??
            [];

        // Pastikan selalu 7 elemen dengan memperhatikan urutan hari
        while (dailyTasks.length < 7) {
          dailyTasks.insert(0, 0);
        }

        if (dailyTasks.length > 7) {
          dailyTasks = dailyTasks.sublist(dailyTasks.length - 7);
        }

        return dailyTasks;
      } else {
        print('Failed to fetch weekly completed tasks: ${response.body}');
        return [0, 0, 0, 0, 0, 0, 0];
      }
    } catch (e) {
      print('Error fetching weekly completed tasks: $e');
      return [0, 0, 0, 0, 0, 0, 0];
    }
  }
}
