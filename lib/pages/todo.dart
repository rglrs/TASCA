import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_todo.dart';
import 'add_todo.dart';
import '../widgets/navbar.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchTodos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Force refresh when returning to this screen
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchTodos();
    }
  }

  // Force refresh when focused again
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      _fetchTodos();
    }
  }

  Future<void> _fetchTodos() async {
    // Don't show loading if refreshing after returning from another page
    // to avoid UI flicker
    if (mounted) {
      setState(() {
        _isLoading = tasks.isEmpty;
        _errorMessage = null;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/todos/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> todosData = responseBody['data'];

        if (mounted) {
          setState(() {
            tasks =
                todosData.map((todo) {
                  return {
                    'id': todo['id'],
                    'title': todo['title'] ?? 'Unnamed Todo',
                    'taskCount': todo['task_count'] ?? 0,
                  };
                }).toList();
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load todos: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showAddTodoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => AddTodoPage(
            onTodoAdded: (task) async {
              try {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('auth_token');

                if (token == null) {
                  throw Exception('No JWT token found');
                }

                final response = await http.post(
                  Uri.parse('https://api.tascaid.com/api/todos/'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: json.encode({
                    'title': task['title'],
                    'urgency': task['urgency'],
                    'importance': task['importance'],
                  }),
                );

                if (response.statusCode == 201) {
                  await _fetchTodos();
                  Navigator.pop(context);
                } else {
                  throw Exception('Failed to create todo: ${response.body}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to add todo: $e')),
                );
              }
            },
          ),
    );
  }

  // Improved delete todo function
  Future<void> _deleteTodo(int todoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      // Create a client instance that will be closed later
      final client = http.Client();

      try {
        // Create DELETE request
        final request = http.Request(
          'DELETE',
          Uri.parse('https://api.tascaid.com/api/todos/$todoId/'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] = 'application/json';

        // Send request and get stream response
        final streamedResponse = await client.send(request);

        // Get full response
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Refresh todo list
          await _fetchTodos();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Todo successfully deleted')));
        } else {
          // Try alternative method if first method fails
          // Try URL without trailing slash
          final alternativeResponse = await http.delete(
            Uri.parse('https://api.tascaid.com/api/todos/$todoId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (alternativeResponse.statusCode >= 200 &&
              alternativeResponse.statusCode < 300) {
            await _fetchTodos();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Todo successfully deleted')),
            );
          } else {
            throw Exception(
              'Failed to delete todo: Status ${response.statusCode}',
            );
          }
        }
      } finally {
        // Always close client when done
        client.close();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting todo: $e')));
    }
  }

  // Show options when three dots clicked
  void _showTodoOptions(int todoId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(
                    'Delete Todo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Delete Todo'),
                            content: Text(
                              'Are you sure you want to delete this todo?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteTodo(todoId);
                                },
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text('Cancel'),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To Do'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showAddTodoBottomSheet),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchTodos,
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : tasks.isEmpty
                      ? _EmptyStateView()
                      : _TodoListView(
                        tasks: tasks,
                        onTodoTap: (todoId, todoTitle, taskCount) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => DetailTodoPage(
                                    todoId: todoId,
                                    todoTitle: todoTitle,
                                    taskCount: taskCount,
                                    onTodoUpdated: () {
                                      // Refresh todo list when detail page updates something
                                      _fetchTodos();
                                    },
                                  ),
                            ),
                          ).then((_) {
                            // Also refresh after returning from detail page
                            _fetchTodos();
                          });
                        },
                        onMorePressed: _showTodoOptions,
                      ),
            ),
          ),
          // Always show the navbar at the bottom
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Navbar(initialActiveIndex: 1),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/empty.png', width: 200, height: 200),
          SizedBox(height: 20),
          Text(
            'There are no scheduled tasks.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          SizedBox(height: 10),
          Text(
            'Create a new task or activity to ensure it is always scheduled.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TodoListView extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final Function(int, String, int) onTodoTap;
  final Function(int) onMorePressed;

  const _TodoListView({
    Key? key,
    required this.tasks,
    required this.onTodoTap,
    required this.onMorePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final int taskCount = task['taskCount'] ?? 0;

          return Card(
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => onTodoTap(task['id'], task['title'], taskCount),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          task['title'] ?? 'Unnamed Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => onMorePressed(task['id']),
                          child: Icon(Icons.more_horiz, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    SizedBox(height: 8),
                    Text(
                      '$taskCount ${taskCount == 1 ? "task" : "tasks"}',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
