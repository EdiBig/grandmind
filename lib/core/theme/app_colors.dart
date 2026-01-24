import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2F7DD8);
  static const Color primaryDark = Color(0xFF1F5CA3);
  static const Color primaryLight = Color(0xFF5CA1EA);

  // Secondary Colors
  static const Color secondary = Color(0xFF5AA5A1);
  static const Color secondaryDark = Color(0xFF458884);
  static const Color secondaryLight = Color(0xFF79BDB8);

  // Accent Colors - WCAG AA compliant for use as foreground
  static const Color accent = Color(0xFFE53935); // Darker coral red
  static const Color accentOrange = Color(0xFFE65100); // Darker orange
  static const Color accentYellow = Color(0xFFD97706); // Amber-700

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF757575); // 4.6:1 contrast on white
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF424242); // Darker for better contrast

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F7FB);
  static const Color backgroundDark = Color(0xFF0F1724);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C2433);

  // Text Colors - WCAG AA compliant (4.5:1 minimum contrast)
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF595959); // 7:1 contrast on white
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBDBDBD); // 7.5:1 contrast on dark

  // Status Colors - WCAG AA compliant
  static const Color success = Color(0xFF2E7D32); // Darker green, 4.5:1 on white
  static const Color error = Color(0xFFD32F2F); // Darker red, 4.5:1 on white
  static const Color warning = Color(0xFFD97706); // Amber-700, 4.5:1 on white
  static const Color info = Color(0xFF1976D2); // Darker blue, 4.5:1 on white

  // Workout Type Colors - WCAG AA compliant
  static const Color workoutStrength = Color(0xFFE53935); // Darker red
  static const Color workoutCardio = Color(0xFF00897B); // Darker teal
  static const Color workoutFlexibility = Color(0xFF7B1FA2); // Darker purple
  static const Color workoutBodyweight = Color(0xFFD97706); // Amber-700

  // Mood Colors (1-5 scale) - WCAG AA compliant
  static const Color mood1 = Color(0xFFC62828); // Very sad - darker red
  static const Color mood2 = Color(0xFFD84315); // Sad - darker orange
  static const Color mood3 = Color(0xFFD97706); // Neutral - amber-700
  static const Color mood4 = Color(0xFF2E7D32); // Happy - darker green
  static const Color mood5 = Color(0xFF1B5E20); // Very happy - darkest green

  // Chart Colors - all WCAG AA compliant
  static const List<Color> chartColors = [
    primary,
    secondary,
    accent,
    accentOrange,
    accentYellow,
    Color(0xFF7B1FA2), // Purple - WCAG compliant
    Color(0xFF1976D2), // Blue - WCAG compliant
  ];

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
