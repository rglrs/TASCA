import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PomodoroService {
  Future<bool> completePomodoroSession(int duration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        return false;
      }

      final timestamp = DateTime.now();

      print('Sending Pomodoro Session - Duration: $duration, Timestamp: $timestamp');

      final response = await http.post(
        Uri.parse('https://api.tascaid.com/api/pomodoro/complete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'duration': duration,
          'timestamp': timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getWeeklyStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        print('No authentication token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/pomodoro/stats/weekly'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final dailyFocusTimes =
            (data['daily_focus_times'] as List?)
                ?.map((e) => (e is int ? e.toDouble() : (e ?? 0.0)))
                .toList() ??
            List.filled(7, 0.0);

        return {...data, 'daily_focus_times': dailyFocusTimes};
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
