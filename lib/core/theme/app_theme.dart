import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sender_sms/core/constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme() {
    const baseColor = AppColors.textPrimary;
    const secondaryColor = AppColors.textSecondary;

    return TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        color: secondaryColor,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.success,
      error: AppColors.error,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightCard,
    textTheme: _buildTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: GoogleFonts.cairo(
        color: AppColors.textHint,
        fontSize: 14,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFF1F5F9)),
      ),
    ),
    dividerColor: const Color(0xFFF1F5F9),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: GoogleFonts.cairo(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );
}
