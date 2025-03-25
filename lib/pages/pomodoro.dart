import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasca_mobile1/widgets/navbar.dart'; // Ensure this path is correct

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({super.key});

  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  int timeLeft = 1500; // 25 minutes in seconds
  Timer? timer;
  bool isRunning = false;
  bool isMuted = true; // State variable to track mute status
  String currentSoundTitle = ''; // State variable to track current sound title
  String currentSoundPath = ''; // State variable to track current sound path
  AudioPlayer audioPlayer = AudioPlayer();
  bool isFocusSession = true; // State variable to track session type

  // Timer settings
  int focusDuration = 1500; // 25 minutes
  int restDuration = 300; // 5 minutes

  @override
  void initState() {
    super.initState();
    _loadSavedInterval();
  }

  // Load saved interval from SharedPreferences
  Future<void> _loadSavedInterval() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final interval = prefs.getInt('focus_interval') ?? 0; // Default to 25min

      setState(() {
        if (interval == 0) {
          // 25 min focus, 5 min rest
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
      // If there's an error, use default values
      print('Error loading focus interval: $e');
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
          timer.cancel();
          setState(() {
            isRunning = false;
            audioPlayer.stop(); // Stop sound when timer ends
            switchSession(); // Switch session when time is up
          });
        }
      });
      setState(() {
        isRunning = true;
        if (!isMuted && currentSoundPath.isNotEmpty) {
          playSound(
            currentSoundPath,
            currentSoundTitle,
          ); // Play sound when timer starts
        }
      });
    }
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      audioPlayer.pause(); // Pause sound when timer is paused
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      switchSession(); // Switch session when skip button is pressed
      isRunning = false;
      isMuted = true; // Ensure sound is off when timer is reset
      currentSoundTitle = ''; // Reset sound title
      currentSoundPath = ''; // Reset sound path
      audioPlayer.stop(); // Stop sound when timer is reset
    });
  }

  void switchSession() {
    setState(() {
      isFocusSession = !isFocusSession;
      timeLeft =
          isFocusSession
              ? focusDuration
              : restDuration; // Switch session duration
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  void playSound(String soundPath, String soundTitle) async {
    await audioPlayer.stop(); // Stop any currently playing sound
    if (!isMuted && isRunning) {
      await audioPlayer.setReleaseMode(ReleaseMode.loop); // Set to loop
      await audioPlayer.play(AssetSource(soundPath));
      setState(() {
        currentSoundTitle = soundTitle; // Update current sound title
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
                  padding: const EdgeInsets.only(
                    top: 40.0,
                  ), // Add top padding to GridView
                  child: GridView.count(
                    crossAxisCount: 4,
                    children: [
                      _buildSoundOption('images/musicoff.png', 'Mute', () {
                        setState(() {
                          isMuted = true;
                          currentSoundTitle = ''; // Clear sound title
                          currentSoundPath = ''; // Clear sound path
                        });
                        audioPlayer.stop();
                      }),
                      _buildSoundOption('images/forest.png', 'Forest', () {
                        setState(() {
                          isMuted = false;
                          currentSoundPath = 'sound/forest_ambience.mp3';
                          currentSoundTitle = 'Forest'; // Set sound title
                        });
                        if (isRunning) {
                          playSound('sound/forest_ambience.mp3', 'Forest');
                        }
                      }),
                      _buildSoundOption('images/rain.png', 'Rain', () {
                        setState(() {
                          isMuted = false;
                          currentSoundPath = 'sound/rain_ambience.mp3';
                          currentSoundTitle = 'Rain'; // Set sound title
                        });
                        if (isRunning) {
                          playSound('sound/rain_ambience.mp3', 'Rain');
                        }
                      }),
                      _buildSoundOption('images/wave.png', 'Ocean', () {
                        setState(() {
                          isMuted = false;
                          currentSoundPath = 'sound/wave_ambience.mp3';
                          currentSoundTitle = 'Ocean'; // Set sound title
                        });
                        if (isRunning) {
                          playSound('sound/wave_ambience.mp3', 'Ocean');
                        }
                      }),
                      _buildSoundOption('images/fire.png', 'Fireplace', () {
                        setState(() {
                          isMuted = false;
                          currentSoundPath = 'sound/fire_ambience.mp3';
                          currentSoundTitle = 'Fireplace'; // Set sound title
                        });
                        if (isRunning) {
                          playSound('sound/fire_ambience.mp3', 'Fireplace');
                        }
                      }),
                      _buildSoundOption('images/bird.png', 'Bird', () {
                        setState(() {
                          isMuted = false;
                          currentSoundPath = 'sound/bird_ambience.mp3';
                          currentSoundTitle = 'Bird'; // Set sound title
                        });
                        if (isRunning) {
                          playSound('sound/bird_ambience.mp3', 'Bird');
                        }
                      }),
                      _buildSoundOption('images/wind.png', 'Wind', () {
                        setState(() {
                          isMuted = false;
                          currentSoundPath = 'sound/wind_ambience.mp3';
                          currentSoundTitle = 'Wind'; // Set sound title
                        });
                        if (isRunning) {
                          playSound('sound/wind_ambience.mp3', 'Wind');
                        }
                      }),
                      _buildSoundOption('images/night.png', 'Night', () {
                        setState(() {
                          isMuted = false;
                          currentSoundPath = 'sound/night_ambience.mp3';
                          currentSoundTitle = 'Night'; // Set sound title
                        });
                        if (isRunning) {
                          playSound('sound/night_ambience.mp3', 'Night');
                        }
                      }),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSoundOption(String imagePath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 60, height: 60), // Increased size
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 16)), // Increased font size
        ],
      ),
    );
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
                const SizedBox(height: 20), // Add space above the title
                const Center(
                  child: Text(
                    "POMODORO",
                    style: TextStyle(
                      fontSize: 32, // Increased font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Add space below the title
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
                        width: 300, // Increased size
                        height: 300, // Increased size
                        child: CircularProgressIndicator(
                          value:
                              1 -
                              (timeLeft /
                                  (isFocusSession
                                      ? focusDuration
                                      : restDuration)),
                          strokeWidth: 10, // Increased stroke width
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
                              fontSize: 20, // Increased font size
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
                                width: 24, // Increased size
                                height: 24, // Increased size
                                color: Colors.black,
                              ),
                              SizedBox(width: 4), // Increased space
                              Image.asset(
                                'images/tomat.png',
                                width: 24, // Increased size
                                height: 24, // Increased size
                                color: Colors.black,
                              ),
                              SizedBox(width: 4), // Increased space
                              Image.asset(
                                'images/tomat.png',
                                width: 24, // Increased size
                                height: 24, // Increased size
                                color: Colors.black,
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),
                          Text(
                            formatTime(timeLeft),
                            style: const TextStyle(
                              fontSize: 60, // Increased font size
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
                                  width: 50, // Increased size
                                  height: 50, // Increased size
                                ),
                              ),
                              if (currentSoundTitle.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    currentSoundTitle,
                                    style: TextStyle(
                                      fontSize: 20, // Increased font size
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
                          width: 55, // Increased size
                          height: 55, // Increased size
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
                              fontSize: 16, // Increased font size
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
                          width: 75, // Increased size
                          height: 75, // Increased size
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
                            size: 40, // Increased size
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: resetTimer,
                        child: Container(
                          width: 55, // Increased size
                          height: 55, // Increased size
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
                              fontSize: 16, // Increased font size
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
}
