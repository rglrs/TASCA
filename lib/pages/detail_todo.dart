import 'package:flutter/material.dart';
import 'add_task.dart';
import 'package:tasca_mobile1/services/task_service.dart';
import 'package:tasca_mobile1/utils/task_utils.dart';
import 'package:provider/provider.dart';
import 'package:tasca_mobile1/providers/task_provider.dart';

class DetailTodoPage extends StatefulWidget {
  final int todoId;
  final String todoTitle;
  final int taskCount;
  final String todoColor;
  final Function? onTodoUpdated;

  const DetailTodoPage({
    super.key,
    required this.todoId,
    required this.todoTitle,
    required this.taskCount,
    required this.todoColor,
    this.onTodoUpdated,
  });

  @override
  _DetailTodoPageState createState() => _DetailTodoPageState();
}

class _DetailTodoPageState extends State<DetailTodoPage> {
  final TaskService _taskService = TaskService();

  List<dynamic> tasks = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _completedTasks = 0;
  String _currentTitle = '';
  bool _isEditingTitle = false;
  bool _isSavingTitle = false;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.todoTitle;
    _titleController.text = _currentTitle;
    _fetchTodoTasks();
  }

  Future<void> _fetchTodoTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedTasks = await _taskService.fetchTodoTasks(widget.todoId);

      setState(() {
        tasks = fetchedTasks;
        _completedTasks =
            tasks.where((task) => task['is_complete'] == true).length;
        _isLoading = false;
      });

      debugPrint('Loaded ${tasks.length} tasks, $_completedTasks completed');

      // Update parent todo list if callback exists
      if (widget.onTodoUpdated != null) {
        widget.onTodoUpdated!();
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Update todo title
  Future<void> _updateTodoTitle(String newTitle) async {
    if (newTitle.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Judul tidak boleh kosong')));
      return;
    }

    setState(() {
      _isSavingTitle = true;
    });

    try {
      // Passing context as first argument
      await _taskService.updateTodoTitle(context, widget.todoId, newTitle);

      setState(() {
        _currentTitle = newTitle;
        _isEditingTitle = false;
      });

      // Trigger callback to update parent if exists
      if (widget.onTodoUpdated != null) {
        widget.onTodoUpdated!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul todo berhasil diperbarui')),
      );
    } catch (e) {
      debugPrint('Update Todo Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      // Reset to previous title
      _titleController.text = _currentTitle;
    } finally {
      setState(() {
        _isSavingTitle = false;
      });
    }
  }

  // Method to delete current todo
  Future<void> _deleteTodo() async {
    try {
      // Passing context as first argument
      await _taskService.deleteTodo(context, widget.todoId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Todo berhasil dihapus')));

      // Trigger callback to update parent if exists
      if (widget.onTodoUpdated != null) {
        widget.onTodoUpdated!();
      }

      // Return to previous screen
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error deleting todo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error menghapus todo: $e')));
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Todo'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus todo ini dan semua task-nya?',
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTodo();
              },
            ),
          ],
        );
      },
    );
  }

  // Show options menu when more button is clicked
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Hapus Todo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    _showDeleteConfirmation();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Batal'),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToAddTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AddTaskPage(
              todoId: widget.todoId,
              onTaskAdded: () {
                _fetchTodoTasks();
                // Update the parent todo list
                if (widget.onTodoUpdated != null) {
                  widget.onTodoUpdated!();
                }

                // Sync dengan TaskProvider untuk update kalender
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Sync dengan TaskProvider untuk update kalender
                  try {
                    final taskProvider = Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    );
                    taskProvider.syncTaskChanges();
                  } catch (e) {
                    debugPrint('Provider sync error (non-critical): $e');
                  }
                });
              },
            ),
      ),
    ).then((_) {
      // Refresh tasks when returning from add task screen
      _fetchTodoTasks();
      // Refresh parent list
      if (widget.onTodoUpdated != null) {
        widget.onTodoUpdated!();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Sync dengan TaskProvider untuk update kalender
        try {
          final taskProvider = Provider.of<TaskProvider>(
            context,
            listen: false,
          );
          taskProvider.syncTaskChanges();
        } catch (e) {
          debugPrint('Provider sync error (non-critical): $e');
        }
      });
    });
  }

  Future<void> _toggleTaskCompletion(int taskId, bool currentStatus) async {
    try {
      // Passing context as first argument and correcting parameter order
      await _taskService.toggleTaskCompletion(
        context,
        widget.todoId,
        taskId,
        currentStatus,
      );
      await _fetchTodoTasks();

      // Trigger callback to update parent if exists
      if (widget.onTodoUpdated != null) {
        widget.onTodoUpdated!();
      }

      // Gunakan WidgetsBinding untuk memastikan sinkronisasi terjadi setelah build selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Sync dengan TaskProvider untuk update kalender
        try {
          final taskProvider = Provider.of<TaskProvider>(
            context,
            listen: false,
          );
          taskProvider.syncTaskChanges();
        } catch (e) {
          debugPrint('Provider sync error (non-critical): $e');
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Method to delete task
  Future<void> _deleteTask(int taskId) async {
    try {
      // Passing context as first argument
      await _taskService.deleteTask(context, widget.todoId, taskId);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task berhasil dihapus')));

      // Refresh task list
      await _fetchTodoTasks();

      // Trigger callback to update parent
      if (widget.onTodoUpdated != null) {
        widget.onTodoUpdated!();
      }

      // Gunakan WidgetsBinding untuk memastikan sinkronisasi terjadi setelah build selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Sync dengan TaskProvider untuk update kalender
        try {
          final taskProvider = Provider.of<TaskProvider>(
            context,
            listen: false,
          );
          taskProvider.dataChanged = true; // Set flag bahwa data telah berubah

          // Gunakan WidgetsBinding untuk menghindari error build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              taskProvider.syncTaskChanges();
            }
          });
        } catch (e) {
          debugPrint('Provider sync error (non-critical): $e');
        }
      });
    } catch (e) {
      debugPrint('Error deleting task: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error menghapus task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    double completionPercentage = 0;
    if (tasks.isNotEmpty) {
      completionPercentage = (_completedTasks / tasks.length) * 100;
    }

    final Color backgroundColor = TaskUtils.getColorFromString(
      widget.todoColor,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: backgroundColor,
            pinned: true,
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditingTitle = true;
                        _titleController.text = _currentTitle;
                        Future.delayed(const Duration(milliseconds: 50), () {
                          _titleController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _titleController.text.length),
                          );
                        });
                      });
                    },
                    child:
                        _isEditingTitle
                            ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _titleController,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 8,
                                            ),
                                        border: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      onSubmitted: (value) {
                                        _updateTodoTitle(value);
                                      },
                                    ),
                                  ),
                                  if (_isSavingTitle)
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
                                        _updateTodoTitle(_titleController.text);
                                      },
                                    ),
                                ],
                              ),
                            )
                            : Text(
                              _currentTitle,
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
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${tasks.length} ${tasks.length == 1 ? "task" : "tasks"} • ${completionPercentage.toStringAsFixed(0)}% Completed',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                onPressed: _showMoreOptions,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Modified task list rendering
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage != null)
                    Center(child: Text('Error: $_errorMessage'))
                  else if (tasks.isEmpty)
                    // When no tasks, show "Add New Task" at the top
                    GestureDetector(
                      onTap: _navigateToAddTask,
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
                    )
                  else
                    Column(
                      children: [
                        // Task list with new design
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
                                // Confirmation dialog code
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
                                _deleteTask(task['id']);
                              },
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to edit task
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => AddTaskPage(
                                            todoId: widget.todoId,
                                            taskId: task['id'],
                                            initialData: task,
                                            onTaskAdded: () {
                                              _fetchTodoTasks();
                                              // Also update the parent todo list
                                              if (widget.onTodoUpdated !=
                                                  null) {
                                                widget.onTodoUpdated!();
                                              }

                                              // Sync dengan TaskProvider untuk update kalender
                                              try {
                                                final taskProvider =
                                                    Provider.of<TaskProvider>(
                                                      context,
                                                      listen: false,
                                                    );
                                                taskProvider.syncTaskChanges();
                                              } catch (e) {
                                                debugPrint(
                                                  'Provider sync error (non-critical): $e',
                                                );
                                              }
                                            },
                                          ),
                                    ),
                                  ).then((_) {
                                    // Refresh tasks when returning from edit screen
                                    _fetchTodoTasks();
                                    // Also refresh parent list
                                    if (widget.onTodoUpdated != null) {
                                      widget.onTodoUpdated!();
                                    }

                                    // Sync dengan TaskProvider untuk update kalender
                                    try {
                                      final taskProvider =
                                          Provider.of<TaskProvider>(
                                            context,
                                            listen: false,
                                          );
                                      taskProvider.syncTaskChanges();
                                    } catch (e) {
                                      debugPrint(
                                        'Provider sync error (non-critical): $e',
                                      );
                                    }
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        task['is_complete']
                                            ? Colors.grey.shade100
                                            : Colors.white,
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
                                      // Move is_complete button to the left
                                      GestureDetector(
                                        onTap:
                                            () => _toggleTaskCompletion(
                                              task['id'],
                                              task['is_complete'],
                                            ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color:
                                                    task['is_complete']
                                                        ? Colors.green
                                                        : Colors.grey.shade300,
                                                width: 2,
                                              ),
                                              color:
                                                  task['is_complete']
                                                      ? Colors.green
                                                          .withOpacity(0.2)
                                                      : Colors.transparent,
                                            ),
                                            child:
                                                task['is_complete']
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                task['title'] ?? 'Unnamed Task',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      task['is_complete']
                                                          ? Colors.grey
                                                          : Colors.black,
                                                ),
                                              ),
                                              // Description section
                                              if (task['description'] != null &&
                                                  task['description']
                                                      .toString()
                                                      .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        top: 4,
                                                      ),
                                                  child: Text(
                                                    task['description'],
                                                    style: TextStyle(
                                                      color:
                                                          task['is_complete']
                                                              ? Colors
                                                                  .grey
                                                                  .shade500
                                                              : Colors
                                                                  .grey
                                                                  .shade600,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  // Priority indicator
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          TaskUtils.getPriorityColor(
                                                            task['priority'] ??
                                                                0,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            20,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      TaskUtils.getPriorityShortText(
                                                        task['priority'] ?? 0,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),

                                                  // Small spacing between priority and deadline
                                                  const SizedBox(width: 8),

                                                  // Deadline container
                                                  if (task['deadline'] != null)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            TaskUtils.getDeadlineColor(
                                                              task['deadline'],
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        TaskUtils.formatDeadline(
                                                          task['deadline'],
                                                        ),
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
                        // "Add New Task" at the bottom
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _navigateToAddTask,
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
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
