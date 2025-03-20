import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PomodoroTimer extends StatefulWidget {
  @override
  _PomodoroTimerState createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  int timeLeft = 1500;
  Timer? timer;
  bool isRunning = false;
  bool isMuted = true; // State variable to track mute status

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
          });
        }
      });
      setState(() {
        isRunning = true;
      });
    }
  }

  void pauseTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    timer?.cancel();
    setState(() {
      timeLeft = 1500;
      isRunning = false;
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '$minutes.${sec.toString().padLeft(2, '0')}';
  }

  void showSoundOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
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
                    _buildSoundOption(Icons.music_note, 'Rain', () {
                      setState(() {
                        isMuted = false;
                      });
                    }),
                    _buildSoundOption(Icons.music_note, 'Forest', () {
                      setState(() {
                        isMuted = false;
                      });
                    }),
                    _buildSoundOption(Icons.music_note, 'Ocean', () {
                      setState(() {
                        isMuted = false;
                      });
                    }),
                    _buildSoundOption(Icons.music_note, 'Fireplace', () {
                      setState(() {
                        isMuted = false;
                      });
                    }),
                    _buildSoundOption(Icons.music_note, 'Cafe', () {
                      setState(() {
                        isMuted = false;
                      });
                    }),
                    _buildSoundOption(Icons.music_note, 'Night', () {
                      setState(() {
                        isMuted = false;
                      });
                    }),
                    _buildSoundOption(Icons.music_note, 'Wind', () {
                      setState(() {
                        isMuted = false;
                      });
                    }),
                    _buildSoundOption(Icons.music_off, 'Mute', () {
                      setState(() {
                        isMuted = true;
                      });
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
        );
      },
    );
  }

  Widget _buildSoundOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.orange),
          SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: 1 - (timeLeft / 1500),
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      backgroundColor: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      const Text(
                        "Stay Focused",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SvgPicture.asset(
                        'assets/tomat.svg',
                        width: 18,
                        height: 18,
                      ),
                      const SizedBox(height: 25),
                      Text(
                        formatTime(timeLeft),
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      IconButton(
                        icon: Icon(
                          isMuted ? Icons.music_off : Icons.music_note,
                          color: Colors.orange,
                        ),
                        onPressed: showSoundOptions,
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
                      width: 45,
                      height: 45,
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
                          fontSize: 13,
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
                      width: 65,
                      height: 65,
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
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: resetTimer,
                    child: Container(
                      width: 45,
                      height: 45,
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
                          fontSize: 13,
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
      ),
    );
  }
}
