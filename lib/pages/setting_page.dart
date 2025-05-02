import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_settings_page.dart';
import 'focus_timer_page.dart';
import 'login_page.dart';
import 'rating_modal.dart';
import 'change_pw.dart';
import 'package:tasca_mobile1/widgets/navbar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:async';

import 'package:tasca_mobile1/widgets/setting/no_internet_view.dart';
import 'package:tasca_mobile1/widgets/setting/error_view.dart';
import 'package:tasca_mobile1/widgets/setting/profile_tile.dart';
import 'package:tasca_mobile1/widgets/setting/settings_section.dart';
import 'package:tasca_mobile1/widgets/setting/settings_tile.dart';
import 'package:tasca_mobile1/widgets/setting/logout_tile.dart';
import 'package:tasca_mobile1/services/notification_service.dart';

enum LoadingState { loading, loaded, error, noInternet }

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
    String pictureUrl = json['picture'] ?? '';

    if (pictureUrl.isNotEmpty && !pictureUrl.startsWith('http')) {
      pictureUrl = 'https://api.tascaid.com/storage/upload/$pictureUrl';
    }

    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      phone: json['phone'] ?? '',
      picture: pictureUrl,
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final String? jwtToken;

  const SettingsScreen({super.key, required this.jwtToken});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserProfile? _userProfile;
  LoadingState _loadingState = LoadingState.loading;
  String? _token;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    try {
      await _getToken();
      await _fetchUserProfile();
    } catch (e) {
      setState(() {
        _loadingState = LoadingState.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _getToken() async {
    try {
      if (widget.jwtToken != null && widget.jwtToken!.isNotEmpty) {
        _token = widget.jwtToken;
      } else {
        final prefs = await SharedPreferences.getInstance();
        _token = prefs.getString('auth_token');
      }

      if (_token == null || _token!.isEmpty) {
        _redirectToLogin();
        return;
      }
    } catch (e) {
      throw Exception('Gagal mendapatkan token: $e');
    }
  }

  Future<void> _fetchUserProfile() async {
    setState(() {
      _loadingState = LoadingState.loading;
    });

    try {
      // Cek koneksi internet
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          setState(() {
            _loadingState = LoadingState.noInternet;
          });
          return;
        }
      } on SocketException catch (_) {
        setState(() {
          _loadingState = LoadingState.noInternet;
        });
        return;
      }

      final response = await http
          .get(
            Uri.parse('https://api.tascaid.com/api/profile'),
            headers: {
              'Authorization': 'Bearer $_token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Koneksi timeout');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _userProfile = UserProfile.fromJson(data);
          _loadingState = LoadingState.loaded;
        });
      } else if (response.statusCode == 401) {
        _redirectToLogin();
      } else {
        setState(() {
          _loadingState = LoadingState.error;
          _errorMessage = 'Gagal memuat profil: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _loadingState = LoadingState.noInternet;
        _errorMessage = e.toString();
      });
    }
  }

  void _redirectToLogin() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('auth_token');
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  Future<void> _logout(BuildContext context) async {
    setState(() {
      _loadingState = LoadingState.loading;
    });

    try {
      final notificationService = Provider.of<NotificationService>(
        context,
        listen: false,
      );
      await notificationService.unregisterDevice();

      final response = await http.post(
        Uri.parse('https://api.tascaid.com/api/logout'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      // Hapus token bahkan jika permintaan gagal
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Masih hapus device dan lanjutkan ke login page meskipun API logout gagal
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Masih hapus token lokal meskipun error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } finally {
      setState(() {
        _loadingState = LoadingState.loaded;
      });
    }
  }

  Widget _buildContent() {
    switch (_loadingState) {
      case LoadingState.loading:
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        );
      case LoadingState.noInternet:
        return NoInternetView(onRetry: _initializeScreen);
      case LoadingState.error:
        return ErrorView(
          errorMessage: _errorMessage,
          onRetry: _initializeScreen,
        );
      case LoadingState.loaded:
        return _buildSettingsContent();
    }
  }

  Widget _buildSettingsContent() {
    final subtitleColor = Colors.grey.shade600;
    final iconColor = Colors.black87;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        // Profile Section
        ProfileTile(
          userProfile: _userProfile,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
            await _fetchUserProfile();
          },
        ),

        const SizedBox(height: 20),

        // General Section
        SettingsSection(
          title: 'General',
          children: [
            SettingsTile(
              icon: Icons.timer_outlined,
              title: 'Focus Timer',
              iconColor: iconColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FocusTimerScreen()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // About Section
        SettingsSection(
          title: 'About',
          children: [
            SettingsTile(
              icon: Icons.message_outlined,
              title: 'Send Feedback',
              iconColor: iconColor,
              onTap: () {
                launch(
                  'https://play.google.com/store/apps/details?id=com.tascaid.app',
                );
              },
            ),
            Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: subtitleColor.withOpacity(0.5),
            ),
            SettingsTile(
              icon: Icons.thumb_up_alt_outlined,
              title: 'Leave Rating',
              iconColor: iconColor,
              onTap: () {
                context.showRatingModal(username: _userProfile?.username ?? '');
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Account Section
        SettingsSection(
          title: 'Account',
          children: [
            SettingsTile(
              icon: Icons.password_outlined,
              title: 'Change Password',
              iconColor: iconColor,
              showTrailing: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Logout Button
        LogoutTile(onTap: () => _logout(context)),

        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // Main content
            Expanded(child: _buildContent()),

            Navbar(initialActiveIndex: 2),
          ],
        ),
      ),
    );
  }
}
