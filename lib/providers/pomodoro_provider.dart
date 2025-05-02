import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:tasca_mobile1/services/pomodoro.dart';

class PomodoroState {
  final int timeLeft;
  final bool isRunning;
  final bool isFocusSession;
  final int focusDuration;
  final int restDuration;
  final bool isMuted;
  final String currentSoundTitle;
  final String currentSoundPath;
  final List<Map<String, dynamic>> incompleteTasks;
  final String? selectedTask;
  final String? errorMessage;
  final bool unauthorized;

  PomodoroState({
    required this.timeLeft,
    required this.isRunning,
    required this.isFocusSession,
    required this.focusDuration,
    required this.restDuration,
    required this.isMuted,
    required this.currentSoundTitle,
    required this.currentSoundPath,
    required this.incompleteTasks,
    required this.selectedTask,
    required this.errorMessage,
    required this.unauthorized,
  });

  PomodoroState copyWith({
    int? timeLeft,
    bool? isRunning,
    bool? isFocusSession,
    int? focusDuration,
    int? restDuration,
    bool? isMuted,
    String? currentSoundTitle,
    String? currentSoundPath,
    List<Map<String, dynamic>>? incompleteTasks,
    String? selectedTask,
    String? errorMessage,
    bool? unauthorized,
  }) {
    return PomodoroState(
      timeLeft: timeLeft ?? this.timeLeft,
      isRunning: isRunning ?? this.isRunning,
      isFocusSession: isFocusSession ?? this.isFocusSession,
      focusDuration: focusDuration ?? this.focusDuration,
      restDuration: restDuration ?? this.restDuration,
      isMuted: isMuted ?? this.isMuted,
      currentSoundTitle: currentSoundTitle ?? this.currentSoundTitle,
      currentSoundPath: currentSoundPath ?? this.currentSoundPath,
      incompleteTasks: incompleteTasks ?? this.incompleteTasks,
      selectedTask: selectedTask ?? this.selectedTask,
      errorMessage: errorMessage,
      unauthorized: unauthorized ?? this.unauthorized,
    );
  }

  factory PomodoroState.initial() {
    return PomodoroState(
      timeLeft: 1500,
      isRunning: false,
      isFocusSession: true,
      focusDuration: 1500,
      restDuration: 300,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
      incompleteTasks: [],
      selectedTask: null,
      errorMessage: null,
      unauthorized: false,
    );
  }
}

class PomodoroNotifier extends StateNotifier<PomodoroState> {
  PomodoroNotifier() : super(PomodoroState.initial()) {
    // Inisialisasi AudioPlayer tanpa playerMode (sudah deprecated)
    _audioPlayer = AudioPlayer();
    _pomodoroService = PomodoroService();
    _initNotifications();
    loadTimerSettings();
    fetchIncompleteTasks();
  }

  Timer? _timer;
  AudioPlayer? _audioPlayer;
  late FlutterLocalNotificationsPlugin _localNotifications;
  late PomodoroService _pomodoroService;

  // --- Timer Settings ---
  Future<void> loadTimerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFocusDuration = prefs.getInt('focus_duration');
    final savedRestDuration = prefs.getInt('rest_duration');

