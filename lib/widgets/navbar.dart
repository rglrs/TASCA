import 'package:flutter/material.dart';
import 'package:tasca_mobile1/pages/pomodoro.dart'; // Import the Pomodoro page
import 'package:tasca_mobile1/pages/setting_page.dart'; // Import the Setting page
import 'package:shared_preferences/shared_preferences.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String? jwtToken;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
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
          children: List.generate(5, (index) => 
            Container(
              width: 40,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: Colors.grey.shade300, size: 28),
                  SizedBox(height: 4),
                  Container(
                    height: 12,
                    width: 30,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            )
          ),
        ),
      );
    }

    return Container(
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
            isActive: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PomodoroTimer()),
              );
            },
          ),
          NavBarItem(
            icon: Icons.format_list_bulleted_add,
            label: 'To Do',
            isActive: false,
            onTap: () {
              // Add navigation logic for To Do page
            },
          ),
          NavBarItem(
            icon: Icons.calendar_today,
            label: 'Date',
            isActive: false,
            onTap: () {
              // Add navigation logic for Date page
            },
          ),
          NavBarItem(
            icon: Icons.check_circle,
            label: 'Done!',
            isActive: false,
            onTap: () {
              // Add navigation logic for Done page
            },
          ),
          NavBarItem(
            icon: Icons.settings,
            label: 'Setting',
            isActive: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    jwtToken: jwtToken ?? '',
                  ),
                ),
              );
            },
          ),
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