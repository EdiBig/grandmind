import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/pagination.dart';
import '../../data/repositories/habit_repository.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';

/// Parameters for paginated habit logs query
class HabitLogsPaginationParams {
  final String userId;
  final String? habitId;
  final DateTime? startDate;
  final DateTime? endDate;

  const HabitLogsPaginationParams({
    required this.userId,
    this.habitId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLogsPaginationParams &&
          userId == other.userId &&
          habitId == other.habitId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(userId, habitId, startDate, endDate);
}

/// Pagination notifier for habit logs
class HabitLogsPaginationNotifier extends PaginationNotifier<HabitLog> {
  final HabitRepository _repository;
  final HabitLogsPaginationParams _params;

  HabitLogsPaginationNotifier(this._repository, this._params) : super(pageSize: 20);

  @override
  Future<PaginatedResult<HabitLog>> fetchPage(int page, dynamic cursor) async {
    return _repository.getHabitLogsPaginated(
      userId: _params.userId,
      habitId: _params.habitId,
      pageSize: pageSize,
      startAfterDocument: cursor as DocumentSnapshot?,
      startDate: _params.startDate,
      endDate: _params.endDate,
      page: page,
    );
  }

  /// Add a new habit log (optimistic update)
  void addHabitLog(HabitLog log) {
    prependItem(log);
  }

  /// Remove a habit log by ID (optimistic update)
  void removeHabitLogById(String logId) {
    removeWhere((log) => log.id == logId);
  }

  /// Update a habit log (optimistic update)
  void updateHabitLogById(String logId, HabitLog updatedLog) {
    updateWhere((log) => log.id == logId, updatedLog);
  }
}

/// Provider for paginated habit logs
final habitLogsPaginationProvider = StateNotifierProvider.family<
    HabitLogsPaginationNotifier, PaginationState<HabitLog>, HabitLogsPaginationParams>(
  (ref, params) {
    final repository = ref.watch(habitRepositoryProvider);
    return HabitLogsPaginationNotifier(repository, params);
  },
);

/// Convenience provider for paginated habit logs with just userId
final userHabitLogsPaginatedProvider = StateNotifierProvider.family<
    HabitLogsPaginationNotifier, PaginationState<HabitLog>, String>(
  (ref, userId) {
    final repository = ref.watch(habitRepositoryProvider);
    return HabitLogsPaginationNotifier(
      repository,
      HabitLogsPaginationParams(userId: userId),
    );
  },
);

/// Provider for recent habit logs (first page only, real-time)
final recentHabitLogsStreamProvider =
    StreamProvider.family<PaginatedResult<HabitLog>, HabitLogsPaginationParams>((ref, params) {
  final repository = ref.watch(habitRepositoryProvider);
  return repository.streamHabitLogsFirstPage(
    userId: params.userId,
    habitId: params.habitId,
    pageSize: 10,
  );
});

// ========== Habits Pagination ==========

/// Parameters for paginated habits query
class HabitsPaginationParams {
  final String userId;
  final bool? isActive;

  const HabitsPaginationParams({
    required this.userId,
    this.isActive,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitsPaginationParams &&
          userId == other.userId &&
          isActive == other.isActive;

  @override
  int get hashCode => Object.hash(userId, isActive);
}

/// Pagination notifier for habits
class HabitsPaginationNotifier extends PaginationNotifier<Habit> {
  final HabitRepository _repository;
  final HabitsPaginationParams _params;

  HabitsPaginationNotifier(this._repository, this._params) : super(pageSize: 20);

  @override
  Future<PaginatedResult<Habit>> fetchPage(int page, dynamic cursor) async {
    return _repository.getHabitsPaginated(
      userId: _params.userId,
      isActive: _params.isActive,
      pageSize: pageSize,
      startAfterDocument: cursor as DocumentSnapshot?,
      page: page,
    );
  }

  /// Add a new habit (optimistic update)
  void addHabit(Habit habit) {
    prependItem(habit);
  }

  /// Remove a habit by ID (optimistic update)
  void removeHabitById(String habitId) {
    removeWhere((habit) => habit.id == habitId);
  }

  /// Update a habit (optimistic update)
  void updateHabitById(String habitId, Habit updatedHabit) {
    updateWhere((habit) => habit.id == habitId, updatedHabit);
  }
}

/// Provider for paginated habits
final habitsPaginationProvider = StateNotifierProvider.family<
    HabitsPaginationNotifier, PaginationState<Habit>, HabitsPaginationParams>(
  (ref, params) {
    final repository = ref.watch(habitRepositoryProvider);
    return HabitsPaginationNotifier(repository, params);
  },
);

/// Convenience provider for user's active habits
final userActiveHabitsPaginatedProvider = StateNotifierProvider.family<
    HabitsPaginationNotifier, PaginationState<Habit>, String>(
  (ref, userId) {
    final repository = ref.watch(habitRepositoryProvider);
    return HabitsPaginationNotifier(
      repository,
      HabitsPaginationParams(userId: userId, isActive: true),
    );
  },
);
