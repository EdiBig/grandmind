import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_log.dart';
import '../../domain/models/user_saved_workout.dart';

/// Provider for WorkoutRepository
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _workoutsCollection = 'workouts';
  static const String _workoutLogsCollection = 'workout_logs';
  static const String _savedWorkoutsCollection = 'user_saved_workouts';

  // ========== Workout Templates ==========

  /// Get all workout templates
  Future<List<Workout>> getWorkouts({
    WorkoutCategory? category,
    WorkoutDifficulty? difficulty,
  }) async {
    Query query = _firestore.collection(_workoutsCollection);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.name);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => Workout.fromJson(_normalizeWorkoutJson(doc)))
        .toList();
  }

  /// Get workout templates stream
  Stream<List<Workout>> getWorkoutsStream({
    WorkoutCategory? category,
    WorkoutDifficulty? difficulty,
  }) {
    Query query = _firestore.collection(_workoutsCollection);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty.name);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Workout.fromJson(_normalizeWorkoutJson(doc)))
        .toList());
  }

  /// Get a specific workout by ID
  Future<Workout?> getWorkout(String workoutId) async {
    final doc = await _firestore.collection(_workoutsCollection).doc(workoutId).get();

    if (!doc.exists) return null;

    return Workout.fromJson(_normalizeWorkoutJson(doc));
  }

  /// Get workout stream by ID
  Stream<Workout?> getWorkoutStream(String workoutId) {
    return _firestore
        .collection(_workoutsCollection)
        .doc(workoutId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return Workout.fromJson(_normalizeWorkoutJson(doc));
    });
  }

  Map<String, dynamic> _normalizeWorkoutJson(
    DocumentSnapshot doc,
  ) {
    final data = (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
    final createdAt = data['createdAt'];
    return {
      ...data,
      'id': doc.id,
      if (createdAt is Timestamp) 'createdAt': createdAt.toDate().toIso8601String(),
    };
  }

  /// Create a custom workout
  Future<String> createWorkout(Workout workout, String userId) async {
    final workoutData = workout.toJson();
    workoutData['createdBy'] = userId;
    workoutData['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection(_workoutsCollection).add(workoutData);
    return docRef.id;
  }

  /// Update a workout
  Future<void> updateWorkout(String workoutId, Map<String, dynamic> data) async {
    await _firestore.collection(_workoutsCollection).doc(workoutId).update(data);
  }

  /// Delete a workout
  Future<void> deleteWorkout(String workoutId) async {
    await _firestore.collection(_workoutsCollection).doc(workoutId).delete();
  }

  // ========== Workout Logs ==========

  /// Log a completed workout
  Future<String> logWorkout(WorkoutLog workoutLog) async {
    final logData = workoutLog.toJson();

    final docRef = await _firestore.collection(_workoutLogsCollection).add(logData);
    return docRef.id;
  }

  /// Get user's workout logs
  Future<List<WorkoutLog>> getUserWorkoutLogs(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    Query query = _firestore
        .collection(_workoutLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: true);

    if (startDate != null) {
      query = query.where('startedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('startedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();

    return snapshot.docs
        .map((doc) => WorkoutLog.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList();
  }

  /// Get user's workout logs stream
  Stream<List<WorkoutLog>> getUserWorkoutLogsStream(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) {
    Query query = _firestore
        .collection(_workoutLogsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: true);

    if (startDate != null) {
      query = query.where('startedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('startedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => WorkoutLog.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList());
  }

  /// Get a specific workout log
  Future<WorkoutLog?> getWorkoutLog(String logId) async {
    final doc = await _firestore.collection(_workoutLogsCollection).doc(logId).get();

    if (!doc.exists) return null;

    return WorkoutLog.fromJson({
      ...doc.data()!,
      'id': doc.id,
    });
  }

  /// Update a workout log
  Future<void> updateWorkoutLog(String logId, Map<String, dynamic> data) async {
    await _firestore.collection(_workoutLogsCollection).doc(logId).update(data);
  }

  /// Delete a workout log
  Future<void> deleteWorkoutLog(String logId) async {
    await _firestore.collection(_workoutLogsCollection).doc(logId).delete();
  }

  // ========== Saved Workouts ==========

  /// Get user's saved workouts stream
  Stream<List<UserSavedWorkout>> getUserSavedWorkoutsStream(String userId) {
    return _firestore
        .collection(_savedWorkoutsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('savedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserSavedWorkout.fromJson(
                  doc.data(),
                  id: doc.id,
                ))
            .toList());
  }

  /// Check if a workout is already saved
  Future<UserSavedWorkout?> getSavedWorkout(
    String userId,
    String workoutId,
  ) async {
    final snapshot = await _firestore
        .collection(_savedWorkoutsCollection)
        .where('userId', isEqualTo: userId)
        .where('workoutId', isEqualTo: workoutId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }
    final doc = snapshot.docs.first;
    return UserSavedWorkout.fromJson(doc.data(), id: doc.id);
  }

  /// Save a workout to the user's routines
  Future<String> saveWorkoutToRoutines({
    required String userId,
    required String workoutId,
    String? folderName,
    String? notes,
  }) async {
    final existing = await getSavedWorkout(userId, workoutId);
    if (existing != null) {
      return existing.id;
    }

    final data = <String, dynamic>{
      'userId': userId,
      'workoutId': workoutId,
      'savedAt': FieldValue.serverTimestamp(),
      'folderName': folderName?.trim().isEmpty ?? true ? null : folderName,
      'notes': notes?.trim().isEmpty ?? true ? null : notes,
    };

    final docRef = await _firestore.collection(_savedWorkoutsCollection).add(
          data,
        );
    return docRef.id;
  }

  /// Update folder or notes for a saved workout
  Future<void> updateSavedWorkout({
    required String savedWorkoutId,
    String? folderName,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'folderName': folderName?.trim().isEmpty ?? true ? null : folderName,
      'notes': notes?.trim().isEmpty ?? true ? null : notes,
    };
    await _firestore
        .collection(_savedWorkoutsCollection)
        .doc(savedWorkoutId)
        .update(data);
  }

  /// Remove a saved workout by saved id
  Future<void> removeSavedWorkout(String savedWorkoutId) async {
    await _firestore
        .collection(_savedWorkoutsCollection)
        .doc(savedWorkoutId)
        .delete();
  }

  /// Remove a saved workout by workout id
  Future<void> removeSavedWorkoutByWorkoutId(
    String userId,
    String workoutId,
  ) async {
    final snapshot = await _firestore
        .collection(_savedWorkoutsCollection)
        .where('userId', isEqualTo: userId)
        .where('workoutId', isEqualTo: workoutId)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // ========== Statistics ==========

  /// Get workout statistics for a user
  Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    final logs = await getUserWorkoutLogs(userId);

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

    final workoutsThisWeek = logs
        .where((log) => log.startedAt.isAfter(weekStart))
        .length;

    final workoutsThisMonth = logs
        .where((log) => log.startedAt.isAfter(monthStart))
        .length;

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
