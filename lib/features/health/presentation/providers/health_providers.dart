import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health/health.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/health_service.dart';
import '../../data/repositories/health_repository.dart';
import '../../domain/models/health_data.dart';
import '../../domain/models/weekly_health_stats.dart';

// ========== SERVICE PROVIDER ==========

/// Provider for HealthService singleton
final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

/// Provider for HealthRepository
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  return HealthRepository(healthService: healthService);
});

// ========== PERMISSION PROVIDERS ==========

/// Provider to check if health permissions are granted
final healthPermissionsProvider = FutureProvider<bool>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  return await healthService.hasPermissions();
});

/// Provider to request health permissions
final healthAuthorizationProvider = FutureProvider<bool>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  return await healthService.requestAuthorization();
});

// ========== HEALTH DATA PROVIDERS ==========

/// Provider for today's health summary
final todayHealthSummaryProvider = FutureProvider<HealthSummary>((ref) async {
  final healthService = ref.watch(healthServiceProvider);

  // Check permissions first
  final hasPermissions = await healthService.hasPermissions();
  if (!hasPermissions) {
    // Return empty summary if no permissions
    return HealthSummary(
      steps: 0,
      distanceMeters: 0.0,
      caloriesBurned: 0.0,
      averageHeartRate: null,
      sleepHours: 0.0,
      date: DateTime.now(),
    );
  }

  return await healthService.getTodaySummary();
});

/// Provider for today's steps count
final todayStepsProvider = FutureProvider<int>((ref) async {
  final healthService = ref.watch(healthServiceProvider);

  final hasPermissions = await healthService.hasPermissions();
  if (!hasPermissions) return 0;

  final steps = await healthService.getTodaySteps();
  return steps ?? 0;
});

/// Provider for steps in a date range
final stepsRangeProvider = FutureProvider.family<int, DateRange>((ref, dateRange) async {
  final healthService = ref.watch(healthServiceProvider);

  final hasPermissions = await healthService.hasPermissions();
  if (!hasPermissions) return 0;

  return await healthService.getSteps(dateRange.start, dateRange.end);
});

/// Provider for weekly steps (last 7 days)
final weeklyStepsProvider = FutureProvider<List<DailySteps>>((ref) async {
  final healthService = ref.watch(healthServiceProvider);

  final hasPermissions = await healthService.hasPermissions();
  if (!hasPermissions) return [];

  final now = DateTime.now();
  final List<DailySteps> weeklyData = [];

  for (int i = 6; i >= 0; i--) {
    final date = now.subtract(Duration(days: i));
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = i == 0 ? now : DateTime(date.year, date.month, date.day, 23, 59, 59);

    final steps = await healthService.getSteps(startOfDay, endOfDay);
    weeklyData.add(DailySteps(date: startOfDay, steps: steps));
  }

  return weeklyData;
});

// ========== SYNC PROVIDERS ==========

/// Provider for last health data sync timestamp
final lastHealthSyncProvider = FutureProvider<DateTime?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final timestamp = prefs.getInt('last_health_sync');

  if (timestamp == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(timestamp);
});

/// Provider to trigger health data sync
final healthSyncProvider = FutureProvider<bool>((ref) async {
  final healthService = ref.watch(healthServiceProvider);

  final hasPermissions = await healthService.hasPermissions();
  if (!hasPermissions) return false;

  try {
    // Fetch today's data to trigger sync
    await healthService.getTodaySummary();

    // Save sync timestamp
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_health_sync', DateTime.now().millisecondsSinceEpoch);

    // Invalidate data providers to refresh
    ref.invalidate(todayHealthSummaryProvider);
    ref.invalidate(todayStepsProvider);
    ref.invalidate(weeklyStepsProvider);

    return true;
  } catch (e) {
    return false;
  }
});

// ========== STATE NOTIFIER FOR WRITE OPERATIONS ==========

/// State notifier for health write operations
class HealthOperations extends StateNotifier<AsyncValue<void>> {
  final HealthService _healthService;
  final Ref _ref;

