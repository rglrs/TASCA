import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tasca_mobile1/pages/sliding_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasca_mobile1/pages/todo.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// GUNAKAN ALIAS UNTUK PROVIDER LAMA
import 'package:provider/provider.dart' as old_provider;
import 'package:tasca_mobile1/providers/task_provider.dart';
import 'package:tasca_mobile1/services/notification_service.dart';
// Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;

  SlidePageRoute({required this.page, this.direction = AxisDirection.right})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: const Duration(milliseconds: 800),
        reverseTransitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          late Offset begin;
          late Offset beginSecondary;

          switch (direction) {
            case AxisDirection.right:
              begin = const Offset(1.0, 0.0);
              beginSecondary = const Offset(-0.3, 0.0);
              break;
            case AxisDirection.left:
              begin = const Offset(-1.0, 0.0);
              beginSecondary = const Offset(0.3, 0.0);
              break;
            case AxisDirection.up:
              begin = const Offset(0.0, 1.0);
              beginSecondary = const Offset(0.0, -0.3);
              break;
            case AxisDirection.down:
              begin = const Offset(0.0, -1.0);
              beginSecondary = const Offset(0.0, 0.3);
              break;
          }

          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          const secondaryCurve = Curves.easeInCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var secondaryTween = Tween(
            begin: end,
            end: beginSecondary,
          ).chain(CurveTween(curve: secondaryCurve));
          var scaleTween = Tween(
            begin: 0.95,
            end: 1.0,
          ).chain(CurveTween(curve: curve));
          var secondaryScaleTween = Tween(
            begin: 1.0,
            end: 0.95,
          ).chain(CurveTween(curve: secondaryCurve));
          var fadeTween = Tween(
            begin: 0.5,
            end: 1.0,
          ).chain(CurveTween(curve: curve));

          Widget currentPage = SlideTransition(
            position: secondaryAnimation.drive(secondaryTween),
            child: ScaleTransition(
              scale: secondaryAnimation.drive(secondaryScaleTween),
              child: child,
            ),
          );

          Widget newPage = SlideTransition(
            position: animation.drive(tween),
            child: ScaleTransition(
              scale: animation.drive(scaleTween),
              child: child,
            ),
          );

          if (secondaryAnimation.status == AnimationStatus.reverse) {
            return currentPage;
          } else {
            return FadeTransition(
              opacity: animation.drive(fadeTween),
              child: newPage,
            );
          }
        },
      );
}

void navigateWithSlide(
  BuildContext context,
  Widget page, {
  AxisDirection direction = AxisDirection.right,
}) {
  Navigator.of(context).push(SlidePageRoute(page: page, direction: direction));
}

void navigateReplaceWithSlide(
  BuildContext context,
  Widget page, {
  AxisDirection direction = AxisDirection.right,
}) {
  Navigator.of(
    context,
  ).pushReplacement(SlidePageRoute(page: page, direction: direction));
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeNotifications();
  final notificationService = NotificationService(
    'https://api.tascaid.com',
    () async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token') ?? '';
    },
  );

  await notificationService.initializeOneSignal(
    'c3856067-4248-4f33-9547-198da753f8d4',
  );

  runApp(
    ProviderScope(
      child: old_provider.MultiProvider(
        providers: [
          old_provider.ChangeNotifierProvider(create: (_) => TaskProvider()),
          old_provider.Provider<NotificationService>.value(
            value: notificationService,
          ),
        ],
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TASCA',
          home: StartScreen(),
        ),
      ),
    ),
  );
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return old_provider.MultiProvider(
      providers: [
        old_provider.ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TASCA',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const StartScreen(),
      ),
    );
  }
}

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
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
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const TodoPage()),
        );
      } else {
        navigateReplaceWithSlide(
          context,
          const SlicingScreen(initialPage: 0),
          direction: AxisDirection.right,
        );
      }
    } catch (e) {
      if (!mounted) return;
      navigateReplaceWithSlide(
        context,
        const SlicingScreen(initialPage: 0),
        direction: AxisDirection.right,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8E2FF), Color(0xFFF5F3FF)],
              ),
            ),
          ),
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
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('images/logo.png', width: 280, height: 280),
                        const SizedBox(height: 40),
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
    );
  }
}
