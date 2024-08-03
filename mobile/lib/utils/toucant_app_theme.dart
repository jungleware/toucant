import 'package:flutter/material.dart';

final toucantDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2A453B), brightness: Brightness.dark),
  scaffoldBackgroundColor: Color(0xFF2D2D2D),
  primaryColor: Color(0xFF2A453B),
);

final toucantLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2A453B), brightness: Brightness.light),
  scaffoldBackgroundColor: Colors.white,
  primaryColor: Color(0xFF2A453B),
);
