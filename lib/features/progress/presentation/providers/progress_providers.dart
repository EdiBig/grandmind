import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/services/image_upload_service.dart';
import '../../domain/models/weight_entry.dart';
import '../../domain/models/measurement_entry.dart';
import '../../domain/models/progress_photo.dart';
import '../../domain/models/progress_goal.dart';

// ========== HELPER CLASSES ==========

/// Date range helper for filtering entries
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);

  // Preset ranges
  static DateRange get last7Days => DateRange(
        DateTime.now().subtract(const Duration(days: 7)),
        DateTime.now(),
      );

  static DateRange get last30Days => DateRange(
        DateTime.now().subtract(const Duration(days: 30)),
        DateTime.now(),
      );

  static DateRange get last90Days => DateRange(
        DateTime.now().subtract(const Duration(days: 90)),
        DateTime.now(),
      );

  static DateRange get allTime => DateRange(
        DateTime(2000), // Far in the past
        DateTime.now(),
      );
}

// ========== BASE PROVIDERS ==========

/// Provider for progress repository
final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository();
});

/// Provider for image upload service
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});

// ========== WEIGHT PROVIDERS ==========

/// Stream of weight entries (last 90 days by default)
final weightEntriesProvider = StreamProvider<List<WeightEntry>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(progressRepositoryProvider);
  final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));

  return repository.getWeightEntriesStream(userId, startDate: ninetyDaysAgo);
});

/// Latest weight entry
final latestWeightProvider = FutureProvider<WeightEntry?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final repository = ref.watch(progressRepositoryProvider);
  return repository.getLatestWeight(userId);
});

/// Weight entries with custom date range
final weightEntriesRangeProvider =
    FutureProvider.family<List<WeightEntry>, DateRange>(
  (ref, dateRange) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final repository = ref.watch(progressRepositoryProvider);
    return repository.getWeightEntries(
      userId,
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
  },
);

// ========== MEASUREMENT PROVIDERS ==========

/// Stream of measurement entries
final measurementEntriesProvider =
    StreamProvider<List<MeasurementEntry>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(progressRepositoryProvider);
  return repository.getMeasurementEntriesStream(userId);
});

/// Latest measurements
final latestMeasurementsProvider =
    FutureProvider<MeasurementEntry?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final repository = ref.watch(progressRepositoryProvider);
  return repository.getLatestMeasurements(userId);
});

/// Baseline (first) measurements for comparison
final baselineMeasurementsProvider =
    FutureProvider<MeasurementEntry?>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final repository = ref.watch(progressRepositoryProvider);
  return repository.getBaselineMeasurements(userId);
});

// ========== PROGRESS PHOTO PROVIDERS ==========

/// Stream of progress photos
final progressPhotosProvider = StreamProvider<List<ProgressPhoto>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(progressRepositoryProvider);
  return repository.getProgressPhotosStream(userId);
});

/// Photos filtered by angle
final progressPhotosByAngleProvider =
    FutureProvider.family<List<ProgressPhoto>, PhotoAngle>(
  (ref, angle) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return [];

    final repository = ref.watch(progressRepositoryProvider);
    return repository.getProgressPhotos(userId, angle: angle);
  },
);

// ========== GOAL PROVIDERS ==========

/// Stream of active goals
final activeGoalsProvider = StreamProvider<List<ProgressGoal>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(progressRepositoryProvider);
  return repository.getActiveGoalsStream(userId);
});

/// All goals (including completed/abandoned)
final allGoalsProvider = FutureProvider<List<ProgressGoal>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final repository = ref.watch(progressRepositoryProvider);
  return repository.getGoals(userId);
});

// ========== OPERATIONS PROVIDER ==========

/// State notifier for progress operations (create, update, delete)
class ProgressOperations extends StateNotifier<AsyncValue<void>> {
  final ProgressRepository _repository;
  final Ref _ref;

