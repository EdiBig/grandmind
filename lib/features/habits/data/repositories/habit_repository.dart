import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';

/// Provider for HabitRepository
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

class HabitRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _habitsCollection = 'habits';
  static const String _habitLogsCollection = 'habit_logs';

  // ========== Habits CRUD ==========

  /// Get all habits for a user
  Future<List<Habit>> getUserHabits(String userId, {bool? isActive}) async {
    Query query = _firestore
        .collection(_habitsCollection)
        .where('userId', isEqualTo: userId);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    query = query.orderBy('createdAt', descending: false);

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => Habit.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList();
  }

  /// Get user habits stream
  Stream<List<Habit>> getUserHabitsStream(String userId, {bool? isActive}) {
    Query query = _firestore
        .collection(_habitsCollection)
        .where('userId', isEqualTo: userId);

    if (isActive != null) {
      query = query.where('isActive', isEqualTo: isActive);
    }

    query = query.orderBy('createdAt', descending: false);

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Habit.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList());
  }

  /// Get a specific habit by ID
  Future<Habit?> getHabit(String habitId) async {
    final doc = await _firestore.collection(_habitsCollection).doc(habitId).get();

    if (!doc.exists) return null;

    return Habit.fromJson({
      ...doc.data()!,
      'id': doc.id,
    });
  }

  /// Get habit stream by ID
  Stream<Habit?> getHabitStream(String habitId) {
    return _firestore
        .collection(_habitsCollection)
        .doc(habitId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Habit.fromJson({
        ...doc.data()!,
        'id': doc.id,
      });
    });
  }

  /// Create a new habit
  Future<String> createHabit(Habit habit) async {
    final habitData = habit.toJson();
    habitData['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection(_habitsCollection).add(habitData);
    return docRef.id;
  }

  /// Update a habit
  Future<void> updateHabit(String habitId, Map<String, dynamic> data) async {
    await _firestore.collection(_habitsCollection).doc(habitId).update(data);
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    // Also delete all associated logs
    final logs = await _firestore
        .collection(_habitLogsCollection)
        .where('habitId', isEqualTo: habitId)
        .get();

    final batch = _firestore.batch();

    for (var doc in logs.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_firestore.collection(_habitsCollection).doc(habitId));

    await batch.commit();
  }

  /// Archive/activate a habit
  Future<void> setHabitActive(String habitId, bool isActive) async {
    await _firestore.collection(_habitsCollection).doc(habitId).update({
      'isActive': isActive,
    });
  }

  // ========== Habit Logs ==========

  /// Log a habit completion
  Future<String> logHabit(HabitLog log) async {
    final logData = log.toJson();
    logData['completedAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection(_habitLogsCollection).add(logData);

    // Update habit's last completed date and streak
    await _updateHabitStreak(log.habitId, log.userId, log.date);

    return docRef.id;
  }

  /// Get habit logs for a specific habit
  Future<List<HabitLog>> getHabitLogs(
    String habitId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query query = _firestore
        .collection(_habitLogsCollection)
        .where('habitId', isEqualTo: habitId)
        .orderBy('date', descending: true);

    if (startDate != null) {
      query = query.where('date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('date',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return HabitLog.fromJson({
            ...?data,
            'id': doc.id,
          });
        })
        .toList();
  }

  /// Get all habit logs for a user on a specific date
  Future<List<HabitLog>> getUserHabitLogsForDate(
    String userId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection(_habitLogsCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs
        .map((doc) => HabitLog.fromJson({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();
  }

  /// Check if a habit was completed on a specific date
  Future<HabitLog?> getHabitLogForDate(String habitId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _firestore
        .collection(_habitLogsCollection)
        .where('habitId', isEqualTo: habitId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return HabitLog.fromJson({
      ...snapshot.docs.first.data(),
      'id': snapshot.docs.first.id,
    });
  }

  /// Delete a habit log
  Future<void> deleteHabitLog(String logId, String habitId, String userId) async {
    await _firestore.collection(_habitLogsCollection).doc(logId).delete();

    // Recalculate streak after deletion
    await _recalculateHabitStreak(habitId, userId);
  }

  /// Update a habit log
  Future<void> updateHabitLog(String logId, Map<String, dynamic> data) async {
    await _firestore.collection(_habitLogsCollection).doc(logId).update(data);
  }

  // ========== Streak Tracking ==========

  /// Update habit streak after logging
  Future<void> _updateHabitStreak(
    String habitId,
    String userId,
    DateTime completedDate,
  ) async {
    final habit = await getHabit(habitId);
    if (habit == null) return;

    // Get all logs for this habit to calculate streak
    final logs = await getHabitLogs(habitId);

    // Sort logs by date (most recent first)
    logs.sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    DateTime? lastDate;

    for (var log in logs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);

      if (lastDate == null) {
        // First log (most recent)
        currentStreak = 1;
        lastDate = logDate;
      } else {
        final daysDiff = lastDate.difference(logDate).inDays;

        if (daysDiff == 1) {
          // Consecutive day
          currentStreak++;
          lastDate = logDate;
        } else {
          // Streak broken
          break;
        }
      }
    }

    final longestStreak = currentStreak > habit.longestStreak
        ? currentStreak
        : habit.longestStreak;

    await updateHabit(habitId, {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Recalculate streak (used after deletion)
  Future<void> _recalculateHabitStreak(String habitId, String userId) async {
    final habit = await getHabit(habitId);
    if (habit == null) return;

    final logs = await getHabitLogs(habitId);

    if (logs.isEmpty) {
      await updateHabit(habitId, {
        'currentStreak': 0,
        'lastCompletedAt': null,
      });
      return;
    }

    // Recalculate streak
    logs.sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    DateTime? lastDate;

    for (var log in logs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);

      if (lastDate == null) {
        currentStreak = 1;
        lastDate = logDate;
      } else {
        final daysDiff = lastDate.difference(logDate).inDays;

        if (daysDiff == 1) {
          currentStreak++;
          lastDate = logDate;
        } else {
          break;
        }
      }
    }

    await updateHabit(habitId, {
      'currentStreak': currentStreak,
      'lastCompletedAt': Timestamp.fromDate(logs.first.date),
    });
  }

  /// Stream recent habit logs for a user (ordered by date ascending)
  Stream<List<HabitLog>> getRecentHabitLogsStream(
    String userId, {
    int limit = 10,
  }) {
    Query query = _firestore
        .collection(_habitLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .limitToLast(limit);

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => HabitLog.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList());
  }

  // ========== Statistics ==========

  /// Get habit statistics for a user
  Future<Map<String, dynamic>> getHabitStats(String userId) async {
    final habits = await getUserHabits(userId, isActive: true);
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    // Get today's completed habits
    final todayLogs = await _firestore
        .collection(_habitLogsCollection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
        .where('date', isLessThan: Timestamp.fromDate(endOfToday))
        .get();

    final completedToday = todayLogs.docs.length;
    final totalActiveHabits = habits.length;
    final completionRate = totalActiveHabits > 0
        ? (completedToday / totalActiveHabits * 100).round()
        : 0;

    // Calculate longest streak across all habits
    int longestStreak = 0;
    for (var habit in habits) {
      if (habit.longestStreak > longestStreak) {
        longestStreak = habit.longestStreak;
      }
    }

    return {
      'totalHabits': totalActiveHabits,
      'completedToday': completedToday,
      'completionRate': completionRate,
      'longestStreak': longestStreak,
    };
  }
}
