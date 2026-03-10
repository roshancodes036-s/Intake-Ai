import 'package:flutter/material.dart';

class AppColors {
  // === 1. पुराने/Shared Colors (ताकि पुरानी फाइलों में एरर न आए) ===
  static const Color background = Color(0xFFFAFAFA);
  static const Color cardColor = Colors.white;
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF909AAB);
  static const Color primaryBlack = Color(0xFF111111);
  static const Color textPrimary = Color(0xFF111111); // Missing
  static const Color textSecondary = Color(0xFF8E8E93); // Missing

  // === 2. Light Theme Colors (नया डिज़ाइन) ===
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF8E8E93);

  // === 3. Dark Theme Colors (नया डिज़ाइन) ===
  static const Color darkBackground = Color(0xFF0D141C);
  static const Color darkCard = Color(0xFF1A222A);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF909AAB);

  // === 4. Brand & Macros Colors ===
  static const Color primaryGreen = Color(0xFF34C759);
  static const Color proteinColor = Color(0xFFFF3B30);
  static const Color carbsColor = Color(0xFFFF9500);
  static const Color fatColor = Color(0xFF007AFF);
}