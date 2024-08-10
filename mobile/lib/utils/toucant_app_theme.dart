import 'package:flutter/material.dart';

final toucantDarkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A453B), brightness: Brightness.dark),
  scaffoldBackgroundColor: const Color(0xFF2D2D2D),
  primaryColor: const Color(0xFF2A453B),
);

final toucantLightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A453B), brightness: Brightness.light),
  scaffoldBackgroundColor: Colors.white,
  primaryColor: const Color(0xFF2A453B),
);
