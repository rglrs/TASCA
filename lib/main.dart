import 'package:flutter/material.dart';
import 'sliding_pages.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliding Pages Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.png'), // Path to your PNG image
              fit: BoxFit.cover, // Cover the entire screen
            ),
          ),
          child: SlidingPages(), // Set SlidingPages as the home widget
        ),
      ),
    );
  }
}