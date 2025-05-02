import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_todo.dart';
import 'add_todo.dart';
import 'package:tasca_mobile1/widgets/navbar.dart';
import 'package:tasca_mobile1/pages/login_page.dart';
import 'package:tasca_mobile1/services/todo_service.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with WidgetsBindingObserver {
  List<Map<String, dynamic>> todos = [];
  List<Map<String, dynamic>> allTasks = []; // Store all tasks for local search
  List<Map<String, dynamic>> searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;
  bool _isInSelectionMode = false;
  Set<int> _selectedTodoIds = {};
  final TextEditingController _searchController = TextEditingController();

  // Store a reference to mounted state
  bool _mounted = true;

  // Store a reference to the current route in didChangeDependencies
  bool _isCurrent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchTodosAndTasks();
  }

  @override
  void dispose() {
    // Set mounted to false first
    _mounted = false;

    // Remove observer
    WidgetsBinding.instance.removeObserver(this);

    // Dispose controller
    _searchController.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _mounted && _isCurrent) {
      _fetchTodosAndTasks();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Store the isCurrent status when the widget is active
    if (_mounted) {
      final route = ModalRoute.of(context);
      _isCurrent = route != null && route.isCurrent;

      if (_isCurrent) {
        _fetchTodosAndTasks();
      }
    }
  }

  // Fetch both todos and all tasks for local search
  Future<void> _fetchTodosAndTasks() async {
    if (!_mounted) return;

    setState(() {
      _isLoading = todos.isEmpty;
      _errorMessage = null;
    });

    try {
      // Fetch todos using the service
      final fetchedTodos = await TodoService.fetchTodos();

      // Fetch all tasks using the service
      final fetchedTasks = await TodoService.fetchAllTasks();

      if (_mounted) {
        setState(() {
          todos = fetchedTodos;
          allTasks = fetchedTasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (_mounted) {
        // Check if unauthorized error
        if (e.toString().contains('Unauthorized')) {
          _redirectToLogin();
          return;
        }

        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Local search implementation that doesn't require API call
  void _searchTasks(String query) {
    if (!_mounted) return;

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;

      // Filter tasks locally based on search query
      searchResults =
          allTasks
              .where(
                (task) =>
                    task['title'].toString().toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    (task['description'] != null &&
                        task['description'].toString().toLowerCase().contains(
                          query.toLowerCase(),
                        )),
              )
              .toList();
    });
  }

  void _redirectToLogin() {
    if (!_mounted) return;

    // Store shared prefs reference first
    SharedPreferences.getInstance().then((prefs) {
      // Then clear the token
      prefs.remove('auth_token');

      // Then check if still mounted before navigation
      if (_mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    });
  }

  Future<void> _deleteTodo(int todoId) async {
    if (!_mounted) return;

    try {
      final success = await TodoService.deleteTodo(todoId);

      if (_mounted && success) {
        await _fetchTodosAndTasks();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Todo berhasil dihapus')));
      }
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error menghapus todo: $e')));
      }
    }
  }

  Future<void> _deleteMultipleTodos() async {
    if (!_mounted) return;

    if (_selectedTodoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada todo yang dipilih')),
      );
      return;
    }

    try {
      final result = await TodoService.deleteMultipleTodos(
        List<int>.from(_selectedTodoIds),
      );

      if (!_mounted) return;

      if (_mounted) {
        await _fetchTodosAndTasks();

        setState(() {
          _isInSelectionMode = false;
          _selectedTodoIds.clear();
        });

        if (result['failed'] == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Semua todo berhasil dihapus')),
          );
        } else if (result['success'] > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${result['success']} todo berhasil dihapus, ${result['failed']} gagal',
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Gagal menghapus todo')));
        }
      }
    } catch (e) {
      if (_mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error menghapus todo: $e')));
      }
    }
  }

  void _toggleSelectionMode() {
    if (!_mounted) return;

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
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : _isSearching
                      ? _buildSearchResults()
                      : todos.isEmpty
                      ? _buildEmptyState()
                      : _buildTodoGrid(),
            ),
            const Navbar(initialActiveIndex: 1),
          ],
        ),
      ),
      floatingActionButton:
          _isInSelectionMode && _selectedTodoIds.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.only(bottom: 90.0),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    if (!_mounted) return;

                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Hapus Todo'),
                            content: Text(
                              'Apakah Anda yakin ingin menghapus ${_selectedTodoIds.length} todo yang dipilih?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteMultipleTodos();
                                },
                                child: const Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );
                  },
                  backgroundColor: Colors.red,
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: Text(
                    'Hapus (${_selectedTodoIds.length})',
                    style: const TextStyle(color: Colors.white),
                  ),
                  extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                  margin: const EdgeInsets.only(right: 12),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _isInSelectionMode
                            ? const Color(0xFFEEE8F8)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _isInSelectionMode ? Icons.close : Icons.delete_outline,
                    size: 24,
                    color:
                        _isInSelectionMode
                            ? const Color(0xFF8B7DFA)
                            : Colors.red,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _isInSelectionMode ? null : _showAddTodoBottomSheet,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _isInSelectionMode
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
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
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
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text(
          'Type something to search tasks',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No tasks found for "${_searchController.text}"',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final task = searchResults[index];

        // Find the corresponding todo for navigation
        final Map<String, dynamic> todoData = {
          'id': task['todo_id'],
          'title': task['todo_title'] ?? 'Unknown Todo',
          'color': task['todo_color'] ?? '#007BFF',
        };

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(
              task['title'],
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In: ${todoData['title']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  task['is_complete'] ? 'Completed' : 'Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: task['is_complete'] ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            onTap: () {
              if (!_mounted) return;

              // Get the taskCount of the todo
              final todoWithCount = todos.firstWhere(
                (todo) => todo['id'] == task['todo_id'],
                orElse: () => {'taskCount': 0},
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DetailTodoPage(
                        todoId: todoData['id'],
                        todoTitle: todoData['title'],
                        taskCount: todoWithCount['taskCount'] ?? 0,
                        todoColor: todoData['color'],
                        onTodoUpdated: _fetchTodosAndTasks,
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
    if (!_mounted) return;

    final currentContext = context;

    showModalBottomSheet(
      context: currentContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (dialogContext) => AddTodoPage(
            onTodoAdded: (todoData) async {
              try {
                final success = await TodoService.createTodo(todoData);

                if (success) {
                  if (Navigator.canPop(dialogContext)) {
                    Navigator.pop(dialogContext);
                  }

                  // Update data if widget still mounted
                  if (_mounted) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_mounted) {
                        _fetchTodosAndTasks();
                      }
                    });
                  }
                }
              } catch (e) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
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
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          Color cardColor = _getCardColor(todo['color']);
          final todoId = todo['id'];
          final isSelected = _selectedTodoIds.contains(todoId);

          return GestureDetector(
            onTap: () {
              if (!_mounted) return;

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
                    builder:
                        (context) => DetailTodoPage(
                          todoId: todo['id'],
                          todoTitle: todo['title'],
                          taskCount: todo['taskCount'],
                          todoColor: todo['color'],
                          onTodoUpdated: _fetchTodosAndTasks,
                        ),
                  ),
                );
              }
            },
            onLongPress: () {
              if (!_mounted) return;

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
                          if (!_mounted) return;

                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Hapus Todo'),
                                  content: const Text(
                                    'Apakah Anda yakin ingin menghapus todo ini?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _deleteTodo(todo['id']);
                                      },
                                      child: const Text(
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
                          color:
                              isSelected
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
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                    size: 16,
                                  ),
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
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
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
