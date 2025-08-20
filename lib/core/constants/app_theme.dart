// ignore_for_file: deprecated_member_use


import 'package:flutter/material.dart';
import 'package:taskflow_ai/features/tasks/domain/task_model.dart';

class AppTheme {
  // --- Primary Color Palette ---
  // A modern, professional blue. Great for primary actions and branding.
  static const Color primaryColor = Color(0xFF4A90E2);

  // --- Light Theme Colors ---
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF8A8A8E);

  // --- Dark Theme Colors ---
  static const Color darkBackground = Color(0xFF1C1C1E);
  static const Color darkSurface = Color(0xFF2C2C2E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8D8D93);

  // --- Multi-variant Background Gradients ---
  // These gradients can be used on screens like the dashboard for a premium feel.
  static final BoxDecoration lightBackgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryColor.withOpacity(0.1), lightBackground, lightBackground],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static final BoxDecoration darkBackgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [primaryColor.withOpacity(0.2), darkBackground, darkBackground],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  // --- Priority Colors ---
  // To visually distinguish tasks by priority.
  static Color priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade400;
      case TaskPriority.medium:
        return Colors.orange.shade400;
      case TaskPriority.low:
        return Colors.green.shade400;
    }
  }

  // --- ThemeData Definitions ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      surface: lightSurface,
      background: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextPrimary,
      onBackground: lightTextPrimary,
    ),
    textTheme: const TextTheme(
      // Define text styles here
      headlineMedium: TextStyle(color: lightTextPrimary, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: lightTextSecondary),
    ),
    // Define other theme properties like AppBarTheme, ButtonTheme, etc.
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      surface: darkSurface,
      background: darkBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: darkTextSecondary),
    ),
    // Define other theme properties
  );
}