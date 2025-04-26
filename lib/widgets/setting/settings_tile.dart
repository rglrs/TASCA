import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final VoidCallback onTap;
  final bool showTrailing;

  const SettingsTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.onTap,
    this.showTrailing = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.black87;
    final subtitleColor = Colors.grey.shade600;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: showTrailing
          ? Icon(Icons.chevron_right, color: subtitleColor)
          : null,
      onTap: onTap,
    );
  }
}