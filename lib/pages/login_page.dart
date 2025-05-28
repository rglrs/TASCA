import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'register_page.dart';
import 'pomodoro.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_pw.dart';
import 'package:tasca_mobile1/services/notification_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginIdentifierController =
      TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dapatkan notificationService dari provider
    _notificationService = Provider.of<NotificationService>(
      context,
      listen: false,
    );
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('https://api.tascaid.com/api/validate_token'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'token': token}),
        );

        if (response.statusCode == 200) {
          await _notificationService.registerDevice();

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PomodoroTimerPage()),
          );
        } else {
          await prefs.remove('auth_token');
          if (!mounted) return;
          _showErrorMessage('Sesi telah berakhir, silakan login ulang.');
        }
      } catch (e) {
        if (!mounted) return;
        _showErrorMessage('Terjadi kesalahan jaringan: ${e.toString()}');
      }
    }
  }

  Future<void> _login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String identifier = loginIdentifierController.text.trim();
      final String password = passwordController.text;

      if (identifier.isEmpty) {
        _showErrorMessage('Email atau username tidak boleh kosong');
        return;
      }

      if (password.isEmpty) {
        _showErrorMessage('Password tidak boleh kosong');
        return;
      }

      final bool isEmail = identifier.contains('@');
      final Map<String, String> requestBody = {'password': password};

      if (isEmail) {
        requestBody['email'] = identifier;
      } else {
        requestBody['username'] = identifier;
      }

      final response = await http.post(
        Uri.parse('https://api.tascaid.com/api/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Daftarkan device untuk notifikasi setelah login berhasil
        await _notificationService.registerDevice();

        if (!mounted) return;
        _showSuccessMessage('Login berhasil!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PomodoroTimerPage()),
        );
      } else {
        // Coba decode response untuk mendapatkan pesan error yang lebih spesifik
        String errorMessage =
            'Login gagal: Periksa kembali email/username dan password Anda.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          }
        } catch (_) {
          // Gunakan pesan default jika tidak bisa decode
        }
        _showErrorMessage(errorMessage);
      }
    } on SocketException {
      _showErrorMessage('Kesalahan Koneksi: Periksa koneksi internet Anda.');
    } catch (e) {
      _showErrorMessage('Terjadi kesalahan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('images/login.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 30.0,
                      bottom: 30.0,
                      left: 10.0,
                      right: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Gabung bersama Tasca, produktif bersama',
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: loginIdentifierController,
                          decoration: InputDecoration(
                            labelText: 'Email atau Username',
                            hintText: 'Masukkan email atau username Anda',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Masukkan password Anda',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12.0),
                              ),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordPage(),
                                ),
                              );
                            },
                            child: Text('Lupa Kata Sandi?'),
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : () => _login(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                            child:
                                _isLoading
                                    ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                    : Text(
                                      'Lanjut',
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Belum mempunyai akun? Sign Up',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
