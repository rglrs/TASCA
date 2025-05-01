import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';

class AddTodoCoachMark {
  final BuildContext context;
  TutorialCoachMark? _tutorialCoachMark;

  // Key untuk SharedPreferences
  static const String _coachMarkShownKey = 'add_todo_coach_mark_shown';

  // Global keys untuk widget yang akan di-highlight
  final GlobalKey titleInputKey;
  final GlobalKey priorityColorKey;
  final GlobalKey prioritySelectionKey;
  final GlobalKey addTaskButtonKey;

  // Variabel untuk tracking step saat ini
  int _currentStep = 0;
  final int _totalSteps = 4;

  AddTodoCoachMark({
    required this.context,
    required this.titleInputKey,
    required this.priorityColorKey,
    required this.prioritySelectionKey,
    required this.addTaskButtonKey,
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
    if ([titleInputKey, priorityColorKey, prioritySelectionKey, addTaskButtonKey]
        .any((key) => key.currentContext == null)) {
      debugPrint("Salah satu GlobalKey tidak valid, AddTodo coach mark tidak ditampilkan");
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
        debugPrint("AddTodo coach mark selesai dan ditandai sebagai telah ditampilkan");
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
        debugPrint("AddTodo coach mark dilewati dan ditandai sebagai telah ditampilkan");
        return true;
      },
    )..show(context: context);
  }

  // Method untuk membuat target-target coach mark
  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    // Target untuk Title Input
    targets.add(
      TargetFocus(
        identify: "title_input",
        keyTarget: titleInputKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Judul Tugas",
                subtitle: "Langkah 1 dari $_totalSteps",
                description: "Masukkan judul tugas yang ingin Anda tambahkan di sini.",
                icon: Icons.text_fields,
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

    // Target untuk Priority Color Preview
    targets.add(
      TargetFocus(
        identify: "priority_color",
        keyTarget: priorityColorKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Pratinjau Warna Prioritas",
                subtitle: "Langkah 2 dari $_totalSteps",
                description: "Lihat warna prioritas tugas berdasarkan pilihan urgensi dan kepentingan.",
                icon: Icons.color_lens,
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

    // Target untuk Urgency and Importance Selection
    targets.add(
      TargetFocus(
        identify: "priority_selection",
        keyTarget: prioritySelectionKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        paddingFocus: 20,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Pemilihan Prioritas",
                subtitle: "Langkah 3 dari $_totalSteps",
                description: "Pilih tingkat urgensi dan kepentingan untuk menentukan prioritas tugas.",
                icon: Icons.priority_high,
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

    // Target untuk Add Task Button
    targets.add(
      TargetFocus(
        identify: "add_task_button",
        keyTarget: addTaskButtonKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Tombol Tambah Tugas",
                subtitle: "Langkah 4 dari $_totalSteps",
                description: "Ketuk tombol ini untuk menambahkan tugas setelah mengisi semua informasi.",
                icon: Icons.add_task,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 1,
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            color: Colors.black45,
                            fontSize: 10,
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
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 3,
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
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.4,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Lewati'),
                  ),
                  const SizedBox(width: 6),

                  // Tombol Next atau Finish
                  ElevatedButton(
                    onPressed: () {
                      onNext();
                      setState(() {}); // Memaksa pembaruan UI
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
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