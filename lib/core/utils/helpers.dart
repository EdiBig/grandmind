import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// General helper utilities
class Helpers {
  Helpers._();

  /// Shows a snackbar with a message
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Shows a success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.success,
    );
  }

  /// Shows an error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error,
    );
  }

  /// Shows a confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows a loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  /// Hides the current dialog
  static void hideDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Unfocus keyboard
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Calculates BMI (Body Mass Index)
  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Gets BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Generates a random motivational tip
  static String getMotivationalTip() {
    final tips = [
      'Small steps every day lead to big changes',
      'Your body can do it, it\'s your mind you need to convince',
      'The only bad workout is the one you didn\'t do',
      'Progress is progress, no matter how small',
      'Consistency is key to success',
      'Believe in yourself and your goals',
      'Every workout counts toward your goal',
      'You\'re stronger than you think',
      'Make time for your health today',
      'Your future self will thank you',
    ];
    return tips[DateTime.now().millisecondsSinceEpoch % tips.length];
  }

  /// Calculates streak from list of dates
  static int calculateStreak(List<DateTime> dates) {
    if (dates.isEmpty) return 0;

    final sortedDates = dates.toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending

    var streak = 1;
    var currentDate = _normalizeDate(sortedDates[0]);
    final today = _normalizeDate(DateTime.now());

    // Check if the most recent date is today or yesterday
    if (currentDate.isBefore(today.subtract(const Duration(days: 1)))) {
      return 0; // Streak is broken
    }

    for (var i = 1; i < sortedDates.length; i++) {
      final nextDate = _normalizeDate(sortedDates[i]);
      final expectedDate = currentDate.subtract(const Duration(days: 1));

      if (_isSameDay(nextDate, expectedDate)) {
        streak++;
        currentDate = nextDate;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Normalizes DateTime to date only (removes time component)
  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Checks if two dates are on the same day
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Checks if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  /// Checks if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return _isSameDay(date, yesterday);
  }

  /// Gets greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  /// Capitalizes first letter of a string
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Converts snake_case to Title Case
  static String snakeToTitleCase(String text) {
    return text
        .split('_')
        .map((word) => capitalize(word))
        .join(' ');
  }
}