    if (savedFocusDuration != null && savedRestDuration != null) {
      state = state.copyWith(
        focusDuration: savedFocusDuration,
        restDuration: savedRestDuration,
        timeLeft: state.isFocusSession ? savedFocusDuration : savedRestDuration,
      );
    } else {
      final savedInterval = prefs.getInt('focus_interval') ?? 0;
      int focus = savedInterval == 0 ? 25 * 60 : 50 * 60;
      int rest = savedInterval == 0 ? 5 * 60 : 10 * 60;
      state = state.copyWith(
        focusDuration: focus,
        restDuration: rest,
        timeLeft: state.isFocusSession ? focus : rest,
      );
      await prefs.setInt('focus_duration', focus);
      await prefs.setInt('rest_duration', rest);
    }
  }

  // --- Notifications ---
  void _initNotifications() {
    _localNotifications = FlutterLocalNotificationsPlugin();
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
    _localNotifications.initialize(initializationSettings);
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

  // --- Timer Logic ---
  void startTimer() {
    if (!state.isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.timeLeft > 0) {
          state = state.copyWith(timeLeft: state.timeLeft - 1);
        } else {
          _sendPomodoroSession();
          timer.cancel();
          _audioPlayer?.stop();
          switchSession();
          _scheduleNotification(
            "Time's up!",
            state.isFocusSession
                ? "Time to take a break."
                : "Time to get back to focus.",
          );
        }
      });

      state = state.copyWith(isRunning: true);
      if (!state.isMuted && state.currentSoundPath.isNotEmpty) {
        playSound(state.currentSoundPath, state.currentSoundTitle);
      }
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    _audioPlayer?.pause();
  }

  void resetTimer() {
    _timer?.cancel();
    switchSession();
    state = state.copyWith(
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
    );
    _audioPlayer?.stop();
    _scheduleNotification(
      "Session switched!",
      state.isFocusSession
          ? "Time for a focus session."
          : "Time for a relax session.",
    );
  }

  void endCurrentSession() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
      timeLeft: state.isFocusSession ? state.focusDuration : state.restDuration,
    );
    _audioPlayer?.stop();
    _sendPomodoroSession();
  }

  void switchSession() {
    bool nextIsFocus = !state.isFocusSession;
    int nextTime = nextIsFocus ? state.focusDuration : state.restDuration;
    state = state.copyWith(isFocusSession: nextIsFocus, timeLeft: nextTime);
  }

  // --- Sound Logic ---
  void playSound(String soundPath, String soundTitle) async {
    await _audioPlayer?.stop();
    if (!state.isMuted && state.isRunning) {
      try {
        await _audioPlayer?.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer?.play(AssetSource(soundPath));
        state = state.copyWith(currentSoundTitle: soundTitle);
      } catch (e) {
        state = state.copyWith(errorMessage: "Error playing sound: $e");
      }
    }
  }

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
    _audioPlayer?.stop();
  }

  // --- Task Logic ---
  Future<void> fetchIncompleteTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        state = state.copyWith(
          errorMessage: 'Unauthorized',
          unauthorized: true,
        );
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
              tasksData
                  .map<Map<String, dynamic>>(
                    (task) => {
                      'id': task['id'],
                      'title': task['title'] ?? 'Unnamed Task',
                    },
                  )
                  .toList(),
          unauthorized: false,
        );
      } else if (response.statusCode == 401) {
        state = state.copyWith(
          errorMessage: 'Unauthorized',
          unauthorized: true,
        );
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to load incomplete tasks: ${response.body}',
          unauthorized: false,
        );
      }
    } on SocketException {
      state = state.copyWith(
        errorMessage: 'Kesalahan Koneksi: Periksa koneksi internet Anda.',
        unauthorized: false,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error fetching tasks: $e',
        unauthorized: false,
      );
    }
  }

  void selectTask(String? taskId) {
    state = state.copyWith(selectedTask: taskId);
  }

  // --- Pomodoro Session Reporting ---
  Future<void> _sendPomodoroSession() async {
    int actualDuration =
        state.isFocusSession
            ? (state.focusDuration - state.timeLeft) ~/ 60
            : (state.restDuration - state.timeLeft) ~/ 60;

    if (actualDuration > 0) {
      final success = await _pomodoroService.completePomodoroSession(
        actualDuration,
      );
      if (!success) {
        state = state.copyWith(
          errorMessage: "Gagal melaporkan sesi Pomodoro ke server.",
        );
      }
    }
  }

  Future<void> updateTimerSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFocusDuration = prefs.getInt('focus_duration');
    final savedRestDuration = prefs.getInt('rest_duration');

    if (savedFocusDuration != null && savedRestDuration != null) {
      state = state.copyWith(
        focusDuration: savedFocusDuration,
        restDuration: savedRestDuration,
        timeLeft: state.isFocusSession ? savedFocusDuration : savedRestDuration,
      );
    }
  }

  // --- Format Time Helper ---
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }
}

// --- Riverpod Provider ---
final pomodoroProvider = StateNotifierProvider<PomodoroNotifier, PomodoroState>(
  (ref) => PomodoroNotifier(),
);
