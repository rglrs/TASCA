import 'package:flutter/material.dart';

/// Class untuk mengelola state halaman todo
class TodoStateManager {
  // State variables
  List<Map<String, dynamic>> todos = [];
  List<Map<String, dynamic>> allTasks = []; 
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = true;
  bool isSearching = false;
  String? errorMessage;
  bool isInSelectionMode = false;
  Set<int> selectedTodoIds = {};
  final TextEditingController searchController = TextEditingController();

  // State tracking
  bool mounted = true;
  bool isCurrent = false;

  // Callback functions
  Function? fetchCallback;
  Function? setStateCallback;

  // Initialize with callbacks (optional now)
  void init({
    Function? fetchCallback, 
    Function? setStateCallback
  }) {
    this.fetchCallback = fetchCallback;
    this.setStateCallback = setStateCallback;
  }

  // Search tasks functionality
  void searchTasks(String query, Function setState) {
    if (!mounted) return;

    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() {
      isSearching = true;

      // Local search implementation
      searchResults = allTasks
          .where(
            (task) =>
                task['title'].toString().toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                (task['description'] != null &&
                    task['description'].toString().toLowerCase().contains(
                      query.toLowerCase(),
                    )),
          )
          .toList();
    });
  }

  // Helper method to convert hex color code to Color
  Color getCardColor(String colorCode) {
    switch (colorCode) {
      case "#FC0101":
        return const Color(0xFFFC0101);
      case "#007BFF":
        return const Color(0xFF007BFF);
      case "#FFC107":
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF808080);
    }
  }
}