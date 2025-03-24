import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_task.dart';

class DetailTodoPage extends StatefulWidget {
  final int todoId;
  final String todoTitle;
  final Function? onTodoUpdated; // Callback untuk ketika todo diperbarui

  const DetailTodoPage({
    Key? key,
    required this.todoId,
    required this.todoTitle,
    this.onTodoUpdated,
  }) : super(key: key);

  @override
  _DetailTodoPageState createState() => _DetailTodoPageState();
}

class _DetailTodoPageState extends State<DetailTodoPage> {
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      debugPrint('Fetching tasks for todo ID: ${widget.todoId}');
      
      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/todos/${widget.todoId}/tasks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Tasks API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        debugPrint('Tasks API response: $responseBody');
        
        setState(() {
          tasks = responseBody['data'] ?? [];
          _completedTasks =
              tasks.where((task) => task['is_complete'] == true).length;
          _isLoading = false;
        });
        
        debugPrint('Loaded ${tasks.length} tasks, $_completedTasks completed');
        
        // Update parent todo list jika callback ada
        if (widget.onTodoUpdated != null) {
          widget.onTodoUpdated!();
        }
      } else {
        throw Exception('Failed to load tasks: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Update judul todo
  Future<void> _updateTodoTitle(String newTitle) async {
    if (newTitle.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Judul tidak boleh kosong')));
      return;
    }

    setState(() {
      _isSavingTitle = true;
    });

    // Buat instance client yang akan digunakan dan ditutup nanti
    final client = http.Client();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      // URL untuk update todo
      final url = 'https://api.tascaid.com/api/todos/${widget.todoId}/';
      final requestBody = {'title': newTitle};

      debugPrint('Update Todo - URL: $url');
      debugPrint('Update Todo - Body: ${json.encode(requestBody)}');

      // Buat request PATCH
      final request = http.Request('PATCH', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/json';
      request.body = json.encode(requestBody);

      // Kirim request dan dapatkan stream response
      final streamedResponse = await client.send(request);

      http.Response response;

      // Jika mendapat redirect, ikuti secara manual dengan mempertahankan metode PATCH
      if (streamedResponse.statusCode == 307) {
        final redirectUrl = streamedResponse.headers['location'];
        if (redirectUrl != null) {
          debugPrint('Redirecting PATCH to: $redirectUrl');

          // Handle URL absolut dan relatif
          Uri redirectUri;
          if (redirectUrl.startsWith('http')) {
            // URL absolut
            redirectUri = Uri.parse(redirectUrl);
          } else {
            // URL relatif - perlu kombinasikan dengan base URL
            final baseUri = Uri.parse(url);
            final baseUrl = '${baseUri.scheme}://${baseUri.host}';

            // Hapus slash di awal jika ada pada keduanya
            final cleanRedirectUrl =
                redirectUrl.startsWith('/')
                    ? redirectUrl.substring(1)
                    : redirectUrl;
            redirectUri = Uri.parse('$baseUrl/$cleanRedirectUrl');
          }

          debugPrint('Full redirect URL: $redirectUri');

          final redirectRequest = http.Request('PATCH', redirectUri);
          redirectRequest.headers['Authorization'] = 'Bearer $token';
          redirectRequest.headers['Content-Type'] = 'application/json';
          redirectRequest.body = json.encode(requestBody);

          final redirectResponse = await client.send(redirectRequest);
          response = await http.Response.fromStream(redirectResponse);
        } else {
          // Jika tidak ada header lokasi, gunakan response asli
          response = await http.Response.fromStream(streamedResponse);
        }
      } else {
        // Jika tidak ada redirect, dapatkan response
        response = await http.Response.fromStream(streamedResponse);
      }

      debugPrint('Update Todo Response Status: ${response.statusCode}');
      debugPrint('Update Todo Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() {
          _currentTitle = newTitle;
          _isEditingTitle = false;
        });
        
        // Trigger callback untuk update parent jika ada
        if (widget.onTodoUpdated != null) {
          widget.onTodoUpdated!();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Judul todo berhasil diperbarui')),
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
      debugPrint('Update Todo Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      // Reset ke judul sebelumnya
      _titleController.text = _currentTitle;
    } finally {
      setState(() {
        _isSavingTitle = false;
      });
      // Selalu tutup client setelah selesai
      client.close();
    }
  }

  // Metode untuk menghapus todo saat ini
  Future<void> _deleteTodo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      // Debug print untuk URL
      final url = 'https://api.tascaid.com/api/todos/${widget.todoId}/';
      debugPrint('Attempting to delete todo with URL: $url');

      // Buat instance client yang akan digunakan dan ditutup nanti
      final client = http.Client();

      try {
        // Buat request DELETE
        final request = http.Request('DELETE', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] = 'application/json';

        // Kirim request dan dapatkan stream response
        final streamedResponse = await client.send(request);
        
        // Dapatkan response lengkap
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint('Delete Todo Response Status: ${response.statusCode}');
        debugPrint('Delete Todo Response Body: ${response.body}');

        if (response.statusCode >= 200 && response.statusCode < 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Todo berhasil dihapus')),
          );
          
          // Trigger callback untuk update parent jika ada
          if (widget.onTodoUpdated != null) {
            widget.onTodoUpdated!();
          }
          
          // Kembali ke layar sebelumnya
          Navigator.pop(context);
        } else {
          // Coba cara alternatif jika metode pertama gagal
          // Coba URL tanpa trailing slash
          final alternativeUrl = 'https://api.tascaid.com/api/todos/${widget.todoId}';
          debugPrint('Trying alternative URL: $alternativeUrl');
          
          final alternativeResponse = await http.delete(
            Uri.parse(alternativeUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          
          debugPrint('Alternative Delete Response Status: ${alternativeResponse.statusCode}');
          
          if (alternativeResponse.statusCode >= 200 && alternativeResponse.statusCode < 300) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Todo berhasil dihapus')),
            );
            
            // Trigger callback untuk update parent jika ada
            if (widget.onTodoUpdated != null) {
              widget.onTodoUpdated!();
            }
            
            // Kembali ke layar sebelumnya
            Navigator.pop(context);
          } else {
            throw Exception('Gagal menghapus todo: Status ${response.statusCode}, ${response.body}');
          }
        }
      } finally {
        // Selalu tutup client setelah selesai
        client.close();
      }
    } catch (e) {
      debugPrint('Error deleting todo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menghapus todo: $e')),
      );
    }
  }

  // Tampilkan dialog konfirmasi hapus
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Todo'),
          content: Text('Apakah Anda yakin ingin menghapus todo ini dan semua task-nya?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
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

  // Tampilkan menu opsi ketika tombol more diklik
  void _showMoreOptions() {
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
              title: Text('Hapus Todo', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                _showDeleteConfirmation();
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Batal'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
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
            // Trigger callback untuk update parent jika ada
            if (widget.onTodoUpdated != null) {
              widget.onTodoUpdated!();
            }
          },
        ),
      ),
    ).then((_) {
      // Refresh tasks saat kembali dari layar add task
      _fetchTodoTasks();
      // Juga refresh parent list
      if (widget.onTodoUpdated != null) {
        widget.onTodoUpdated!();
      }
    });
  }

  Future<void> _toggleTaskCompletion(int taskId, bool currentStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      final response = await http.patch(
        Uri.parse(
          'https://api.tascaid.com/api/todos/${widget.todoId}/tasks/$taskId/complete',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'is_complete': !currentStatus}),
      );

      if (response.statusCode == 200) {
        await _fetchTodoTasks();
        
        // Trigger callback untuk update parent jika ada
        if (widget.onTodoUpdated != null) {
          widget.onTodoUpdated!();
        }
      } else {
        throw Exception('Failed to update task: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Metode baru untuk menghapus task
  Future<void> _deleteTask(int taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('No JWT token found');
      }

      // Debug print untuk URL
      final url = 'https://api.tascaid.com/api/todos/${widget.todoId}/tasks/$taskId/';
      debugPrint('Attempting to delete task with URL: $url');

      // Buat instance client
      final client = http.Client();

      try {
        // Buat request DELETE
        final request = http.Request('DELETE', Uri.parse(url));
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Content-Type'] = 'application/json';

        // Kirim request dan dapatkan stream response
        final streamedResponse = await client.send(request);
        
        // Dapatkan response lengkap
        final response = await http.Response.fromStream(streamedResponse);

        debugPrint('Delete Task Response Status: ${response.statusCode}');
        
        if (response.statusCode >= 200 && response.statusCode < 300) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Task berhasil dihapus')),
          );
          
          // Refresh daftar task
          await _fetchTodoTasks();
          
          // Trigger callback untuk update parent
          if (widget.onTodoUpdated != null) {
            widget.onTodoUpdated!();
          }
        } else {
          // Coba cara alternatif jika metode pertama gagal
          // Coba URL tanpa trailing slash
          final alternativeUrl = 'https://api.tascaid.com/api/todos/${widget.todoId}/tasks/$taskId';
          debugPrint('Trying alternative URL for task deletion: $alternativeUrl');
          
          final alternativeResponse = await http.delete(
            Uri.parse(alternativeUrl),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          
          debugPrint('Alternative Delete Response Status: ${alternativeResponse.statusCode}');
          
          if (alternativeResponse.statusCode >= 200 && alternativeResponse.statusCode < 300) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Task berhasil dihapus')),
            );
            
            // Refresh daftar task
            await _fetchTodoTasks();
            
            // Trigger callback untuk update parent
            if (widget.onTodoUpdated != null) {
              widget.onTodoUpdated!();
            }
          } else {
            throw Exception('Gagal menghapus task: Status ${response.statusCode}');
          }
        }
      } finally {
        // Selalu tutup client setelah selesai
        client.close();
      }
    } catch (e) {
      debugPrint('Error deleting task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error menghapus task: $e')),
      );
    }
  }

  // Tampilkan dialog konfirmasi hapus task
  void _showDeleteTaskConfirmation(int taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Task'),
          content: Text('Apakah Anda yakin ingin menghapus task ini?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask(taskId);
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDeadline(String? deadlineStr) {
    if (deadlineStr == null) return '';

    try {
      DateTime deadline = DateTime.parse(deadlineStr);
      DateTime now = DateTime.now();

      if (deadline.year == now.year &&
          deadline.month == now.month &&
          deadline.day == now.day) {
        return 'Today, ${DateFormat('HH:mm').format(deadline)}';
      }

      // Check if it's a past date
      if (deadline.isBefore(now)) {
        final difference = now.difference(deadline);

        if (difference.inDays < 30) {
          // Within a month, show days ago
          return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago, ${DateFormat('HH:mm').format(deadline)}';
        } else {
          // More than a month ago, show full date
          return DateFormat('d MMM yyyy, HH:mm').format(deadline);
        }
      } else {
        // Future date, show full date
        return DateFormat('d MMM yyyy, HH:mm').format(deadline);
      }
    } catch (e) {
      debugPrint('Error parsing deadline: $e');
      return deadlineStr; // Return original string if parsing fails
    }
  }

  // Warna background untuk action hapus dalam swipe
  Color _getDeleteBackgroundColor() {
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    // Hitung persentase penyelesaian dengan aman
    double completionPercentage = 0;
    if (tasks.isNotEmpty) {
      completionPercentage = (_completedTasks / tasks.length) * 100;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.red,
            pinned: true,
            expandedHeight: 150,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditingTitle = true;
                        _titleController.text = _currentTitle;
                        // Pastikan text field mendapat fokus dan kursor di akhir
                        Future.delayed(Duration(milliseconds: 50), () {
                          _titleController
                              .selection = TextSelection.fromPosition(
                            TextPosition(offset: _titleController.text.length),
                          );
                        });
                      });
                    },
                    child:
                        _isEditingTitle
                            ? Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: 40,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _titleController,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 8,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.white,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
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
                                      icon: Icon(
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                  SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: completionPercentage / 100,
                    backgroundColor: Colors.red.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${tasks.length} ${tasks.length == 1 ? "task" : "tasks"} • ${completionPercentage.toStringAsFixed(0)}% Completed',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              centerTitle: false,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.white),
                onPressed: _showMoreOptions,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _navigateToAddTask,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, color: Colors.grey),
                          SizedBox(width: 10),
                          Text(
                            'Add New Task...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(child: Text('Error: $_errorMessage'))
                      : tasks.isEmpty
                      ? Center(child: Text('No tasks yet'))
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Dismissible(
                            // Key unik untuk Dismissible
                            key: Key('task-${task['id']}'),
                            
                            // Hanya izinkan swipe dari kanan ke kiri (untuk delete)
                            direction: DismissDirection.endToStart,
                            
                            // Background yang tampil saat swipe
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20.0),
                              decoration: BoxDecoration(
                                color: _getDeleteBackgroundColor(),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Yang terjadi saat dismissed (diswipe)
                            confirmDismiss: (direction) async {
                              // Tampilkan dialog konfirmasi sebelum menghapus
                              bool confirmDelete = false;
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Hapus Task'),
                                    content: Text('Apakah Anda yakin ingin menghapus task ini?'),
                                    actions: [
                                      TextButton(
                                        child: Text('Batal'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          confirmDelete = false;
                                        },
                                      ),
                                      TextButton(
                                        child: Text(
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
                            
                            // Yang terjadi setelah dismissal dikonfirmasi
                            onDismissed: (direction) {
                              _deleteTask(task['id']);
                            },
                            
                            // Card task yang sebenarnya
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to edit task
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTaskPage(
                                      todoId: widget.todoId,
                                      taskId: task['id'],
                                      initialData: task,
                                      onTaskAdded: () {
                                        _fetchTodoTasks();
                                        // Also update the parent todo list
                                        if (widget.onTodoUpdated != null) {
                                          widget.onTodoUpdated!();
                                        }
                                      },
                                    ),
                                  ),
                                ).then((_) {
                                  // Refresh tasks when returning from edit screen
                                  _fetchTodoTasks();
                                  // Juga refresh parent list
                                  if (widget.onTodoUpdated != null) {
                                    widget.onTodoUpdated!();
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade200,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _toggleTaskCompletion(
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
                                            color:
                                                task['is_complete']
                                                    ? Colors.green
                                                    : Colors.grey.shade300,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task['title'] ?? 'Unnamed Task',
                                            style: TextStyle(
                                              decoration:
                                                  task['is_complete']
                                                      ? TextDecoration.lineThrough
                                                      : null,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (task['deadline'] != null)
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.pink.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    _formatDeadline(
                                                      task['deadline'],
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.pink,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
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