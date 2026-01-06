import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for user statistics
class UserStats {
  final int totalWorkouts;
  final int currentStreak;
  final int longestStreak;
  final int totalHabitsCompleted;
  final int achievementsUnlocked;
  final int activeDays;

  UserStats({
    required this.totalWorkouts,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalHabitsCompleted,
    required this.achievementsUnlocked,
    required this.activeDays,
  });

  factory UserStats.empty() => UserStats(
        totalWorkouts: 0,
        currentStreak: 0,
        longestStreak: 0,
        totalHabitsCompleted: 0,
        achievementsUnlocked: 0,
        activeDays: 0,
      );
}

/// Service for calculating user statistics
class UserStatsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get comprehensive user statistics
  Future<UserStats> getUserStats(String userId) async {
    try {
      final results = await Future.wait([
        _getWorkoutStats(userId),
        _getHabitStats(userId),
        _getAchievementStats(userId),
      ]);

      final workoutStats = results[0] as Map<String, int>;
      final habitStats = results[1] as Map<String, int>;
      final achievementStats = results[2] as int;

      return UserStats(
        totalWorkouts: workoutStats['totalWorkouts'] ?? 0,
        currentStreak: habitStats['currentStreak'] ?? 0,
        longestStreak: habitStats['longestStreak'] ?? 0,
        totalHabitsCompleted: habitStats['totalCompleted'] ?? 0,
        achievementsUnlocked: achievementStats,
        activeDays: workoutStats['activeDays'] ?? 0,
      );
    } catch (e) {
      print('Error calculating user stats: $e');
      return UserStats.empty();
    }
  }

  /// Get workout-related statistics
  Future<Map<String, int>> _getWorkoutStats(String userId) async {
    try {
      // Get total workout logs
      final workoutLogsSnapshot = await _firestore
          .collection('workout_logs')
          .where('userId', isEqualTo: userId)
          .get();

      final totalWorkouts = workoutLogsSnapshot.docs.length;

      // Calculate active days (unique dates with workouts)
      final uniqueDates = <String>{};
      for (final doc in workoutLogsSnapshot.docs) {
        final data = doc.data();
        final timestamp = data['date'] as Timestamp?;
        if (timestamp != null) {
          final date = timestamp.toDate();
          final dateStr = '${date.year}-${date.month}-${date.day}';
          uniqueDates.add(dateStr);
        }
      }

      return {
        'totalWorkouts': totalWorkouts,
        'activeDays': uniqueDates.length,
      };
    } catch (e) {
      print('Error calculating workout stats: $e');
      return {'totalWorkouts': 0, 'activeDays': 0};
    }
  }

  /// Get habit-related statistics including streaks
  Future<Map<String, int>> _getHabitStats(String userId) async {
    try {
      // Get all habit logs
      final habitLogsSnapshot = await _firestore
          .collection('habit_logs')
          .where('userId', isEqualTo: userId)
          .where('completed', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();

      final totalCompleted = habitLogsSnapshot.docs.length;

      // Calculate streak based on consecutive days
      int currentStreak = 0;
      int longestStreak = 0;
      int tempStreak = 0;

      if (habitLogsSnapshot.docs.isNotEmpty) {
        // Group logs by date
        final logsByDate = <String, int>{};
        for (final doc in habitLogsSnapshot.docs) {
          final data = doc.data();
          final timestamp = data['date'] as Timestamp?;
          if (timestamp != null) {
            final date = timestamp.toDate();
            final dateStr =
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            logsByDate[dateStr] = (logsByDate[dateStr] ?? 0) + 1;
          }
        }

        // Sort dates
        final sortedDates = logsByDate.keys.toList()..sort((a, b) => b.compareTo(a));

        // Calculate current streak
        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        final yesterday = today.subtract(const Duration(days: 1));
        final yesterdayStr =
            '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

        DateTime? lastDate;
        bool streakBroken = false;

        for (final dateStr in sortedDates) {
          final date = DateTime.parse(dateStr);

          if (lastDate == null) {
            // First date - check if it's today or yesterday
            if (dateStr == todayStr || dateStr == yesterdayStr) {
              currentStreak = 1;
              tempStreak = 1;
              lastDate = date;
            } else {
              // Streak already broken
              streakBroken = true;
              tempStreak = 1;
              lastDate = date;
            }
          } else {
            // Check if consecutive
            final daysDiff = lastDate.difference(date).inDays;
            if (daysDiff == 1) {
              if (!streakBroken) {
                currentStreak++;
              }
              tempStreak++;
              lastDate = date;
            } else {
              // Streak broken
              if (tempStreak > longestStreak) {
                longestStreak = tempStreak;
              }
              tempStreak = 1;
              streakBroken = true;
              lastDate = date;
            }
          }
        }

        // Check final temp streak
        if (tempStreak > longestStreak) {
          longestStreak = tempStreak;
        }

        // If current streak wasn't set, it means we don't have recent activity
        if (currentStreak == 0 && tempStreak > 0) {
          longestStreak = tempStreak;
        }
      }

      return {
        'totalCompleted': totalCompleted,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
      };
    } catch (e) {
      print('Error calculating habit stats: $e');
      return {
        'totalCompleted': 0,
        'currentStreak': 0,
        'longestStreak': 0,
      };
    }
  }

  /// Get achievement statistics
  /// For now, we'll calculate based on milestones reached
  Future<int> _getAchievementStats(String userId) async {
    try {
      int achievements = 0;

      // Get workout count
      final workoutCount = await _firestore
          .collection('workout_logs')
          .where('userId', isEqualTo: userId)
          .count()
          .get();

      final totalWorkouts = workoutCount.count ?? 0;

      // Achievement milestones for workouts
      if (totalWorkouts >= 1) achievements++; // First workout
      if (totalWorkouts >= 5) achievements++; // 5 workouts
      if (totalWorkouts >= 10) achievements++; // 10 workouts
      if (totalWorkouts >= 25) achievements++; // 25 workouts
      if (totalWorkouts >= 50) achievements++; // 50 workouts
      if (totalWorkouts >= 100) achievements++; // 100 workouts

      // Get habit logs for streak achievements
      final habitStats = await _getHabitStats(userId);
      final longestStreak = habitStats['longestStreak'] ?? 0;

      // Achievement milestones for streaks
      if (longestStreak >= 3) achievements++; // 3-day streak
      if (longestStreak >= 7) achievements++; // 7-day streak
      if (longestStreak >= 14) achievements++; // 2-week streak
      if (longestStreak >= 30) achievements++; // 30-day streak

      // Check if user has goals
      final goalsSnapshot = await _firestore
          .collection('progress_goals')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .count()
          .get();

      final completedGoals = goalsSnapshot.count ?? 0;
      if (completedGoals >= 1) achievements++; // First goal completed
      if (completedGoals >= 3) achievements++; // 3 goals completed
      if (completedGoals >= 5) achievements++; // 5 goals completed

      return achievements;
    } catch (e) {
      print('Error calculating achievement stats: $e');
      return 0;
    }
  }
}
