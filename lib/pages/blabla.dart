import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tasca_mobile1/providers/pomodoro_provider.dart';
import 'package:tasca_mobile1/pages/login_page.dart';
import 'package:tasca_mobile1/widgets/navbar.dart';
import 'package:tasca_mobile1/services/pomodoro.dart';

class PomodoroTimer extends ConsumerStatefulWidget {
  const PomodoroTimer({Key? key}) : super(key: key);

  @override
  ConsumerState<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends ConsumerState<PomodoroTimer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Fetch tasks saat halaman pertama kali dibuka
    Future.microtask(() {
      ref
          .read(pomodoroProvider.notifier)
          .fetchTasks(
            onUnauthorized: () {
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              }
            },
          );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Optional: Pause sound if needed
    // final pomodoro = ref.read(pomodoroProvider);
    // if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
    //   if (pomodoro.isRunning && !pomodoro.isMuted) {
    //     ref.read(pomodoroProvider.notifier).pauseTimer();
    //   }
    // }
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int sec = seconds % 60;
    return '$minutes:${sec.toString().padLeft(2, '0')}';
  }

  void showSoundOptions(BuildContext context, PomodoroNotifier notifier) {
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
                        notifier.muteSound();
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/forest.png', 'Forest', () {
                        notifier.setSoundOption(
                          'sound/forest_ambience.mp3',
                          'Forest',
                        );
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/rain.png', 'Rain', () {
                        notifier.setSoundOption(
                          'sound/rain_ambience.mp3',
                          'Rain',
                        );
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/wave.png', 'Ocean', () {
                        notifier.setSoundOption(
                          'sound/wave_ambience.mp3',
                          'Ocean',
                        );
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/fire.png', 'Fireplace', () {
                        notifier.setSoundOption(
                          'sound/fire_ambience.mp3',
                          'Fireplace',
                        );
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/bird.png', 'Bird', () {
                        notifier.setSoundOption(
                          'sound/bird_ambience.mp3',
                          'Bird',
                        );
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/wind.png', 'Wind', () {
                        notifier.setSoundOption(
                          'sound/wind_ambience.mp3',
                          'Wind',
                        );
                        Navigator.pop(context);
                      }),
                      _buildSoundOption('images/night.png', 'Night', () {
                        notifier.setSoundOption(
                          'sound/night_ambience.mp3',
                          'Night',
                        );
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
  Widget build(BuildContext context) {
    final pomodoro = ref.watch(pomodoroProvider);
    final pomodoroNotifier = ref.read(pomodoroProvider.notifier);

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
                    constraints: BoxConstraints(maxWidth: 150),
                    child: CustomDropdown(
                      items: pomodoro.tasks,
                      selectedValue: pomodoro.selectedTask,
                      onChanged: (String? newValue) {
                        pomodoroNotifier.setSelectedTask(newValue);
                      },
                    ),
                  ),
                ),
                if (pomodoro.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      pomodoro.errorMessage!,
                      style: TextStyle(color: Colors.red),
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
                              (pomodoro.timeLeft /
                                  (pomodoro.isFocusSession
                                      ? PomodoroNotifier.focusDuration
                                      : PomodoroNotifier.restDuration)),
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
                            pomodoro.isFocusSession
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
                            formatTime(pomodoro.timeLeft),
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
                                onTap:
                                    () => showSoundOptions(
                                      context,
                                      pomodoroNotifier,
                                    ),
                                child: Image.asset(
                                  pomodoro.isMuted
                                      ? 'images/mute.png'
                                      : 'images/on.png',
                                  width: 50,
                                  height: 50,
                                ),
                              ),
                              if (pomodoro.currentSoundTitle.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    pomodoro.currentSoundTitle,
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
                        onTap: pomodoroNotifier.resetTimer,
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
                        onTap:
                            pomodoro.isRunning
                                ? pomodoroNotifier.pauseTimer
                                : pomodoroNotifier.startTimer,
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
                            pomodoro.isRunning ? Icons.pause : Icons.play_arrow,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: pomodoroNotifier.endCurrentSession,
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
}

// --- CustomDropdown Widget ---
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
