import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_todo.dart';
import 'add_todo.dart';
import '../widgets/navbar.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchTodos();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      _fetchTodos();
    }
  }

  Future<void> _fetchTodos() async {
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
                    'color': _getColorForTodo(todo['id']),
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

  String _getColorForTodo(int todoId) {
    final colors = ["#FC0101", "#007BFF", "#FFC107"];
    return colors[todoId % colors.length];
  }

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
          ).showSnackBar(SnackBar(content: Text('Todo berhasil dihapus')));
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Todo berhasil dihapus')));
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
      ).showSnackBar(SnackBar(content: Text('Error menghapus todo: $e')));
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
                    'Hapus Todo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context); // Close bottom sheet
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Hapus Todo'),
                            content: Text(
                              'Apakah Anda yakin ingin menghapus todo ini?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteTodo(todoId);
                                },
                                child: Text(
                                  'Hapus',
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
                  title: Text('Batal'),
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
      backgroundColor: const Color(0xFFF7F1FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child:
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : tasks.isEmpty
                      ? _buildEmptyState()
                      : _buildTodoGrid(),
            ),
            Navbar(initialActiveIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          InkWell(
            onTap: _showAddTodoBottomSheet,
            child: const Icon(Icons.add, size: 30, weight: 700),
          ),
        ],
      ),
    );
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

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'images/empty.png',
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 20),
        Text(
          'There are no scheduled tasks.',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6A6A6A),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
          child: Text(
            'Create a new task or activity to ensure it is always scheduled.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF6A6A6A),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodoGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final todo = tasks[index];
          Color cardColor = _getCardColor(todo['color']);

          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DetailTodoPage(
                        todoId: todo['id'],
                        todoTitle: todo['title'],
                        taskCount: todo['taskCount'],
                        todoColor: todo['color'],
                        onTodoUpdated: _fetchTodos,
                      ),
                ),
              );
            },
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
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: Text('Hapus Todo'),
                                content: Text(
                                  'Apakah Anda yakin ingin menghapus todo ini?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteTodo(todo['id']);
                                    },
                                    child: Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
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
        return const Color(0xFFFC0101);
      case "#007BFF":
        return const Color(0xFF007BFF);
      case "#FFC107":
        return const Color(0xFFFFC107);
      default:
        return const Color(0xFF808080);
    }
  }
}
