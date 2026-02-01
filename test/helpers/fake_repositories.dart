/// Fake repository implementations for integration-style tests
///
/// These in-memory fakes allow testing without Firebase dependencies.
library;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:kinesa/features/habits/data/repositories/habit_repository.dart';
import 'package:kinesa/features/workouts/data/repositories/workout_repository.dart';
import 'package:kinesa/features/workouts/domain/models/workout_log.dart';
import 'package:kinesa/shared/services/analytics_service.dart';
import 'test_helpers.dart';

// ========== Fake Workout Repository ==========

/// A fake workout repository that stores data in memory for testing.
///
/// Usage:
/// ```dart
/// final fakeRepo = FakeWorkoutRepository();
/// await fakeRepo.logWorkout(testWorkoutLog);
/// expect(fakeRepo.loggedWorkouts, hasLength(1));
/// ```
class FakeWorkoutRepository extends WorkoutRepository {
  /// Tracks all workout logs that have been logged
  final List<WorkoutLog> loggedWorkouts = [];

  /// The last workout log that was created
  WorkoutLog? lastLog;

  /// Create a fake workout repository with mock dependencies
  FakeWorkoutRepository({
    AnalyticsService? analytics,
  }) : super(
          firestore: FakeFirebaseFirestore(),
          analytics: analytics ?? MockAnalyticsService(),
        );

  @override
  Future<String> logWorkout(WorkoutLog workoutLog) async {
    lastLog = workoutLog;
    loggedWorkouts.add(workoutLog);
    return 'fake-log-${loggedWorkouts.length}';
  }

  /// Clears all stored test data
  void reset() {
    loggedWorkouts.clear();
    lastLog = null;
  }
}

/// A testable habit repository that uses FakeFirebaseFirestore
///
/// This allows testing HabitRepository methods with in-memory storage.
class TestableHabitRepository extends HabitRepository {
  final FakeFirebaseFirestore fakeFirestore;

  TestableHabitRepository({
    FakeFirebaseFirestore? firestore,
    AnalyticsService? analytics,
  })  : fakeFirestore = firestore ?? FakeFirebaseFirestore(),
        super(analytics: analytics ?? MockAnalyticsService());

  /// Allows direct access to the fake Firestore for test setup
  FakeFirebaseFirestore get firestore => fakeFirestore;
}

/// A testable workout repository that uses FakeFirebaseFirestore
///
/// This allows testing WorkoutRepository methods with in-memory storage.
class TestableWorkoutRepository extends WorkoutRepository {
  final FakeFirebaseFirestore fakeFirestore;

  TestableWorkoutRepository({
    FakeFirebaseFirestore? firestore,
    AnalyticsService? analytics,
  })  : fakeFirestore = firestore ?? FakeFirebaseFirestore(),
        super(
          firestore: firestore ?? FakeFirebaseFirestore(),
          analytics: analytics ?? MockAnalyticsService(),
        );

  /// Allows direct access to the fake Firestore for test setup
  FakeFirebaseFirestore get firestore => fakeFirestore;
}
