import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tasca_mobile1/providers/task_provider.dart';
import 'package:tasca_mobile1/services/calendar_service.dart' as calendar_service;
import 'package:tasca_mobile1/widgets/navbar.dart';
import 'package:tasca_mobile1/widgets/calendar/calendar_coach_mark.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with WidgetsBindingObserver {
  late DateTime _selectedMonth;
  late DateTime _focusedDay;
  bool _initialized = false;

  // Global keys untuk coach mark
  final GlobalKey _monthNavigationKey = GlobalKey();
  final GlobalKey _refreshButtonKey = GlobalKey();
  final GlobalKey _calendarGridKey = GlobalKey();
  final GlobalKey _tasksListKey = GlobalKey();

  // Coach mark manager
  CalendarCoachMark? _coachMark;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _focusedDay = DateTime.now();

    // Tambahkan observer untuk mendeteksi aplikasi kembali dari background
    WidgetsBinding.instance.addObserver(this);

    // Inisialisasi coach mark setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCoachMark();
    });
  }

  @override
  void dispose() {
    // Hapus observer saat widget dihancurkan
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ketika aplikasi kembali ke foreground, periksa apakah data perlu di-refresh
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          taskProvider.dataChanged = true;
          taskProvider.fetchTasksForDate(_focusedDay);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initializeScreen();
      _initialized = true;
    }
  }

  void _initializeScreen() {
    // Get the provider and initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.setSelectedDate(_focusedDay);
      taskProvider.fetchTasksForMonth(_selectedMonth);

      // Mulai background fetching untuk bulan sebelumnya dan berikutnya
      taskProvider.prefetchAdjacentMonths();
    });
  }

  // Inisialisasi coach mark
  void _initCoachMark() {
    _coachMark = CalendarCoachMark(
      context: context,
      monthNavigationKey: _monthNavigationKey,
      refreshButtonKey: _refreshButtonKey,
      calendarGridKey: _calendarGridKey,
      tasksListKey: _tasksListKey,
    );

    _coachMark?.showCoachMarkIfNeeded();
  }

  // Method untuk menampilkan coach mark saat tombol bantuan diklik
  void _showCoachMark() {
    if (_coachMark != null) {
      CalendarCoachMark.resetCoachMarkStatus().then((_) {
        _coachMark!.showCoachMark();
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
    });

    // Pindahkan ke post-frame callback untuk menghindari rebuild saat build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Update tasks for the month using provider
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.fetchTasksForMonth(_selectedMonth);

      // Update focused day to first day of month
      setState(() {
        _focusedDay = _selectedMonth;
      });
      taskProvider.setSelectedDate(_focusedDay);

      // Prefetch bulan selanjutnya (bulan sebelumnya lagi)
      final prevPrevMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
        1,
      );
      taskProvider.backgroundFetchForMonth(prevPrevMonth);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.fetchTasksForMonth(_selectedMonth);

      setState(() {
        _focusedDay = _selectedMonth;
      });
      taskProvider.setSelectedDate(_focusedDay);

      // Prefetch bulan selanjutnya (bulan berikutnya lagi)
      final nextNextMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        1,
      );
      taskProvider.backgroundFetchForMonth(nextNextMonth);
    });
  }

  List<DateTime> _getDaysInMonth() {
    final daysInMonth = calendar_service.DateUtils.getDaysInMonth(
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
    final daysInPreviousMonth = calendar_service.DateUtils.getDaysInMonth(
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

    // Listen to the task provider
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasksByDate = taskProvider.tasksByDate;
        final currentDayTasks = taskProvider.currentDayTasks;
        final isLoading = taskProvider.isLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F1FE),
          body: SafeArea(
            child: Column(
              children: [
                // Calendar Card and Tasks List
                Expanded(
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
                          child: Stack(
                            children: [
                              // Background calendar image - positioned inside the card
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Opacity(
                                  opacity: 0.3,
                                  child: Image.asset(
                                    'images/kalender.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),

                              // Calendar content
                              Column(
                                children: [
                                  // Month Navigation with loading indicator
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 10.0,
                                    ),
                                    child: Row(
                                      key: _monthNavigationKey,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.chevron_left),
                                          onPressed: _previousMonth,
                                        ),

                                        // Center section with month title and optional loading spinner
                                        Row(
                                          children: [
                                            Text(
                                              monthFormat.format(_selectedMonth),
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            // Small loading indicator next to month name when background fetching
                                            if (taskProvider.isBackgroundFetching)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                ),
                                                child: SizedBox(
                                                  height: 14,
                                                  width: 14,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.purple.withOpacity(0.5),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),

                                        IconButton(
                                          icon: const Icon(Icons.chevron_right),
                                          onPressed: _nextMonth,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Pull to Refresh Indicator
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          key: _refreshButtonKey,
                                          onTap: () {
                                            // Manual refresh functionality
                                            final taskProvider = Provider.of<TaskProvider>(
                                              context,
                                              listen: false,
                                            );
                                            taskProvider.dataChanged = true;
                                            taskProvider.fetchTasksForDate(
                                              _focusedDay,
                                            );
                                            taskProvider.fetchTasksForMonth(
                                              _selectedMonth,
                                            );

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Refreshing calendar data...',
                                                ),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.purple.withOpacity(
                                                0.1,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                20,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.refresh,
                                                  size: 12,
                                                  color: Colors.purple,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  'Tap to refresh',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    color: Colors.purple,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Days of Week Headers
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                            'Sun',
                                            'Mon',
                                            'Tue',
                                            'Wed',
                                            'Thu',
                                            'Fri',
                                            'Sat',
                                          ]
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
                                    child: Container(
                                      key: _calendarGridKey,
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
                                          final isSelected = _focusedDay.year == day.year &&
                                              _focusedDay.month == day.month &&
                                              _focusedDay.day == day.day;
                                          final dateKey = DateTime(
                                            day.year,
                                            day.month,
                                            day.day,
                                          );
                                          final tasksForDay = tasksByDate[dateKey] ?? [];

                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _focusedDay = day;
                                              });
                                              // Use provider to update selected date and fetch tasks
                                              taskProvider.setSelectedDate(day);
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
                                                          isSelected ? FontWeight.bold : FontWeight.normal,
                                                      color: isCurrentMonth
                                                          ? (isSelected ? Colors.purple : Colors.black)
                                                          : Colors.grey[400],
                                                    ),
                                                  ),
                                                  if (tasksForDay.isNotEmpty)
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
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
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tasks List
                      Expanded(
                        flex: 3,
                        child: Container(
                          key: _tasksListKey,
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
                                child: isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.purple,
                                          ),
                                        ),
                                      )
                                    : currentDayTasks.isEmpty
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
                                            itemCount: currentDayTasks.length,
                                            itemBuilder: (context, index) {
                                              final task = currentDayTasks[index];
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
                                                    color: task.isComplete ? Colors.green : Colors.grey,
                                                  ),
                                                  title: Text(
                                                    task.title,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                      decoration: task.isComplete
                                                          ? TextDecoration.lineThrough
                                                          : null,
                                                      color:
                                                          task.isComplete ? Colors.grey : Colors.black,
                                                    ),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                                              color: task.isComplete
                                                                  ? Colors.grey
                                                                  : Colors.black54,
                                                            ),
                                                          ),
                                                        ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: _getPriorityColor(
                                                                task.priority,
                                                              ),
                                                              borderRadius: BorderRadius.circular(
                                                                16,
                                                              ),
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
                                                              'HH:mm',
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
                    ],
                  ),
                ),

                // Tombol Bantuan
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: _showCoachMark,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.help_outline,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Bantuan',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Navbar
                const Navbar(initialActiveIndex: 4),
              ],
            ),
          ),
        );
      },
    );
  }

  // Priority color and label methods remain the same
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