  ProgressOperations(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  // ========== WEIGHT OPERATIONS ==========

  /// Log a new weight entry
  Future<String?> logWeight(WeightEntry entry) async {
    state = const AsyncValue.loading();
    try {
      final entryId = await _repository.createWeightEntry(entry);

      // Update any active weight goals
      await _updateWeightGoals(entry.userId, entry.weight);

      // Invalidate providers to refresh UI
      _ref.invalidate(weightEntriesProvider);
      _ref.invalidate(latestWeightProvider);

      state = const AsyncValue.data(null);
      return entryId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update a weight entry
  Future<bool> updateWeight(String entryId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateWeightEntry(entryId, data);

      // Invalidate providers
      _ref.invalidate(weightEntriesProvider);
      _ref.invalidate(latestWeightProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Delete a weight entry
  Future<bool> deleteWeight(String entryId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteWeightEntry(entryId);

      // Invalidate providers
      _ref.invalidate(weightEntriesProvider);
      _ref.invalidate(latestWeightProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // ========== MEASUREMENT OPERATIONS ==========

  /// Log new measurements
  Future<String?> logMeasurements(MeasurementEntry entry) async {
    state = const AsyncValue.loading();
    try {
      final entryId = await _repository.createMeasurementEntry(entry);

      // Update any active measurement goals
      await _updateMeasurementGoals(entry.userId, entry.measurements);

      // Invalidate providers
      _ref.invalidate(measurementEntriesProvider);
      _ref.invalidate(latestMeasurementsProvider);

      state = const AsyncValue.data(null);
      return entryId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update measurements
  Future<bool> updateMeasurements(
      String entryId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateMeasurementEntry(entryId, data);

      // Invalidate providers
      _ref.invalidate(measurementEntriesProvider);
      _ref.invalidate(latestMeasurementsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Delete measurements
  Future<bool> deleteMeasurements(String entryId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteMeasurementEntry(entryId);

      // Invalidate providers
      _ref.invalidate(measurementEntriesProvider);
      _ref.invalidate(latestMeasurementsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // ========== GOAL OPERATIONS ==========

  /// Create a new goal
  Future<String?> createGoal(ProgressGoal goal) async {
    state = const AsyncValue.loading();
    try {
      final goalId = await _repository.createGoal(goal);

      // Invalidate providers
      _ref.invalidate(activeGoalsProvider);
      _ref.invalidate(allGoalsProvider);

      state = const AsyncValue.data(null);
      return goalId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update goal progress
  Future<bool> updateGoalProgress(String goalId, double newValue) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateGoalProgress(goalId, newValue);

      // Invalidate providers
      _ref.invalidate(activeGoalsProvider);
      _ref.invalidate(allGoalsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Complete a goal manually
  Future<bool> completeGoal(String goalId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateGoal(goalId, {
        'status': GoalStatus.completed.name,
        'completedDate': FieldValue.serverTimestamp(),
      });

      // Invalidate providers
      _ref.invalidate(activeGoalsProvider);
      _ref.invalidate(allGoalsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Delete a goal
  Future<bool> deleteGoal(String goalId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteGoal(goalId);

      // Invalidate providers
      _ref.invalidate(activeGoalsProvider);
      _ref.invalidate(allGoalsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // ========== PHOTO OPERATIONS ==========

  /// Upload a progress photo
  Future<String?> uploadProgressPhoto({
    required String userId,
    required File imageFile,
    required PhotoAngle angle,
    DateTime? date,
    String? notes,
    double? weight,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Upload image with compression
      final imageService = _ref.read(imageUploadServiceProvider);
      final uploadResult = await imageService.uploadProgressPhoto(
        userId: userId,
        imageFile: imageFile,
        angle: angle,
      );

      // Create photo entry
      final photo = ProgressPhoto(
        id: '',
        userId: userId,
        imageUrl: uploadResult.imageUrl,
        thumbnailUrl: uploadResult.thumbnailUrl,
        angle: angle,
        date: date ?? DateTime.now(),
        createdAt: DateTime.now(),
        notes: notes,
        weight: weight,
        metadata: uploadResult.metadata,
      );

      final photoId = await _repository.createProgressPhoto(photo);

      // Invalidate providers
      _ref.invalidate(progressPhotosProvider);

      state = const AsyncValue.data(null);
      return photoId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Upload a progress photo from raw bytes (web-friendly)
  Future<String?> uploadProgressPhotoBytes({
    required String userId,
    required Uint8List imageBytes,
    required PhotoAngle angle,
    DateTime? date,
    String? notes,
    double? weight,
  }) async {
    state = const AsyncValue.loading();
    try {
      final imageService = _ref.read(imageUploadServiceProvider);
      final uploadResult = await imageService.uploadProgressPhotoBytes(
        userId: userId,
        imageBytes: imageBytes,
        angle: angle,
      );

      final photo = ProgressPhoto(
        id: '',
        userId: userId,
        imageUrl: uploadResult.imageUrl,
        thumbnailUrl: uploadResult.thumbnailUrl,
        angle: angle,
        date: date ?? DateTime.now(),
        createdAt: DateTime.now(),
        notes: notes,
        weight: weight,
        metadata: uploadResult.metadata,
      );

      final photoId = await _repository.createProgressPhoto(photo);
      _ref.invalidate(progressPhotosProvider);

      state = const AsyncValue.data(null);
      return photoId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Delete a progress photo
  Future<bool> deleteProgressPhoto(String photoId, String imageUrl) async {
    state = const AsyncValue.loading();
    try {
      // Delete from Firestore
      await _repository.deleteProgressPhoto(photoId);

      // Delete from Storage (best effort)
      try {
        final imageService = _ref.read(imageUploadServiceProvider);
        await imageService.deleteProgressPhoto(imageUrl);
      } catch (_) {
        // Storage deletion failed, but Firestore entry is deleted
      }

      // Invalidate providers
      _ref.invalidate(progressPhotosProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  // ========== HELPER METHODS ==========

  /// Update active weight goals when user logs weight
  Future<void> _updateWeightGoals(String userId, double newWeight) async {
    try {
      final goals = await _repository.getGoals(
        userId,
        status: GoalStatus.active,
      );

      for (var goal in goals) {
        if (goal.type == GoalType.weight) {
          await _repository.updateGoalProgress(goal.id, newWeight);
        }
      }
    } catch (e) {
      // Silently fail - don't block weight logging if goal update fails
      debugPrint('Error updating weight goals: $e');
    }
  }

  /// Update active measurement goals when user logs measurements
  Future<void> _updateMeasurementGoals(
      String userId, Map<String, double> measurements) async {
    try {
      final goals = await _repository.getGoals(
        userId,
        status: GoalStatus.active,
      );

      for (var goal in goals) {
        if (goal.type == GoalType.measurement && goal.measurementType != null) {
          final measurementValue =
              measurements[goal.measurementType!.name];
          if (measurementValue != null) {
            await _repository.updateGoalProgress(goal.id, measurementValue);
          }
        }
      }
    } catch (e) {
      // Silently fail
      debugPrint('Error updating measurement goals: $e');
    }
  }
}

/// Provider for progress operations
final progressOperationsProvider =
    StateNotifierProvider<ProgressOperations, AsyncValue<void>>((ref) {
  final repository = ref.watch(progressRepositoryProvider);
  return ProgressOperations(repository, ref);
});
