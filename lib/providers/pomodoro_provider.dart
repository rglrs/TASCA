import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';  // Add this import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasca_mobile1/services/pomodoro.dart';

class PomodoroState {
  final int timeLeft;
  final bool isRunning;
  final bool isFocusSession;
  final bool isMuted;
  final String currentSoundTitle;
  final String currentSoundPath;
  final List<Map<String, dynamic>> tasks;
  final String? selectedTask;
  final String? errorMessage;

  PomodoroState({
    required this.timeLeft,
    required this.isRunning,
    required this.isFocusSession,
    required this.isMuted,
    required this.currentSoundTitle,
    required this.currentSoundPath,
    required this.tasks,
    required this.selectedTask,
    required this.errorMessage,
  });

  PomodoroState copyWith({
    int? timeLeft,
    bool? isRunning,
    bool? isFocusSession,
    bool? isMuted,
    String? currentSoundTitle,
    String? currentSoundPath,
    List<Map<String, dynamic>>? tasks,
    String? selectedTask,
    String? errorMessage,
  }) {
    return PomodoroState(
      timeLeft: timeLeft ?? this.timeLeft,
      isRunning: isRunning ?? this.isRunning,
      isFocusSession: isFocusSession ?? this.isFocusSession,
      isMuted: isMuted ?? this.isMuted,
      currentSoundTitle: currentSoundTitle ?? this.currentSoundTitle,
      currentSoundPath: currentSoundPath ?? this.currentSoundPath,
      tasks: tasks ?? this.tasks,
      selectedTask: selectedTask ?? this.selectedTask,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  PomodoroNotifier()
    : super(
        PomodoroState(
          timeLeft: 1500, // Default value, will be updated in init
          isRunning: false,
          isFocusSession: true,
          isMuted: true,
          currentSoundTitle: '',
          currentSoundPath: '',
          tasks: [],
          selectedTask: null,
          errorMessage: null,
        ),
      ) {
    _initNotifications();
    _loadSavedSettings();
  }

  // These will be updated from shared preferences
  int _focusDuration = 1500; 
  int _restDuration = 300;
  
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final PomodoroService _pomodoroService = PomodoroService();

  // --- INITIALIZATION ---
  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _focusDuration = prefs.getInt('focus_duration') ?? 1500;
    _restDuration = prefs.getInt('rest_duration') ?? 300;
    
    state = state.copyWith(
      timeLeft: state.isFocusSession ? _focusDuration : _restDuration,
    );
  }

  // --- NOTIFIKASI ---
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _localNotifications.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pomodoro_channel',
          'Pomodoro Notifications',
          channelDescription:
              'Notifies when Pomodoro focus or relax timer ends',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails notificationDetails =
        NotificationDetails(
          android: androidDetails,
        );
    await _localNotifications.show(0, title, body, notificationDetails);
  }

  // --- TIMER ---
  void startTimer() {
    if (state.isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        timer.cancel();
        stopSound();
        _showNotification(
          "Time's up!",
          state.isFocusSession
              ? "Time to take a break."
              : "Time to get back to focus.",
        );
        
        // Send completed session data to server
        int actualDuration = state.isFocusSession 
            ? (_focusDuration - state.timeLeft) ~/ 60
            : (_restDuration - state.timeLeft) ~/ 60;
            
        if (actualDuration > 0) {
          _sendPomodoroSession(actualDuration);
        }
        
        switchSession();
      }
    });
    
    state = state.copyWith(isRunning: true);
    if (!state.isMuted && state.currentSoundPath.isNotEmpty) {
      playSound(state.currentSoundPath, state.currentSoundTitle);
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    _audioPlayer.pause();
  }

  void resetTimer() {
    _timer?.cancel();
    stopSound();
    switchSession();
    state = state.copyWith(
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
    );
    _showNotification(
      "Session switched!",
      state.isFocusSession
          ? "Time for a focus session."
          : "Time for a relax session.",
    );
  }

  void endCurrentSession() {
    _timer?.cancel();
    stopSound();
    
    // Send completed session data to server
    int actualDuration = state.isFocusSession 
        ? (_focusDuration - state.timeLeft) ~/ 60
        : (_restDuration - state.timeLeft) ~/ 60;
        
    if (actualDuration > 0) {
      _sendPomodoroSession(actualDuration);
    }
    
    state = state.copyWith(
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
      timeLeft: state.isFocusSession ? _focusDuration : _restDuration,
    );
  }

  void switchSession() {
    bool nextFocus = !state.isFocusSession;
    state = state.copyWith(
      isFocusSession: nextFocus,
      timeLeft: nextFocus ? _focusDuration : _restDuration,
    );
  }
  
  Future<void> _sendPomodoroSession(int duration) async {
    try {
      await _pomodoroService.completePomodoroSession(duration);
    } catch (e) {
      // Handle error silently
    }
  }

  // --- SOUND ---
  void setSoundOption(String soundPath, String soundTitle) {
    state = state.copyWith(
      isMuted: false,
      currentSoundPath: soundPath,
      currentSoundTitle: soundTitle,
    );
    if (state.isRunning) {
      playSound(soundPath, soundTitle);
    }
  }

  void muteSound() {
    state = state.copyWith(
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
    );
    stopSound();
  }

  Future<void> playSound(String soundPath, String soundTitle) async {
    await _audioPlayer.stop();
    if (!state.isMuted && state.isRunning) {
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource(soundPath));
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> stopSound() async {
    await _audioPlayer.stop();
  }

  // --- TASKS & API ---
  Future<void> fetchTasks({Function? onUnauthorized}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        if (onUnauthorized != null) onUnauthorized();
        return;
      }

      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/tasks/incomplete'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> tasksData = responseBody['data'];

        state = state.copyWith(
          tasks:
              tasksData.map<Map<String, dynamic>>((task) {
                return {
                  'id': task['id'],
                  'title': task['title'] ?? 'Unnamed Task',
                };
              }).toList(),
          errorMessage: null,
        );
      } else if (response.statusCode == 401) {
        if (onUnauthorized != null) onUnauthorized();
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load incomplete tasks: ${response.body}',
        );
      }
    } on SocketException {
      state = state.copyWith(
        errorMessage: 'Kesalahan Koneksi: Periksa koneksi internet Anda.',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error fetching incomplete tasks: $e',
      );
    }
  }

  void setSelectedTask(String? taskId) {
    state = state.copyWith(selectedTask: taskId);
  }

  // Method to handle app lifecycle changes
  void handleAppLifecycleChange(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background or navigating away
      if (this.state.isRunning) {
        pauseTimer();
      }
    } else if (state == AppLifecycleState.detached) {
      // App being terminated
      int actualDuration = this.state.isFocusSession 
          ? (_focusDuration - this.state.timeLeft) ~/ 60
          : (_restDuration - this.state.timeLeft) ~/ 60;
          
      if (actualDuration > 0) {
        _sendPomodoroSession(actualDuration);
      }
      
      _timer?.cancel();
      _audioPlayer.stop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>(
  (ref) => PomodoroNotifier(),
);