import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Blues
  static const Color primary = Color(0xFF1A73E8);
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color primaryLight = Color(0xFF4A90D9);

  // Success Green
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);

  // Warning Orange
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Error Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF475569);

  // Light Theme
  static const Color lightBackground = Color(0xFFF1F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color textLight = Color(0xFFF8FAFC);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF1A73E8),
    Color(0xFF0EA5E9),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];

  // Stat Card Colors
  static const Color statBlue = Color(0xFF3B82F6);
  static const Color statGreen = Color(0xFF10B981);
  static const Color statRed = Color(0xFFEF4444);
  static const Color statOrange = Color(0xFFF59E0B);
}
