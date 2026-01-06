import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_log.dart';
import '../../data/repositories/workout_repository.dart';

/// Provider for all workout templates
final workoutsProvider = StreamProvider.family<List<Workout>, WorkoutFilters>(
  (ref, filters) {
    final repository = ref.watch(workoutRepositoryProvider);
    return repository.getWorkoutsStream(
      category: filters.category,
      difficulty: filters.difficulty,
    );
  },
);

/// Provider for a specific workout
final workoutProvider = StreamProvider.family<Workout?, String>(
  (ref, workoutId) {
    final repository = ref.watch(workoutRepositoryProvider);
    return repository.getWorkoutStream(workoutId);
  },
);

/// Provider for user's workout logs
final userWorkoutLogsProvider = StreamProvider<List<WorkoutLog>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getUserWorkoutLogsStream(userId, limit: 50);
});

/// Provider for recent workout logs (last 10)
final recentWorkoutLogsProvider = StreamProvider<List<WorkoutLog>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getUserWorkoutLogsStream(userId, limit: 10);
});

/// Provider for workout statistics
final workoutStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return {};

  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutStats(userId);
});

/// State provider for workout filters
final workoutFiltersProvider = StateProvider<WorkoutFilters>((ref) {
  return const WorkoutFilters();
});

/// Workout filters model
class WorkoutFilters {
  final WorkoutCategory? category;
  final WorkoutDifficulty? difficulty;

  const WorkoutFilters({
    this.category,
    this.difficulty,
  });

  WorkoutFilters copyWith({
    WorkoutCategory? category,
    WorkoutDifficulty? difficulty,
  }) {
    return WorkoutFilters(
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  WorkoutFilters clearCategory() {
    return WorkoutFilters(
      category: null,
      difficulty: difficulty,
    );
  }

  WorkoutFilters clearDifficulty() {
    return WorkoutFilters(
      category: category,
      difficulty: null,
    );
  }

  WorkoutFilters clearAll() {
    return const WorkoutFilters();
  }
}
