import 'package:flutter/material.dart';
import 'package:tasca_mobile1/pages/done.dart';
import 'package:tasca_mobile1/pages/pomodoro.dart';
import 'package:tasca_mobile1/pages/setting_page.dart';
import 'package:tasca_mobile1/pages/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasca_mobile1/pages/calendar.dart';
import 'package:tasca_mobile1/widgets/navbar/navbar_coach_mark.dart'; // Import coach mark dari folder navbar
import 'package:google_fonts/google_fonts.dart';

// Konstanta untuk mode pengujian coach mark
const bool TESTING_MODE = false;

class Navbar extends StatefulWidget {
  final int initialActiveIndex;

  const Navbar({super.key, this.initialActiveIndex = 0});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with WidgetsBindingObserver {
  String? jwtToken;
  bool isLoading = true;
  int activeIndex = 0;

  // Global keys untuk coach mark
  final GlobalKey _focusKey = GlobalKey();
  final GlobalKey _todoKey = GlobalKey();
  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _doneKey = GlobalKey();
  final GlobalKey _settingKey = GlobalKey();

  // Coach mark manager
  NavbarCoachMark? _coachMark;

  @override
  void initState() {
    super.initState();
    activeIndex = widget.initialActiveIndex;
    _loadToken();
    WidgetsBinding.instance.addObserver(this);

    // Inisialisasi coach mark setelah build pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCoachMark();
    });
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        jwtToken = prefs.getString('auth_token') ?? '';
        isLoading = false;
      });
    } catch (e) {
      print('Error loading token: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Inisialisasi coach mark
  void _initCoachMark() {
    _coachMark = NavbarCoachMark(
      context: context,
      focusKey: _focusKey,
      todoKey: _todoKey,
      dateKey: _dateKey,
      doneKey: _doneKey,
      settingKey: _settingKey,
    );

    // Tampilkan coach mark sesuai mode
    if (TESTING_MODE) {
      _coachMark?.showCoachMark();
    } else {
      _coachMark?.showCoachMarkIfNeeded();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (activeIndex != index) {
      setState(() {
        activeIndex = index;
      });

      Widget page;
      switch (index) {
        case 0:
          page = PomodoroTimerPage();
          break;
        case 1:
          page = TodoPage();
          break;
        case 2:
          page = SettingsScreen(jwtToken: jwtToken ?? '');
          break;
        case 3:
          page = DonePage();
          break;
        case 4:
          page = CalendarScreen();
          break;
        default:
          return;
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => page,
          transitionDuration: Duration.zero,
          transitionsBuilder: (context, animation1, animation2, child) {
            return child;
          },
        ),
      );
    }
  }

  // Method untuk manual menampilkan coach mark - dipertahankan meskipun tombol dihapus
  // sehingga masih dapat digunakan dari kode lain jika diperlukan
  void _showCoachMark() {
    if (_coachMark != null) {
      if (!TESTING_MODE) {
        NavbarCoachMark.resetCoachMarkStatus().then((_) {
          _coachMark!.showCoachMark();
        });
      } else {
        _coachMark!.showCoachMark();
      }
    }
  }

  Future<bool> _onWillPop() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Stack(
        children: [
          isLoading
              ? Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (index) => SizedBox(
                      width: 40,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.grey.shade300,
                            size: 28,
                          ),
                          SizedBox(height: 4),
                          Container(
                            height: 12,
                            width: 30,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              : Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NavBarItem(
                      key: _focusKey,
                      icon: Icons.more_time_rounded,
                      label: 'Focus',
                      isActive: activeIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),
                    NavBarItem(
                      key: _todoKey,
                      icon: Icons.format_list_bulleted_add,
                      label: 'To Do',
                      isActive: activeIndex == 1,
                      onTap: () => _onItemTapped(1),
                    ),
                    NavBarItem(
                      key: _dateKey,
                      icon: Icons.calendar_today,
                      label: 'Date',
                      isActive: activeIndex == 4,
                      onTap: () => _onItemTapped(4),
                    ),
                    NavBarItem(
                      key: _doneKey,
                      icon: Icons.check_circle,
                      label: 'Done!',
                      isActive: activeIndex == 3,
                      onTap: () => _onItemTapped(3),
                    ),
                    NavBarItem(
                      key: _settingKey,
                      icon: Icons.settings,
                      label: 'Setting',
                      isActive: activeIndex == 2,
                      onTap: () => _onItemTapped(2),
                    ),
                  ],
                ),
              ),
          // Tombol bantuan telah dihapus dari sini
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.deepPurple : Colors.grey,
            size: 28,
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.deepPurple : Colors.grey,
              fontSize: 12,
            ),
          ),
          if (isActive)
            Container(
              margin: EdgeInsets.only(top: 4),
              width: 20,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}
