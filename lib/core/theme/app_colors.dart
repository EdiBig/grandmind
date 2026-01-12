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

  // Accent Colors
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentOrange = Color(0xFFFF9F43);
  static const Color accentYellow = Color(0xFFFFC837);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF5F7FB);
  static const Color backgroundDark = Color(0xFF0F1724);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1C2433);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Workout Type Colors
  static const Color workoutStrength = Color(0xFFFF6B6B);
  static const Color workoutCardio = Color(0xFF4ECDC4);
  static const Color workoutFlexibility = Color(0xFF9B59B6);
  static const Color workoutBodyweight = Color(0xFFF39C12);

  // Mood Colors (1-5 scale)
  static const Color mood1 = Color(0xFFE74C3C); // Very sad
  static const Color mood2 = Color(0xFFE67E22); // Sad
  static const Color mood3 = Color(0xFFF39C12); // Neutral
  static const Color mood4 = Color(0xFF27AE60); // Happy
  static const Color mood5 = Color(0xFF2ECC71); // Very happy

  // Chart Colors
  static const List<Color> chartColors = [
    primary,
    secondary,
    accent,
    accentOrange,
    accentYellow,
    Color(0xFF9B59B6),
    Color(0xFF3498DB),
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
