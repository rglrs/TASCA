import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoCoachMark {
  final BuildContext context;
  TutorialCoachMark? _tutorialCoachMark;
  
  // Key for SharedPreferences
  static const String _coachMarkShownKey = 'todo_coach_mark_shown';
  
  // Global keys untuk widget yang akan di-highlight
  final GlobalKey searchKey;
  final GlobalKey deleteKey;
  final GlobalKey addKey;
  
  // Variabel untuk tracking step saat ini
  int _currentStep = 0;
  final int _totalSteps = 3;

  TodoCoachMark({
    required this.context,
    required this.searchKey,
    required this.deleteKey,
    required this.addKey,
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
    
    // Delay untuk memastikan widget sudah terbentuk sepenuhnya
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
    _tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.black.withOpacity(0.8),
      hideSkip: true, // Sembunyikan tombol skip default
      paddingFocus: 10,
      opacityShadow: 0.8,
      focusAnimationDuration: const Duration(milliseconds: 400),
      pulseAnimationDuration: const Duration(milliseconds: 1000),
      onFinish: () {
        // Tandai bahwa coach mark sudah ditampilkan
        _markCoachMarkAsShown();
        debugPrint("Coach mark selesai dan ditandai sebagai telah ditampilkan");
      },
      onClickTarget: (target) {
        // Update step saat ini
        _currentStep++;
        debugPrint("Step $_currentStep dari $_totalSteps");
      },
      onSkip: () {
        // Tandai bahwa coach mark sudah ditampilkan meskipun dilewati
        _markCoachMarkAsShown();
        debugPrint("Coach mark dilewati dan ditandai sebagai telah ditampilkan");
        return true;
      },
    )..show(context: context);
  }

  // Method untuk membuat target-target coach mark
  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    // Target untuk fitur search
    targets.add(
      TargetFocus(
        identify: "search_key",
        keyTarget: searchKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Pencarian Tugas",
                subtitle: "Langkah 1 dari $_totalSteps",
                description: "Ketikkan kata kunci untuk mencari tugas berdasarkan judul atau deskripsi.",
                icon: Icons.search,
                onNext: () {
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

    // Target untuk fitur delete
    targets.add(
      TargetFocus(
        identify: "delete_key",
        keyTarget: deleteKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Hapus Todo",
                subtitle: "Langkah 2 dari $_totalSteps",
                description: "Tekan tombol ini untuk masuk ke mode seleksi dan hapus beberapa todo sekaligus.",
                icon: Icons.delete_outline,
                onNext: () {
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

    // Target untuk fitur add
    targets.add(
      TargetFocus(
        identify: "add_key",
        keyTarget: addKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildModernCoachContent(
                title: "Tambah Todo Baru",
                subtitle: "Langkah 3 dari $_totalSteps",
                description: "Tekan tombol ini untuk membuat kategori todo baru untuk tugas-tugas Anda.",
                icon: Icons.add,
                onNext: () {
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
        shape: ShapeLightFocus.Circle,
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
          
          // Progress indicator
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            height: 4,
            child: Row(
              children: List.generate(
                _totalSteps,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: index < (isFirstStep ? 1 : isLastStep ? _totalSteps : 2)
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
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
                onPressed: onSkip,
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
                onPressed: onNext,
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
  }
}