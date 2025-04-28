import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:tasca_mobile1/services/calendar_service.dart';
import 'package:tasca_mobile1/widgets/navbar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedMonth;
  late DateTime _focusedDay;
  List<Task> _tasks = [];
  bool _isTaskLoading = false;
  Map<DateTime, List<Task>> _monthTasks = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _focusedDay = DateTime.now();
    _initializeScreen();
  }

  void _initializeScreen() {
    _fetchTasksForMonth();
    _fetchTasksForDay();
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
      _fetchTasksForMonth();
      _fetchTasksForDay(); // Fetch tasks for the first day of the new month
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
      _fetchTasksForMonth();
      _fetchTasksForDay(); // Fetch tasks for the first day of the new month
    });
  }

  Future<void> _fetchTasksForMonth() async {
    try {
      final monthTasks = await CalendarService().fetchTasksForMonth(
        _selectedMonth,
      );

      setState(() {
        _monthTasks = monthTasks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading monthly tasks: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchTasksForDay() async {
    setState(() {
      _isTaskLoading = true;
      _tasks = [];
    });

    try {
      final tasksForDay = await CalendarService().fetchTasksByDate(_focusedDay);

      setState(() {
        _tasks = tasksForDay;
        _isTaskLoading = false;
      });
    } catch (e) {
      setState(() {
        _isTaskLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error loading daily tasks: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<DateTime> _getDaysInMonth() {
    final daysInMonth = DateUtils.getDaysInMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    final firstDayOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month,
      1,
    );
    final firstDayWeekday = firstDayOfMonth.weekday % 7;

    final previousMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
      1,
    );
    final daysInPreviousMonth = DateUtils.getDaysInMonth(
      previousMonth.year,
      previousMonth.month,
    );

    List<DateTime> days = [];

    // Add days from previous month
    for (int i = 0; i < firstDayWeekday; i++) {
      days.add(
        DateTime(
          previousMonth.year,
          previousMonth.month,
          daysInPreviousMonth - firstDayWeekday + i + 1,
        ),
      );
    }

    // Add days of current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_selectedMonth.year, _selectedMonth.month, i));
    }

    // Add days from next month
    final remainingDays = 42 - days.length;
    final nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      1,
    );

    for (int i = 1; i <= remainingDays; i++) {
      days.add(DateTime(nextMonth.year, nextMonth.month, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth();
    final monthFormat = DateFormat('MMMM, yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1FE),
      body: SafeArea(
        child: Column(
          children: [
            // Calendar Card
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Month Navigation
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _previousMonth,
                          ),
                          Text(
                            monthFormat.format(_selectedMonth),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                    ),

                    // Days of Week Headers
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:
                            ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                                .map(
                                  (day) => Text(
                                    day,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),

                    // Calendar Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              mainAxisSpacing: 4,
                              crossAxisSpacing: 4,
                              childAspectRatio: 1,
                            ),
                        itemCount: days.length,
                        itemBuilder: (context, index) {
                          final day = days[index];
                          final isCurrentMonth =
                              day.month == _selectedMonth.month;
                          final isSelected =
                              _focusedDay.year == day.year &&
                              _focusedDay.month == day.month &&
                              _focusedDay.day == day.day;
                          final dateKey = DateTime(
                            day.year,
                            day.month,
                            day.day,
                          );
                          final tasksForDay = _monthTasks[dateKey] ?? [];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _focusedDay = day;
                              });
                              _fetchTasksForDay();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.purple[100] : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    day.day.toString(),
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isCurrentMonth
                                              ? (isSelected
                                                  ? Colors.purple
                                                  : Colors.black)
                                              : Colors.grey[400],
                                    ),
                                  ),
                                  if (tasksForDay.isNotEmpty)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.purple,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          tasksForDay.length.toString(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: Colors.purple,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tasks List
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Tasks for ${DateFormat('dd MMM yyyy').format(_focusedDay)}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          _isTaskLoading
                              ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.purple,
                                  ),
                                ),
                              )
                              : _tasks.isEmpty
                              ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'No Tasks',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Create a new task for this day',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: _tasks.length,
                                itemBuilder: (context, index) {
                                  final task = _tasks[index];
                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(12),
                                      leading: Icon(
                                        task.isComplete
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color:
                                            task.isComplete
                                                ? Colors.green
                                                : Colors.grey,
                                      ),
                                      title: Text(
                                        task.title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              task.isComplete
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                          color:
                                              task.isComplete
                                                  ? Colors.grey
                                                  : Colors.black,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (task.description.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 8.0,
                                              ),
                                              child: Text(
                                                task.description,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color:
                                                      task.isComplete
                                                          ? Colors.grey
                                                          : Colors.black54,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getPriorityColor(
                                                    task.priority,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  _getPriorityLabel(
                                                    task.priority,
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                DateFormat(
                                                  'HH: mm',
                                                ).format(task.deadline),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Bar
            const Navbar(initialActiveIndex: 4),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 0:
        return 'Rendah';
      case 1:
        return 'Sedang';
      case 2:
        return 'Tinggi';
      case 3:
        return 'Sangat Tinggi';
      default:
        return 'Tidak Diketahui';
    }
  }
}

class DateUtils {
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
