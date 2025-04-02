import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tasca_mobile1/pages/sliding_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasca_mobile1/pages/todo.dart'; // Pastikan path ini benar

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TASCA',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthCheckScreen(),
    );
  }
}

class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      setState(() {
        _isLoggedIn = token != null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_isLoggedIn) {
      // Jika sudah login, langsung menuju TodoPage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TodoPage()),
        );
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      // Jika belum login, tampilkan StartScreen
      return StartScreen();
    }
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Menggunakan animasi slide dari slicing.dart
        navigateWithSlide(context, const SlicingScreen(initialPage: 0));
      },
      child: Scaffold(
        // [Kode StartScreen tetap sama seperti sebelumnya]
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8E2FF), // Ungu muda di bagian atas
                    Color(0xFFF5F3FF), // Ungu sangat muda di bagian bawah
                  ],
                ),
              ),
            ),
            
            // Purple moon shadow in the top right corner
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 70,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            
            // Purple moon shadow in the bottom left corner
            Positioned(
              bottom: 0,
              left: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.15),
                      blurRadius: 60,
                      spreadRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
            
            // Main content (logo and text)
            SafeArea(
              child: Column(
                children: [
                  // Add space at the top to push logo down
                  const SizedBox(height: 80),
                  
                  // Logo and text in a centered column
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo dari folder assets
                          Image.asset(
                            'images/logo.png',
                            width: 280,
                            height: 280,
                          ),
                          const SizedBox(height: 40),
                          // Nama aplikasi dengan teks berwarna dan font Poppins
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'T',
                                style: GoogleFonts.poppins(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                'a',
                                style: GoogleFonts.poppins(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                's',
                                style: GoogleFonts.poppins(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                'c',
                                style: GoogleFonts.poppins(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              Text(
                                'a',
                                style: GoogleFonts.poppins(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}