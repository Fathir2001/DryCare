import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary gradient colors
  static const Color deepPurple = Color(0xFF4B2C5E);
  static const Color dustyRose = Color(0xFFB07A8F);
  static const Color softPeach = Color(0xFFF2A07B);

  // Accent
  static const Color coral = Color(0xFFFF7A59);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFD6C7D9);

  // Cards - glass style
  static const Color cardBackground = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color cardBackgroundLight = Color(0x1A4B2C5E);

  // Dark theme
  static const Color darkBackground = Color(0xFF1A1025);
  static const Color darkSurface = Color(0xFF241635);
  static const Color darkCard = Color(0xFF2D1F3E);

  // Light theme
  static const Color lightBackground = Color(0xFFFFF5F0);
  static const Color lightSurface = Color(0xFFFFEDE5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF2D1F3E);
  static const Color lightTextSecondary = Color(0xFF6B5A7A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepPurple, dustyRose, softPeach],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coral, Color(0xFFFF9A7B)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepPurple, Color(0xFF6B3F7F)],
  );

  // Severity colors
  static const Color mildGreen = Color(0xFF7BC67E);
  static const Color moderateYellow = Color(0xFFFFB74D);
  static const Color severeRed = Color(0xFFEF5350);
}
