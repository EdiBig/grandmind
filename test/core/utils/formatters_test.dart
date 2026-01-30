import 'package:flutter_test/flutter_test.dart';
import 'package:kinesa/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('formatDate', () {
      test('formats date correctly', () {
        final date = DateTime(2024, 1, 15);
        expect(Formatters.formatDate(date), 'Jan 15, 2024');
      });

      test('formats date with different month', () {
        final date = DateTime(2024, 12, 25);
        expect(Formatters.formatDate(date), 'Dec 25, 2024');
      });

      test('formats date with single digit day', () {
        final date = DateTime(2024, 3, 5);
        expect(Formatters.formatDate(date), 'Mar 5, 2024');
      });
    });

    group('formatDateShort', () {
      test('formats date in short format', () {
        final date = DateTime(2024, 1, 15);
        expect(Formatters.formatDateShort(date), '01/15/2024');
      });

      test('formats date with padding', () {
        final date = DateTime(2024, 3, 5);
        expect(Formatters.formatDateShort(date), '03/05/2024');
      });
    });

    group('formatTime', () {
      test('formats time in 12-hour format with AM', () {
        final time = DateTime(2024, 1, 15, 9, 30);
        expect(Formatters.formatTime(time), '9:30 AM');
      });

      test('formats time in 12-hour format with PM', () {
        final time = DateTime(2024, 1, 15, 15, 45);
        expect(Formatters.formatTime(time), '3:45 PM');
      });

      test('formats noon correctly', () {
        final time = DateTime(2024, 1, 15, 12, 0);
        expect(Formatters.formatTime(time), '12:00 PM');
      });

      test('formats midnight correctly', () {
        final time = DateTime(2024, 1, 15, 0, 0);
        expect(Formatters.formatTime(time), '12:00 AM');
      });
    });

    group('formatDateTime', () {
      test('formats date and time together', () {
        final dateTime = DateTime(2024, 1, 15, 15, 45);
        expect(Formatters.formatDateTime(dateTime), 'Jan 15, 2024 at 3:45 PM');
      });
    });

    group('formatRelativeTime', () {
      test('returns "Just now" for recent times', () {
        final now = DateTime.now();
        final recent = now.subtract(const Duration(seconds: 30));
        expect(Formatters.formatRelativeTime(recent), 'Just now');
      });

      test('returns minutes ago for times under an hour', () {
        final now = DateTime.now();
        final minutesAgo = now.subtract(const Duration(minutes: 5));
        expect(Formatters.formatRelativeTime(minutesAgo), '5 minutes ago');
      });

      test('returns singular minute', () {
        final now = DateTime.now();
        final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
        expect(Formatters.formatRelativeTime(oneMinuteAgo), '1 minute ago');
      });

      test('returns hours ago for times under a day', () {
        final now = DateTime.now();
        final hoursAgo = now.subtract(const Duration(hours: 3));
        expect(Formatters.formatRelativeTime(hoursAgo), '3 hours ago');
      });

      test('returns singular hour', () {
        final now = DateTime.now();
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        expect(Formatters.formatRelativeTime(oneHourAgo), '1 hour ago');
      });

      test('returns "Yesterday" for previous day', () {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        expect(Formatters.formatRelativeTime(yesterday), 'Yesterday');
      });

      test('returns days ago for times under a week', () {
        final now = DateTime.now();
        final daysAgo = now.subtract(const Duration(days: 5));
        expect(Formatters.formatRelativeTime(daysAgo), '5 days ago');
      });

      test('returns weeks ago for times under a month', () {
        final now = DateTime.now();
        final weeksAgo = now.subtract(const Duration(days: 14));
        expect(Formatters.formatRelativeTime(weeksAgo), '2 weeks ago');
      });

      test('returns singular week', () {
        final now = DateTime.now();
        final oneWeekAgo = now.subtract(const Duration(days: 7));
        expect(Formatters.formatRelativeTime(oneWeekAgo), '1 week ago');
      });

      test('returns months ago for times under a year', () {
        final now = DateTime.now();
        final monthsAgo = now.subtract(const Duration(days: 60));
        expect(Formatters.formatRelativeTime(monthsAgo), '2 months ago');
      });

      test('returns singular month', () {
        final now = DateTime.now();
        final oneMonthAgo = now.subtract(const Duration(days: 30));
        expect(Formatters.formatRelativeTime(oneMonthAgo), '1 month ago');
      });

      test('returns years ago for times over a year', () {
        final now = DateTime.now();
        final yearsAgo = now.subtract(const Duration(days: 730));
        expect(Formatters.formatRelativeTime(yearsAgo), '2 years ago');
      });

      test('returns singular year', () {
        final now = DateTime.now();
        final oneYearAgo = now.subtract(const Duration(days: 365));
        expect(Formatters.formatRelativeTime(oneYearAgo), '1 year ago');
      });
    });

    group('formatDuration', () {
      test('formats minutes only when under an hour', () {
        expect(Formatters.formatDuration(45), '45m');
      });

      test('formats hours only when no remaining minutes', () {
        expect(Formatters.formatDuration(60), '1h');
        expect(Formatters.formatDuration(120), '2h');
      });

      test('formats hours and minutes together', () {
        expect(Formatters.formatDuration(90), '1h 30m');
        expect(Formatters.formatDuration(150), '2h 30m');
      });

      test('handles zero minutes', () {
        expect(Formatters.formatDuration(0), '0m');
      });
    });

    group('formatTimeMMSS', () {
      test('formats seconds to mm:ss', () {
        expect(Formatters.formatTimeMMSS(65), '01:05');
        expect(Formatters.formatTimeMMSS(125), '02:05');
      });

      test('handles zero seconds', () {
        expect(Formatters.formatTimeMMSS(0), '00:00');
      });

      test('handles exact minutes', () {
        expect(Formatters.formatTimeMMSS(60), '01:00');
        expect(Formatters.formatTimeMMSS(120), '02:00');
      });

      test('pads single digit minutes and seconds', () {
        expect(Formatters.formatTimeMMSS(5), '00:05');
        expect(Formatters.formatTimeMMSS(65), '01:05');
      });
    });

    group('formatWeight', () {
      test('formats weight with kg unit', () {
        expect(Formatters.formatWeight(75.0), '75.0 kg');
      });

      test('formats weight with one decimal place', () {
        expect(Formatters.formatWeight(75.55), '75.5 kg');
      });
    });

    group('formatHeight', () {
      test('formats height with cm unit', () {
        expect(Formatters.formatHeight(175.0), '175 cm');
      });

      test('formats height without decimals', () {
        expect(Formatters.formatHeight(175.5), '176 cm');
      });
    });

    group('formatDistance', () {
      test('formats distance in km for values >= 1', () {
        expect(Formatters.formatDistance(5.0), '5.00 km');
        expect(Formatters.formatDistance(5.25), '5.25 km');
      });

      test('formats distance in meters for values < 1', () {
        expect(Formatters.formatDistance(0.5), '500 m');
        expect(Formatters.formatDistance(0.75), '750 m');
      });
    });

    group('formatCalories', () {
      test('formats calories with cal unit', () {
        expect(Formatters.formatCalories(250), '250 cal');
        expect(Formatters.formatCalories(1500), '1500 cal');
      });
    });

    group('formatNumber', () {
      test('formats number with commas', () {
        expect(Formatters.formatNumber(1000), '1,000');
        expect(Formatters.formatNumber(1234567), '1,234,567');
      });

      test('handles small numbers without commas', () {
        expect(Formatters.formatNumber(100), '100');
        expect(Formatters.formatNumber(999), '999');
      });
    });

    group('formatPercentage', () {
      test('formats percentage with % symbol', () {
        expect(Formatters.formatPercentage(75.0), '75%');
      });

      test('rounds percentage to nearest integer', () {
        expect(Formatters.formatPercentage(75.5), '76%');
        expect(Formatters.formatPercentage(75.4), '75%');
      });
    });

    group('formatDecimal', () {
      test('formats decimal with default 2 places', () {
        expect(Formatters.formatDecimal(3.14159), '3.14');
      });

      test('formats decimal with custom decimal places', () {
        expect(Formatters.formatDecimal(3.14159, decimalPlaces: 3), '3.142');
        expect(Formatters.formatDecimal(3.14159, decimalPlaces: 1), '3.1');
      });
    });

    group('formatDayOfWeek', () {
      test('returns full day name', () {
        final monday = DateTime(2024, 1, 15); // Monday
        expect(Formatters.formatDayOfWeek(monday), 'Monday');
      });
    });

    group('formatMonthYear', () {
      test('formats month and year', () {
        final date = DateTime(2024, 1, 15);
        expect(Formatters.formatMonthYear(date), 'January 2024');
      });
    });

    group('getDaySuffix', () {
      test('returns st for 1st', () {
        expect(Formatters.getDaySuffix(1), 'st');
        expect(Formatters.getDaySuffix(21), 'st');
        expect(Formatters.getDaySuffix(31), 'st');
      });

      test('returns nd for 2nd', () {
        expect(Formatters.getDaySuffix(2), 'nd');
        expect(Formatters.getDaySuffix(22), 'nd');
      });

      test('returns rd for 3rd', () {
        expect(Formatters.getDaySuffix(3), 'rd');
        expect(Formatters.getDaySuffix(23), 'rd');
      });

      test('returns th for 11th, 12th, 13th (special cases)', () {
        expect(Formatters.getDaySuffix(11), 'th');
        expect(Formatters.getDaySuffix(12), 'th');
        expect(Formatters.getDaySuffix(13), 'th');
      });

      test('returns th for other numbers', () {
        expect(Formatters.getDaySuffix(4), 'th');
        expect(Formatters.getDaySuffix(10), 'th');
        expect(Formatters.getDaySuffix(15), 'th');
        expect(Formatters.getDaySuffix(20), 'th');
      });
    });

    group('formatOrdinalDate', () {
      test('formats date with ordinal suffix', () {
        final date = DateTime(2024, 1, 1);
        expect(Formatters.formatOrdinalDate(date), '1st January 2024');
      });

      test('formats date with 2nd suffix', () {
        final date = DateTime(2024, 1, 2);
        expect(Formatters.formatOrdinalDate(date), '2nd January 2024');
      });

      test('formats date with 3rd suffix', () {
        final date = DateTime(2024, 1, 3);
        expect(Formatters.formatOrdinalDate(date), '3rd January 2024');
      });

      test('formats date with th suffix', () {
        final date = DateTime(2024, 1, 15);
        expect(Formatters.formatOrdinalDate(date), '15th January 2024');
      });
    });
  });
}
