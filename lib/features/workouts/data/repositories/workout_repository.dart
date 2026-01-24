import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_log.dart';
import '../../domain/models/user_saved_workout.dart';

/// Provider for WorkoutRepository
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final analytics = ref.watch(analyticsProvider);
  return WorkoutRepository(analytics: analytics);
});

class WorkoutRepository {
  WorkoutRepository({
    FirebaseFirestore? firestore,
    AnalyticsService? analytics,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? AnalyticsService();

  final FirebaseFirestore _firestore;
  final AnalyticsService _analytics;

  static const String _workoutsCollection = 'workouts';
  static const String _workoutLogsCollection = 'workout_logs';
  static const String _savedWorkoutsCollection = 'user_saved_workouts';
  static const String _workoutFavoritesCollection = 'workout_favorites';

  // ========== Workout Templates ==========

  /// Get all workout templates
  Future<List<Workout>> getWorkouts({
    WorkoutCategory? category,
    WorkoutDifficulty? difficulty,
  }) async {
    Query query = _firestore
        .collection(_workoutsCollection)
        .where('createdBy', isNull: true);

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
    Query query = _firestore
        .collection(_workoutsCollection)
        .where('createdBy', isNull: true);

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

  /// Search workouts with indexed keywords
  /// Set [includeUserWorkouts] to true to also search user-created workouts
  /// Set [userId] to filter to a specific user's workouts only
  Stream<List<Workout>> searchWorkoutsStream(
    String query, {
    bool includeUserWorkouts = false,
    String? userId,
  }) {
    final token = _normalizeToken(query);

    // If searching for a specific user's workouts only
    if (userId != null) {
      Query queryRef = _firestore
          .collection(_workoutsCollection)
          .where('createdBy', isEqualTo: userId);
      if (token.isNotEmpty) {
        queryRef = queryRef.where('searchKeywords', arrayContains: token);
      }
      return queryRef.snapshots().map((snapshot) => snapshot.docs
          .map((doc) => Workout.fromJson(_normalizeWorkoutJson(doc)))
          .toList());
    }

    // If including user workouts, we need to do two queries and merge
    if (includeUserWorkouts) {
      // Query for templates
      Query templatesQuery = _firestore
          .collection(_workoutsCollection)
          .where('createdBy', isNull: true);
      if (token.isNotEmpty) {
        templatesQuery = templatesQuery.where('searchKeywords', arrayContains: token);
      }

      // Query for user workouts (where createdBy is not null)
      // Note: Firestore doesn't support "isNotNull" directly, so we fetch all
      // and filter on the client side for the merged result
      return templatesQuery.snapshots().asyncMap((templatesSnapshot) async {
        final templates = templatesSnapshot.docs
            .map((doc) => Workout.fromJson(_normalizeWorkoutJson(doc)))
            .toList();

        // Fetch user workouts separately (without createdBy filter)
        Query userQuery = _firestore.collection(_workoutsCollection);
        if (token.isNotEmpty) {
          userQuery = userQuery.where('searchKeywords', arrayContains: token);
        }
        final userSnapshot = await userQuery.get();
        final userWorkouts = userSnapshot.docs
            .where((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              return data != null && data['createdBy'] != null;
            })
            .map((doc) => Workout.fromJson(_normalizeWorkoutJson(doc)))
            .toList();

        return [...templates, ...userWorkouts];
      });
    }

    // Default: templates only
    Query queryRef = _firestore
        .collection(_workoutsCollection)
        .where('createdBy', isNull: true);
    if (token.isNotEmpty) {
      queryRef = queryRef.where('searchKeywords', arrayContains: token);
    }
    return queryRef.snapshots().map((snapshot) => snapshot.docs
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

  /// Get workouts by IDs
  Future<Map<String, Workout>> getWorkoutsByIds(
    List<String> workoutIds,
  ) async {
    final uniqueIds = workoutIds.where((id) => id.isNotEmpty).toSet().toList();
    if (uniqueIds.isEmpty) return {};

    final result = <String, Workout>{};
    for (final chunk in _chunkIds(uniqueIds, 10)) {
      final snapshot = await _firestore
          .collection(_workoutsCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      for (final doc in snapshot.docs) {
        result[doc.id] = Workout.fromJson(_normalizeWorkoutJson(doc));
      }
    }
    return result;
  }

  /// Get user-created workout templates stream
  Stream<List<Workout>> getUserWorkoutsStream(String userId) {
    return _firestore
        .collection(_workoutsCollection)
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Workout.fromJson(_normalizeWorkoutJson(doc)))
            .toList());
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
    workoutData['source'] = 'user';
    workoutData['searchKeywords'] = _buildSearchKeywords(workout);

    final docRef = await _firestore.collection(_workoutsCollection).add(workoutData);
    return docRef.id;
  }

  /// Update a workout
  Future<void> updateWorkout(String workoutId, Map<String, dynamic> data) async {
    if (data.containsKey('name') || data.containsKey('description')) {
      final name = data['name']?.toString();
      final description = data['description']?.toString();
      data['searchKeywords'] = _buildSearchKeywordsFromFields(
        name: name,
        description: description,
      );
    }
    await _firestore.collection(_workoutsCollection).doc(workoutId).update(data);
  }

  /// Delete a workout
  Future<void> deleteWorkout(String workoutId) async {
    await _firestore.collection(_workoutsCollection).doc(workoutId).delete();
  }

  // ========== Favorites ==========

  Stream<Set<String>> getWorkoutFavoritesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_workoutFavoritesCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toSet());
  }

  Future<void> toggleWorkoutFavorite(
    String userId,
    Workout workout,
  ) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection(_workoutFavoritesCollection)
        .doc(workout.id);

    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
      return;
    }

    await docRef.set({
      'workoutId': workout.id,
      'name': workout.name,
      'source': workout.createdBy == null ? 'template' : 'user',
      'savedAt': FieldValue.serverTimestamp(),
      'difficulty': workout.difficulty.name,
      'duration': workout.estimatedDuration,
    });
  }

