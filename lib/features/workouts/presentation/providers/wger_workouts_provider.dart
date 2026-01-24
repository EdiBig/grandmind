import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/workout.dart';
import '../../data/repositories/workout_repository.dart';

/// Provider for wger sync status
final wgerSyncStatusProvider = StreamProvider<WgerSyncStatus>((ref) {
  return FirebaseFirestore.instance
      .collection('sync_status')
      .doc('wger')
      .snapshots()
      .map((doc) {
    if (!doc.exists || doc.data() == null) {
      return WgerSyncStatus.unknown();
    }
    return WgerSyncStatus.fromJson(doc.data()!);
  });
});

/// Provider for wger workouts from Firestore
final wgerWorkoutsProvider = StreamProvider<List<Workout>>((ref) {
  final repository = ref.watch(workoutRepositoryProvider);
  return repository.getWorkoutsStream();
});

/// Provider for wger workouts count
final wgerWorkoutsCountProvider = FutureProvider<int>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('workouts')
      .where('source', isEqualTo: 'wger')
      .count()
      .get();
  return snapshot.count ?? 0;
});

/// Provider for searching wger workouts
final wgerWorkoutsSearchProvider =
    StreamProvider.family<List<Workout>, String>((ref, query) {
  final repository = ref.watch(workoutRepositoryProvider);
  if (query.trim().isEmpty) {
    return repository.getWorkoutsStream();
  }
  return repository.searchWorkoutsStream(query);
});

/// Provider for filtered wger workouts
final filteredWgerWorkoutsProvider =
    Provider.family<AsyncValue<List<Workout>>, WgerWorkoutFilters>((ref, filters) {
  final workoutsAsync = ref.watch(wgerWorkoutsProvider);

  return workoutsAsync.whenData((workouts) {
    var filtered = workouts.where((workout) {
      // Category filter
      if (filters.category != null && workout.category != filters.category) {
        return false;
      }

      // Difficulty filter
      if (filters.difficulty != null && workout.difficulty != filters.difficulty) {
        return false;
      }

      // Search filter
      if (filters.searchQuery.isNotEmpty) {
        final query = filters.searchQuery.toLowerCase();
        final searchableText = [
          workout.name,
          workout.description,
          ...?workout.tags,
        ].join(' ').toLowerCase();

        if (!searchableText.contains(query)) {
          return false;
        }
      }

      // Equipment filter
      if (filters.equipment != null &&
          workout.equipment?.toLowerCase() != filters.equipment!.toLowerCase()) {
        return false;
      }

      return true;
    }).toList();

    // Sort
    switch (filters.sortBy) {
      case WgerWorkoutSort.name:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case WgerWorkoutSort.nameDesc:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case WgerWorkoutSort.difficulty:
        filtered.sort((a, b) => a.difficulty.index.compareTo(b.difficulty.index));
        break;
      case WgerWorkoutSort.newest:
        filtered.sort((a, b) {
          final aTime = a.createdAt ?? DateTime(2000);
          final bTime = b.createdAt ?? DateTime(2000);
          return bTime.compareTo(aTime);
        });
        break;
    }

    return filtered;
  });
});

/// Sync status model
class WgerSyncStatus {
  final DateTime? lastSyncAt;
  final String? lastSyncStatus;
  final int? exerciseCount;
  final String? errorMessage;
  final bool isSyncing;

  WgerSyncStatus({
    this.lastSyncAt,
    this.lastSyncStatus,
    this.exerciseCount,
    this.errorMessage,
    this.isSyncing = false,
  });

  factory WgerSyncStatus.unknown() => WgerSyncStatus();

  factory WgerSyncStatus.fromJson(Map<String, dynamic> json) {
    return WgerSyncStatus(
      lastSyncAt: json['lastSyncAt'] != null
          ? (json['lastSyncAt'] as Timestamp).toDate()
          : null,
      lastSyncStatus: json['status'] as String?,
      exerciseCount: json['exerciseCount'] as int?,
      errorMessage: json['errorMessage'] as String?,
      isSyncing: json['isSyncing'] as bool? ?? false,
    );
  }

  bool get hasNeverSynced => lastSyncAt == null;
  bool get isSuccessful => lastSyncStatus == 'success';
  bool get hasFailed => lastSyncStatus == 'error';
}

/// Filter model for wger workouts
class WgerWorkoutFilters {
  final String searchQuery;
  final WorkoutCategory? category;
  final WorkoutDifficulty? difficulty;
  final String? equipment;
  final WgerWorkoutSort sortBy;

  const WgerWorkoutFilters({
    this.searchQuery = '',
    this.category,
    this.difficulty,
    this.equipment,
    this.sortBy = WgerWorkoutSort.name,
  });

  WgerWorkoutFilters copyWith({
    String? searchQuery,
    WorkoutCategory? category,
    WorkoutDifficulty? difficulty,
    String? equipment,
    WgerWorkoutSort? sortBy,
    bool clearCategory = false,
    bool clearDifficulty = false,
    bool clearEquipment = false,
  }) {
    return WgerWorkoutFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      category: clearCategory ? null : (category ?? this.category),
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      equipment: clearEquipment ? null : (equipment ?? this.equipment),
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

enum WgerWorkoutSort { name, nameDesc, difficulty, newest }
