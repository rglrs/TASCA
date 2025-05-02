import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailTodoCoachMark {
  final BuildContext context;
  TutorialCoachMark? _tutorialCoachMark;

  // Keys untuk SharedPreferences
  static const String _coachMarkAddTaskShownKey = 'detail_todo_coach_mark_shown_add_task';
  static const String _coachMarkFullShownKey = 'detail_todo_coach_mark_shown_full';

  // Global keys untuk widget yang akan di-highlight
  final GlobalKey todoTitleKey;
  final GlobalKey moreOptionsKey;
  final GlobalKey taskListKey;
  final GlobalKey addNewTaskKey;

  // Variabel untuk tracking step saat ini
  int _currentStep = 0;
  int _totalSteps = 3; // Diperbarui untuk coach mark lengkap (3 langkah)

  DetailTodoCoachMark({
    required this.context,
    required this.todoTitleKey,
    required this.moreOptionsKey,
    required this.taskListKey,
    required this.addNewTaskKey,
  });

  // Method untuk memeriksa apakah coach mark sudah pernah ditampilkan
  Future<bool> _hasCoachMarkBeenShown(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  // Method untuk menandai bahwa coach mark sudah ditampilkan
  Future<void> _markCoachMarkAsShown(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  // Method untuk me-reset status coach mark (untuk pengujian atau tombol bantuan)
  static Future<void> resetCoachMarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_coachMarkAddTaskShownKey, false);
    await prefs.setBool(_coachMarkFullShownKey, false);
  }

  // Method untuk memulai coach mark berdasarkan status task
  Future<void> showCoachMarkIfNeeded({required bool isNewTodo, required bool hasTasks}) async {
    if (isNewTodo && !hasTasks) {
      // Coach mark untuk todo baru tanpa task
      if (await _hasCoachMarkBeenShown(_coachMarkAddTaskShownKey)) {
        return; // Tidak ditampilkan jika sudah pernah muncul
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        _showAddTaskCoachMark();
      });
    } else if (hasTasks) {
      // Coach mark lengkap untuk todo dengan task
      if (await _hasCoachMarkBeenShown(_coachMarkFullShownKey)) {
        return; // Tidak ditampilkan jika sudah pernah muncul
      }
      Future.delayed(const Duration(milliseconds: 500), () {
        _showFullCoachMark();
      });
    }
  }

  // Method untuk memaksa tampilkan coach mark (misalnya, via tombol bantuan)
  void showCoachMark({required bool hasTasks}) {
    _currentStep = 0;
    if (hasTasks) {
      _showFullCoachMark();
    } else {
      _showAddTaskCoachMark();
    }
  }

  // Method untuk menampilkan coach mark hanya untuk "Tambah Tugas Baru"
  void _showAddTaskCoachMark() {
    if (addNewTaskKey.currentContext == null) {
      debugPrint("addNewTaskKey tidak valid, coach mark tidak ditampilkan");
      return;
    }

    _totalSteps = 1; // Hanya satu langkah
    _tutorialCoachMark = TutorialCoachMark(
      targets: _createAddTaskTarget(),
      colorShadow: Colors.black.withOpacity(0.8),
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
      focusAnimationDuration: const Duration(milliseconds: 400),
      pulseAnimationDuration: const Duration(milliseconds: 1000),
      onFinish: () {
        _markCoachMarkAsShown(_coachMarkAddTaskShownKey);
        debugPrint("Add Task coach mark selesai dan ditandai sebagai telah ditampilkan");
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
        _markCoachMarkAsShown(_coachMarkAddTaskShownKey);
        debugPrint("Add Task coach mark dilewati dan ditandai sebagai telah ditampilkan");
        return true;
      },
    )..show(context: context);
  }

  // Method untuk menampilkan coach mark lengkap
  void _showFullCoachMark() {
    if ([moreOptionsKey, taskListKey, addNewTaskKey]
        .any((key) => key.currentContext == null)) {
      debugPrint("Salah satu GlobalKey tidak valid, DetailTodo coach mark tidak ditampilkan");
      return;
    }

    _totalSteps = 3; // Tiga langkah
    _tutorialCoachMark = TutorialCoachMark(
      targets: _createFullTargets(),
      colorShadow: Colors.black.withOpacity(0.8),
      hideSkip: true,
      paddingFocus: 10,
      opacityShadow: 0.8,
      focusAnimationDuration: const Duration(milliseconds: 400),
      pulseAnimationDuration: const Duration(milliseconds: 1000),
      onFinish: () {
        _markCoachMarkAsShown(_coachMarkFullShownKey);
        debugPrint("Full coach mark selesai dan ditandai sebagai telah ditampilkan");
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
        _markCoachMarkAsShown(_coachMarkFullShownKey);
        debugPrint("Full coach mark dilewati dan ditandai sebagai telah ditampilkan");
        return true;
      },
    )..show(context: context);
  }

  // Method untuk membuat target untuk coach mark "Tambah Tugas Baru"
  List<TargetFocus> _createAddTaskTarget() {
    return [
      TargetFocus(
        identify: "add_new_task",
        keyTarget: addNewTaskKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom, // Posisi di bawah
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Tambah Tugas Baru",
                subtitle: "Langkah 1 dari 1",
                description: "Ketuk di sini untuk menambahkan tugas baru ke todo ini.",
                icon: Icons.add_task,
                onNext: () {
                  _currentStep++;
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
                isFirstStep: true,
                isLastStep: true,
              );
            },
          ),
        ],
        shape: ShapeLightFocus.RRect,
        radius: 8,
      ),
    ];
  }

  // Method untuk membuat target-target coach mark lengkap
  List<TargetFocus> _createFullTargets() {
    List<TargetFocus> targets = [];

    // Target untuk More Options Button
    targets.add(
      TargetFocus(
        identify: "more_options",
        keyTarget: moreOptionsKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Opsi Lain",
                subtitle: "Langkah 1 dari $_totalSteps",
                description: "Ketuk tombol ini untuk menghapus todo atau membatalkan aksi.",
                icon: Icons.more_horiz,
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

    // Target untuk Task List
    targets.add(
      TargetFocus(
        identify: "task_list",
        keyTarget: taskListKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        paddingFocus: 20,
        contents: [
          TargetContent(
            align: ContentAlign.custom,
            customPosition: CustomTargetContentPosition(top: 100),
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Daftar Tugas",
                subtitle: "Langkah 2 dari $_totalSteps",
                description: "Lihat semua tugas dalam todo ini. Geser tugas untuk menghapus atau ketuk untuk mengedit.",
                icon: Icons.list,
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

    // Target untuk Add New Task
    targets.add(
      TargetFocus(
        identify: "add_new_task",
        keyTarget: addNewTaskKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Tambah Tugas Baru",
                subtitle: "Langkah 3 dari $_totalSteps",
                description: "Ketuk di sini untuk menambahkan tugas baru ke todo ini.",
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