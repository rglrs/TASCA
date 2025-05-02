import 'package:flutter/material.dart';

class TodoTitleWidget extends StatelessWidget {
  final String currentTitle;
  final bool isEditingTitle;
  final bool isSavingTitle;
  final TextEditingController titleController;
  final double completionPercentage;
  final int taskCount;
  final VoidCallback onEditTapped;
  final Function(String) onTitleSubmitted;

  const TodoTitleWidget({
    super.key,
    required this.currentTitle,
    required this.isEditingTitle,
    required this.isSavingTitle,
    required this.titleController,
    required this.completionPercentage,
    required this.taskCount,
    required this.onEditTapped,
    required this.onTitleSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onEditTapped,
          child: isEditingTitle
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: titleController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          autofocus: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onSubmitted: onTitleSubmitted,
                        ),
                      ),
                      if (isSavingTitle)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            onTitleSubmitted(titleController.text);
                          },
                        ),
                    ],
                  ),
                )
              : Text(
                  currentTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: LinearProgressIndicator(
            value: completionPercentage / 100,
            backgroundColor: Colors.red.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$taskCount ${taskCount == 1 ? "task" : "tasks"} • ${completionPercentage.toStringAsFixed(0)}% Completed',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}