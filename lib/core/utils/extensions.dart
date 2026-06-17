import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {
  bool get isValidPhone {
    final cleaned = replaceAll(RegExp(r'[\s\-\+\(\)]'), '');
    return cleaned.length >= 8 &&
        cleaned.length <= 15 &&
        RegExp(r'^\d+$').hasMatch(cleaned);
  }

  String get cleanPhone {
    return replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  bool get isNotBlank => trim().isNotEmpty;
}

extension DateTimeExtension on DateTime {
  String get formattedDate {
    return DateFormat('dd/MM/yyyy', 'ar').format(this);
  }

  String get formattedDateTime {
    return DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(this);
  }

  String get formattedTime {
    return DateFormat('hh:mm a', 'ar').format(this);
  }

  String get relativeTime {
    final now = DateTime.now();
    final diff = now.difference(this);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 30) return 'منذ ${diff.inDays} يوم';
    return formattedDate;
  }
}

extension IntExtension on int {
  String get arabicNumber {
    return toString();
  }

  String withCommas() {
    return NumberFormat('#,###').format(this);
  }
}

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
