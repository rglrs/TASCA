import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String? dateRange;
  final Widget child;

  const ChartCard({super.key, required this.title, this.dateRange, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (dateRange != null)
                Text(dateRange!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 150, child: child),
        ],
      ),
    );
  }
}
