import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import '../widgets/done/stat_card.dart';
import '../widgets/done/chart_card.dart';
import '../widgets/done/task_done_bar_chart.dart';
import '../widgets/done/focus_line_chart.dart';

class DonePage extends StatelessWidget {
  const DonePage({super.key});

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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StatCard(title: 'Task Done', value: '2'),
                        StatCard(title: 'Focused', value: '20m'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ChartCard(
                      title: 'Task Done',
                      dateRange: '02/03 - 08/03',
                      child: TaskDoneBarChart(
                        taskDoneData: List.filled(7, 11),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ChartCard(
                      title: 'Focused',
                      child: FocusLineChart(),
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
