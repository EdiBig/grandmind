import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/habit.dart';
import '../../domain/models/habit_log.dart';
import '../../data/repositories/habit_repository.dart';
import '../../data/services/habit_insights_service.dart';

/// Provider for user's habits stream
final userHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(habitRepositoryProvider);
  return repository.getUserHabitsStream(userId, isActive: true);
});

/// Provider for a specific habit
final habitProvider = StreamProvider.family<Habit?, String>(
  (ref, habitId) {
    final repository = ref.watch(habitRepositoryProvider);
    return repository.getHabitStream(habitId);
  },
);

/// Provider for today's habit logs
final todayHabitLogsProvider = FutureProvider<List<HabitLog>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final repository = ref.watch(habitRepositoryProvider);
  final today = DateTime.now();
  return repository.getUserHabitLogsForDate(userId, today);
});

/// Provider for checking if a specific habit is completed today
final habitCompletedTodayProvider = FutureProvider.family<HabitLog?, String>(
  (ref, habitId) async {
    final repository = ref.watch(habitRepositoryProvider);
    final today = DateTime.now();
    return repository.getHabitLogForDate(habitId, today);
  },
);

/// Provider for habit statistics
final habitStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return {};

  final repository = ref.watch(habitRepositoryProvider);
  return repository.getHabitStats(userId);
});

/// Provider for habit logs for a specific habit
final habitLogsProvider = FutureProvider.family<List<HabitLog>, HabitLogsParams>(
  (ref, params) async {
    final repository = ref.watch(habitRepositoryProvider);
    return repository.getHabitLogs(
      params.habitId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  },
);

/// Parameters for habit logs query
class HabitLogsParams {
  final String habitId;
  final DateTime? startDate;
  final DateTime? endDate;

  HabitLogsParams({
    required this.habitId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitLogsParams &&
          runtimeType == other.runtimeType &&
          habitId == other.habitId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(habitId, startDate, endDate);
}

/// State notifier for managing habit operations
class HabitOperations extends StateNotifier<AsyncValue<void>> {
  final HabitRepository _repository;

  HabitOperations(this._repository) : super(const AsyncValue.data(null));

  /// Create a new habit
  Future<String?> createHabit(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final habitId = await _repository.createHabit(habit);
      state = const AsyncValue.data(null);
      return habitId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update an existing habit
  Future<bool> updateHabit(String habitId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateHabit(habitId, data);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Delete a habit
  Future<bool> deleteHabit(String habitId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteHabit(habitId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Toggle habit completion for today
  Future<bool> toggleHabitCompletion(Habit habit) async {
    state = const AsyncValue.loading();
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Check if already completed today
      final existingLog = await _repository.getHabitLogForDate(habit.id, today);

      if (existingLog != null) {
        // Uncomplete - delete the log
        await _repository.deleteHabitLog(existingLog.id, habit.id, habit.userId);
      } else {
        // Complete - create a log
        final log = HabitLog(
          id: '',
          habitId: habit.id,
          userId: habit.userId,
          date: startOfDay,
          completedAt: DateTime.now(),
          count: 1,
        );
        await _repository.logHabit(log);
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Log habit with custom count
  Future<bool> logHabitWithCount(Habit habit, int count, {String? notes}) async {
    state = const AsyncValue.loading();
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      // Check if already logged today
      final existingLog = await _repository.getHabitLogForDate(habit.id, today);

      if (existingLog != null) {
        // Update existing log
        await _repository.updateHabitLog(existingLog.id, {
          'count': count,
          if (notes != null) 'notes': notes,
        });
      } else {
        // Create new log
        final log = HabitLog(
          id: '',
          habitId: habit.id,
          userId: habit.userId,
          date: startOfDay,
          completedAt: DateTime.now(),
          count: count,
          notes: notes,
        );
        await _repository.logHabit(log);
      }

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Archive/activate a habit
  Future<bool> setHabitActive(String habitId, bool isActive) async {
    state = const AsyncValue.loading();
    try {
      await _repository.setHabitActive(habitId, isActive);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

/// Provider for habit operations
final habitOperationsProvider =
    StateNotifierProvider<HabitOperations, AsyncValue<void>>((ref) {
  final repository = ref.watch(habitRepositoryProvider);
  return HabitOperations(repository);
});

/// Provider for AI-generated habit insights
final habitInsightsProvider = FutureProvider<HabitInsights>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return HabitInsights.empty();

  final insightsService = ref.watch(habitInsightsServiceProvider);
  final repository = ref.watch(habitRepositoryProvider);

  // Get user's habits
  final habits = await repository.getUserHabits(userId, isActive: true);
  if (habits.isEmpty) return HabitInsights.empty();

  // Get recent logs (last 30 days)
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));

  final allLogs = <HabitLog>[];
  for (var habit in habits) {
    final logs = await repository.getHabitLogs(
      habit.id,
      startDate: thirtyDaysAgo,
      endDate: now,
    );
    allLogs.addAll(logs);
  }

  // Generate insights
  return insightsService.generateInsights(userId, habits, allLogs);
});
