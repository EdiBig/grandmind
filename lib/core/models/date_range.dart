/// Shared DateRange model for date range selections across the app
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  /// Last 7 days
  factory DateRange.last7Days() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  /// Last 30 days
  factory DateRange.last30Days() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29)),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  /// Last 90 days
  factory DateRange.last90Days() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 89)),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  /// All time (from 2020)
  factory DateRange.allTime() {
    final now = DateTime.now();
    return DateRange(
      start: DateTime(2020, 1, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  /// This week (Monday to Sunday)
  factory DateRange.thisWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return DateRange(start: monday, end: sunday);
  }

  /// This month
  factory DateRange.thisMonth() {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRange(start: firstDay, end: lastDay);
  }

  /// Number of days in the range
  int get dayCount => end.difference(start).inDays + 1;

  /// Check if a date is within this range
  bool contains(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);
    return !normalizedDate.isBefore(normalizedStart) &&
           !normalizedDate.isAfter(normalizedEnd);
  }

  /// Get a human-readable label for the range
  String get label {
    final days = dayCount;
    if (days <= 7) return 'Last 7 days';
    if (days <= 30) return 'Last 30 days';
    if (days <= 90) return 'Last 90 days';
    return 'All time';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start.year == other.start.year &&
          start.month == other.start.month &&
          start.day == other.start.day &&
          end.year == other.end.year &&
          end.month == other.end.month &&
          end.day == other.end.day;

  @override
  int get hashCode => Object.hash(
        start.year,
        start.month,
        start.day,
        end.year,
        end.month,
        end.day,
      );

  @override
  String toString() => 'DateRange($start - $end)';
}
