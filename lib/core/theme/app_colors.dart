import 'package:flutter/material.dart';

class AppColors {
  // ─── Light Mode Colors (New Teal Theme) ─────────────────────────────────
  static const Color primaryLight = Color(0xFF1B4D4A); // Dark greenish-teal
  static const Color primaryVariantLight = Color(0xFF0F3A38); // Darker teal variant
  static const Color secondaryLight = Color(0xFF03DAC6);
  static const Color secondaryVariantLight = Color(0xFF018786);

  // ─── Dark Mode Colors (Old Purple Theme - Preserved) ───────────────────────
  static const Color primary = Color(0xFFBF5AF2); // Purple accent color (OLD DARK THEME)
  static const Color primaryDark = Color(0xFFBF5AF2); // Purple for dark mode

  // ─── Light Mode Backgrounds ─────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF5F5F5);

  // ─── Dark Mode Backgrounds (OLD - Preserved) ────────────────────────────
  static const Color background = Color(0xFF1C1C1E); // Dark background (OLD)
  static const Color backgroundDark = Color(0xFF1C1C1E); // OLD dark background
  static const Color surface = Color(0xFF2C2C2E); // Slightly lighter surface (OLD)
  static const Color surfaceDark = Color(0xFF2C2C2E); // OLD surface
  static const Color backgroundSurface = Color(0xFF3A3A3B); // OLD
  static const Color cardBackground = Color(0xFF2C2C2E); // Card background (OLD)
  static const Color cardDark = Color(0xFF2C2C2E); // OLD card

  // ─── Light Mode Text ─────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF757575);

  // ─── Dark Mode Text (OLD - Preserved) ───────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF); // White text (OLD)
  static const Color textPrimaryDark = Color(0xFFFFFFFF); // OLD
  static const Color textSecondary = Color(0xFF8E8E93); // Gray text (OLD)
  static const Color textSecondaryDark = Color(0xFF8E8E93); // OLD

  // ─── Light Mode Dividers ────────────────────────────────────────────────
  static const Color dividerLight = Color(0xFFD1D1D6);

  // ─── Dark Mode Dividers (OLD - Preserved) ────────────────────────────────
  static const Color divider = Color(0xFF3C3C3E); // Divider color (OLD)
  static const Color dividerDark = Color(0xFF3C3C3E); // OLD

  // ─── Status Colors ───────────────────────────────────────────────────────
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);

  // ─── Button Text (OLD - Preserved) ───────────────────────────────────────
  static const Color buttonText = Color(0xFFFFFFFF); // Button text color (OLD)

  // ─── Light Mode Backward-compat Aliases ─────────────────────────────────
  static const Color lightBackground = backgroundLight;
  static const Color lightSurface = surfaceLight;
  static const Color lightBackgroundSurface = Color(0xFFE5E5E5);
  static const Color lightTextPrimary = textPrimaryLight;
  static const Color lightTextSecondary = textSecondaryLight;
  static const Color lightCardBackground = cardLight;
  static const Color lightDivider = dividerLight;
  static const Color lightButtonText = Color(0xFFFFFFFF);
}
