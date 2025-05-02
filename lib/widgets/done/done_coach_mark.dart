import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';

class DoneCoachMark {
  final BuildContext context;
  TutorialCoachMark? _tutorialCoachMark;

  // Key untuk SharedPreferences
  static const String _coachMarkShownKey = 'done_coach_mark_shown';

  // Global keys untuk widget yang akan di-highlight
  final GlobalKey taskDoneCardKey;
  final GlobalKey focusedCardKey;
  final GlobalKey taskDoneChartKey;
  final GlobalKey focusedChartKey;

  // Variabel untuk tracking step saat ini
  int _currentStep = 0;
  final int _totalSteps = 4;

  DoneCoachMark({
    required this.context,
    required this.taskDoneCardKey,
    required this.focusedCardKey,
    required this.taskDoneChartKey,
    required this.focusedChartKey,
  });

  // Method untuk memeriksa apakah coach mark sudah pernah ditampilkan
  Future<bool> _hasCoachMarkBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_coachMarkShownKey) ?? false;
  }

  // Method untuk menandai bahwa coach mark sudah ditampilkan
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
    if ([taskDoneCardKey, focusedCardKey, taskDoneChartKey, focusedChartKey].any((key) => key.currentContext == null)) {
      debugPrint("Salah satu GlobalKey tidak valid, Done coach mark tidak ditampilkan");
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
        debugPrint("Done coach mark selesai dan ditandai sebagai telah ditampilkan");
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
        debugPrint("Done coach mark dilewati dan ditandai sebagai telah ditampilkan");
        return true;
      },
    )..show(context: context);
  }

  // Method untuk membuat target-target coach mark
  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    // Target untuk Card Task Done
    targets.add(
      TargetFocus(
        identify: "task_done_card",
        keyTarget: taskDoneCardKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Task Done Card",
                subtitle: "Langkah 1 dari $_totalSteps",
                description: "Kartu ini menunjukkan jumlah tugas yang telah selesai dalam seminggu terakhir.",
                icon: Icons.check_circle,
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
        shape: ShapeLightFocus.RRect,
        radius: 8,
      ),
    );

    // Target untuk Card Focused
    targets.add(
      TargetFocus(
        identify: "focused_card",
        keyTarget: focusedCardKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Focused Card",
                subtitle: "Langkah 2 dari $_totalSteps",
                description: "Kartu ini menampilkan total waktu fokus Anda dalam menit selama seminggu terakhir.",
                icon: Icons.timer,
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
        shape: ShapeLightFocus.RRect,
        radius: 8,
      ),
    );

    // Target untuk Chart Task Done
    targets.add(
      TargetFocus(
        identify: "task_done_chart",
        keyTarget: taskDoneChartKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        paddingFocus: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Task Done Chart",
                subtitle: "Langkah 3 dari $_totalSteps",
                description: "Grafik ini menunjukkan tugas selesai harian selama seminggu.",
                icon: Icons.bar_chart,
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
        shape: ShapeLightFocus.RRect,
        radius: 8,
      ),
    );

    // Target untuk Chart Focused
    targets.add(
      TargetFocus(
        identify: "focused_chart",
        keyTarget: focusedChartKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Focused Chart",
                subtitle: "Langkah 4 dari $_totalSteps",
                description: "Grafik ini menampilkan waktu fokus harian Anda dalam seminggu terakhir.",
                icon: Icons.show_chart,
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
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Mengurangi margin vertikal
          padding: const EdgeInsets.all(16), // Mengurangi padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Mengurangi radius
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8, // Mengurangi blur
                spreadRadius: 1, // Mengurangi spread
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
                    padding: const EdgeInsets.all(8), // Mengurangi padding icon
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: 20, // Mengurangi ukuran icon
                    ),
                  ),
                  const SizedBox(width: 10), // Mengurangi jarak
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 16, // Mengurangi ukuran font judul
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.black45,
                            fontSize: 10, // Mengurangi ukuran font subtitle
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
                margin: const EdgeInsets.symmetric(vertical: 12), // Mengurangi margin vertikal
                height: 3, // Mengurangi ketebalan progress bar
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
                padding: const EdgeInsets.only(bottom: 12.0), // Mengurangi padding bawah
                child: Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12, // Mengurangi ukuran font deskripsi
                    color: Colors.black54,
                    height: 1.4, // Mengurangi line height
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Mengurangi padding tombol
                      textStyle: GoogleFonts.poppins(
                        fontSize: 12, // Mengurangi ukuran font tombol
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Lewati'),
                  ),
                  const SizedBox(width: 6), // Mengurangi jarak antar tombol

                  // Tombol Next atau Finish
                  ElevatedButton(
                    onPressed: () {
                      onNext();
                      setState(() {}); // Memaksa pembaruan UI
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Mengurangi padding tombol
                      textStyle: GoogleFonts.poppins(
                        fontSize: 12, // Mengurangi ukuran font tombol
                        fontWeight: FontWeight.w500,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6), // Mengurangi radius
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