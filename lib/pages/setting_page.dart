import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_settings_page.dart';
import 'focus_timer_page.dart';
import 'login_page.dart';
import 'change_pw.dart';
import 'package:tasca_mobile1/widgets/navbar.dart';

class UserProfile {
  final String name;
  final String email;
  final String username;
  final String phone;
  final String picture;

  UserProfile({
    required this.name,
    required this.email,
    required this.username,
    required this.phone,
    required this.picture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      picture: json['picture'] ?? '',
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final String jwtToken;

  const SettingsScreen({super.key, required this.jwtToken});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.tascaid.com/api/profile'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _userProfile = UserProfile.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load profile: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Call the logout API
      final response = await http.post(
        Uri.parse('https://api.tascaid.com/api/logout'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
          'Content-Type': 'application/json',
        },
      );

      // Clear token from SharedPreferences regardless of API response
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      if (response.statusCode == 200) {
        // If logout was successful, navigate to LoginPage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false, // Remove all previous pages
        );
      } else {
        // If logout failed, show error message but still navigate to login
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout gagal, coba lagi!')));

        // Navigate to login page anyway
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Even if there's an error with the API call, we still want to clear the token and navigate to login
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logged out with error: $e')));

      // Navigate to login page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.black87;
    final subtitleColor = Colors.grey.shade600;
    final iconColor = Colors.black87;
    final backgroundColor = Color(0xFFF0E9F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child:
                        _isLoading
                            ? const ListTile(
                              title: Center(child: CircularProgressIndicator()),
                            )
                            : _errorMessage.isNotEmpty
                            ? ListTile(
                              title: Text(
                                'Error loading profile',
                                style: TextStyle(color: textColor),
                              ),
                            )
                            : ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.withOpacity(0.2),
                                backgroundImage:
                                    _userProfile?.picture != null &&
                                            _userProfile!.picture.isNotEmpty
                                        ? NetworkImage(_userProfile!.picture)
                                        : null,
                                child:
                                    _userProfile?.picture == null ||
                                            _userProfile!.picture.isEmpty
                                        ? const Icon(
                                          Icons.person,
                                          color: Colors.red,
                                        )
                                        : null,
                              ),
                              title: Text(
                                _userProfile?.name ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Text(
                                _userProfile?.email ?? '',
                                style: TextStyle(color: subtitleColor),
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: subtitleColor,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(),
                                  ),
                                );
                              },
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // ListTile(
                        //   leading: Icon(
                        //     Icons.dark_mode_outlined,
                        //     color: iconColor,
                        //   ),
                        //   title: Text(
                        //     'Shift Mode',
                        //     style: TextStyle(
                        //       fontWeight: FontWeight.w500,
                        //       color: textColor,
                        //     ),
                        //   ),
                        //   trailing: Switch(
                        //     value: false, // Default to light mode
                        //     onChanged: (bool value) {
                        //       // Handle theme change
                        //     },
                        //     activeTrackColor: Colors.grey.shade300,
                        //     activeColor: Colors.grey,
                        //   ),
                        // ),
                        // Divider(
                        //   height: 1,
                        //   indent: 16,
                        //   endIndent: 16,
                        //   color: subtitleColor.withOpacity(0.5),
                        // ),
                        ListTile(
                          leading: Icon(Icons.timer_outlined, color: iconColor),
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
                      color: Colors.white,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Logout Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Center(
                        child: Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () => _logout(context),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Navbar(
                initialActiveIndex: 4,
              ), // Set the active index for Settings
            ),
          ],
        ),
      ),
    );
  }
}
