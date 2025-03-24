import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddTaskPage extends StatefulWidget {
  final int todoId;
  final int? taskId;
  final Map<String, dynamic>? initialData;
  final VoidCallback onTaskAdded;

  const AddTaskPage({
    Key? key,
    required this.todoId,
    this.taskId,
    this.initialData,
    required this.onTaskAdded,
  }) : super(key: key);

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

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
        DateTime deadline = DateTime.parse(widget.initialData!['deadline']);
        _selectedDate = DateTime(deadline.year, deadline.month, deadline.day);
        _selectedTime = TimeOfDay.fromDateTime(deadline);
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
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

      final deadline = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        hour,
        minute,
        59,
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

  // Add a new task
  Future<void> _addTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task title is required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      // URL for creating a new task
      final url = 'https://api.tascaid.com/api/todos/${widget.todoId}/tasks/';
      final requestBody = _prepareRequestBody();

      print('Add Task - URL: $url');
      print('Add Task - Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Add Response Status: ${response.statusCode}');
      print('Add Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        widget.onTaskAdded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task added successfully')),
        );
      } else {
        String errorMessage;
        try {
          final responseData = json.decode(response.body);
          errorMessage = responseData['error'] ?? 'Unknown error occurred';
        } catch (e) {
          errorMessage = 'Error: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Add Task Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update an existing task
  Future<void> _updateTask() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task title is required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Create http client that will be used and closed later
    final client = http.Client();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      // URL for updating an existing task
      final url = 'https://api.tascaid.com/api/todos/${widget.todoId}/tasks/${widget.taskId}/';
      final requestBody = _prepareRequestBody();

      print('Update Task - URL: $url');
      print('Update Task - Body: ${json.encode(requestBody)}');
      
      // Create a PATCH request
      final request = http.Request('PATCH', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode(requestBody);

      // Send the request and get the stream response
      final streamedResponse = await client.send(request);
      
      http.Response response;
      
      // If we get a redirect, manually follow it while maintaining the PATCH method
      if (streamedResponse.statusCode == 307) {
        final redirectUrl = streamedResponse.headers['location'];
        if (redirectUrl != null) {
          print('Redirecting PATCH to: $redirectUrl');
          
          // Handle both absolute and relative URLs
          Uri redirectUri;
          if (redirectUrl.startsWith('http')) {
            // It's an absolute URL
            redirectUri = Uri.parse(redirectUrl);
          } else {
            // It's a relative URL - we need to combine it with the base URL
            // Extract the base URL from the original request
            final baseUri = Uri.parse(url);
            final baseUrl = '${baseUri.scheme}://${baseUri.host}';
            
            // Remove leading slash if present in both
            final cleanRedirectUrl = redirectUrl.startsWith('/') ? redirectUrl.substring(1) : redirectUrl;
            redirectUri = Uri.parse('$baseUrl/$cleanRedirectUrl');
          }
          
          print('Full redirect URL: $redirectUri');
          
          final redirectRequest = http.Request('PATCH', redirectUri);
          redirectRequest.headers['Authorization'] = 'Bearer $token';
          redirectRequest.headers['Content-Type'] = 'application/json';
          redirectRequest.body = json.encode(requestBody);
          
          final redirectResponse = await client.send(redirectRequest);
          response = await http.Response.fromStream(redirectResponse);
        } else {
          // If no location header, just use the original response
          response = await http.Response.fromStream(streamedResponse);
        }
      } else {
        // If no redirect, just get the response
        response = await http.Response.fromStream(streamedResponse);
      }

      print('Update Response Status: ${response.statusCode}');
      print('Update Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        widget.onTaskAdded();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task updated successfully')),
        );
      } else {
        String errorMessage;
        try {
          if (response.body.isNotEmpty) {
            final responseData = json.decode(response.body);
            errorMessage = responseData['error'] ?? 'Unknown error occurred';
          } else {
            errorMessage = 'Server returned status ${response.statusCode}';
          }
        } catch (e) {
          errorMessage = 'Error: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Update Task Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      // Always close the client when done
      client.close();
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
              onPressed: _addOrUpdateTask,
              child: Text(
                widget.taskId == null ? 'Add' : 'Save',
                style: TextStyle(color: Colors.white),
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