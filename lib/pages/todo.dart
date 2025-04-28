import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_todo.dart';
import 'add_todo.dart';
import '../widgets/navbar.dart';
import 'package:tasca_mobile1/pages/login_page.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;
  bool _isInSelectionMode = false;
  Set<int> _selectedTodoIds = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchTodos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
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
        _redirectToLogin();
        return;
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
            tasks = todosData.map((todo) {
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
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else {
        throw Exception('Failed to load todos: ${response.body}');
      }
    } on SocketException {
      if (mounted) {
        setState(() {
          _errorMessage = 'Kesalahan Koneksi: Periksa koneksi internet Anda.';
          _isLoading = false;
        });
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

  Future<void> _searchTasks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _redirectToLogin();
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/tasks/search?search=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> tasksData = responseBody['data'];

        if (mounted) {
          setState(() {
            searchResults = tasksData.map((task) {
              return {
                'id': task['id'],
                'title': task['title'] ?? 'Unnamed Task',
                'is_complete': task['is_complete'] ?? false,
                'todo_id': task['todo_id'], // Changed from todo_title to todo_id
              };
            }).toList();
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else {
        throw Exception('Failed to search tasks: ${response.body}');
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

  void _redirectToLogin() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('auth_token');
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
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

      final client = http.Client();
      try {
        final request = http.Request(
          'DELETE',
          Uri.parse('https://api.tascaid.com/api/todos/$todoId/'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] = 'application/json';

        final streamedResponse = await client.send(request);
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          await _fetchTodos();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Todo berhasil dihapus')));
        } else {
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
                SnackBar(content: Text('Todo berhasil dihapus')));
          } else {
            throw Exception(
                'Failed to delete todo: Status ${response.statusCode}');
          }
        }
      } finally {
        client.close();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menghapus todo: $e')));
    }
  }

  Future<void> _deleteMultipleTodos() async {
    if (_selectedTodoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak ada todo yang dipilih')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      final client = http.Client();
      int successCount = 0;
      List<int> failedIds = [];

      for (int todoId in _selectedTodoIds) {
        try {
          final request = http.Request(
            'DELETE',
            Uri.parse('https://api.tascaid.com/api/todos/$todoId/'),
          );
          request.headers['Authorization'] = 'Bearer $token';
          request.headers['Content-Type'] = 'application/json';

          final streamedResponse = await client.send(request);
          final response = await http.Response.fromStream(streamedResponse);

          if (response.statusCode >= 200 && response.statusCode < 300) {
            successCount++;
          } else {
            final alternativeResponse = await http.delete(
              Uri.parse('https://api.tascaid.com/api/todos/$todoId'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            );

            if (alternativeResponse.statusCode >= 200 &&
                alternativeResponse.statusCode < 300) {
              successCount++;
            } else {
              failedIds.add(todoId);
            }
          }
        } catch (e) {
          failedIds.add(todoId);
        }
      }

      await _fetchTodos();
      setState(() {
        _isInSelectionMode = false;
        _selectedTodoIds.clear();
      });

      if (successCount == _selectedTodoIds.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Semua todo berhasil dihapus')),
        );
      } else if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '$successCount todo berhasil dihapus, ${failedIds.length} gagal')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus todo')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menghapus todo: $e')),
      );
    }
  }

  void _showTodoOptions(int todoId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
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
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _isInSelectionMode = !_isInSelectionMode;
      _selectedTodoIds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : _isSearching
                          ? _buildSearchResults()
                          : tasks.isEmpty
                              ? _buildEmptyState()
                              : _buildTodoGrid(),
            ),
            Navbar(initialActiveIndex: 1),
          ],
        ),
      ),
      floatingActionButton: _isInSelectionMode && _selectedTodoIds.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Hapus Todo'),
                      content: Text(
                        'Apakah Anda yakin ingin menghapus ${_selectedTodoIds.length} todo yang dipilih?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteMultipleTodos();
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
                backgroundColor: Colors.red,
                icon: Icon(Icons.delete_outline, color: Colors.white),
                label: Text('Hapus (${_selectedTodoIds.length})',
                    style: TextStyle(color: Colors.white)),
                extendedPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            )
          : null,
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
          Row(
            children: [
              if (_isInSelectionMode)
                Container(
                  margin: EdgeInsets.only(right: 12),
                  child: Text(
                    '${_selectedTodoIds.length} dipilih',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              InkWell(
                onTap: _toggleSelectionMode,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isInSelectionMode
                        ? Color(0xFFEEE8F8)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isInSelectionMode ? Icons.close : Icons.delete_outline,
                    size: 24,
                    color: _isInSelectionMode ? Color(0xFF8B7DFA) : Colors.red,
                  ),
                ),
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: _isInSelectionMode ? null : _showAddTodoBottomSheet,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isInSelectionMode
                        ? Colors.grey.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 24,
                    color: _isInSelectionMode ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari Task....',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchTasks('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          _searchTasks(value);
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    if (searchResults.isEmpty) {
      return Center(
        child: Text(
          'No tasks found',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final task = searchResults[index];
        return Card(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              task['title'],
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              task['is_complete'] ? 'Completed' : 'Pending',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: task['is_complete'] ? Colors.green : Colors.red,
              ),
            ),
            onTap: () {
              // Find the corresponding todo for color
              final todo = tasks.firstWhere(
                (t) => t['id'] == task['todo_id'],
                orElse: () => {'color': '#007BFF', 'title': 'Unknown Todo'},
              );
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context)  => DetailTodoPage(
                    todoId: task['todo_id'],
                    todoTitle: todo['title'],
                    taskCount: 0, // You might want to fetch actual task count
                    todoColor: todo['color'],
                    onTodoUpdated: _fetchTodos,
                  ),
                ),
              );
            },
            trailing: Icon(
              task['is_complete'] ? Icons.check_circle : Icons.circle_outlined,
              color: task['is_complete'] ? Colors.green : Colors.grey,
            ),
          ),
        );
      },
    );
  }

  void _showAddTodoBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddTodoPage(
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
          final todoId = todo['id'];
          final isSelected = _selectedTodoIds.contains(todoId);

          return GestureDetector(
            onTap: () {
              if (_isInSelectionMode) {
                setState(() {
                  if (isSelected) {
                    _selectedTodoIds.remove(todoId);
                  } else {
                    _selectedTodoIds.add(todoId);
                  }
                });
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailTodoPage(
                      todoId: todo['id'],
                      todoTitle: todo['title'],
                      taskCount: todo['taskCount'],
                      todoColor: todo['color'],
                      onTodoUpdated: _fetchTodos,
                    ),
                  ),
                );
              }
            },
            onLongPress: () {
              if (!_isInSelectionMode) {
                setState(() {
                  _isInSelectionMode = true;
                  _selectedTodoIds.add(todoId);
                });
              }
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
                  if (!_isInSelectionMode)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
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
                  if (_isInSelectionMode)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
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
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.check,
                                      color: Theme.of(context).primaryColor,
                                      size: 16),
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
                                        color: Colors.white, width: 1.5),
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