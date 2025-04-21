import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tasca_mobile1/pages/sliding_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasca_mobile1/pages/todo.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeNotifications();
  runApp(MyApp());
}

// Initialize local notifications
Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TASCA',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Check login status and navigate after 5 seconds
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    try {
      await Future.delayed(const Duration(seconds: 5));
      
      if (!mounted) return;
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (!mounted) return;
      
      if (token != null) {
        // User is logged in, navigate to TodoPage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TodoPage()),
        );
      } else {
        // User is not logged in, navigate to StartScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const StartScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      // If error occurs, still navigate to StartScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const StartScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8E2FF),
              Color(0xFFF5F3FF),
            ],
          ),
        ),
        child: Center(
          child: Image.asset(
            'images/logo.png',
            width: 280,
            height: 280,
          ),
        ),
      ),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigateWithSlide(context, const SlicingScreen(initialPage: 0));
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8E2FF),
                    Color(0xFFF5F3FF),
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
                          // Logo from assets folder
                          Image.asset(
                            'images/logo.png',
                            width: 280,
                            height: 280,
                          ),
                          const SizedBox(height: 40),
                          // Application name with colored text and Poppins font
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
                          
                          const SizedBox(height: 60),
                          
                          // Static "Tap to continue" text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: Theme.of(context).primaryColor,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tap to continue',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).primaryColor,
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
