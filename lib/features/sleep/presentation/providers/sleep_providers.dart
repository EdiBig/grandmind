import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sleep_repository.dart';
import '../../domain/models/sleep_log.dart';

/// Provider for the current user's ID
final _currentUserIdProvider = Provider<String?>((ref) {
  return FirebaseAuth.instance.currentUser?.uid;
});

/// Stream provider for today's sleep log
final todaySleepLogProvider = StreamProvider<SleepLog?>((ref) {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return Stream.value(null);

  final repository = ref.watch(sleepRepositoryProvider);
  return repository.watchTodayLog(userId);
});

/// Provider for weekly sleep statistics
final weeklySleepStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) {
    return {
      'averageHours': 0.0,
      'averageQuality': 0.0,
      'totalLogs': 0,
    };
  }

  final repository = ref.watch(sleepRepositoryProvider);
  return repository.getWeeklyStats(userId);
});

/// Provider for sleep logs in a date range
final sleepLogsRangeProvider = FutureProvider.family<List<SleepLog>, DateRange>((ref, range) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(sleepRepositoryProvider);
  return repository.getLogsInRange(userId, range.start, range.end);
});

/// Helper class for date range
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// Notifier for sleep operations (create, update, delete)
class SleepOperationsNotifier extends StateNotifier<AsyncValue<void>> {
  final SleepRepository _repository;
  final Ref _ref;

  SleepOperationsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<bool> logSleep({
    required double hoursSlept,
    int? quality,
    DateTime? bedTime,
    DateTime? wakeTime,
    List<String>? tags,
    String? notes,
    DateTime? logDate,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      state = AsyncValue.error('User not logged in', StackTrace.current);
      return false;
    }

    state = const AsyncValue.loading();

    try {
      final log = SleepLog(
        id: '',
        userId: userId,
        logDate: logDate ?? DateTime.now(),
        hoursSlept: hoursSlept,
        quality: quality,
        bedTime: bedTime,
        wakeTime: wakeTime,
        tags: tags ?? [],
        notes: notes,
        source: 'manual',
      );

      await _repository.upsertLog(log);

      // Invalidate related providers to refresh data
      _ref.invalidate(todaySleepLogProvider);
      _ref.invalidate(weeklySleepStatsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteSleepLog(String logId) async {
    state = const AsyncValue.loading();

    try {
      await _repository.deleteLog(logId);

      _ref.invalidate(todaySleepLogProvider);
      _ref.invalidate(weeklySleepStatsProvider);

      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final sleepOperationsProvider =
    StateNotifierProvider<SleepOperationsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(sleepRepositoryProvider);
  return SleepOperationsNotifier(repository, ref);
});
