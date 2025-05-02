import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoHeader extends StatelessWidget {
  final bool isInSelectionMode;
  final int selectedCount;
  final VoidCallback onToggleSelectionMode;
  final VoidCallback onAddTodo;

  const TodoHeader({
    Key? key,
    required this.isInSelectionMode,
    required this.selectedCount,
    required this.onToggleSelectionMode,
    required this.onAddTodo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'To Do',
            style: GoogleFonts.poppins(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              if (isInSelectionMode)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Text(
                    '$selectedCount dipilih',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              InkWell(
                onTap: onToggleSelectionMode,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isInSelectionMode
                            ? const Color(0xFFEEE8F8)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isInSelectionMode ? Icons.close : Icons.delete_outline,
                    size: 24,
                    color:
                        isInSelectionMode
                            ? const Color(0xFF8B7DFA)
                            : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: isInSelectionMode ? null : onAddTodo,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isInSelectionMode
                            ? Colors.grey.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 24,
                    color: isInSelectionMode ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}