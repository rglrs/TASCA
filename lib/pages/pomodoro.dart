import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasca_mobile1/widgets/navbar.dart'; // Ensure this path is correct
import 'package:tasca_mobile1/services/pomodoro.dart';
import 'dart:io'; // Import for SocketException
import 'package:tasca_mobile1/pages/login_page.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({Key? key}) : super(key: key);

  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer>
    with WidgetsBindingObserver {
  final PomodoroService _pomodoroService = PomodoroService();
  late FlutterLocalNotificationsPlugin localNotifications;
  int timeLeft = 1500; // 25 minutes in seconds
  Timer? timer;
  bool isRunning = false;
  bool isFocusSession = true;

  // Timer settings
  int focusDuration = 1500; // 25 minutes
  int restDuration = 300; // 5 minutes

  // Sound variables
  bool isMuted = true;
  String currentSoundTitle = '';
  String currentSoundPath = '';
  AudioPlayer audioPlayer = AudioPlayer();

  // Todo variables
  List<Map<String, dynamic>> tasks = [];
  String? selectedTask;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedState();
    _initializeNotifications();
    _fetchTasks(); // Fetch todos on initialization
  }

  void _initializeNotifications() async {
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
  }

  Future<void> _fetchTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _redirectToLogin();
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

        setState(() {
          tasks =
              tasksData.map((task) {
                return {
                  'id': task['id'],
                  'title': task['title'] ?? 'Unnamed Task',
                };
              }).toList();
        });
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else {
        throw Exception('Failed to load incomplete tasks: ${response.body}');
      }
    } on SocketException {
      setState(() {
        _errorMessage = 'Kesalahan Koneksi: Periksa koneksi internet Anda.';
      });
    } catch (e) {
      print('Error fetching incomplete tasks: $e');
    }
  }

  void _redirectToLogin() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('auth_token');
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
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
    await localNotifications.show(0, title, body, notificationDetails);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveState();
    } else if (state == AppLifecycleState.resumed) {
      _loadSavedState();
    }
  }

  Future<void> _loadSavedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStartTime = prefs.getInt('start_time');
      final savedIsRunning = prefs.getBool('is_running') ?? false;
      final savedIsFocusSession = prefs.getBool('is_focus_session') ?? true;

      setState(() {
        isRunning = savedIsRunning;
        isFocusSession = savedIsFocusSession;
      });

      if (savedStartTime != null && isRunning) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final elapsedTime = (currentTime - savedStartTime) ~/ 1000;
        timeLeft =
            (isFocusSession ? focusDuration : restDuration) - elapsedTime;
        if (timeLeft <= 0) {
          timeLeft = 0;
          isRunning = false;
          switchSession();
        } else {
          startTimer();
        }
      }
    } catch (e) {
      print('Error loading saved state: $e');
    }
  }

  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (isRunning) {
        final startTime =
            DateTime.now().millisecondsSinceEpoch -
            ((isFocusSession ? focusDuration : restDuration) - timeLeft) * 1000;
        await prefs.setInt('start_time', startTime);
      }
      await prefs.setBool('is_running', isRunning);
      await prefs.setBool('is_focus_session', isFocusSession);
    } catch (e) {
      print('Error saving state: $e');
    }
  }

  void _sendPomodoroSession() {
    int actualDuration =
        isFocusSession
            ? (focusDuration - timeLeft) ~/ 60
            : (restDuration - timeLeft) ~/ 60;

    if (actualDuration > 0) {
      _pomodoroService.completePomodoroSession(actualDuration);
    }
  }

  void startTimer() {
    if (!isRunning) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (timeLeft > 0) {
          setState(() {
            timeLeft--;
          });
        } else {
          _sendPomodoroSession();

          timer.cancel();
          setState(() {
            isRunning = false;
            audioPlayer.stop(); // Stop sound when timer ends
            switchSession(); // Switch session when time is up
            _scheduleNotification(
              "Time's up!",
              isFocusSession
                  ? "Time to take a break."
                  : "Time to get back to focus.",
            ); // Schedule notification
          });
        }
      });

      setState(() {
        isRunning = true;
        if (!isMuted && currentSoundPath.isNotEmpty) {
          playSound(currentSoundPath, currentSoundTitle);
        }
      });
    }
  }

  void endCurrentSession() {
    // Hitung durasi aktual dalam menit
    int actualDuration =
        isFocusSession
            ? (focusDuration - timeLeft) ~/ 60
            : (restDuration - timeLeft) ~/ 60;

    // Kirim data sesi ke backend hanya jika ada durasi
    if (actualDuration > 0) {
      _pomodoroService.completePomodoroSession(actualDuration);
    }

    timer?.cancel();
    setState(() {
      isRunning = false;
      isMuted = true;
      currentSoundTitle = '';
      currentSoundPath = '';
      audioPlayer.stop();
      timeLeft = isFocusSession ? focusDuration : restDuration;
    });
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      audioPlayer.pause();
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      switchSession();
      isRunning = false;
      isMuted = true; // Ensure sound is off when timer is reset
      currentSoundTitle = ''; // Reset sound title
      currentSoundPath = ''; // Reset sound path
      audioPlayer.stop(); // Stop sound when timer is reset

      print('Switched to session: ${isFocusSession ? "Focus" : "Relax"}');
    });

    // Schedule a notification when switching sessions
    try {
      _scheduleNotification(
        "Session switched!",
        isFocusSession
            ? "Time for a focus session."
            : "Time for a relax session.",
      );
      print("Notification scheduled successfully.");
    } catch (e) {
      print("Failed to schedule notification: $e");
    }
  }

  void switchSession() {
    setState(() {
      isFocusSession = !isFocusSession;
      timeLeft = isFocusSession ? focusDuration : restDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(
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
                    constraints: BoxConstraints(
                      maxWidth: 150,
                    ), // Set a maximum width
                    child: CustomDropdown(
                      items: tasks,
                      selectedValue: selectedTask,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTask = newValue;
                        });
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
                              (timeLeft /
                                  (isFocusSession
                                      ? focusDuration
                                      : restDuration)),
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
                            isFocusSession ? "Stay Focused" : "Take a Break",
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
                                  ), // Even spacing
                                  child: Image.asset(
                                    'images/tomat.png',
                                    width: 24, // Image width
                                    height: 24, // Image height
                                    color: Colors.black,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Text(
                            formatTime(timeLeft),
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
                                onTap: showSoundOptions,
                                child: Image.asset(
                                  isMuted ? 'images/mute.png' : 'images/on.png',
                                  width: 50, // Image width
                                  height: 50, // Image height
                                ),
                              ),
                              if (currentSoundTitle.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    currentSoundTitle,
                                    style: TextStyle(
                                      fontSize: 20, // Font size
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
                        onTap: resetTimer,
                        child: Container(
                          width: 55, // Button width
                          height: 55, // Button height
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
                              fontSize: 16, // Font size
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: isRunning ? pauseTimer : startTimer,
                        child: Container(
                          width: 75, // Button width
                          height: 75, // Button height
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
                            isRunning ? Icons.pause : Icons.play_arrow,
                            size: 40, // Icon size
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: endCurrentSession,
                        child: Container(
                          width: 55, // Button width
                          height: 55, // Button height
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
                              fontSize: 16, // Font size
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
      ),
    );
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  void playSound(String soundPath, String soundTitle) async {
    await audioPlayer.stop();
    if (!isMuted && isRunning) {
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.play(AssetSource(soundPath));
      setState(() {
        currentSoundTitle = soundTitle;
      });
    }
  }

  void showSoundOptions() {
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
                      _buildSoundOption('images/musicoff.png', 'Mute', () {
                        setState(() {
                          isMuted = true;
                          currentSoundTitle = '';
                          currentSoundPath = '';
                        });
                        audioPlayer.stop();
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/forest.png', 'Forest', () {
                        _setSoundOption('sound/forest_ambience.mp3', 'Forest');
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/rain.png', 'Rain', () {
                        _setSoundOption('sound/rain_ambience.mp3', 'Rain');
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/wave.png', 'Ocean', () {
                        _setSoundOption('sound/wave_ambience.mp3', 'Ocean');
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/fire.png', 'Fireplace', () {
                        _setSoundOption('sound/fire_ambience.mp3', 'Fireplace');
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/bird.png', 'Bird', () {
                        _setSoundOption('sound/bird_ambience.mp3', 'Bird');
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/wind.png', 'Wind', () {
                        _setSoundOption('sound/wind_ambience.mp3', 'Wind');
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/night.png', 'Night', () {
                        _setSoundOption('sound/night_ambience.mp3', 'Night');
                        Navigator.pop(context);
                      }),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
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

  void _setSoundOption(String soundPath, String soundTitle) {
    setState(() {
      isMuted = false;
      currentSoundPath = soundPath;
      currentSoundTitle = soundTitle;
    });
    if (isRunning) {
      playSound(soundPath, soundTitle);
    }
  }

  Widget _buildSoundOption(String imagePath, String label, VoidCallback onTap) {
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
              offset: Offset(0.0, size.height),
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
                                  widget.onChanged(task['title']);
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          decoration: BoxDecoration(color: Colors.purple),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.selectedValue ?? "Select a Task",
                style: TextStyle(color: Colors.white),
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
