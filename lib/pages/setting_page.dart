import 'package:flutter/material.dart';
import 'package:tasca_mobile1/pages/focus_timer_page.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeToggle;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode ? Colors.white : Colors.black;
    final subtitleColor =
        widget.isDarkMode ? Colors.grey.shade400 : Colors.grey;
    final iconColor = widget.isDarkMode ? Colors.white70 : Colors.black87;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Status bar and title
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                child: Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    // Profile Section
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.withOpacity(0.2),
                          child: const Icon(Icons.person, color: Colors.red),
                        ),
                        title: Text(
                          'Alex26',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          'aloxander@gmail.com',
                          style: TextStyle(color: subtitleColor),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: subtitleColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // General Section
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                      child: Text(
                        'General',
                        style: TextStyle(color: subtitleColor, fontSize: 16),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              widget.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.wb_sunny_outlined,
                              color: iconColor,
                            ),
                            title: Text(
                              'Shift Mode',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            trailing: Switch(
                              value: widget.isDarkMode,
                              onChanged: widget.onThemeToggle,
                              activeTrackColor: Colors.grey.shade300,
                              activeColor: Colors.grey,
                            ),
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: subtitleColor.withOpacity(0.5),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.timer_outlined,
                              color: iconColor,
                            ),
                            title: Text(
                              'Focus Timer',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: subtitleColor,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FocusTimerScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // About Section
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                      child: Text(
                        'About',
                        style: TextStyle(color: subtitleColor, fontSize: 16),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.message_outlined,
                              color: iconColor,
                            ),
                            title: Text(
                              'Send Feedback',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: subtitleColor,
                            ),
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: subtitleColor.withOpacity(0.5),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.thumb_up_alt_outlined,
                              color: iconColor,
                            ),
                            title: Text(
                              'Leave Rating',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Account Section
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
                      child: Text(
                        'Account',
                        style: TextStyle(color: subtitleColor, fontSize: 16),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons.g_mobiledata,
                              size: 28,
                              color: iconColor,
                            ),
                            title: Text(
                              'Linking With Google',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: subtitleColor.withOpacity(0.5),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.g_mobiledata,
                              size: 28,
                              color: iconColor,
                            ),
                            title: Text(
                              'Unlinking With Google',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: subtitleColor.withOpacity(0.5),
                          ),
                          ListTile(
                            leading: Icon(
                              Icons.password_outlined,
                              color: iconColor,
                            ),
                            title: Text(
                              'Change Password',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logout Button
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const ListTile(
                        title: Center(
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
