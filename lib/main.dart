import 'package:flutter/material.dart';
// import 'login_page.dart';
import 'pomodoro.dart';

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
