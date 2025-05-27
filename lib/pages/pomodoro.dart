import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasca_mobile1/widgets/navbar.dart';
import 'package:tasca_mobile1/services/pomodoro.dart';
import 'package:tasca_mobile1/pages/login_page.dart';
import 'package:tasca_mobile1/widgets/pomodoro/pomodoro_coach_mark.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        _sendPomodoroSession();
        timer.cancel();
        state = state.copyWith(isRunning: false);
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
    state = state.copyWith(isRunning: true);
    if (!state.isMuted && state.currentSoundPath.isNotEmpty) {
      playSound(state.currentSoundPath, state.currentSoundTitle);
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
    );
    _audioPlayer.stop();
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
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
    );
  }

  void playSound(String soundPath, String soundTitle) async {
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
        );
      } else if (response.statusCode == 401) {
        await _redirectToLogin();
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
    state = state.copyWith(unauthorized: true);
  }

  void clearUnauthorized() {
    state = state.copyWith(unauthorized: false);
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

class PomodoroTimer extends ConsumerStatefulWidget {
  const PomodoroTimer({Key? key}) : super(key: key);

  @override
  ConsumerState<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends ConsumerState<PomodoroTimer>
    with WidgetsBindingObserver {
  final GlobalKey _skipKey = GlobalKey();
  final GlobalKey _playKey = GlobalKey();
  final GlobalKey _endKey = GlobalKey();
  final GlobalKey _soundKey = GlobalKey();
  final GlobalKey _selectTaskKey = GlobalKey();
  PomodoroCoachMark? _coachMark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCoachMark();
    });
    ref.read(pomodoroProvider.notifier).fetchIncompleteTasks();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(pomodoroProvider.notifier).pauseTimer();
    } else if (state == AppLifecycleState.detached) {
      ref.read(pomodoroProvider.notifier).endCurrentSession();
    }
  }

  void _initCoachMark() {
    _coachMark = PomodoroCoachMark(
      context: context,
      skipKey: _skipKey,
      playKey: _playKey,
      endKey: _endKey,
      soundKey: _soundKey,
      selectTaskKey: _selectTaskKey,
    );
    if (TESTING_MODE) {
      _coachMark?.showCoachMark();
    } else {
      _coachMark?.showCoachMarkIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pomodoroProvider);
    final notifier = ref.read(pomodoroProvider.notifier);

    // Redirect to login if unauthorized
    if (state.unauthorized) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        notifier.clearUnauthorized();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "POMODORO",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        key: _selectTaskKey,
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: CustomDropdown(
                          items: state.incompleteTasks,
                          selectedValue: state.selectedTask,
                          onChanged: (String? newValue) {
                            notifier.setSelectedTask(newValue);
                          },
                        ),
                      ),
                    ),
                    if (state.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4,
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 300,
                            height: 300,
                            child: CircularProgressIndicator(
                              value:
                                  1 -
                                  (state.timeLeft /
                                      (state.isFocusSession
                                          ? state.focusDuration
                                          : state.restDuration)),
                              strokeWidth: 10,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.orange,
                              ),
                              backgroundColor: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                state.isFocusSession
                                    ? "Stay Focused"
                                    : "Take a Break",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (var i = 0; i < 3; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2.0,
                                      ),
                                      child: Image.asset(
                                        'images/tomat.png',
                                        width: 24,
                                        height: 24,
                                        color: Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              Text(
                                formatTime(state.timeLeft),
                                style: const TextStyle(
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    key: _soundKey,
                                    onTap:
                                        () => showSoundOptions(
                                          context,
                                          notifier,
                                          state,
                                        ),
                                    child: Image.asset(
                                      state.isMuted
                                          ? 'images/mute.png'
                                          : 'images/on.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                  if (state.currentSoundTitle.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        state.currentSoundTitle,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 90),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            key: _skipKey,
                            onTap: notifier.resetTimer,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Skip",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            key: _playKey,
                            onTap:
                                state.isRunning
                                    ? notifier.pauseTimer
                                    : notifier.startTimer,
                            child: Container(
                              width: 75,
                              height: 75,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.orange,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                state.isRunning
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            key: _endKey,
                            onTap: notifier.endCurrentSession,
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "End",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Navbar(initialActiveIndex: 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  void showSoundOptions(
    BuildContext context,
    PomodoroNotifier notifier,
    PomodoroState state,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: SizedBox(
            height: 300,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: GridView.count(
                    crossAxisCount: 4,
                    children: [
                      _buildSoundOption(
                        context,
                        notifier,
                        'images/musicoff.png',
                        'Mute',
                        '',
                        true,
                      ),
                      _buildSoundOption(
                        context,
                        notifier,
                        'images/forest.png',
                        'Forest',
                        'sound/forest_ambience.mp3',
                        false,
                      ),
                      _buildSoundOption(
                        context,
                        notifier,
                        'images/rain.png',
                        'Rain',
                        'sound/rain_ambience.mp3',
                        false,
                      ),
                      _buildSoundOption(
                        context,
                        notifier,
                        'images/wave.png',
                        'Ocean',
                        'sound/wave_ambience.mp3',
                        false,
                      ),
                      _buildSoundOption(
                        context,
                        notifier,
                        'images/fire.png',
                        'Fireplace',
                        'sound/fire_ambience.mp3',
                        false,
                      ),
                      _buildSoundOption(
                        context,
                        notifier,
                        'images/bird.png',
                        'Bird',
                        'sound/bird_ambience.mp3',
                        false,
                      ),
                      _buildSoundOption(
                        context,
                        notifier,
                        'images/wind.png',
                        'Wind',
                        'sound/wind_ambience.mp3',
                        false,
                      ),
                      _buildSoundOption(
                        context,
                        notifier,
                        'images/night.png',
                        'Night',
                        'sound/night_ambience.mp3',
                        false,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoundOption(
    BuildContext context,
    PomodoroNotifier notifier,
    String imagePath,
    String label,
    String soundPath,
    bool isMute,
  ) {
    return GestureDetector(
      onTap: () {
        if (isMute) {
          notifier.muteSound();
        } else {
          notifier.setSoundOption(soundPath, label);
        }
        Navigator.pop(context);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 60, height: 60),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const CustomDropdown({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;

  bool get _isNoTaskState =>
      widget.items.isEmpty ||
      (widget.items.length == 1 &&
          widget.items[0]['title'] == 'Tidak ada task');

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context)!.insert(_overlayEntry!);
      setState(() {
        _isDropdownOpen = true;
      });
    } else {
      _overlayEntry!.remove();
      _overlayEntry = null;
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 2.0),
              child: Material(
                elevation: 4.0,
                child: Container(
                  decoration: const BoxDecoration(color: Colors.purple),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        _isNoTaskState
                            ? [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Tidak ada task',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ]
                            : widget.items.map((task) {
                              return GestureDetector(
                                onTap: () {
                                  widget.onChanged(task['id'].toString());
                                  _toggleDropdown();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    task['title'],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }).toList(),
                  ),
                ),
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String displayValue = "Select a Task";
    if (widget.selectedValue != null) {
      final selectedItem = widget.items.firstWhere(
        (item) => item['id'].toString() == widget.selectedValue,
        orElse: () => {'title': 'Select a Task'},
      );
      displayValue = selectedItem['title'];
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.purple,
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayValue,
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
