/// Example: Syncable Workout Log Repository
///
/// This demonstrates how to add offline-first sync capabilities
/// to an existing repository using the SyncableRepository mixin.
///
/// Usage:
/// ```dart
/// final repo = ref.watch(syncableWorkoutLogRepositoryProvider);
///
/// // Save with offline support
/// await repo.logWorkout(workoutLog, userId);
///
/// // Get with offline fallback
/// final logs = await repo.getWorkoutLogs(userId);
/// ```

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/workouts/domain/models/workout_log.dart';
import '../mixins/syncable_repository.dart';
import '../services/local_database_service.dart';
import '../services/sync_service.dart';

/// Provider for SyncableWorkoutLogRepository
final syncableWorkoutLogRepositoryProvider =
    Provider<SyncableWorkoutLogRepository>((ref) {
  final deps = ref.watch(syncableRepositoryDepsProvider);
  return SyncableWorkoutLogRepository(
    syncService: deps.syncService,
    localDb: deps.localDb,
    firestore: deps.firestore,
  );
});

class SyncableWorkoutLogRepository with SyncableRepository {
  SyncableWorkoutLogRepository({
    required SyncService syncService,
    required LocalDatabaseService localDb,
    required FirebaseFirestore firestore,
  })  : _syncService = syncService,
        _localDb = localDb,
        _firestore = firestore;

  final SyncService _syncService;
  final LocalDatabaseService _localDb;
  final FirebaseFirestore _firestore;

  @override
  String get collectionName => 'workout_logs';

  @override
  SyncService get syncService => _syncService;

  @override
  LocalDatabaseService get localDb => _localDb;

  @override
  FirebaseFirestore get firestore => _firestore;

  /// Log a workout with offline support
  Future<String> logWorkout(WorkoutLog log, String userId) async {
    final data = log.toJson();

    // Add created timestamp if new
    if (!data.containsKey('createdAt')) {
      data['createdAt'] = DateTime.now().toIso8601String();
    }

    return saveWithSync(
      documentId: log.id.isEmpty ? null : log.id,
      data: data,
      userId: userId,
    );
  }

  /// Get user's workout logs with offline fallback
  Future<List<WorkoutLog>> getWorkoutLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final results = await getListWithFallback(
      userId: userId,
      queryBuilder: (query) {
        if (startDate != null) {
          query = query.where(
            'startedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          );
        }
        if (endDate != null) {
          query = query.where(
            'startedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          );
        }
        return query;
      },
    );

    // Parse and sort
    final logs = results
        .map((data) => WorkoutLog.fromJson(data))
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    if (limit != null && logs.length > limit) {
      return logs.take(limit).toList();
    }

    return logs;
  }

  /// Stream workout logs with local cache updates
  Stream<List<WorkoutLog>> streamWorkoutLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return streamWithCache(
      userId: userId,
      queryBuilder: (query) {
        if (startDate != null) {
          query = query.where(
            'startedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          );
        }
        if (endDate != null) {
          query = query.where(
            'startedAt',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          );
        }
        return query.orderBy('startedAt', descending: true);
      },
    ).map(
      (results) => results.map((data) => WorkoutLog.fromJson(data)).toList(),
    );
  }

  /// Get a single workout log with offline fallback
  Future<WorkoutLog?> getWorkoutLog(String logId) async {
    final data = await getWithFallback(logId);
    if (data == null) return null;
    return WorkoutLog.fromJson(data);
  }

  /// Update a workout log with offline support
  Future<void> updateWorkoutLog(
    String logId,
    Map<String, dynamic> updates,
    String userId,
  ) async {
    // Get existing data first
    final existing = await getWithFallback(logId);
    if (existing == null) {
      throw Exception('Workout log not found: $logId');
    }

    // Merge updates
    final merged = {...existing, ...updates};

    await saveWithSync(
      documentId: logId,
      data: merged,
      userId: userId,
    );
  }

  /// Delete a workout log with offline support
  Future<void> deleteWorkoutLog(String logId, String userId) async {
    await deleteWithSync(
      documentId: logId,
      userId: userId,
    );
  }

  /// Get workout statistics with offline fallback
  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    final logs = await getWorkoutLogs(userId);

    if (logs.isEmpty) {
      return {
        'totalWorkouts': 0,
        'totalDuration': 0,
        'totalCalories': 0,
        'workoutsThisWeek': 0,
        'workoutsThisMonth': 0,
      };
    }

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final workoutsThisWeek =
        logs.where((log) => log.startedAt.isAfter(weekStart)).length;

    final workoutsThisMonth =
        logs.where((log) => log.startedAt.isAfter(monthStart)).length;

    final totalDuration = logs.fold<int>(
      0,
      (total, log) => total + log.duration,
    );

    final totalCalories = logs.fold<int>(
      0,
      (total, log) => total + (log.caloriesBurned ?? 0),
    );

    return {
      'totalWorkouts': logs.length,
      'totalDuration': totalDuration,
      'totalCalories': totalCalories,
      'workoutsThisWeek': workoutsThisWeek,
      'workoutsThisMonth': workoutsThisMonth,
    };
  }
}
