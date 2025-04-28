import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tasca_mobile1/services/task_service.dart'; 

class TaskDoneBarChart extends StatefulWidget {
  final TaskService taskService;

  const TaskDoneBarChart({super.key, required this.taskService});

  @override
  _TaskDoneBarChartState createState() => _TaskDoneBarChartState();
}

class _TaskDoneBarChartState extends State<TaskDoneBarChart> {
  List<int> _taskDoneData = List.filled(7, 0);
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyTaskStats();
  }

  Future<void> _fetchWeeklyTaskStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final taskStats = await widget.taskService.getWeeklyCompletedTaskCount();

      setState(() {
        _taskDoneData = taskStats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _taskDoneData = List.filled(7, 0);
        _errorMessage = 'Error fetching weekly task stats';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _fetchWeeklyTaskStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          // Replace the existing barTouchData with this enhanced version
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()}', // Convert to int to remove decimal
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 2,
            getDrawingHorizontalLine:
                (value) => FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  if (value % 2 == 0 && value > 0 && value <= 10) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              bottom: BorderSide(color: Colors.black),
              left: BorderSide(color: Colors.black),
            ),
          ),
          maxY: 12,
          barGroups: List.generate(_taskDoneData.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _taskDoneData[index].toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(8),
                  color:
                      _taskDoneData[index] > 0
                          ? Colors.blue.shade300
                          : Colors.grey.shade300,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// Contoh penggunaan di layar
class WeeklyTaskProgressScreen extends StatelessWidget {
  final TaskService taskService;

  const WeeklyTaskProgressScreen({super.key, required this.taskService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Task Progress')),
      body: Center(child: TaskDoneBarChart(taskService: taskService)),
    );
  }
}
