import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasca_mobile1/widgets/navbar.dart';
import 'package:tasca_mobile1/widgets/done/stat_card.dart';
import 'package:tasca_mobile1/widgets/done/chart_card.dart';
import 'package:tasca_mobile1/widgets/done/task_done_bar_chart.dart';
import 'package:tasca_mobile1/widgets/done/focus_line_chart.dart';
import 'package:tasca_mobile1/services/task_service.dart';
import 'package:tasca_mobile1/services/pomodoro.dart';
import 'login_page.dart';

class DonePage extends StatefulWidget {
  const DonePage({super.key});

  @override
  _DonePageState createState() => _DonePageState();
}

class _DonePageState extends State<DonePage> {
  final TaskService _taskService = TaskService();
  final PomodoroService _pomodoroService = PomodoroService();

  int _totalTaskDone = 0;
  int _totalFocusedMinutes = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      // Fetch weekly task stats
      final weeklyTaskStats = await _taskService.getWeeklyCompletedTaskCount();

      // Fetch weekly pomodoro stats
      final weeklyPomodoroStats = await _pomodoroService.getWeeklyStats();

      setState(() {
        _totalTaskDone = weeklyTaskStats.reduce((a, b) => a + b);

        if (weeklyPomodoroStats != null &&
            weeklyPomodoroStats['daily_focus_times'] != null) {
          final focusDurations = List<double>.from(
            weeklyPomodoroStats['daily_focus_times'],
          );
          _totalFocusedMinutes = focusDurations.reduce((a, b) => a + b).toInt();
        }
      });
    } catch (e) {
      if (e == 'Unauthorized access') {
        _redirectToLogin();
      } else {
        print('Error fetching stats: $e');
      }
    }
  }

  void _redirectToLogin() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('auth_token');
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  // Mendapatkan rentang tanggal seminggu
  String _getWeekDateRange() {
    DateTime now = DateTime.now();
    // Cari hari Senin terakhir
    DateTime monday = now.subtract(Duration(days: now.weekday - 1));
    // Cari hari Minggu terakhir
    DateTime sunday = monday.add(const Duration(days: 6));

    return '${DateFormat('dd/MM').format(monday)} - ${DateFormat('dd/MM').format(sunday)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F1FE),
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Done',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatCard(title: 'Task Done', value: '$_totalTaskDone'),
                        StatCard(
                          title: 'Focused',
                          value: '${_totalFocusedMinutes}m',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ChartCard(
                      title: 'Task Done',
                      dateRange: _getWeekDateRange(),
                      child: TaskDoneBarChart(taskService: _taskService),
                    ),
                    const SizedBox(height: 16),
                    ChartCard(
                      title: 'Focused',
                      dateRange: _getWeekDateRange(),
                      child: FocusLineChart(pomodoroService: _pomodoroService),
                    ),
                  ],
                ),
              ),
            ),
            const Navbar(initialActiveIndex: 3),
          ],
        ),
      ),
    );
  }
}
