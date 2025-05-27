import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'detail_todo.dart';
import 'package:tasca_mobile1/widgets/navbar.dart';
import 'package:tasca_mobile1/services/todo_service.dart';
import 'package:tasca_mobile1/widgets/todo/todo_state_manager.dart';
import 'package:tasca_mobile1/widgets/todo/todo_search_bar.dart';
import 'package:tasca_mobile1/widgets/todo/todo_search_results.dart';
import 'package:tasca_mobile1/widgets/todo/todo_empty_state.dart';
import 'package:tasca_mobile1/widgets/todo/todo_grid.dart';
import 'package:tasca_mobile1/widgets/todo/todo_selection_fab.dart';
import 'package:tasca_mobile1/widgets/todo/todo_delete_dialog.dart';
import 'package:tasca_mobile1/widgets/todo/todo_coach_mark.dart';
import 'package:tasca_mobile1/pages/add_todo.dart';

// Konstanta untuk mode pengujian coach mark
// Set ke false untuk production, true untuk pengujian
const bool TESTING_MODE = false;

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> with WidgetsBindingObserver {
  // Inisialisasi state manager
  final TodoStateManager stateManager = TodoStateManager();
  
  // Global keys untuk coach mark
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _deleteKey = GlobalKey();
  final GlobalKey _addKey = GlobalKey();
  
  // Coach mark manager
  TodoCoachMark? _coachMark;
  
  // Tambahkan state untuk menampilkan loading screen
  bool _isDeleting = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Setup state manager
    stateManager.mounted = true;
    stateManager.init(
      fetchCallback: _fetchTodosAndTasks,
      setStateCallback: () {
        if (mounted) setState(() {});
      }
    );
    
    // Fetch data setelah inisialisasi
    _fetchTodosAndTasks();
    
    // Inisialisasi coach mark setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCoachMark();
    });
  }

  // Inisialisasi coach mark
  void _initCoachMark() {
    _coachMark = TodoCoachMark(
      context: context,
      searchKey: _searchKey,
      deleteKey: _deleteKey,
      addKey: _addKey,
    );
    
    // Tampilkan coach mark sesuai mode
    if (TESTING_MODE) {
      // Untuk pengujian, selalu tampilkan
      _coachMark?.showCoachMark();
    } else {
      // Untuk produksi, cek shared preference
      _coachMark?.showCoachMarkIfNeeded();
    }
  }

  @override
  void dispose() {
    stateManager.mounted = false;
    WidgetsBinding.instance.removeObserver(this);
    stateManager.searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && stateManager.mounted && stateManager.isCurrent) {
      _fetchTodosAndTasks();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (stateManager.mounted) {
      final route = ModalRoute.of(context);
      stateManager.isCurrent = route != null && route.isCurrent;

      if (stateManager.isCurrent) {
        _fetchTodosAndTasks();
      }
    }
  }

  // Fetch todos and tasks 
  Future<void> _fetchTodosAndTasks() async {
    if (!stateManager.mounted) return;

    setState(() {
      stateManager.isLoading = stateManager.todos.isEmpty;
      stateManager.errorMessage = null;
    });

    try {
      // Fetch todos and tasks
      final fetchedTodos = await TodoService.fetchTodos();
      final fetchedTasks = await TodoService.fetchAllTasks();

      if (stateManager.mounted) {
        setState(() {
          stateManager.todos = fetchedTodos;
          stateManager.allTasks = fetchedTasks;
          stateManager.isLoading = false;
        });
      }
    } catch (e) {
      if (stateManager.mounted) {
        if (e.toString().contains('Unauthorized')) {
          _redirectToLogin();
          return;
        }

        setState(() {
          stateManager.errorMessage = e.toString();
          stateManager.isLoading = false;
        });
      }
    }
  }

  // Redirect to login
  void _redirectToLogin() {
    if (!stateManager.mounted) return;

    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('auth_token');
      if (stateManager.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      }
    });
  }

  // Delete single todo dengan loading screen
  Future<void> _deleteTodo(int todoId) async {
    if (!stateManager.mounted) return;

    // Tampilkan loading screen
    setState(() {
      _isDeleting = true;
    });

    try {
      final success = await TodoService.deleteTodo(todoId);

      if (stateManager.mounted) {
        if (success) {
          // Update state secara lokal untuk menghindari permintaan tambahan
          setState(() {
            stateManager.todos.removeWhere((todo) => todo['id'] == todoId);
            _isDeleting = false;
          });
          
          // Setelah update UI, lakukan refresh data dari server
          _fetchTodosAndTasks();
          
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Todo berhasil dihapus')));
        } else {
          setState(() {
            _isDeleting = false;
          });
        }
      }
    } catch (e) {
      if (stateManager.mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error menghapus todo: $e')));
      }
    }
  }

  // Delete multiple todos dengan loading screen
  Future<void> _deleteMultipleTodos() async {
    if (!stateManager.mounted) return;

    if (stateManager.selectedTodoIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada todo yang dipilih')),
      );
      return;
    }

    // Tampilkan loading screen
    setState(() {
      _isDeleting = true;
    });

    try {
      final result = await TodoService.deleteMultipleTodos(
        List<int>.from(stateManager.selectedTodoIds),
      );

      if (!stateManager.mounted) return;

      // Update state secara lokal untuk menghindari permintaan tambahan
      setState(() {
        stateManager.todos.removeWhere(
          (todo) => stateManager.selectedTodoIds.contains(todo['id'])
        );
        stateManager.isInSelectionMode = false;
        stateManager.selectedTodoIds.clear();
        _isDeleting = false;
      });
      
      // Setelah update UI, lakukan refresh data dari server
      _fetchTodosAndTasks();

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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Gagal menghapus todo')));
      }
    } catch (e) {
      if (stateManager.mounted) {
        setState(() {
          _isDeleting = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error menghapus todo: $e')));
      }
    }
  }

  // Show add todo bottom sheet
  void _showAddTodoBottomSheet() {
    if (!stateManager.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) => AddTodoPage(
        onTodoAdded: (todoData) async {
          try {
            final success = await TodoService.createTodo(todoData);

            if (success) {
              if (Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }

              if (stateManager.mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (stateManager.mounted) {
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

  // Navigate to detail page
  void _navigateToDetailPage(Map<String, dynamic> todo) {
    if (!stateManager.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailTodoPage(
          todoId: todo['id'],
          todoTitle: todo['title'],
          taskCount: todo['taskCount'],
          todoColor: todo['color'],
          onTodoUpdated: _fetchTodosAndTasks,
        ),
      ),
    );
  }

  // Toggle selection mode
  void _toggleSelectionMode() {
    if (!stateManager.mounted) return;

    setState(() {
      stateManager.isInSelectionMode = !stateManager.isInSelectionMode;
      stateManager.selectedTodoIds.clear();
    });
  }

  // Show delete confirmation dialog
  void _showDeleteDialog(int todoId) {
    if (!stateManager.mounted) return;

    showDialog(
      context: context,
      builder: (context) => TodoDeleteDialog(
        isSingleTodo: true,
        onDelete: () {
          Navigator.pop(context);
          _deleteTodo(todoId);
        },
      ),
    );
  }

  // Show multiple delete confirmation
  void _showMultiDeleteDialog() {
    if (!stateManager.mounted) return;

    showDialog(
      context: context,
      builder: (context) => TodoDeleteDialog(
        isSingleTodo: false,
        count: stateManager.selectedTodoIds.length,
        onDelete: () {
          Navigator.pop(context);
          _deleteMultipleTodos();
        },
      ),
    );
  }

  // Method untuk manual menampilkan coach mark
  void _showCoachMark() {
    if (_coachMark != null) {
      // Reset status untuk menampilkan ulang
      if (!TESTING_MODE) {
        TodoCoachMark.resetCoachMarkStatus().then((_) {
          _coachMark!.showCoachMark();
        });
      } else {
        _coachMark!.showCoachMark();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FE),
      // Stack untuk loading screen
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header dengan GlobalKey untuk coach mark
                Padding(
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
                          if (stateManager.isInSelectionMode)
                            Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Text(
                                '${stateManager.selectedTodoIds.length} dipilih',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          InkWell(
                            key: _deleteKey, // GlobalKey untuk coach mark
                            onTap: _toggleSelectionMode,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: stateManager.isInSelectionMode
                                    ? const Color(0xFFEEE8F8)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                stateManager.isInSelectionMode ? Icons.close : Icons.delete_outline,
                                size: 24,
                                color: stateManager.isInSelectionMode
                                    ? const Color(0xFF8B7DFA)
                                    : Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            key: _addKey, // GlobalKey untuk coach mark
                            onTap: stateManager.isInSelectionMode ? null : _showAddTodoBottomSheet,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: stateManager.isInSelectionMode
                                    ? Colors.grey.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 24,
                                color: stateManager.isInSelectionMode ? Colors.grey : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Search Bar dengan GlobalKey untuk coach mark
                Padding(
                  key: _searchKey, // GlobalKey untuk coach mark
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: TextField(
                    controller: stateManager.searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari Task....',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: stateManager.searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                stateManager.searchController.clear();
                                stateManager.searchTasks('', setState);
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
                      stateManager.searchTasks(value, setState);
                    },
                  ),
                ),
                
                // Main Content
                Expanded(
                  child: stateManager.isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : stateManager.errorMessage != null 
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: ${stateManager.errorMessage}'),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _fetchTodosAndTasks,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : stateManager.isSearching 
                        ? TodoSearchResults(
                            searchResults: stateManager.searchResults,
                            searchText: stateManager.searchController.text,
                            todos: stateManager.todos,
                            onTodoTap: _navigateToDetailPage,
                          )
                        : stateManager.todos.isEmpty 
                          ? const TodoEmptyState()
                          : TodoGrid(
                              todos: stateManager.todos,
                              isInSelectionMode: stateManager.isInSelectionMode,
                              selectedTodoIds: stateManager.selectedTodoIds,
                              onTodoTap: (todo) {
                                if (stateManager.isInSelectionMode) {
                                  setState(() {
                                    final todoId = todo['id'];
                                    if (stateManager.selectedTodoIds.contains(todoId)) {
                                      stateManager.selectedTodoIds.remove(todoId);
                                    } else {
                                      stateManager.selectedTodoIds.add(todoId);
                                    }
                                  });
                                } else {
                                  _navigateToDetailPage(todo);
                                }
                              },
                              onTodoLongPress: (todo) {
                                if (!stateManager.isInSelectionMode) {
                                  setState(() {
                                    stateManager.isInSelectionMode = true;
                                    stateManager.selectedTodoIds.add(todo['id']);
                                  });
                                }
                              },
                              onTodoMenuPressed: _showDeleteDialog,
                            ),
                ),
                
                // Navigation Bar
                const Navbar(initialActiveIndex: 1),
              ],
            ),
          ),
          
          // Loading overlay saat proses penghapusan
          if (_isDeleting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 20),
                        Text(
                          'Menghapus Todo...',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      
      // Floating Action Button for multiple delete
      floatingActionButton: stateManager.isInSelectionMode && stateManager.selectedTodoIds.isNotEmpty
          ? TodoSelectionFAB(
              selectedCount: stateManager.selectedTodoIds.length,
              onPressed: _showMultiDeleteDialog,
            )
          : null,
    );
  }
}