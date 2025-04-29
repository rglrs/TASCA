import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
      errorMessage: errorMessage,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  PomodoroNotifier()
    : super(
        PomodoroState(
          timeLeft: focusDuration,
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
  }

  static const int focusDuration = 1500; // 25 menit
  static const int restDuration = 300; // 5 menit
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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
    const NotificationDetails notificationDetails = NotificationDetails(
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
    state = state.copyWith(
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
      timeLeft: state.isFocusSession ? focusDuration : restDuration,
    );
  }

  void switchSession() {
    bool nextFocus = !state.isFocusSession;
    state = state.copyWith(
      isFocusSession: nextFocus,
      timeLeft: nextFocus ? focusDuration : restDuration,
    );
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
