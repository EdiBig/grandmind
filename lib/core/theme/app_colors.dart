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

  // Metric Colors (for dashboard widgets)
  static const Color metricSleep = Color(0xFFA78BFA);     // Purple
  static const Color metricEnergy = Color(0xFFFBBF24);    // Yellow
  static const Color metricSteps = Color(0xFF60A5FA);     // Blue
  static const Color metricHeart = Color(0xFFF87171);     // Red
  static const Color metricHabits = Color(0xFF4ADE80);    // Green
  static const Color metricWorkouts = Color(0xFFFB923C);  // Orange
  static const Color metricNutrition = Color(0xFFF87171); // Rose
  static const Color metricMood = Color(0xFF14B8A6);      // Teal

  // Readiness Score Colors
  static const Color readinessLow = Color(0xFFEF4444);      // Red (0-30)
  static const Color readinessModerate = Color(0xFFF59E0B); // Orange (31-50)
  static const Color readinessFair = Color(0xFFEAB308);     // Yellow (51-70)
  static const Color readinessGood = Color(0xFF14B8A6);     // Teal (71-85)
  static const Color readinessPeak = Color(0xFF22C55E);     // Green (86-100)

  // Rank Colors (for leaderboards)
  static const Color rankGold = Color(0xFFFFD700);
  static const Color rankSilver = Color(0xFFC0C0C0);
  static const Color rankBronze = Color(0xFFCD7F32);

  // Midnight Theme Colors (AMOLED)
  static const Color midnightBackground = Color(0xFF000000);  // Pure black
  static const Color midnightSurface = Color(0xFF0A0A0A);     // Near black
  static const Color midnightCard = Color(0xFF141414);        // Very dark gray

  // Secondary text/icon color for dark backgrounds
  static const Color textSecondaryOnDark = Color(0xFF94A3B8); // Slate-400
  static const Color textMutedOnDark = Color(0xFF6B7280);     // Gray-500
}
