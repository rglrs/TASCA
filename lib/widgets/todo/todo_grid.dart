import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoGrid extends StatelessWidget {
  final List<Map<String, dynamic>> todos;
  final bool isInSelectionMode;
  final Set<int> selectedTodoIds;
  final Function(Map<String, dynamic>) onTodoTap;
  final Function(Map<String, dynamic>) onTodoLongPress;
  final Function(int) onTodoMenuPressed;

  const TodoGrid({
    Key? key,
    required this.todos,
    required this.isInSelectionMode,
    required this.selectedTodoIds,
    required this.onTodoTap,
    required this.onTodoLongPress,
    required this.onTodoMenuPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          Color cardColor = _getCardColor(todo['color']);
          final todoId = todo['id'];
          final isSelected = selectedTodoIds.contains(todoId);

          return GestureDetector(
            onTap: () => onTodoTap(todo),
            onLongPress: () => onTodoLongPress(todo),
            child: Card(
              color: cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Text(
                          todo['title'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${todo['taskCount']} ${todo['taskCount'] == 1 ? 'task' : 'tasks'}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Ikon titik tiga telah dihapus dari sini
                  if (isInSelectionMode)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            if (isSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                    size: 16,
                                  ),
                                ),
                              )
                            else
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCardColor(String colorCode) {
    switch (colorCode) {
      case "#FC0101":
        return const Color(0xFFFC0101); // Merah - High Priority
      case "#FFC107":
        return const Color(0xFFFFC107); // Kuning - Medium Priority
      case "#28A745":
        return const Color(0xFF28A745);
      default:
        return const Color(0xFF808080); // Abu-abu - No Priority
    }
  }
}
