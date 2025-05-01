import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskUtils {
  // Convert color string to Color object
  static Color getColorFromString(String colorString) {
    switch (colorString) {
      case "#FC0101":
        return const Color(0xFFFC0101); // Red
      case "#007BFF":
        return const Color(0xFF007BFF); // Blue
      case "#FFC107":
        return const Color(0xFFFFC107); // Yellow
      default:
        return const Color(0xFF808080); // Default gray
    }
  }

  // Format deadline for display
  static String formatDeadline(String? deadlineStr) {
    if (deadlineStr == null) return '';

    try {
      // Parse as UTC and convert to local
      DateTime deadline = DateTime.parse(deadlineStr).toLocal();
      DateTime now = DateTime.now();

      // Today
      if (deadline.year == now.year &&
          deadline.month == now.month &&
          deadline.day == now.day) {
        return 'Today, ${DateFormat('HH:mm').format(deadline)}';
      }

      // Tomorrow
      if (deadline.year == now.year &&
          deadline.month == now.month &&
          deadline.day == now.day + 1) {
        return 'Tomorrow, ${DateFormat('HH:mm').format(deadline)}';
      }

      // Past
      if (deadline.isBefore(now)) {
        final difference = now.difference(deadline);

        if (difference.inDays < 1) {
          // Less than 24 hours
          return 'Yesterday, ${DateFormat('HH:mm').format(deadline)}';
        } else if (difference.inDays < 7) {
          // Within a week
          return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago, ${DateFormat('HH:mm').format(deadline)}';
        } else {
          // More than a week
          return DateFormat('d MMM yyyy, HH:mm').format(deadline);
        }
      }
      // Future
      else {
        // Within this week or this year
        if (deadline.year == now.year) {
          return DateFormat('d MMM, HH:mm').format(deadline);
        } else {
          // Different year
          return DateFormat('d MMM yyyy, HH:mm').format(deadline);
        }
      }
    } catch (e) {
      return deadlineStr; // Return original string if parsing fails
    }
  }

  // Get color for priority level
  static Color getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.blue.shade300; // Low
      case 1:
        return Colors.green.shade400; // Medium
      case 2:
        return Colors.orange.shade400; // High
      case 3:
        return Colors.red.shade400; // Highest
      default:
        return Colors.blue.shade300;
    }
  }

  // Get priority text
  static String getPriorityShortText(int priority) {
    switch (priority) {
      case 0:
        return 'Rendah';
      case 1:
        return 'Sedang';
      case 2:
        return 'Tinggi';
      case 3:
        return 'Paling Tinggi';
      default:
        return 'L';
    }
  }

  // Get color for deadline
  static Color getDeadlineColor(String? deadlineStr) {
    if (deadlineStr == null) return Colors.grey.shade300;

    try {
      DateTime deadline = DateTime.parse(deadlineStr).toLocal();
      DateTime now = DateTime.now();

      // Today
      if (deadline.year == now.year &&
          deadline.month == now.month &&
          deadline.day == now.day) {
        return Colors.green; // Green for today
      }

      // Tomorrow
      if (deadline.year == now.year &&
          deadline.month == now.month &&
          deadline.day == now.day + 1) {
        return Colors.blue; // Blue for tomorrow
      }

      // Past
      if (deadline.isBefore(now)) {
        return Colors.red; // Red for missed deadline
      }

      // Future
      return Colors.pink.shade300;
    } catch (e) {
      return Colors.grey.shade300;
    }
  }

  // Background color for delete action in swipe
  static Color getDeleteBackgroundColor() {
    return Colors.red;
  }
}