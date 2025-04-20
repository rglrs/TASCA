import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
        // Redirect ke login jika token kosong
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
        // Token expired, redirect to login
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
      final response = await http.post(
        Uri.parse('https://api.tascaid.com/api/logout'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout gagal, coba lagi nanti')),
        );
        setState(() {
          _loadingState = LoadingState.loaded;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saat logout: $e')));
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
        return _buildNoInternetView();
      case LoadingState.error:
        return _buildErrorView();
      case LoadingState.loaded:
        return _buildSettingsContent();
    }
  }

  Widget _buildNoInternetView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 100, color: Colors.grey[500]),
          SizedBox(height: 20),
          Text(
            'Tidak ada koneksi internet',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _initializeScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 100, color: Colors.red[500]),
          SizedBox(height: 20),
          Text(
            'Terjadi kesalahan',
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          Text(
            _errorMessage,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _initializeScreen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    final textColor = Colors.black87;
    final subtitleColor = Colors.grey.shade600;
    final iconColor = Colors.black87;
    final backgroundColor = Color(0xFFF0E9F7);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        // Profile Section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.withOpacity(0.2),
              child:
                  _userProfile?.picture == null || _userProfile!.picture.isEmpty
                      ? const Icon(Icons.person, color: Colors.red)
                      : ClipOval(
                        child: Image.network(
                          _userProfile!.picture,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.person, color: Colors.red);
                          },
                        ),
                      ),
            ),
            title: Text(
              _userProfile?.name ?? '',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
            ),
            subtitle: Text(
              _userProfile?.email ?? '',
              style: TextStyle(color: subtitleColor),
            ),
            trailing: Icon(Icons.chevron_right, color: subtitleColor),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );

              await _fetchUserProfile();
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
              ListTile(
                leading: Icon(Icons.timer_outlined, color: iconColor),
                title: Text(
                  'Focus Timer',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: subtitleColor),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FocusTimerScreen()),
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
                leading: Icon(Icons.message_outlined, color: iconColor),
                title: Text(
                  'Send Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: subtitleColor),
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
              ListTile(
                leading: Icon(Icons.thumb_up_alt_outlined, color: iconColor),
                title: Text(
                  'Leave Rating',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                trailing: Icon(Icons.chevron_right, color: subtitleColor),
                onTap: () {
                  // Use the user's actual ID from _userProfile
                  context.showRatingModal(
                    username: _userProfile?.username ?? '',
                  );
                },
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
                leading: Icon(Icons.password_outlined, color: iconColor),
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
