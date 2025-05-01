import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tasca_mobile1/widgets/navbar.dart';
import 'package:tasca_mobile1/services/pomodoro.dart';
import 'dart:io';
import 'package:tasca_mobile1/pages/login_page.dart';
import 'package:tasca_mobile1/widgets/pomodoro/pomodoro_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart'; // Impor google_fonts untuk tombol bantuan

// Konstanta untuk mode pengujian coach mark
const bool TESTING_MODE = false;

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
  List<Map<String, dynamic>> incompleteTasks = [];
  String? selectedTask;
  String? _errorMessage;

  // Global keys untuk coach mark
  final GlobalKey _skipKey = GlobalKey();
  final GlobalKey _playKey = GlobalKey();
  final GlobalKey _endKey = GlobalKey();
  final GlobalKey _soundKey = GlobalKey();
  final GlobalKey _selectTaskKey = GlobalKey();

  // Coach mark manager
  PomodoroCoachMark? _coachMark;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeNotifications();
    _fetchIncompleteTasks();

    // Inisialisasi coach mark setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCoachMark();
    });
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

  Future<void> _fetchIncompleteTasks() async {
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
        final List tasksData = responseBody['data'];

        setState(() {
          incompleteTasks =
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

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
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
            audioPlayer.stop();
            switchSession();
            _scheduleNotification(
              "Time's up!",
              isFocusSession
                  ? "Time to take a break."
                  : "Time to get back to focus.",
            );
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
    int actualDuration =
        isFocusSession
            ? (focusDuration - timeLeft) ~/ 60
            : (restDuration - timeLeft) ~/ 60;

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
      isMuted = true;
      currentSoundTitle = '';
      currentSoundPath = '';
      audioPlayer.stop();

      print('Switched to session: ${isFocusSession ? "Focus" : "Relax"}');
    });

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

  // Inisialisasi coach mark
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

  // Method untuk manual menampilkan coach mark (untuk tombol bantuan)
  void _showCoachMark() {
    if (_coachMark != null) {
      if (!TESTING_MODE) {
        PomodoroCoachMark.resetCoachMarkStatus().then((_) {
          _coachMark!.showCoachMark();
        });
      } else {
        _coachMark!.showCoachMark();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        constraints: BoxConstraints(
                          maxWidth: 150,
                        ),
                        child: CustomDropdown(
                          items: incompleteTasks,
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
                                    key: _soundKey,
                                    onTap: showSoundOptions,
                                    child: Image.asset(
                                      isMuted ? 'images/mute.png' : 'images/on.png',
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                  if (currentSoundTitle.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        currentSoundTitle,
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
                            onTap: resetTimer,
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
                            onTap: isRunning ? pauseTimer : startTimer,
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
                                isRunning ? Icons.pause : Icons.play_arrow,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            key: _endKey,
                            onTap: endCurrentSession,
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
            // Tombol bantuan
            Positioned(
              top: 16,
              right: 16,
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
      try {
        await audioPlayer.setReleaseMode(ReleaseMode.loop);
        await audioPlayer.play(AssetSource(soundPath));
        setState(() {
          currentSoundTitle = soundTitle;
        });
      } catch (e) {
        print("Error playing sound: $e");
      }
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