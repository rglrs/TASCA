import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoSearchResults extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final List<Map<String, dynamic>> todos;
  final String searchText;
  final Function(Map<String, dynamic>) onTodoTap;

  const TodoSearchResults({
    Key? key,
    required this.searchResults,
    required this.searchText,
    required this.todos,
    required this.onTodoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (searchText.isEmpty) {
      return const Center(
        child: Text(
          'Type something to search tasks',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No tasks found for "$searchText"',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final task = searchResults[index];

        // Find the corresponding todo for navigation
        final Map<String, dynamic> todoData = {
          'id': task['todo_id'],
          'title': task['todo_title'] ?? 'Unknown Todo',
          'color': task['todo_color'] ?? '#007BFF',
        };

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              task['title'],
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In: ${todoData['title']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  task['is_complete'] ? 'Completed' : 'Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: task['is_complete'] ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Get the taskCount of the todo
              final todoWithCount = todos.firstWhere(
                (todo) => todo['id'] == task['todo_id'],
                orElse: () => {'taskCount': 0},
              );

              // Create full todo object with taskCount
              final fullTodo = {
                ...todoData,
                'taskCount': todoWithCount['taskCount'] ?? 0,
              };
              
              onTodoTap(fullTodo);
            },
            trailing: Icon(
              task['is_complete'] ? Icons.check_circle : Icons.circle_outlined,
              color: task['is_complete'] ? Colors.green : Colors.grey,
            ),
          ),
        );
      },
    );
  }
}