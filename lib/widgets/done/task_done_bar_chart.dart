import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TaskDoneBarChart extends StatelessWidget {
  final List<int> taskDoneData;

  const TaskDoneBarChart({super.key, required this.taskDoneData});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: false),
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
                    'Sun',
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
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
          barGroups: List.generate(taskDoneData.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: taskDoneData[index].toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade300,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
