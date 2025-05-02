import 'package:flutter/material.dart';
import 'add_task.dart';
import 'package:tasca_mobile1/services/task_service.dart';
import 'package:tasca_mobile1/utils/task_utils.dart';
import 'package:provider/provider.dart';
import 'package:tasca_mobile1/providers/task_provider.dart';
import 'package:tasca_mobile1/widgets/detail_todo/detail_todo_coach_mark.dart';
import 'package:tasca_mobile1/widgets/detail_todo/todo_title_widget.dart';
import 'package:tasca_mobile1/widgets/detail_todo/task_list_widget.dart';
// Import HelpButtonWidget dihapus

class DetailTodoPage extends StatefulWidget {
  final int todoId;
  final String todoTitle;
  final int taskCount;
  final String todoColor;
  final bool isNewTodo; // Parameter baru
  final Function? onTodoUpdated;

  const DetailTodoPage({
    super.key,
    required this.todoId,
    required this.todoTitle,
    required this.taskCount,
    required this.todoColor,
    this.isNewTodo = false,
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

  // Global keys untuk coach mark
  final GlobalKey _todoTitleKey = GlobalKey();
  final GlobalKey _moreOptionsKey = GlobalKey();
  final GlobalKey _taskListKey = GlobalKey();
  final GlobalKey _addNewTaskKey = GlobalKey();

  // Coach mark manager
  DetailTodoCoachMark? _coachMark;

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.todoTitle;
    _titleController.text = _currentTitle;
    _fetchTodoTasks();

    // Inisialisasi coach mark setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCoachMark();
    });
  }

  // Inisialisasi coach mark
  void _initCoachMark() {
    _coachMark = DetailTodoCoachMark(
      context: context,
      todoTitleKey: _todoTitleKey,
      moreOptionsKey: _moreOptionsKey,
      taskListKey: _taskListKey,
      addNewTaskKey: _addNewTaskKey,
    );

    // Tampilkan coach mark berdasarkan status task dan isNewTodo
    _coachMark?.showCoachMarkIfNeeded(
      isNewTodo: widget.isNewTodo,
      hasTasks: tasks.isNotEmpty,
    );
  }

  // Method untuk menampilkan coach mark saat tombol bantuan diklik
  void _showCoachMark() {
    if (_coachMark != null) {
      DetailTodoCoachMark.resetCoachMarkStatus().then((_) {
        _coachMark!.showCoachMark(hasTasks: tasks.isNotEmpty);
      });
    }
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

      // Update coach mark setelah tasks diambil
      if (mounted) {
        _coachMark?.showCoachMarkIfNeeded(
          isNewTodo: widget.isNewTodo,
          hasTasks: tasks.isNotEmpty,
        );
      }

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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Judul tidak boleh kosong')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
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

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todo berhasil dihapus')));

      // Trigger callback to update parent if exists
      if (widget.onTodoUpdated != null) {
        widget.onTodoUpdated!();
      }

      // Return to previous screen
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error deleting todo: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error menghapus todo: $e')));
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
      builder: (context) => Container(
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
        builder: (context) => AddTaskPage(
          todoId: widget.todoId,
          onTaskAdded: () {
            _fetchTodoTasks();
            // Update the parent todo list
            if (widget.onTodoUpdated != null) {
              widget.onTodoUpdated!();
            }

            // Sync dengan TaskProvider untuk update kalender
            WidgetsBinding.instance.addPostFrameCallback((_) {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteTask(int taskId) async {
    try {
      // Passing context as first argument
      await _taskService.deleteTask(context, widget.todoId, taskId);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Task berhasil dihapus')));

      // Refresh task list
      await _fetchTodoTasks();

      // Trigger callback to update parent
      if (widget.onTodoUpdated != null) {
        widget.onTodoUpdated!();
      }

      // Gunakan WidgetsBinding untuk memastikan sinkronisasi terjadi setelah build selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final taskProvider = Provider.of<TaskProvider>(
            context,
            listen: false,
          );
          taskProvider.dataChanged = true; // Set flag bahwa data telah berubah
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error menghapus task: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = TaskUtils.getColorFromString(widget.todoColor);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: backgroundColor,
            pinned: true,
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: TodoTitleWidget(
                key: _todoTitleKey,
                currentTitle: _currentTitle,
                isEditingTitle: _isEditingTitle,
                isSavingTitle: _isSavingTitle,
                titleController: _titleController,
                completionPercentage:
                    tasks.isNotEmpty ? (_completedTasks / tasks.length) * 100 : 0,
                taskCount: tasks.length,
                onEditTapped: () {
                  setState(() {
                    _isEditingTitle = true;
                    _titleController.text = _currentTitle;
                    Future.delayed(const Duration(milliseconds: 50), () {
                      _titleController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _titleController.text.length),
                      );
                    });
                  });
                },
                onTitleSubmitted: _updateTodoTitle,
              ),
            ),
            actions: [
              IconButton(
                key: _moreOptionsKey,
                icon: const Icon(Icons.more_horiz, color: Colors.white),
                onPressed: _showMoreOptions,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TaskListWidget(
                key: _taskListKey,
                addNewTaskKey: _addNewTaskKey,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                tasks: tasks,
                onAddTaskTapped: _navigateToAddTask,
                onTaskTapped: (task) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTaskPage(
                        todoId: widget.todoId,
                        taskId: task['id'],
                        initialData: task,
                        onTaskAdded: () {
                          _fetchTodoTasks();
                          if (widget.onTodoUpdated != null) {
                            widget.onTodoUpdated!();
                          }
                          try {
                            final taskProvider = Provider.of<TaskProvider>(
                              context,
                              listen: false,
                            );
                            taskProvider.syncTaskChanges();
                          } catch (e) {
                            debugPrint(
                                'Provider sync error (non-critical): $e');
                          }
                        },
                      ),
                    ),
                  ).then((_) {
                    _fetchTodoTasks();
                    if (widget.onTodoUpdated != null) {
                      widget.onTodoUpdated!();
                    }
                    try {
                      final taskProvider = Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      );
                      taskProvider.syncTaskChanges();
                    } catch (e) {
                      debugPrint(
                          'Provider sync error (non-critical): $e');
                    }
                  });
                },
                onToggleCompletion: _toggleTaskCompletion,
                onDeleteTask: _deleteTask,
              ),
            ),
          ),
        ],
      ),
    );
  }
}