  // ========== Workout Logs ==========

  /// Log a completed workout
  Future<String> logWorkout(WorkoutLog workoutLog) async {
    final logData = workoutLog.toJson();

    final docRef = await _firestore.collection(_workoutLogsCollection).add(logData);

    // Track analytics
    await _analytics.logWorkoutLogged(
      workoutType: workoutLog.category?.name ?? 'unknown',
      durationMinutes: workoutLog.duration,
      exerciseCount: workoutLog.exercises.length,
      caloriesBurned: workoutLog.caloriesBurned,
    );

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
        .where('userId', isEqualTo: userId);

    if (startDate != null) {
      query = query.where('startedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('startedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    final snapshot = await query.get();

    final logs = snapshot.docs
        .map((doc) => WorkoutLog.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }))
        .toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    if (limit != null && logs.length > limit) {
      return logs.take(limit).toList();
    }

    return logs;
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
        .where('userId', isEqualTo: userId);

    if (startDate != null) {
      query = query.where('startedAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('startedAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    return query.snapshots().map((snapshot) {
      final logs = snapshot.docs
          .map((doc) => WorkoutLog.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

      if (limit != null && logs.length > limit) {
        return logs.take(limit).toList();
      }
      return logs;
    });
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

  List<List<String>> _chunkIds(List<String> ids, int size) {
    final chunks = <List<String>>[];
    for (var i = 0; i < ids.length; i += size) {
      final end = (i + size < ids.length) ? i + size : ids.length;
      chunks.add(ids.sublist(i, end));
    }
    return chunks;
  }

  // ========== Saved Workouts ==========

  /// Get user's saved workouts stream
  Stream<List<UserSavedWorkout>> getUserSavedWorkoutsStream(String userId) {
    return _firestore
        .collection(_savedWorkoutsCollection)
        .where('userId', isEqualTo: userId)
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

  String _normalizeToken(String query) {
    final normalized = query.trim().toLowerCase();
    final match = RegExp(r'[a-z0-9]+').firstMatch(normalized);
    return match?.group(0) ?? '';
  }

  List<String> _buildSearchKeywords(Workout workout) {
    return _buildSearchKeywordsFromFields(
      name: workout.name,
      description: workout.description,
      category: workout.category.displayName,
      equipment: workout.equipment,
      tags: workout.tags,
    );
  }

  List<String> _buildSearchKeywordsFromFields({
    String? name,
    String? description,
    String? category,
    String? equipment,
    List<String>? tags,
  }) {
    final parts = <String>[
      if (name != null) name,
      if (description != null) description,
      if (category != null) category,
      if (equipment != null) equipment,
      ...?tags,
    ];
    final tokens = <String>{};
    for (final part in parts) {
      final matches = RegExp(r'[a-z0-9]+')
          .allMatches(part.toLowerCase())
          .map((m) => m.group(0)!)
          .where((token) => token.length >= 2);
      tokens.addAll(matches);
    }
    final list = tokens.toList()..sort();
    return list;
  }
}
