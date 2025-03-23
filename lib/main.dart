import 'package:flutter/material.dart';
// import 'pages/login_page.dart';
import 'pages/pomodoro.dart';

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
      home: PomodoroTimer(),
    );
  }
}
