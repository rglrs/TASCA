import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasca_mobile1/services/pomodoro.dart';
import 'package:tasca_mobile1/pages/login_page.dart';

const bool TESTING_MODE = false;

class PomodoroState {
  final int timeLeft;
  final bool isRunning;
  final bool isFocusSession;
  final bool isMuted;
  final String currentSoundTitle;
  final String currentSoundPath;
  final List<Map<String, dynamic>> incompleteTasks;
  final String? selectedTask;
  final String? errorMessage;
  final int focusDuration;
  final int restDuration;
  final bool unauthorized;
  final DateTime? lastUpdatedTime;

  PomodoroState({
    required this.timeLeft,
    required this.isRunning,
    required this.isFocusSession,
    required this.isMuted,
    required this.currentSoundTitle,
    required this.currentSoundPath,
    required this.incompleteTasks,
    required this.selectedTask,
    required this.errorMessage,
    required this.focusDuration,
    required this.restDuration,
    this.unauthorized = false,
    this.lastUpdatedTime,
  });

  PomodoroState copyWith({
    int? timeLeft,
    bool? isRunning,
    bool? isFocusSession,
    bool? isMuted,
    String? currentSoundTitle,
    String? currentSoundPath,
    List<Map<String, dynamic>>? incompleteTasks,
    String? selectedTask,
    String? errorMessage,
    int? focusDuration,
    int? restDuration,
    bool? unauthorized,
    DateTime? lastUpdatedTime,
  }) {
    return PomodoroState(
      timeLeft: timeLeft ?? this.timeLeft,
      isRunning: isRunning ?? this.isRunning,
      isFocusSession: isFocusSession ?? this.isFocusSession,
      isMuted: isMuted ?? this.isMuted,
      currentSoundTitle: currentSoundTitle ?? this.currentSoundTitle,
      currentSoundPath: currentSoundPath ?? this.currentSoundPath,
      incompleteTasks: incompleteTasks ?? this.incompleteTasks,
      selectedTask: selectedTask ?? this.selectedTask,
      errorMessage: errorMessage ?? this.errorMessage,
      focusDuration: focusDuration ?? this.focusDuration,
      restDuration: restDuration ?? this.restDuration,
      unauthorized: unauthorized ?? this.unauthorized,
      lastUpdatedTime: lastUpdatedTime ?? this.lastUpdatedTime,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  PomodoroNotifier()
    : super(
        PomodoroState(
          timeLeft: 1500,
          isRunning: false,
          isFocusSession: true,
          isMuted: true,
          currentSoundTitle: '',
          currentSoundPath: '',
          incompleteTasks: [],
          selectedTask: null,
          errorMessage: null,
          focusDuration: 1500,
          restDuration: 300,
          lastUpdatedTime: DateTime.now(),
        ),
      ) {
    _pomodoroService = PomodoroService();
    _audioPlayer = AudioPlayer();
    _localNotifications = FlutterLocalNotificationsPlugin();
    _init();
  }

  late PomodoroService _pomodoroService;
  late AudioPlayer _audioPlayer;
  late FlutterLocalNotificationsPlugin _localNotifications;
  Timer? _timer;

  Future<void> _init() async {
    await _initializeNotifications();
    await _loadSavedSettings();
    await fetchIncompleteTasks();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final focus = prefs.getInt('focus_duration') ?? 1500;
    final rest = prefs.getInt('rest_duration') ?? 300;
    state = state.copyWith(
      focusDuration: focus,
      restDuration: rest,
      timeLeft: state.isFocusSession ? focus : rest,
      lastUpdatedTime: DateTime.now(),
    );
  }

  /// PATCH: Timer & sound langsung mati, timer langsung berubah saat setDurations
  Future<void> setDurations({required int focus, required int rest}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('focus_duration', focus);
    await prefs.setInt('rest_duration', rest);

    // Cancel timer & sound
    _timer?.cancel();
    await _audioPlayer.stop();

    // Update state: timer langsung berubah, timer & sound langsung mati
    final newTimeLeft = state.isFocusSession ? focus : rest;
    state = state.copyWith(
      focusDuration: focus,
      restDuration: rest,
      timeLeft: newTimeLeft,
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
      lastUpdatedTime: DateTime.now(),
    );
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );
    await _localNotifications.initialize(initializationSettings);
  }

  void startTimer() {
    if (state.isRunning) return;
    _syncTimerIfNeeded();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(
          timeLeft: state.timeLeft - 1,
          lastUpdatedTime: DateTime.now(),
        );
      } else {
        _sendPomodoroSession();
        timer.cancel();
        state = state.copyWith(isRunning: false, lastUpdatedTime: DateTime.now());
        _audioPlayer.stop();
        switchSession();
        _scheduleNotification(
          "Time's up!",
          state.isFocusSession
              ? "Time to take a break."
              : "Time to get back to focus.",
        );
      }
    });
    state = state.copyWith(isRunning: true, lastUpdatedTime: DateTime.now());
    if (!state.isMuted && state.currentSoundPath.isNotEmpty) {
      playSound(state.currentSoundPath, state.currentSoundTitle);
    }
  }

  void _syncTimerIfNeeded() {
    if (state.lastUpdatedTime != null && state.isRunning) {
      final now = DateTime.now();
      final secondsPassed = now.difference(state.lastUpdatedTime!).inSeconds;
      if (secondsPassed > 0) {
        if (state.timeLeft <= secondsPassed) {
          _sendPomodoroSession();
          switchSession();
        } else {
          state = state.copyWith(
            timeLeft: state.timeLeft - secondsPassed,
            lastUpdatedTime: now,
          );
        }
      }
    }
  }

  void endCurrentSession() {
    _sendPomodoroSession();
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
      timeLeft: state.isFocusSession ? state.focusDuration : state.restDuration,
      lastUpdatedTime: DateTime.now(),
    );
    _audioPlayer.stop();
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false, lastUpdatedTime: DateTime.now());
    _audioPlayer.pause();
  }

  void resetTimer() {
    _timer?.cancel();
    switchSession();
    state = state.copyWith(
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
      lastUpdatedTime: DateTime.now(),
    );
    _audioPlayer.stop();
    _scheduleNotification(
      "Session switched!",
      state.isFocusSession
          ? "Time for a focus session."
          : "Time for a relax session.",
    );
  }

  void switchSession() {
    final nextFocus = !state.isFocusSession;
    state = state.copyWith(
      isFocusSession: nextFocus,
      timeLeft: nextFocus ? state.focusDuration : state.restDuration,
      lastUpdatedTime: DateTime.now(),
    );
  }

  Future<void> playSound(String soundPath, String soundTitle) async {
    await _audioPlayer.stop();
    if (!state.isMuted && state.isRunning) {
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource(soundPath));
        state = state.copyWith(currentSoundTitle: soundTitle);
      } catch (e) {}
    }
  }

  void setSoundOption(String soundPath, String soundTitle) {
    state = state.copyWith(
      isMuted: false,
      currentSoundPath: soundPath,
      currentSoundTitle: soundTitle,
      lastUpdatedTime: DateTime.now(),
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
      lastUpdatedTime: DateTime.now(),
    );
    _audioPlayer.stop();
  }

  Future<void> _scheduleNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pomodoro_channel',
          'Pomodoro Notifications',
          channelDescription:
              'Notifies when Pomodoro focus or relax timer ends',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );
    await _localNotifications.show(0, title, body, notificationDetails);
  }

  Future<void> fetchIncompleteTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        await _redirectToLogin();
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
        final List tasksData = responseBody['data'];
        state = state.copyWith(
          incompleteTasks:
              tasksData.map<Map<String, dynamic>>((task) {
                return {
                  'id': task['id'],
                  'title': task['title'] ?? 'Unnamed Task',
                };
              }).toList(),
          errorMessage: null,
          unauthorized: false,
          lastUpdatedTime: DateTime.now(),
        );
      } else if (response.statusCode == 401) {
        await _redirectToLogin();
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load incomplete tasks: ${response.body}',
          lastUpdatedTime: DateTime.now(),
        );
      }
    } on SocketException {
      state = state.copyWith(
        errorMessage: 'Kesalahan Koneksi: Periksa koneksi internet Anda.',
        lastUpdatedTime: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error fetching incomplete tasks: $e',
        lastUpdatedTime: DateTime.now(),
      );
    }
  }

  void setSelectedTask(String? taskId) {
    state = state.copyWith(selectedTask: taskId, lastUpdatedTime: DateTime.now());
  }

  void _sendPomodoroSession() {
    int actualDuration =
        state.isFocusSession
            ? (state.focusDuration - state.timeLeft) ~/ 60
            : (state.restDuration - state.timeLeft) ~/ 60;
    if (actualDuration > 0) {
      _pomodoroService.completePomodoroSession(actualDuration);
    }
  }

  Future<void> _redirectToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    state = state.copyWith(unauthorized: true, lastUpdatedTime: DateTime.now());
  }

  void clearUnauthorized() {
    state = state.copyWith(unauthorized: false, lastUpdatedTime: DateTime.now());
  }

  void handleAppLifecycleChange(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) {
      _syncTimerIfNeeded();
      if (state.isRunning &&
          !state.isMuted &&
          state.currentSoundPath.isNotEmpty) {
        playSound(state.currentSoundPath, state.currentSoundTitle);
      }
    } else if (appState == AppLifecycleState.paused ||
        appState == AppLifecycleState.inactive) {
      state = state.copyWith(lastUpdatedTime: DateTime.now());
    } else if (appState == AppLifecycleState.detached) {
      endCurrentSession();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>(
  (ref) => PomodoroNotifier(),
);

String formatTime(int seconds) {
  int minutes = seconds ~/ 60;
  int sec = seconds % 60;
  return '$minutes:${sec.toString().padLeft(2, '0')}';
}
