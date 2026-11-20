import 'package:flutter/material.dart';

/// Design tokens for colors used throughout LET'S FLY TGR.
/// Engineered for high contrast, minimal distraction, and rich dual-theme depth.
abstract class AppColors {
  // Brand Identity Colors
  static const Color primary = Color(0xFF4F46E5);       // Deep Indigo
  static const Color primaryLight = Color(0xFF818CF8);  // Indigo Tint
  static const Color primaryDark = Color(0xFF3730A3);   // Midnight Indigo

  static const Color secondary = Color(0xFF10B981);     // Emerald
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF047857);

  static const Color accent = Color(0xFFF59E0B);        // Amber Flame
  static const Color accentLight = Color(0xFFFBBF24);

  // Semantic & Feedback
  static const Color success = Color(0xFF22C55E);       // Green
  static const Color warning = Color(0xFFF97316);       // Orange
  static const Color error = Color(0xFFEF4444);         // Rose Red
  static const Color info = Color(0xFF3B82F6);          // Blue
  static const Color focus = Color(0xFF6366F1);         // Vibrant Active Focus
  static const Color breakMode = Color(0xFF06B6D4);     // Cyan Rest

  // Light Mode Surfaces & Neutrals
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Mode Surfaces & Neutrals (OLED Optimized)
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceElevated = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Subject Preset Colors
  static const List<Color> subjectPalette = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
    Color(0xFF06B6D4), // Cyan
    Color(0xFFE11D48), // Rose
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF3B82F6), // Blue
  ];
}
