import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_log.dart';
import '../../data/repositories/workout_repository.dart';
import '../../data/services/algolia_search_service.dart';

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

/// Provider for current user id in workout logging flows (override in tests).
final workoutLogUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

/// Toggle for health sync during workout logging (override in tests).
final workoutHealthSyncEnabledProvider = Provider<bool>((ref) => true);

class WorkoutSearchRequest {
  final String query;
  final WorkoutDifficulty? difficulty;
  final String? equipment;
  final bool includeTemplates;
  final bool includeUserWorkouts;
  final String? createdBy;

  const WorkoutSearchRequest({
    required this.query,
    this.difficulty,
    this.equipment,
    this.includeTemplates = true,
    this.includeUserWorkouts = true,
    this.createdBy,
  });
}

/// Provider for searching workouts
final workoutsSearchProvider =
    FutureProvider.family<List<Workout>, WorkoutSearchRequest>((ref, request) async {
  final trimmed = request.query.trim();
  if (!request.includeTemplates && !request.includeUserWorkouts) {
    return [];
  }

  if (!AlgoliaConfig.isValid) {
    final repository = ref.watch(workoutRepositoryProvider);
    final results = await repository
        .searchWorkoutsStream(
          trimmed,
          includeUserWorkouts: request.includeUserWorkouts,
          userId: request.createdBy,
        )
        .first;
    return results.where((workout) {
      if (request.createdBy != null &&
          workout.createdBy != request.createdBy) {
        return false;
      }
      if (!request.includeTemplates && workout.createdBy == null) {
        return false;
      }
      if (!request.includeUserWorkouts && workout.createdBy != null) {
        return false;
      }
      if (request.difficulty != null &&
          workout.difficulty != request.difficulty) {
        return false;
      }
      if (request.equipment != null && request.equipment!.isNotEmpty) {
        final equipment = workout.equipment?.toLowerCase() ?? '';
        if (!equipment.contains(request.equipment!.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  final filters = _buildAlgoliaFilters(request);
  final service = ref.watch(algoliaSearchServiceProvider);
  final ids = await service.searchWorkoutIds(
    trimmed,
    filters: filters,
  );
  if (ids.isEmpty) return [];
  final repository = ref.watch(workoutRepositoryProvider);
  final workoutsById = await repository.getWorkoutsByIds(ids);
  return [
    for (final id in ids)
      if (workoutsById.containsKey(id)) workoutsById[id]!,
  ];
});

String _buildAlgoliaFilters(WorkoutSearchRequest request) {
  final filters = <String>[];
  if (request.difficulty != null) {
    filters.add('difficulty:${request.difficulty!.name}');
  }
  if (request.equipment != null && request.equipment!.isNotEmpty) {
    filters.add('equipment:"${request.equipment!}"');
  }
  if (request.includeTemplates != request.includeUserWorkouts) {
    filters.add('isTemplate:${request.includeTemplates}');
  }
  if (request.createdBy != null && request.createdBy!.isNotEmpty) {
    filters.add('createdBy:"${request.createdBy!}"');
  }
  return filters.join(' AND ');
}

/// Provider for workout favorites
final workoutFavoritesProvider = StreamProvider<Set<String>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value({});
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutFavoritesStream(userId);
});

/// Provider for user-created workout templates
final userWorkoutTemplatesProvider = StreamProvider<List<Workout>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getUserWorkoutsStream(userId);
});

final workoutAttributionProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, workoutId) {
  return FirebaseFirestore.instance
      .collection('workouts')
      .doc(workoutId)
      .snapshots()
      .map((doc) => doc.data()?['attribution'] as Map<String, dynamic>?);
});

/// Provider for fetching workouts by IDs
final workoutsByIdsProvider =
    FutureProvider.family<Map<String, Workout>, List<String>>((ref, ids) async {
  if (ids.isEmpty) return {};
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutsByIds(ids);
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
