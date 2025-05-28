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
  final int focusDuration;
  final int restDuration;
  final bool isMuted;
  final String currentSoundTitle;
  final String currentSoundPath;
  final List<Map<String, dynamic>> incompleteTasks;
  final String? selectedTask;
  final String? errorMessage;

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
          focusDuration: 1500,
          restDuration: 300,
          isMuted: true,
          currentSoundTitle: '',
          currentSoundPath: '',
          incompleteTasks: [],
          selectedTask: null,
          errorMessage: null,
        ),
      ) {
    _audioPlayer = AudioPlayer();
    _pomodoroService = PomodoroService();
    _init();
  }

  Timer? _timer;
  late AudioPlayer _audioPlayer;
  late PomodoroService _pomodoroService;
  FlutterLocalNotificationsPlugin? localNotifications;

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

  void updateDurations(int newFocus, int newRest) {
    // Matikan timer dan sound
    _timer?.cancel();
    _audioPlayer.stop();

    // Timer langsung berubah ke durasi baru, status idle
    state = state.copyWith(
      focusDuration: newFocus,
      restDuration: newRest,
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
      timeLeft: state.isFocusSession ? newFocus : newRest,
    );
  }

  Future<void> _initializeNotifications() async {
    localNotifications = FlutterLocalNotificationsPlugin();
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
    await localNotifications!.initialize(initializationSettings);
  }

  Future<void> fetchIncompleteTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) {
        state = state.copyWith(errorMessage: '401');
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
        );
      } else if (response.statusCode == 401) {
        state = state.copyWith(errorMessage: '401');
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

  void startTimer() {
    if (state.isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeLeft > 0) {
        state = state.copyWith(timeLeft: state.timeLeft - 1);
      } else {
        timer.cancel();
        _audioPlayer.stop();
        _sendPomodoroSession();
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

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
    _audioPlayer.pause();
  }

  void resetTimer() {
    _timer?.cancel();
    _audioPlayer.stop();
    switchSession();
    state = state.copyWith(
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
    );
    _scheduleNotification(
      "Session switched!",
      state.isFocusSession
          ? "Time for a focus session."
          : "Time for a relax session.",
    );
  }

  void endCurrentSession() {
    _sendPomodoroSession();
    _timer?.cancel();
    _audioPlayer.stop();
    state = state.copyWith(
      isRunning: false,
      isMuted: true,
      currentSoundTitle: '',
      currentSoundPath: '',
      timeLeft: state.isFocusSession ? state.focusDuration : state.restDuration,
    );
  }

  void switchSession() {
    final isFocus = !state.isFocusSession;
    final newTime = isFocus ? state.focusDuration : state.restDuration;
    state = state.copyWith(isFocusSession: isFocus, timeLeft: newTime);
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

  void selectTask(String? taskId) {
    state = state.copyWith(selectedTask: taskId);
  }

  Future<void> _scheduleNotification(String title, String body) async {
    if (localNotifications == null) return;
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
    await localNotifications!.show(0, title, body, notificationDetails);
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

class PomodoroTimerPage extends ConsumerStatefulWidget {
  const PomodoroTimerPage({Key? key}) : super(key: key);

  @override
  ConsumerState<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends ConsumerState<PomodoroTimerPage>
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final timerState = ref.read(pomodoroProvider);
    final timerNotifier = ref.read(pomodoroProvider.notifier);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (timerState.isRunning) {
        timerNotifier.pauseTimer();
      }
    }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(pomodoroProvider);
    final timerNotifier = ref.read(pomodoroProvider.notifier);

    if (timerState.errorMessage != null && timerState.errorMessage == '401') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                        constraints: BoxConstraints(maxWidth: 150),
                        child: CustomDropdown(
                          items: timerState.incompleteTasks,
                          selectedValue: timerState.selectedTask,
                          onChanged: (String? newValue) {
                            timerNotifier.selectTask(newValue);
                          },
                        ),
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
                                  (timerState.timeLeft /
                                      (timerState.isFocusSession
                                          ? timerState.focusDuration
                                          : timerState.restDuration)),
                              strokeWidth: 10,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.orange,
                              ),
                              backgroundColor: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          Column(
                            children: [
                              const SizedBox(height: 5),
                              Text(
                                timerState.isFocusSession
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
                                      padding: EdgeInsets.symmetric(
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
                                formatTime(timerState.timeLeft),
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
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return SingleChildScrollView(
                                            child: SizedBox(
                                              height: 300,
                                              child: GridView.count(
                                                crossAxisCount: 4,
                                                children: [
                                                  _buildSoundOption(
                                                    context,
                                                    'images/musicoff.png',
                                                    'Mute',
                                                    () {
                                                      timerNotifier.muteSound();
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  _buildSoundOption(
                                                    context,
                                                    'images/forest.png',
                                                    'Forest',
                                                    () {
                                                      timerNotifier.setSoundOption(
                                                        'sound/forest_ambience.mp3',
                                                        'Forest',
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  _buildSoundOption(
                                                    context,
                                                    'images/rain.png',
                                                    'Rain',
                                                    () {
                                                      timerNotifier.setSoundOption(
                                                        'sound/rain_ambience.mp3',
                                                        'Rain',
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  _buildSoundOption(
                                                    context,
                                                    'images/wave.png',
                                                    'Ocean',
                                                    () {
                                                      timerNotifier.setSoundOption(
                                                        'sound/wave_ambience.mp3',
                                                        'Ocean',
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  _buildSoundOption(
                                                    context,
                                                    'images/fire.png',
                                                    'Fireplace',
                                                    () {
                                                      timerNotifier.setSoundOption(
                                                        'sound/fire_ambience.mp3',
                                                        'Fireplace',
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  _buildSoundOption(
                                                    context,
                                                    'images/bird.png',
                                                    'Bird',
                                                    () {
                                                      timerNotifier.setSoundOption(
                                                        'sound/bird_ambience.mp3',
                                                        'Bird',
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  _buildSoundOption(
                                                    context,
                                                    'images/wind.png',
                                                    'Wind',
                                                    () {
                                                      timerNotifier.setSoundOption(
                                                        'sound/wind_ambience.mp3',
                                                        'Wind',
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  _buildSoundOption(
                                                    context,
                                                    'images/night.png',
                                                    'Night',
                                                    () {
                                                      timerNotifier.setSoundOption(
                                                        'sound/night_ambience.mp3',
                                                        'Night',
                                                      );
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Image.asset(
                                      timerState.isMuted
                                          ? 'images/mute.png'
                                          : 'images/on.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                  if (timerState.currentSoundTitle.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        timerState.currentSoundTitle,
                                        style: TextStyle(
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
                            onTap: timerNotifier.resetTimer,
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
                                timerState.isRunning
                                    ? timerNotifier.pauseTimer
                                    : timerNotifier.startTimer,
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
                                timerState.isRunning
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
                            onTap: timerNotifier.endCurrentSession,
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

  Widget _buildSoundOption(
    BuildContext context,
    String imagePath,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 60, height: 60),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  CustomDropdown({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpen = false;

  bool get _isNoTaskState =>
      widget.items.length == 1 && widget.items[0]['title'] == 'Tidak ada task';

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
    setState(() {});
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
                  decoration: BoxDecoration(color: Colors.purple),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        _isNoTaskState
                            ? [
                              Container(
                                padding: EdgeInsets.symmetric(
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
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    task['title'],
                                    style: TextStyle(color: Colors.white),
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
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayValue,
                  style: TextStyle(color: Colors.white),
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