  HealthOperations(this._healthService, this._ref)
      : super(const AsyncValue.data(null));

  /// Write weight to health data
  Future<bool> writeWeight(double weightKg, DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final success = await _healthService.writeWeight(weightKg, date);
      state = const AsyncValue.data(null);

      // Refresh health data
      _ref.invalidate(todayHealthSummaryProvider);

      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Write workout to health data
  Future<bool> writeWorkout({
    required String workoutType,
    required DateTime startTime,
    required DateTime endTime,
    int? caloriesBurned,
    double? distanceMeters,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Map workout type string to HealthWorkoutActivityType
      final activityType = _mapWorkoutType(workoutType);

      final success = await _healthService.writeWorkout(
        activityType: activityType,
        startTime: startTime,
        endTime: endTime,
        totalEnergyBurned: caloriesBurned,
        totalDistance: distanceMeters,
      );

      state = const AsyncValue.data(null);

      // Refresh health data
      _ref.invalidate(todayHealthSummaryProvider);
      _ref.invalidate(todayStepsProvider);

      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Map workout type string to HealthWorkoutActivityType
  HealthWorkoutActivityType _mapWorkoutType(String type) {
    // For now, return a generic workout type
    // TODO: Update with correct enum values from health package v10.0.0
    return HealthWorkoutActivityType.WALKING;
  }
}

/// Provider for health operations
final healthOperationsProvider = StateNotifierProvider<HealthOperations, AsyncValue<void>>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  return HealthOperations(healthService, ref);
});

// ========== REPOSITORY-BASED PROVIDERS ==========

/// Provider for current user ID
final _currentUserIdProvider = Provider<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
});

/// Provider for synced health data (from Firestore + HealthKit/Google Fit)
final syncedTodayHealthDataProvider = FutureProvider<HealthData?>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return null;

  final repository = ref.watch(healthRepositoryProvider);

  // Sync today's data from HealthKit/Google Fit to Firestore
  return await repository.syncTodayHealthData(userId);
});

/// Provider for health data by date
final healthDataByDateProvider = FutureProvider.family<HealthData?, DateTime>((ref, date) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return null;

  final repository = ref.watch(healthRepositoryProvider);
  return await repository.getHealthDataByDate(userId, date);
});

/// Provider for last 7 days health data
final last7DaysHealthDataProvider = FutureProvider<List<HealthData>>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(healthRepositoryProvider);
  return await repository.getLast7DaysData(userId);
});

/// Provider for last 30 days health data
final last30DaysHealthDataProvider = FutureProvider<List<HealthData>>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(healthRepositoryProvider);
  return await repository.getLast30DaysData(userId);
});

/// Provider for weekly health statistics
final weeklyHealthStatsProvider = FutureProvider<WeeklyHealthStats>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) {
    final now = DateTime.now();
    return WeeklyHealthStats(
      totalSteps: 0,
      totalDistanceKm: 0,
      totalCalories: 0,
      averageHeartRate: 0,
      averageSleepHours: 0,
      daysWithData: 0,
      weekStartDate: now,
      weekEndDate: now,
    );
  }

  final repository = ref.watch(healthRepositoryProvider);
  return await repository.getWeeklyStats(userId);
});

/// Provider for daily health points (for charts)
final dailyHealthPointsProvider = FutureProvider.family<List<DailyHealthPoint>, int>((ref, days) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final repository = ref.watch(healthRepositoryProvider);
  return await repository.getDailyPointsForChart(userId, days);
});

/// Stream provider for watching health data range
final watchHealthDataRangeProvider = StreamProvider.family<List<HealthData>, DateRange>((ref, dateRange) {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(healthRepositoryProvider);
  return repository.watchHealthDataRange(userId, dateRange.start, dateRange.end);
});

// ========== HELPER MODELS ==========

/// Date range helper
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
}

/// Daily steps model
class DailySteps {
  final DateTime date;
  final int steps;

  DailySteps({required this.date, required this.steps});
}
