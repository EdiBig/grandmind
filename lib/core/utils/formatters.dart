import 'package:intl/intl.dart';

/// Formatting utilities for dates, numbers, and other data
class Formatters {
  Formatters._();

  /// Formats date to readable string (e.g., "Jan 15, 2024")
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }

  /// Formats date to short string (e.g., "01/15/2024")
  static String formatDateShort(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date);
  }

  /// Formats time (e.g., "3:45 PM")
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  /// Formats date and time (e.g., "Jan 15, 2024 at 3:45 PM")
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y \'at\' h:mm a').format(dateTime);
  }

  /// Formats relative time (e.g., "2 hours ago", "Yesterday")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Formats duration in minutes to readable string (e.g., "1h 30m", "45m")
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${remainingMinutes}m';
  }

  /// Formats duration in seconds to mm:ss format
  static String formatTimeMMSS(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Formats weight with unit (kg)
  static String formatWeight(double weight) {
    return '${weight.toStringAsFixed(1)} kg';
  }

  /// Formats height with unit (cm)
  static String formatHeight(double height) {
    return '${height.toStringAsFixed(0)} cm';
  }

  /// Formats distance with unit (km)
  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(2)} km';
  }

  /// Formats calories
  static String formatCalories(int calories) {
    return '$calories cal';
  }

  /// Formats number with commas (e.g., 1,234,567)
  static String formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  /// Formats percentage (e.g., "75%")
  static String formatPercentage(double value) {
    return '${value.toStringAsFixed(0)}%';
  }

  /// Formats decimal to specified places
  static String formatDecimal(double value, {int decimalPlaces = 2}) {
    return value.toStringAsFixed(decimalPlaces);
  }

  /// Formats day of week (e.g., "Monday")
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Formats month and year (e.g., "January 2024")
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM y').format(date);
  }

  /// Gets day suffix (st, nd, rd, th)
  static String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Formats ordinal date (e.g., "1st", "2nd", "3rd", "15th")
  static String formatOrdinalDate(DateTime date) {
    final day = date.day;
    final suffix = getDaySuffix(day);
    return '$day$suffix ${DateFormat('MMMM y').format(date)}';
  }
}
