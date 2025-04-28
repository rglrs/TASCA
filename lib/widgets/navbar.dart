import 'package:flutter/material.dart';
import 'package:tasca_mobile1/pages/done.dart';
import 'package:tasca_mobile1/pages/pomodoro.dart'; // Import the Pomodoro page
import 'package:tasca_mobile1/pages/setting_page.dart'; // Import the Setting page
import 'package:tasca_mobile1/pages/todo.dart'; // Import the Setting page
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasca_mobile1/pages/calendar.dart';

class Navbar extends StatefulWidget {
  final int initialActiveIndex;

  const Navbar({super.key, this.initialActiveIndex = 0});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String? jwtToken;
  bool isLoading = true;
  int activeIndex = 0; // Track the active index

  @override
  void initState() {
    super.initState();
    activeIndex = widget.initialActiveIndex;
    _loadToken();
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

  void _onItemTapped(int index) {
    // Ensure not to re-navigate unnecessarily
    if (activeIndex != index) {
      setState(() {
        activeIndex = index;
      });

      Widget page;
      switch (index) {
        case 0: // Navigate to Pomodoro
          page = PomodoroTimer();
          break;
        case 1: // Navigate to To-Do List
          page = TodoPage();
          break;
        case 2: // Navigate to Settings
          page = SettingsScreen(jwtToken: jwtToken ?? '');
          break;
        default:
          return;
      }

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => page,
          transitionDuration: Duration.zero, // No animation duration
          transitionsBuilder: (context, animation1, animation2, child) {
            return child; // Directly show the new page without animations
          },
        ),
      );
    }
  }

  Future<bool> _onWillPop() async {
    // Exit the app when back button is pressed
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child:
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
                      icon: Icons.more_time_rounded,
                      label: 'Focus',
                      isActive: activeIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),                    
                    NavBarItem(
                      icon: Icons.format_list_bulleted_add,
                      label: 'To Do',
                      isActive: activeIndex == 1,
                      onTap: () {
                        _onItemTapped(1);
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation1, animation2) => TodoPage(),
                            transitionDuration: Duration.zero,
                            transitionsBuilder: (
                              context,
                              animation1,
                              animation2,
                              child,
                            ) {
                              return child;
                            },
                          ),
                        );
                      },
                    ),
                    NavBarItem(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      isActive: activeIndex == 4,
                      onTap: () {
                        _onItemTapped(4);
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation1, animation2) => CalendarScreen(),
                            transitionDuration: Duration.zero,
                            transitionsBuilder: (
                              context,
                              animation1,
                              animation2,
                              child,
                            ) {
                              return child;
                            },
                          ),
                        );
                      },
                    ),
                    NavBarItem(
                      icon: Icons.check_circle,
                      label: 'Done!',
                      isActive: activeIndex == 3,
                      onTap: () {
                        _onItemTapped(3);
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation1, animation2) => DonePage(),
                            transitionDuration: Duration.zero,
                            transitionsBuilder: (
                              context,
                              animation1,
                              animation2,
                              child,
                            ) {
                              return child;
                            },
                          ),
                        );
                      },
                    ),
                    NavBarItem(
                      icon: Icons.settings,
                      label: 'Setting',
                      isActive: activeIndex == 2,
                      onTap: () => _onItemTapped(2),
                    ),
                  ],
                ),
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
