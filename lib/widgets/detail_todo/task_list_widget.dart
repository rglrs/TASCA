import 'package:flutter/material.dart';
import 'package:tasca_mobile1/utils/task_utils.dart';
import 'package:provider/provider.dart';
import 'package:tasca_mobile1/providers/task_provider.dart';

class TaskListWidget extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<dynamic> tasks;
  final GlobalKey addNewTaskKey;
  final VoidCallback onAddTaskTapped;
  final Function(dynamic) onTaskTapped;
  final Function(int, bool) onToggleCompletion;
  final Function(int) onDeleteTask;

  const TaskListWidget({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.tasks,
    required this.addNewTaskKey,
    required this.onAddTaskTapped,
    required this.onTaskTapped,
    required this.onToggleCompletion,
    required this.onDeleteTask,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      return Center(child: Text('Error: $errorMessage'));
    } else if (tasks.isEmpty) {
      return GestureDetector(
        key: addNewTaskKey,
        onTap: onAddTaskTapped,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.add, color: Colors.grey),
              const SizedBox(width: 10),
              const Text(
                'Add New Task...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else {
      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: Key('task-${task['id']}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: TaskUtils.getDeleteBackgroundColor(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                confirmDismiss: (direction) async {
                  bool confirmDelete = false;
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Hapus Task'),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus task ini?',
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Batal'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              confirmDelete = false;
                            },
                          ),
                          TextButton(
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              confirmDelete = true;
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  return confirmDelete;
                },
                onDismissed: (direction) {
                  onDeleteTask(task['id']);
                },
                child: GestureDetector(
                  onTap: () => onTaskTapped(task),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: task['is_complete'] ? Colors.grey.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => onToggleCompletion(task['id'], task['is_complete']),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: task['is_complete']
                                      ? Colors.green
                                      : Colors.grey.shade300,
                                  width: 2,
                                ),
                                color: task['is_complete']
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.transparent,
                              ),
                              child: task['is_complete']
                                  ? const Center(
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task['title'] ?? 'Unnamed Task',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: task['is_complete'] ? Colors.grey : Colors.black,
                                  ),
                                ),
                                if (task['description'] != null &&
                                    task['description'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      task['description'],
                                      style: TextStyle(
                                        color: task['is_complete']
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: TaskUtils.getPriorityColor(task['priority'] ?? 0),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        TaskUtils.getPriorityShortText(task['priority'] ?? 0),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (task['deadline'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: TaskUtils.getDeadlineColor(task['deadline']),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          TaskUtils.formatDeadline(task['deadline']),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          GestureDetector(
            key: addNewTaskKey,
            onTap: onAddTaskTapped,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Text(
                    'Add New Task...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}