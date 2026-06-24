import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Green (Adopted from the image)
  static const Color primary = Color(0xFF1B9016);
  static const Color primaryDark = Color(0xFF126C0E);
  static const Color primaryLight = Color(0xFF4CB347);

  // Success Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  // Warning Orange
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Error Red
  static const Color error = Color(0xFFF43F5E);
  static const Color errorLight = Color(0xFFFFE4E6);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkDivider = Color(0xFF334155);

  // Light Theme (Mint green background)
  static const Color lightBackground = Color(0xFFEAF9E7);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFF8FAFC);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1B9016),
    Color(0xFF4CB347),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFF43F5E),
    Color(0xFFE11D48),
  ];

  // Stat Card Colors
  static const Color statBlue = Color(0xFF3B82F6);
  static const Color statGreen = Color(0xFF1B9016);
  static const Color statRed = Color(0xFFF43F5E);
  static const Color statOrange = Color(0xFFF59E0B);
}
