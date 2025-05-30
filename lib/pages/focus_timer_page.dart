import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasca_mobile1/pages/pomodoro.dart'; // Pastikan path ini sesuai dengan lokasi provider Pomodoro kamu

class FocusTimerScreen extends ConsumerStatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> {
  int selectedInterval = 0; // 0 for 25min, 1 for 50min

  @override
  void initState() {
    super.initState();
    _loadSavedInterval();
  }

  Future<void> _loadSavedInterval() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedInterval = prefs.getInt('focus_interval') ?? 0;
    });
  }

  Future<void> _saveInterval(int interval) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('focus_interval', interval);

    int focusDuration;
    int restDuration;

    if (interval == 0) {
      focusDuration = 25 * 60;
      restDuration = 5 * 60;
    } else {
      focusDuration = 50 * 60;
      restDuration = 10 * 60;
    }

    await prefs.setInt('focus_duration', focusDuration);
    await prefs.setInt('rest_duration', restDuration);

    // === INI BAGIAN PENTING ===
    // Update provider Pomodoro agar timer langsung berubah tanpa reload
    ref
        .read(pomodoroProvider.notifier)
        .updateDurations(focusDuration, restDuration);

    setState(() {
      selectedInterval = interval;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            interval == 0
                ? 'Timer set to 25 min focus, 5 min break'
                : 'Timer set to 50 min focus, 10 min break',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Focus Timer',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppBar().preferredSize.height + 20),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                'Interval',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildIntervalOption(
                    isSelected: selectedInterval == 0,
                    focusTime: '25 min',
                    relaxTime: '5 min',
                    onTap: () => _saveInterval(0),
                  ),
                  const Divider(height: 1, thickness: 1),
                  _buildIntervalOption(
                    isSelected: selectedInterval == 1,
                    focusTime: '50 min',
                    relaxTime: '10 min',
                    onTap: () => _saveInterval(1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '25 minutes',
                      style: TextStyle(color: Color(0xFFFF9966)),
                    ),
                    TextSpan(
                      text: ' - Popular Pomodoro technique',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 10),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: '50 minutes',
                      style: TextStyle(color: Color(0xFFFF9966)),
                    ),
                    TextSpan(
                      text: ' - Recommended by researchers',
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Current session: ${selectedInterval == 0 ? "25/5" : "50/10"} minutes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Changes will take effect on the next session',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalOption({
    required bool isSelected,
    required String focusTime,
    required String relaxTime,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Container(
                        margin: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                      )
                      : null,
            ),
            const SizedBox(width: 15),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: focusTime,
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const TextSpan(
                    text: ' Focus, ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: relaxTime,
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const TextSpan(
                    text: ' Relax',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
