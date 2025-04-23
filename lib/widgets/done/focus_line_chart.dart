import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:tasca_mobile1/services/pomodoro.dart';

class FocusLineChart extends StatefulWidget {
  final PomodoroService pomodoroService;

  const FocusLineChart({super.key, required this.pomodoroService});

  @override
  _FocusLineChartState createState() => _FocusLineChartState();
}

class _FocusLineChartState extends State<FocusLineChart> {
  List<double> _focusDurations = List.filled(7, 0.0);
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWeeklyStats();
  }

  Future<void> _fetchWeeklyStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final weeklyStats = await widget.pomodoroService.getWeeklyStats();

      print('Weekly Stats Received: $weeklyStats'); // Tambahkan log

      if (weeklyStats != null && weeklyStats['daily_focus_times'] != null) {
        setState(() {
          _focusDurations = List<double>.from(weeklyStats['daily_focus_times']);
          print('Focus Durations Set: $_focusDurations'); // Tambahkan log
          _isLoading = false;
        });
      } else {
        setState(() {
          _focusDurations = List.filled(7, 0.0);
          _errorMessage = 'Failed to fetch weekly stats';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _focusDurations = List.filled(7, 0.0);
        _errorMessage = 'Error fetching weekly stats: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate max Y value dynamically
    final double maxYValue =
        _focusDurations.isEmpty
            ? 24.0
            : max(24.0, (_focusDurations.reduce(max) * 1.2).ceilToDouble());

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
              onPressed: _fetchWeeklyStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: maxYValue,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            final showLinesAt = [
              maxYValue * 0.25,
              maxYValue * 0.5,
              maxYValue * 0.75,
            ];
            if (showLinesAt.contains(value)) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              );
            }
            return FlLine(strokeWidth: 0);
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      days[value.toInt()],
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: maxYValue / 4,
              getTitlesWidget: (value, meta) {
                if (value >= 0 && value <= maxYValue) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            left: BorderSide(color: Colors.black, width: 1),
            bottom: BorderSide(color: Colors.transparent, width: 0),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: false,
            spots: List.generate(
              7,
              (index) => FlSpot(index.toDouble(), _focusDurations[index]),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.black.withOpacity(0.1),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3,
                  color: Colors.black,
                  strokeWidth: 0,
                );
              },
            ),
            color: Colors.black,
            isStrokeCapRound: true,
            barWidth: 2,
          ),
        ],
      ),
    );
  }
}

// Example usage in a screen
class WeeklyFocusScreen extends StatelessWidget {
  final PomodoroService pomodoroService;

  const WeeklyFocusScreen({super.key, required this.pomodoroService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Focus')),
      body: Center(child: FocusLineChart(pomodoroService: pomodoroService)),
    );
  }
}
