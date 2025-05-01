import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tasca_mobile1/providers/task_provider.dart';
import 'package:tasca_mobile1/services/task_service.dart';

class AddTaskPage extends StatefulWidget {
  final int todoId;
  final int? taskId;
  final Map<String, dynamic>? initialData;
  final VoidCallback onTaskAdded;

  const AddTaskPage({
    super.key,
    required this.todoId,
    this.taskId,
    this.initialData,
    required this.onTaskAdded,
  });

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TaskService _taskService = TaskService();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedPriority = 0; // Default priority
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Populate fields if editing existing task
    if (widget.initialData != null) {
      _titleController.text = widget.initialData!['title'] ?? '';
      _notesController.text = widget.initialData!['description'] ?? '';
      _selectedPriority = widget.initialData!['priority'] ?? 0;

      // Parse deadline if exists
      if (widget.initialData!['deadline'] != null) {
        // Parse the deadline and convert to local time
        DateTime deadline =
            DateTime.parse(widget.initialData!['deadline']).toLocal();
        _selectedDate = DateTime(deadline.year, deadline.month, deadline.day);
        _selectedTime = TimeOfDay(hour: deadline.hour, minute: deadline.minute);
      }
    }
  }

  void _showPriorityBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Rendah'),
                onTap: () {
                  setState(() {
                    _selectedPriority = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Sedang'),
                onTap: () {
                  setState(() {
                    _selectedPriority = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Tinggi'),
                onTap: () {
                  setState(() {
                    _selectedPriority = 2;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Paling Tinggi'),
                onTap: () {
                  setState(() {
                    _selectedPriority = 3;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPriorityText(int priority) {
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
        return 'Rendah';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Fix: Ensure initialDate is not before firstDate
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    
    // Ensure initialDate is valid (not before firstDate)
    final DateTime initialDate = (_selectedDate != null && _selectedDate!.isAfter(now)) 
        ? _selectedDate! 
        : now;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Prepare the request body for both add and update
  Map<String, dynamic> _prepareRequestBody() {
    // Prepare deadline in the format expected by the API
    String? deadlineString;
    if (_selectedDate != null) {
      final hour = _selectedTime?.hour ?? 23;
      final minute = _selectedTime?.minute ?? 59;

      final deadline =
          DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            hour,
            minute,
            00,
          ).toUtc();

      deadlineString = deadline.toIso8601String();
    }

    // Request body
    final Map<String, dynamic> requestBody = {
      'title': _titleController.text,
      'description': _notesController.text,
      'priority': _selectedPriority,
    };

    if (deadlineString != null) {
      requestBody['deadline'] = deadlineString;
    }

    return requestBody;
  }

  // Add a new task using TaskService with Provider
  Future<void> _addTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task title is required')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare request body
      final requestBody = _prepareRequestBody();

      // Use TaskService with Provider support
      await _taskService.addTask(context, widget.todoId, requestBody);

      // Call the callback
      widget.onTaskAdded();

      // Show success message and navigate back
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task added successfully')));

      // Menggunakan WidgetsBinding untuk memastikan sinkronisasi terjadi setelah build selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Manually sync the provider
        try {
          final taskProvider = Provider.of<TaskProvider>(
            context,
            listen: false,
          );
          taskProvider.dataChanged = true;
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
      print('Add Task Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update an existing task using TaskService with Provider
  Future<void> _updateTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task title is required')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare request body
      final requestBody = _prepareRequestBody();

      // Use TaskService with Provider support
      await _taskService.updateTask(
        context,
        widget.todoId,
        widget.taskId!,
        requestBody,
      );

      // Call the callback
      widget.onTaskAdded();

      // Show success message and navigate back
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Task updated successfully')));

      // Menggunakan WidgetsBinding untuk memastikan sinkronisasi terjadi setelah build selesai
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Manually sync the provider
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
      print('Update Task Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Call the appropriate function based on whether we're adding or editing
  void _addOrUpdateTask() {
    if (widget.taskId == null) {
      _addTask();
    } else {
      _updateTask();
    }
  }

  bool _isTaskReady() {
    bool isTitleFilled = _titleController.text.trim().isNotEmpty;

    bool isDeadlineValid = _selectedDate != null && _selectedTime != null;

    return isTitleFilled &&
        isDeadlineValid; // Atau tambahkan && isDeadlineValid jika ingin deadline wajib
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.taskId == null ? 'Add Task' : 'Edit Task'),
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isTaskReady() ? _addOrUpdateTask : null,
              style: TextButton.styleFrom(
                backgroundColor:
                    _isTaskReady()
                        ? Colors.green
                        : Colors.grey.shade300, // Background button
              ), // Disable jika belum siap
              child: Text(
                widget.taskId == null ? 'Add' : 'Save',
                style: TextStyle(
                  color:
                      _isTaskReady()
                          ? Colors.white
                          : Colors.grey, // Warna berubah sesuai kesiapan
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Add Task...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Add Notes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Priority'),
                subtitle: Text(_getPriorityText(_selectedPriority)),
                trailing: Icon(Icons.chevron_right),
                onTap: _showPriorityBottomSheet,
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Deadline (day)'),
                trailing: Text(
                  _selectedDate != null
                      ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                      : 'None',
                ),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Deadline (time)'),
                trailing: Text(
                  _selectedTime != null
                      ? _selectedTime!.format(context)
                      : 'None',
                ),
                onTap: () => _selectTime(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}