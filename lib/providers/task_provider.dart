import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:tasca_mobile1/services/calendar_service.dart';

class TaskProvider extends ChangeNotifier {
  Map<DateTime, List<Task>> _tasksByDate = {};
  List<Task> _currentDayTasks = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;
  
  // Status untuk background fetching
  bool _isBackgroundFetching = false;
  bool get isBackgroundFetching => _isBackgroundFetching;
  
  // Status untuk tracking apakah data sudah di-fetch
  final Set<String> _fetchedMonths = {};
  final Set<String> _fetchedDates = {};
  
  // Flag untuk menandai apakah ada perubahan data
  bool _dataChanged = false;
  
  Map<DateTime, List<Task>> get tasksByDate => _tasksByDate;
  List<Task> get currentDayTasks => _currentDayTasks;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  final CalendarService _calendarService = CalendarService();
  
  // Setter untuk flag perubahan data
  set dataChanged(bool value) {
    _dataChanged = value;
  }
  
  // Mendapatkan key untuk tracking bulan yang sudah di-fetch
  String _getMonthKey(DateTime date) {
    return '${date.year}-${date.month}';
  }
  
  // Mendapatkan key untuk tracking tanggal yang sudah di-fetch
  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Method to set selected date and fetch tasks for that date
  Future<void> setSelectedDate(DateTime date) async {
    _selectedDate = date;
    
    // Memanggil fetchTasksForDate terpisah untuk mencegah notifyListeners berulang
    await fetchTasksForDate(date);
  }
  
  // Fetch tasks for specific date, dengan optimasi cache
  Future<void> fetchTasksForDate(DateTime date) async {
    final dateKey = _getDateKey(date);
    
    // Jika data sudah di-fetch dan tidak ada perubahan, skip fetch
    if (_fetchedDates.contains(dateKey) && !_dataChanged) {
      // Gunakan data yang sudah ada di cache
      final formattedDate = DateTime(date.year, date.month, date.day);
      final cachedTasks = _calendarService.getCachedTasks(formattedDate);
      if (cachedTasks != null) {
        _currentDayTasks = cachedTasks;
        notifyListeners();
        return;
      }
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Check if tasks are in cache
      final cachedTasks = _calendarService.getCachedTasks(date);
      if (cachedTasks != null && !_dataChanged) {
        _currentDayTasks = cachedTasks;
        _isLoading = false;
        _fetchedDates.add(dateKey);
        notifyListeners();
        return;
      }
      
      // Otherwise fetch from API
      final tasks = await _calendarService.fetchTasksByDate(date);
      _currentDayTasks = tasks;
      
      // Update the map
      final formattedDate = DateTime(date.year, date.month, date.day);
      _tasksByDate[formattedDate] = tasks;
      
      _isLoading = false;
      _fetchedDates.add(dateKey);
      _dataChanged = false; // Reset flag perubahan data
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch tasks for month, dengan optimasi cache
  Future<void> fetchTasksForMonth(DateTime month) async {
    final monthKey = _getMonthKey(month);
    
    // Jika data bulan sudah di-fetch dan tidak ada perubahan, skip fetch
    if (_fetchedMonths.contains(monthKey) && !_dataChanged) {
      return;
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final monthTasks = await _calendarService.fetchTasksForMonth(month);
      _tasksByDate.addAll(monthTasks);
      _isLoading = false;
      _fetchedMonths.add(monthKey);
      _dataChanged = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Method to sync after task modifications (called after add, edit, delete)
  // Menggunakan Future.microtask untuk menghindari rebuild saat build
  Future<void> syncTaskChanges() async {
    _dataChanged = true;
    
    Future.microtask(() async {
      final selectedDateKey = _getDateKey(_selectedDate);
      _fetchedDates.remove(selectedDateKey);
      _calendarService.clearCache();
      
      _isLoading = true;
      notifyListeners();
      
      try {
        final tasks = await _calendarService.fetchTasksByDate(_selectedDate);
        
        _currentDayTasks = tasks;
        final formattedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        _tasksByDate[formattedDate] = tasks;
        _error = null;
        
        _fetchedDates.add(selectedDateKey);
      } catch (e) {
        _error = e.toString();
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }
  
  // Background fetching untuk bulan tertentu
  Future<void> backgroundFetchForMonth(DateTime month) async {
    if (_isBackgroundFetching) return; // Mencegah multiple requests
    
    final monthKey = _getMonthKey(month);
    
    // Jika data bulan sudah di-fetch dan tidak ada perubahan, skip fetch
    if (_fetchedMonths.contains(monthKey) && !_dataChanged) {
      return;
    }
    
    _isBackgroundFetching = true;
    notifyListeners();
    
    try {
      // Fetch data bulan ini
      final monthTasks = await _calendarService.fetchTasksForMonth(month);
      
      _tasksByDate.addAll(monthTasks);
      
      _fetchedMonths.add(monthKey);
      
      if (month.year == _selectedDate.year && month.month == _selectedDate.month) {
        final dateKey = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
        if (monthTasks.containsKey(dateKey)) {
          _currentDayTasks = monthTasks[dateKey]!;
        }
      }
      
      _isBackgroundFetching = false;
      notifyListeners();
    } catch (e) {
      _isBackgroundFetching = false;
    }
  }
  
  void prefetchAdjacentMonths() {
    final thisMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    
    final prevMonth = DateTime(thisMonth.year, thisMonth.month - 1, 1);
    backgroundFetchForMonth(prevMonth);
    
    final nextMonth = DateTime(thisMonth.year, thisMonth.month + 1, 1);
    backgroundFetchForMonth(nextMonth);
  }
  
  void clearAll() {
    _tasksByDate.clear();
    _currentDayTasks.clear();
    _fetchedMonths.clear();
    _fetchedDates.clear();
    _calendarService.clearCache();
    _dataChanged = true;
    notifyListeners();
  }
}