import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pomodoro.dart';
import '../widgets/navbar.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({Key? key}) : super(key: key);

  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  final PomodoroService _pomodoroService = PomodoroService();

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

  @override
  void initState() {
    super.initState();
    _loadSavedInterval();
  }

  // Load saved interval from SharedPreferences
  Future<void> _loadSavedInterval() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interval = prefs.getInt('focus_interval') ?? 0; 

      setState(() {
        if (interval == 0) {
          focusDuration = 1500;
          restDuration = 300;
        } else {
          // 50 min focus, 10 min rest
          focusDuration = 3000;
          restDuration = 600;
        }

        timeLeft = isFocusSession ? focusDuration : restDuration;
      });
    } catch (e) {
      print('Error loading focus interval: $e');
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
            audioPlayer.stop();
            switchSession();
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
      isMuted = true;
      currentSoundTitle = '';
      currentSoundPath = '';
      audioPlayer.stop();
    });
  }

  void switchSession() {
    setState(() {
      isFocusSession = !isFocusSession;
      timeLeft = isFocusSession ? focusDuration : restDuration;
    });
  }

  // Metode lainnya (formatTime, playSound, showSoundOptions) tetap sama seperti sebelumnya
  // ...

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
                              Image.asset(
                                'images/tomat.png',
                                width: 24,
                                height: 24,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                'images/tomat.png',
                                width: 24,
                                height: 24,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                'images/tomat.png',
                                width: 24,
                                height: 24,
                                color: Colors.black,
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
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              if (currentSoundTitle.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    currentSoundTitle,
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
      ),
    );
  }

  // Metode-metode tambahan yang sebelumnya ada (formatTime, playSound, showSoundOptions, dll.)
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

  @override
  void dispose() {
    timer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }
}
