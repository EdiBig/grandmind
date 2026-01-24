import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/streak_data.dart';

/// Service for calculating activity streaks and calendar data
class StreakService {
  final FirebaseFirestore _firestore;

  StreakService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Calculate streak with adaptive forgiveness
  /// - graceDays: number of days user can miss without breaking streak
  Future<StreakData> calculateStreak({
    required String userId,
    int graceDays = 1,
  }) async {
    // Fetch all activity dates
    final workoutDates = await _getWorkoutDates(userId);
    final habitDates = await _getHabitLogDates(userId);
    final weightDates = await _getWeightLogDates(userId);

    // Merge and dedupe dates (normalize to date only)
    final allActiveDates = <DateTime>{
      ...workoutDates.map(_normalizeDate),
      ...habitDates.map(_normalizeDate),
      ...weightDates.map(_normalizeDate),
    }.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first

    if (allActiveDates.isEmpty) {
      return StreakData.empty();
    }

    // Calculate current streak with grace period
    final currentStreak = _calculateCurrentStreak(allActiveDates, graceDays);

    // Calculate longest streak
    final longestStreak = _calculateLongestStreak(allActiveDates, graceDays);

    // Get this month's active dates
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final activeDatesThisMonth = allActiveDates
        .where((d) => !d.isBefore(thisMonthStart))
        .toList();

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalActiveDays: allActiveDates.length,
      lastActiveDate: allActiveDates.isNotEmpty ? allActiveDates.first : null,
      activeDatesThisMonth: activeDatesThisMonth,
      graceDays: graceDays,
    );
  }

  int _calculateCurrentStreak(List<DateTime> sortedDates, int graceDays) {
    if (sortedDates.isEmpty) return 0;

    final today = _normalizeDate(DateTime.now());
    final latestActive = sortedDates.first;

    // Check if still within grace period from today
    final daysSinceLastActive = today.difference(latestActive).inDays;
    if (daysSinceLastActive > graceDays) {
      return 0; // Streak broken
    }

    int streak = 1;
    DateTime checkDate = latestActive;

    for (int i = 1; i < sortedDates.length; i++) {
      final previousDate = sortedDates[i];
      final gap = checkDate.difference(previousDate).inDays;

      if (gap <= graceDays + 1) {
        // Within grace period, continue streak
        streak++;
        checkDate = previousDate;
      } else {
        // Gap too large, streak ends here
        break;
      }
    }

    return streak;
  }

  int _calculateLongestStreak(List<DateTime> sortedDates, int graceDays) {
    if (sortedDates.isEmpty) return 0;
    if (sortedDates.length == 1) return 1;

    int longest = 1;
    int current = 1;

    // Dates are sorted newest first, so we iterate from newest to oldest
    for (int i = 0; i < sortedDates.length - 1; i++) {
      final currentDate = sortedDates[i];
      final nextDate = sortedDates[i + 1];
      final gap = currentDate.difference(nextDate).inDays;

      if (gap <= graceDays + 1) {
        current++;
        if (current > longest) {
          longest = current;
        }
      } else {
        current = 1;
      }
    }

    return longest;
  }

  /// Get activity data for calendar heatmap
  Future<List<ActivityDay>> getActivityCalendar({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedStart = _normalizeDate(startDate);
    final normalizedEnd = _normalizeDate(endDate);

    // Fetch all relevant data in parallel with error handling
    // Each query may fail if Firestore index doesn't exist, so we handle gracefully
    List<DateTime> workoutDates = [];
    List<DateTime> habitLogDates = [];
    int totalHabits = 0;
    List<DateTime> weightDates = [];
    List<DateTime> measurementDates = [];

    try {
      workoutDates = await _getWorkoutsInRange(userId, normalizedStart, normalizedEnd);
    } catch (e) {
      // Fallback: try without date filter
      try {
        final allWorkouts = await _getWorkoutDates(userId);
        workoutDates = allWorkouts.where((d) {
          final normalized = _normalizeDate(d);
          return !normalized.isBefore(normalizedStart) && !normalized.isAfter(normalizedEnd);
        }).toList();
      } catch (_) {
        // Still failed, use empty list
      }
    }

    try {
      habitLogDates = await _getHabitLogsInRange(userId, normalizedStart, normalizedEnd);
    } catch (e) {
      // Fallback: try without date filter
      try {
        final allHabits = await _getHabitLogDates(userId);
        habitLogDates = allHabits.where((d) {
          final normalized = _normalizeDate(d);
          return !normalized.isBefore(normalizedStart) && !normalized.isAfter(normalizedEnd);
        }).toList();
      } catch (_) {
        // Still failed, use empty list
      }
    }

    try {
      totalHabits = await _getActiveHabitCount(userId);
    } catch (_) {
      // Use 0 as default
    }

    try {
      weightDates = await _getWeightEntriesInRange(userId, normalizedStart, normalizedEnd);
    } catch (e) {
      // Fallback: try without date filter
      try {
        final allWeight = await _getWeightLogDates(userId);
        weightDates = allWeight.where((d) {
          final normalized = _normalizeDate(d);
          return !normalized.isBefore(normalizedStart) && !normalized.isAfter(normalizedEnd);
        }).toList();
      } catch (_) {
        // Still failed, use empty list
      }
    }

    try {
      measurementDates = await _getMeasurementsInRange(userId, normalizedStart, normalizedEnd);
    } catch (e) {
      // Fallback: use empty list (measurements are optional)
    }

    // Group by date
    final workoutsByDate = _groupByDate(workoutDates);
    final habitsByDate = _groupByDate(habitLogDates);
    final weightByDate = weightDates.map(_normalizeDate).toSet();
    final measurementByDate = measurementDates.map(_normalizeDate).toSet();

    // Build day-by-day activity
    final days = <ActivityDay>[];
    DateTime current = normalizedStart;

    while (!current.isAfter(normalizedEnd)) {
      final workoutCount = workoutsByDate[current] ?? 0;
      final habitsCompleted = habitsByDate[current] ?? 0;
      final weightLogged = weightByDate.contains(current);
      final measurementsLogged = measurementByDate.contains(current);

      // Calculate activity score (0-100)
      int score = 0;
      if (workoutCount > 0) score += 40;
      if (habitsCompleted > 0 && totalHabits > 0) {
        score += ((habitsCompleted / totalHabits) * 40).round().clamp(0, 40);
      }
      if (weightLogged) score += 10;
      if (measurementsLogged) score += 10;

      days.add(ActivityDay(
        date: current,
        workoutCount: workoutCount,
        habitsCompleted: habitsCompleted,
        habitsTotal: totalHabits,
        weightLogged: weightLogged,
        measurementsLogged: measurementsLogged,
        activityScore: score.clamp(0, 100),
      ));

      current = current.add(const Duration(days: 1));
    }

    return days;
  }

  // ========== PRIVATE HELPER METHODS ==========

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Map<DateTime, int> _groupByDate(List<DateTime> dates) {
    final map = <DateTime, int>{};
    for (final date in dates) {
      final normalized = _normalizeDate(date);
      map[normalized] = (map[normalized] ?? 0) + 1;
    }
    return map;
  }

  Future<List<DateTime>> _getWorkoutDates(String userId) async {
    final snapshot = await _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['completedAt'] ?? data['startedAt'];
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      return DateTime.now();
    }).toList();
  }

  Future<List<DateTime>> _getHabitLogDates(String userId) async {
    final snapshot = await _firestore
        .collection('habit_logs')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['date'];
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      return DateTime.now();
    }).toList();
  }

  Future<List<DateTime>> _getWeightLogDates(String userId) async {
    final snapshot = await _firestore
        .collection('weight_entries')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['date'];
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      return DateTime.now();
    }).toList();
  }

  Future<List<DateTime>> _getWorkoutsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _firestore
        .collection('workout_logs')
        .where('userId', isEqualTo: userId)
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('completedAt', isLessThanOrEqualTo: Timestamp.fromDate(end.add(const Duration(days: 1))))
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['completedAt'] ?? data['startedAt'];
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      return DateTime.now();
    }).toList();
  }

  Future<List<DateTime>> _getHabitLogsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _firestore
        .collection('habit_logs')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end.add(const Duration(days: 1))))
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['date'];
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      return DateTime.now();
    }).toList();
  }

  Future<int> _getActiveHabitCount(String userId) async {
    final snapshot = await _firestore
        .collection('habits')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  Future<List<DateTime>> _getWeightEntriesInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _firestore
        .collection('weight_entries')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end.add(const Duration(days: 1))))
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['date'];
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      return DateTime.now();
    }).toList();
  }

  Future<List<DateTime>> _getMeasurementsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _firestore
        .collection('measurement_entries')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end.add(const Duration(days: 1))))
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final timestamp = data['date'];
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      }
      return DateTime.now();
    }).toList();
  }
}
