import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tasca_mobile1/widgets/navbar/navbar_coach_mark.dart';

class PomodoroCoachMark {
  final BuildContext context;
  TutorialCoachMark? _tutorialCoachMark;

  // Key untuk SharedPreferences
  static const String _coachMarkShownKey = 'pomodoro_coach_mark_shown';
  static const String _navbarCoachMarkShownKey = 'navbar_coach_mark_shown';

  // Global keys untuk widget yang akan di-highlight
  final GlobalKey skipKey;
  final GlobalKey playKey;
  final GlobalKey endKey;
  final GlobalKey soundKey;
  final GlobalKey selectTaskKey;

  // Variabel untuk tracking step saat ini
  int _currentStep = 0;
  final int _totalSteps = 5;

  PomodoroCoachMark({
    required this.context,
    required this.skipKey,
    required this.playKey,
    required this.endKey,
    required this.soundKey,
    required this.selectTaskKey,
  });

  // Method untuk memeriksa apakah coach mark sudah pernah ditampilkan
  Future<bool> _hasCoachMarkBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_coachMarkShownKey) ?? false;
  }

  // Method untuk memeriksa apakah coach mark navbar sudah selesai
  Future<bool> _hasNavbarCoachMarkBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_navbarCoachMarkShownKey) ?? false;
  }

  // Method untuk menandai bahwa coach mark semua ditampilkan
  Future<void> _markCoachMarkAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_coachMarkShownKey, true);
  }

  // Method untuk me-reset status coach mark (untuk pengujian)
  static Future<void> resetCoachMarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_coachMarkShownKey, false);
  }

  // Method untuk memulai coach mark jika belum pernah ditampilkan
  Future<void> showCoachMarkIfNeeded() async {
    if (await _hasCoachMarkBeenShown()) {
      return;
    }

    if (!(await _hasNavbarCoachMarkBeenShown())) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        showCoachMarkIfNeeded();
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      _showCoachMark();
    });
  }

  // Method untuk memaksa tampilkan coach mark
  void showCoachMark() {
    _currentStep = 0;
    _showCoachMark();
  }

  // Method utama untuk membuat dan menampilkan coach mark
  void _showCoachMark() {
    if ([skipKey, playKey, endKey, soundKey, selectTaskKey].any((key) => key.currentContext == null)) {
      debugPrint("Salah satu GlobalKey tidak valid, Pomodoro coach mark tidak ditampilkan");
      return;
    }

    _tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black.withOpacity(0.8),
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
      focusAnimationDuration: const Duration(milliseconds: 400),
      pulseAnimationDuration: const Duration(milliseconds: 1000),
      onFinish: () {
        _markCoachMarkAsShown();
        debugPrint("Pomodoro coach mark selesai dan ditandai sebagai telah ditampilkan");
      },
      onClickTarget: (target) {
        _currentStep++;
        debugPrint("Step $_currentStep dari $_totalSteps");
      },
      onClickOverlay: (target) {
        _currentStep++;
        debugPrint("Overlay clicked, moving to step $_currentStep dari $_totalSteps");
      },
      onSkip: () {
        _markCoachMarkAsShown();
        debugPrint("Pomodoro coach mark dilewati dan ditandai sebagai telah ditampilkan");
        return true;
      },
    )..show(context: context);
  }

  // Method untuk membuat target-target coach mark
  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "skip_key",
        keyTarget: skipKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Lewati Sesi",
                subtitle: "Langkah 1 dari $_totalSteps",
                description: "Gunakan tombol ini untuk melewati sesi saat ini dan beralih ke sesi berikutnya.",
                icon: Icons.skip_next,
                onNext: () {
                  _currentStep++;
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
                isFirstStep: true,
                isLastStep: false,
              );
            },
          ),
        ],
        shape: ShapeLightFocus.Circle,
        radius: 8,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "play_key",
        keyTarget: playKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Mulai/Jeda Timer",
                subtitle: "Langkah 2 dari $_totalSteps",
                description: "Tekan tombol ini untuk memulai atau menjeda timer Pomodoro Anda.",
                icon: Icons.play_arrow,
                onNext: () {
                  _currentStep++;
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
                isFirstStep: false,
                isLastStep: false,
              );
            },
          ),
        ],
        shape: ShapeLightFocus.Circle,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "end_key",
        keyTarget: endKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Akhiri Sesi",
                subtitle: "Langkah 3 dari $_totalSteps",
                description: "Gunakan tombol ini untuk mengakhiri sesi Pomodoro dan menyimpan progres Anda.",
                icon: Icons.stop,
                onNext: () {
                  _currentStep++;
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
                isFirstStep: false,
                isLastStep: false,
              );
            },
          ),
        ],
        shape: ShapeLightFocus.Circle,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "sound_key",
        keyTarget: soundKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Pilih Suara",
                subtitle: "Langkah 4 dari $_totalSteps",
                description: "Tekan ikon ini untuk memilih suara latar yang membantu Anda fokus atau bersantai.",
                icon: Icons.music_note,
                onNext: () {
                  _currentStep++;
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
                isFirstStep: false,
                isLastStep: false,
              );
            },
          ),
        ],
        shape: ShapeLightFocus.Circle,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "select_task_key",
        keyTarget: selectTaskKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Pilih Tugas",
                subtitle: "Langkah 5 dari $_totalSteps",
                description: "Pilih tugas dari daftar untuk fokus mengerjakannya selama sesi Pomodoro.",
                icon: Icons.task,
                onNext: () {
                  _currentStep++;
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
                isFirstStep: false,
                isLastStep: true,
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 8,
      ),
    );

    return targets;
  }

  // Widget builder untuk tampilan konten coach mark modern
  Widget _buildModernCoachContent({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required VoidCallback onNext,
    required VoidCallback onSkip,
    required bool isFirstStep,
    required bool isLastStep,
  }) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header dengan icon dan judul
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.black45,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Progress indicator dengan animasi
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                height: 4,
                child: Row(
                  children: List.generate(
                    _totalSteps,
                    (index) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: index <= _currentStep
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Deskripsi
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ),

              // Tombol action
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Tombol Skip
                  TextButton(
                    onPressed: () {
                      onSkip();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black45,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Lewati'),
                  ),
                  const SizedBox(width: 8),

                  // Tombol Next atau Finish
                  ElevatedButton(
                    onPressed: () {
                      onNext();
                      setState(() {}); // Memaksa pembaruan UI
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(isLastStep ? 'Selesai' : 'Lanjut'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}