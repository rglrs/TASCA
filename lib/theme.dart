import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
);
