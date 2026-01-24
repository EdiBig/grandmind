import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension on BuildContext to easily access theme colors
///
/// Use these instead of hardcoded Colors.* values to ensure
/// theme consistency and WCAG compliance across light/dark modes.
///
/// Example usage:
/// ```dart
/// // Instead of: Colors.grey
/// context.colors.textSecondary
///
/// // Instead of: Colors.red
/// context.colors.error
///
/// // Instead of: Colors.green
/// context.colors.success
/// ```
extension ThemeContextExtension on BuildContext {
  /// Access semantic colors based on current theme
  AppSemanticColors get colors => AppSemanticColors(this);

  /// Quick access to color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Quick access to text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

/// Semantic color accessor that returns appropriate colors based on theme
class AppSemanticColors {
  final BuildContext _context;

  AppSemanticColors(this._context);

  bool get _isDark => Theme.of(_context).brightness == Brightness.dark;
  ColorScheme get _scheme => Theme.of(_context).colorScheme;

  // Primary colors
  Color get primary => _scheme.primary;
  Color get onPrimary => _scheme.onPrimary;
  Color get primaryContainer => _scheme.primaryContainer;
  Color get onPrimaryContainer => _scheme.onPrimaryContainer;

  // Secondary colors
  Color get secondary => _scheme.secondary;
  Color get onSecondary => _scheme.onSecondary;

  // Surface colors
  Color get surface => _scheme.surface;
  Color get onSurface => _scheme.onSurface;
  Color get surfaceVariant => _scheme.surfaceContainerHighest;
  Color get onSurfaceVariant => _scheme.onSurfaceVariant;

  // Background colors
  Color get background => _isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

  // Text colors - WCAG compliant
  Color get textPrimary => _isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
  Color get textSecondary => _isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

  // Status colors - WCAG compliant
  Color get success => AppColors.success;
  Color get error => _scheme.error;
  Color get warning => AppColors.warning;
  Color get info => AppColors.info;

  // Status colors with appropriate on-colors
  Color get onSuccess => AppColors.white;
  Color get onError => _scheme.onError;
  Color get onWarning => AppColors.white;
  Color get onInfo => AppColors.white;

  // Divider and outline colors
  Color get divider => _scheme.outlineVariant;
  Color get outline => _scheme.outline;

  // Disabled state colors
  Color get disabled => _isDark
      ? AppColors.greyDark.withValues(alpha: 0.38)
      : AppColors.grey.withValues(alpha: 0.38);
  Color get disabledOnSurface => _scheme.onSurface.withValues(alpha: 0.38);

  // Icon colors
  Color get icon => _scheme.onSurfaceVariant;
  Color get iconPrimary => _scheme.primary;

  // Card and container colors
  Color get card => _scheme.surface;
  Color get cardElevated => _scheme.surfaceContainerHigh;

  // Workout type colors
  Color get workoutStrength => AppColors.workoutStrength;
  Color get workoutCardio => AppColors.workoutCardio;
  Color get workoutFlexibility => AppColors.workoutFlexibility;
  Color get workoutBodyweight => AppColors.workoutBodyweight;

  // Mood colors
  Color moodColor(int level) {
    switch (level) {
      case 1: return AppColors.mood1;
      case 2: return AppColors.mood2;
      case 3: return AppColors.mood3;
      case 4: return AppColors.mood4;
      case 5: return AppColors.mood5;
      default: return AppColors.mood3;
    }
  }

  // Metric colors (for dashboard widgets)
  Color get metricSleep => AppColors.metricSleep;
  Color get metricEnergy => AppColors.metricEnergy;
  Color get metricSteps => AppColors.metricSteps;
  Color get metricHeart => AppColors.metricHeart;
  Color get metricHabits => AppColors.metricHabits;
  Color get metricWorkouts => AppColors.metricWorkouts;
  Color get metricNutrition => AppColors.metricNutrition;
  Color get metricMood => AppColors.metricMood;

  // Readiness score color based on value
  Color readinessColor(int score) {
    if (score <= 30) return AppColors.readinessLow;
    if (score <= 50) return AppColors.readinessModerate;
    if (score <= 70) return AppColors.readinessFair;
    if (score <= 85) return AppColors.readinessGood;
    return AppColors.readinessPeak;
  }

  // Rank colors (for leaderboards)
  Color get rankGold => AppColors.rankGold;
  Color get rankSilver => AppColors.rankSilver;
  Color get rankBronze => AppColors.rankBronze;

  // Secondary text colors for on-dark backgrounds
  Color get textSecondaryOnDark => AppColors.textSecondaryOnDark;
  Color get textMutedOnDark => AppColors.textMutedOnDark;
}

/// Extension for getting on-colors (text/icon colors to use on a background)
extension ColorOnExtension on Color {
  /// Get appropriate text color for this background color
  /// Uses WCAG luminance calculation
  Color get onColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? AppColors.textPrimaryLight : AppColors.textPrimaryDark;
  }

  /// Check if this color has sufficient contrast with another color
  /// Returns true if contrast ratio >= 4.5 (WCAG AA for normal text)
  bool hasWcagContrastWith(Color other) {
    final l1 = computeLuminance();
    final l2 = other.computeLuminance();
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    final contrastRatio = (lighter + 0.05) / (darker + 0.05);
    return contrastRatio >= 4.5;
  }
}

/// Pre-defined status color schemes for consistent usage
class StatusColors {
  StatusColors._();

  static Color background(BuildContext context, StatusType type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (type) {
      case StatusType.success:
        return AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1);
      case StatusType.error:
        return AppColors.error.withValues(alpha: isDark ? 0.2 : 0.1);
      case StatusType.warning:
        return AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1);
      case StatusType.info:
        return AppColors.info.withValues(alpha: isDark ? 0.2 : 0.1);
    }
  }

  static Color foreground(StatusType type) {
    switch (type) {
      case StatusType.success: return AppColors.success;
      case StatusType.error: return AppColors.error;
      case StatusType.warning: return AppColors.warning;
      case StatusType.info: return AppColors.info;
    }
  }
}

enum StatusType { success, error, warning, info }
