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

      if (weeklyStats != null && weeklyStats['daily_focus_times'] != null) {
        setState(() {
          _focusDurations = List<double>.from(weeklyStats['daily_focus_times']);
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
            ? 40.0
            : max(40.0, (_focusDurations.reduce(max) * 1.2).ceilToDouble());

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

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: maxYValue,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  // Format value as integer without decimal places
                  return LineTooltipItem(
                    '${barSpot.y.toInt()}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: 8,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
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
                      padding: const EdgeInsets.only(top: 8),
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
                interval: 8,
                getTitlesWidget: (value, meta) {
                  if (value % 8 == 0 && value >= 0 && value <= 40) {
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
              bottom: BorderSide(color: Colors.black, width: 1),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              // Use dotted line style
              dashArray: [5, 5],
              // No curvature
              isCurved: false,
              spots: List.generate(
                7,
                (index) => FlSpot(index.toDouble(), _focusDurations[index]),
              ),
              // Remove below bar area
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.red,
                    strokeWidth: 0,
                  );
                },
              ),
              color: Colors.red,
              barWidth: 1,
            ),
          ],
        ),
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