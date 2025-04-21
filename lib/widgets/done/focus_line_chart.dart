import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class FocusLineChart extends StatelessWidget {
  const FocusLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: 24,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          drawHorizontalLine: true,
          getDrawingHorizontalLine: (value) {
            const showLinesAt = [4.0, 8.0, 12.0, 16.0, 20.0];
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
                const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
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
              interval: 1,
              getTitlesWidget: (value, meta) {
                const labels = [4.0, 8.0, 12.0, 16.0, 20.0];
                if (labels.contains(value)) {
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
            bottom: BorderSide(
              color: Colors.transparent,
              width: 0,
            ), // Tidak ada garis bawah
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: false,
            spots: List.generate(7, (index) => FlSpot(index.toDouble(), 1)),
            belowBarData: BarAreaData(show: false),
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
