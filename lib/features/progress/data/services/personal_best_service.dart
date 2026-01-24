import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/personal_best.dart';

/// Service for tracking and detecting personal bests (PRs)
class PersonalBestService {
  final FirebaseFirestore _firestore;

  PersonalBestService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get all personal bests for a user
  Future<List<PersonalBest>> getPersonalBests(String userId) async {
    final snapshot = await _firestore
        .collection('personal_bests')
        .where('userId', isEqualTo: userId)
        .orderBy('achievedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return PersonalBest.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  /// Get personal bests summary
  Future<PersonalBestsSummary> getPersonalBestsSummary(String userId) async {
    final allPRs = await getPersonalBests(userId);

    if (allPRs.isEmpty) {
      return PersonalBestsSummary.empty();
    }

    // Recent PRs (last 5)
    final recentPRs = allPRs.take(5).toList();

    // Group by category and get best in each
    final bestByCategory = <PersonalBestCategory, PersonalBest>{};
    final countByCategory = <PersonalBestCategory, int>{};

    for (final pr in allPRs) {
      countByCategory[pr.category] = (countByCategory[pr.category] ?? 0) + 1;

      final existing = bestByCategory[pr.category];
      if (existing == null || pr.value > existing.value) {
        bestByCategory[pr.category] = pr;
      }
    }

    // Monthly count
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthlyPRCount = allPRs
        .where((pr) => pr.achievedAt.isAfter(monthStart))
        .length;

    return PersonalBestsSummary(
      recentPRs: recentPRs,
      allTimeBests: bestByCategory.values.toList(),
      totalPRCount: allPRs.length,
      monthlyPRCount: monthlyPRCount,
      prsByCategory: countByCategory,
    );
  }

  /// Record a new personal best
  Future<String?> recordPersonalBest(PersonalBest pr) async {
    try {
      // Check for existing PR of same category/metric
      final existingSnapshot = await _firestore
          .collection('personal_bests')
          .where('userId', isEqualTo: pr.userId)
          .where('category', isEqualTo: pr.category.name)
          .where('metric', isEqualTo: pr.metric)
          .orderBy('value', descending: true)
          .limit(1)
          .get();

      PersonalBest prToSave = pr;

      // If there's an existing PR and new value is better, update with previous values
      if (existingSnapshot.docs.isNotEmpty) {
        final existing = PersonalBest.fromJson({
          ...existingSnapshot.docs.first.data(),
          'id': existingSnapshot.docs.first.id,
        });

        if (pr.value > existing.value) {
          // New PR! Save with previous record info
          prToSave = pr.copyWith(
            previousValue: existing.value,
            previousDate: existing.achievedAt,
          );
        } else {
          // Not a new PR, don't save
          return null;
        }
      }

      // Save the new PR
      final docRef = await _firestore
          .collection('personal_bests')
          .add(prToSave.toJson()..remove('id'));

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  /// Check if a workout contains any new PRs and auto-record them
  Future<List<PersonalBest>> checkWorkoutForPRs({
    required String userId,
    required String workoutLogId,
    required List<ExerciseSetData> exerciseSets,
  }) async {
    final newPRs = <PersonalBest>[];
    final now = DateTime.now();

    for (final exercise in exerciseSets) {
      // Calculate estimated 1RM for strength exercises
      final oneRM = _calculateEstimated1RM(exercise.weight, exercise.reps);

      if (oneRM > 0) {
        // Check if this is a PR for this exercise
        final existingPRs = await _firestore
            .collection('personal_bests')
            .where('userId', isEqualTo: userId)
            .where('category', isEqualTo: PersonalBestCategory.strength.name)
            .where('metric', isEqualTo: exercise.exerciseName)
            .orderBy('value', descending: true)
            .limit(1)
            .get();

        double? previousValue;
        DateTime? previousDate;

        if (existingPRs.docs.isNotEmpty) {
          final existing = existingPRs.docs.first.data();
          previousValue = (existing['value'] as num?)?.toDouble();
          final prevTimestamp = existing['achievedAt'];
          if (prevTimestamp is Timestamp) {
            previousDate = prevTimestamp.toDate();
          }

          // Not a new PR
          if (previousValue != null && oneRM <= previousValue) {
            continue;
          }
        }

        // New PR found!
        final pr = PersonalBest(
          id: '',
          userId: userId,
          category: PersonalBestCategory.strength,
          title: '${exercise.exerciseName} PR',
          metric: exercise.exerciseName,
          value: oneRM,
          unit: 'kg',
          achievedAt: now,
          createdAt: now,
          previousValue: previousValue,
          previousDate: previousDate,
          notes: '${exercise.weight}kg x ${exercise.reps} reps',
          workoutLogId: workoutLogId,
        );

        // Record the PR
        final prId = await recordPersonalBest(pr);
        if (prId != null) {
          newPRs.add(pr.copyWith(id: prId));
        }
      }
    }

    return newPRs;
  }

  /// Calculate estimated 1RM using Epley formula
  double _calculateEstimated1RM(double weight, int reps) {
    if (reps == 0 || weight == 0) return 0;
    if (reps == 1) return weight;

    // Epley formula: weight × (1 + reps/30)
    return weight * (1 + reps / 30);
  }

  /// Record a cardio PR (e.g., fastest 5K)
  Future<String?> recordCardioPR({
    required String userId,
    required String activityName, // e.g., "5K Run", "10K Cycle"
    required double value,        // time in minutes or distance
    required String unit,         // "min", "km"
    required DateTime achievedAt,
    String? notes,
    String? workoutLogId,
  }) async {
    // Get existing PR
    final existingSnapshot = await _firestore
        .collection('personal_bests')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: PersonalBestCategory.cardio.name)
        .where('metric', isEqualTo: activityName)
        .orderBy('value', descending: unit == 'km') // Higher distance is better
        .limit(1)
        .get();

    double? previousValue;
    DateTime? previousDate;

    if (existingSnapshot.docs.isNotEmpty) {
      final existing = existingSnapshot.docs.first.data();
      previousValue = (existing['value'] as num?)?.toDouble();
      final prevTimestamp = existing['achievedAt'];
      if (prevTimestamp is Timestamp) {
        previousDate = prevTimestamp.toDate();
      }

      // For time: lower is better
      // For distance: higher is better
      final isBetter = unit == 'km'
          ? value > (previousValue ?? 0)
          : value < (previousValue ?? double.infinity);

      if (!isBetter) return null;
    }

    final pr = PersonalBest(
      id: '',
      userId: userId,
      category: PersonalBestCategory.cardio,
      title: '$activityName PR',
      metric: activityName,
      value: value,
      unit: unit,
      achievedAt: achievedAt,
      createdAt: DateTime.now(),
      previousValue: previousValue,
      previousDate: previousDate,
      notes: notes,
      workoutLogId: workoutLogId,
    );

    return recordPersonalBest(pr);
  }

  /// Get exercise-specific PRs
  Future<List<ExercisePR>> getExercisePRs(
    String userId, {
    String? exerciseName,
    int limit = 20,
  }) async {
    var query = _firestore
        .collection('personal_bests')
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: PersonalBestCategory.strength.name);

    if (exerciseName != null) {
      query = query.where('metric', isEqualTo: exerciseName);
    }

    final snapshot = await query
        .orderBy('achievedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ExercisePR(
        exerciseName: data['metric'] as String? ?? '',
        weight: (data['value'] as num?)?.toDouble() ?? 0,
        reps: 1, // Stored as estimated 1RM
        achievedAt: (data['achievedAt'] as Timestamp).toDate(),
        previousWeight: (data['previousValue'] as num?)?.toDouble(),
        previousReps: null,
        previousDate: data['previousDate'] != null
            ? (data['previousDate'] as Timestamp).toDate()
            : null,
      );
    }).toList();
  }

  /// Delete a personal best
  Future<bool> deletePersonalBest(String prId) async {
    try {
      await _firestore.collection('personal_bests').doc(prId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Data class for exercise set info used in PR detection
class ExerciseSetData {
  final String exerciseName;
  final double weight; // in kg
  final int reps;

  ExerciseSetData({
    required this.exerciseName,
    required this.weight,
    required this.reps,
  });
}
