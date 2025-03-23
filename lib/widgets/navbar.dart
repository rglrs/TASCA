import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ), // Reduced horizontal padding
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
          ),
          NavBarItem(
            icon: Icons.format_list_bulleted_add,
            label: 'To Do',
            isActive: false,
          ),
          NavBarItem(
            icon: Icons.calendar_today,
            label: 'Date',
            isActive: false,
          ),
          NavBarItem(icon: Icons.check_circle, label: 'Done!', isActive: false),
          NavBarItem(icon: Icons.settings, label: 'Setting', isActive: false),
        ],
      ),
    );
  }
}

class NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;

  const NavBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.isActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Colors.deepPurple : Colors.grey, size: 28),
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
    );
  }
}
