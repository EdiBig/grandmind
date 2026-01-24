import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health/health.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../data/services/health_service.dart';
import '../../data/services/health_insights_service.dart';
import '../../data/repositories/health_repository.dart';
import '../../domain/models/health_data.dart';
import '../../domain/models/health_insights.dart';
import '../../domain/models/weekly_health_stats.dart';
import '../../../ai/data/services/claude_api_service.dart';
import '../../../mood_energy/domain/models/energy_log.dart';
import '../../../mood_energy/data/repositories/mood_energy_repository.dart';
import '../../../workouts/domain/models/workout_log.dart';
import '../../../workouts/data/repositories/workout_repository.dart';

// ========== SERVICE PROVIDER ==========

/// Provider for HealthService singleton
final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

/// Provider for HealthRepository
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  final analytics = ref.watch(analyticsProvider);
  return HealthRepository(healthService: healthService, analytics: analytics);
});

const String _healthSummaryCacheKey = 'health_summary_cache';

Future<HealthSummary?> _loadCachedSummary() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_healthSummaryCacheKey);
  if (raw == null || raw.isEmpty) return null;
  try {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final dateMs = data['date'] as int?;
    if (dateMs == null) return null;
    return HealthSummary(
      steps: data['steps'] as int? ?? 0,
      distanceMeters: (data['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      caloriesBurned: (data['caloriesBurned'] as num?)?.toDouble() ?? 0.0,
      averageHeartRate: (data['averageHeartRate'] as num?)?.toDouble(),
      sleepHours: (data['sleepHours'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.fromMillisecondsSinceEpoch(dateMs),
    );
  } catch (_) {
    return null;
  }
}

Future<void> _saveCachedSummary(HealthSummary summary) async {
  final prefs = await SharedPreferences.getInstance();
  final data = <String, dynamic>{
    'steps': summary.steps,
    'distanceMeters': summary.distanceMeters,
    'caloriesBurned': summary.caloriesBurned,
    'averageHeartRate': summary.averageHeartRate,
    'sleepHours': summary.sleepHours,
    'date': summary.date.millisecondsSinceEpoch,
  };
  await prefs.setString(_healthSummaryCacheKey, jsonEncode(data));
}

HealthSummary _emptySummary() {
  return HealthSummary(
    steps: 0,
    distanceMeters: 0.0,
    caloriesBurned: 0.0,
    averageHeartRate: null,
    sleepHours: 0.0,
    date: DateTime.now(),
  );
}

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

final healthConnectStatusProvider = FutureProvider<HealthConnectSdkStatus?>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  return await healthService.getHealthConnectStatus();
});

// ========== HEALTH DATA PROVIDERS ==========

class HealthSummaryController extends StateNotifier<AsyncValue<HealthSummary>> {
  HealthSummaryController(this._healthService)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final HealthService _healthService;

  Future<void> _load() async {
    final cached = await _loadCachedSummary();
    state = AsyncValue.data(cached ?? _emptySummary());
    await refresh();
  }

  Future<void> refresh({bool force = false}) async {
    final hasPermissions = await _healthService.hasPermissions();
    if (!hasPermissions) {
      return;
    }

    try {
      final summary = await _healthService.getTodaySummary();
      final shouldCache = summary.hasMeaningfulData || force;
      if (shouldCache) {
        await _saveCachedSummary(summary);
        state = AsyncValue.data(summary);
      } else if (state.asData?.value == null) {
        state = AsyncValue.data(summary);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider for today's health summary (cache-first, refreshes in background)
final healthSummaryProvider =
    StateNotifierProvider<HealthSummaryController, AsyncValue<HealthSummary>>(
        (ref) {
  final healthService = ref.watch(healthServiceProvider);
  return HealthSummaryController(healthService);
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
  final repository = ref.watch(healthRepositoryProvider);
  final userId = ref.watch(_currentUserIdProvider);

  final hasPermissions = await healthService.hasPermissions();
  if (!hasPermissions || userId == null) return false;

  try {
    // Fetch today's data and persist to Firestore
    await repository.syncTodayHealthData(userId);

    // Save sync timestamp
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_health_sync', DateTime.now().millisecondsSinceEpoch);

    // Invalidate data providers to refresh
    ref.read(healthSummaryProvider.notifier).refresh(force: true);
    ref.invalidate(todayStepsProvider);
    ref.invalidate(weeklyStepsProvider);
    ref.invalidate(syncedTodayHealthDataProvider);
    ref.invalidate(last7DaysHealthDataProvider);
    ref.invalidate(last30DaysHealthDataProvider);
    ref.invalidate(weeklyHealthStatsProvider);

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
      _ref.read(healthSummaryProvider.notifier).refresh(force: true);

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
      _ref.read(healthSummaryProvider.notifier).refresh(force: true);
      _ref.invalidate(todayStepsProvider);

      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Map workout type string to HealthWorkoutActivityType
  HealthWorkoutActivityType _mapWorkoutType(String type) {
    final normalized = type.toLowerCase();
    if (normalized.contains('yoga')) {
      return HealthWorkoutActivityType.YOGA;
    }
    if (normalized.contains('walk')) {
      return HealthWorkoutActivityType.WALKING;
    }
    if (normalized.contains('run')) {
      return HealthWorkoutActivityType.RUNNING;
    }
    if (normalized.contains('bike') || normalized.contains('cycle')) {
      return HealthWorkoutActivityType.BIKING;
    }
    if (normalized.contains('swim')) {
      return HealthWorkoutActivityType.SWIMMING;
    }
    if (normalized.contains('row')) {
      return HealthWorkoutActivityType.ROWING;
    }
    if (normalized.contains('hiit') || normalized.contains('interval')) {
      return HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING;
    }
    if (normalized.contains('strength') ||
        normalized.contains('weights') ||
        normalized.contains('weight') ||
        normalized.contains('resistance')) {
      return HealthWorkoutActivityType.STRENGTH_TRAINING;
    }
    if (normalized.contains('sport')) {
      return HealthWorkoutActivityType.OTHER;
    }
    return HealthWorkoutActivityType.OTHER;
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

// ========== HEALTH INSIGHTS PROVIDERS ==========

/// Provider for HealthInsightsService
final healthInsightsServiceProvider = Provider<HealthInsightsService>((ref) {
  // Try to get ClaudeAPIService if available (optional)
  ClaudeAPIService? claudeService;
  try {
    claudeService = ref.watch(claudeApiServiceProvider);
  } catch (_) {
    // AI service not available, insights will use fallback
  }
  return HealthInsightsService(claudeService: claudeService);
});

/// Provider for ClaudeAPIService (can fail if not configured)
final claudeApiServiceProvider = Provider<ClaudeAPIService>((ref) {
  return ClaudeAPIService();
});

/// Provider for health insights (30-day analysis)
final healthInsightsProvider = FutureProvider.autoDispose<HealthInsights>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  // Get health data (last 30 days)
  final healthData = await ref.watch(last30DaysHealthDataProvider.future);

  // Get energy logs (last 30 days)
  final energyLogs = await ref.watch(energyLogsLast30DaysProvider.future);

  // Get workout logs (last 30 days)
  final workoutLogs = await ref.watch(workoutLogsLast30DaysProvider.future);

  // Generate insights
  final insightsService = ref.watch(healthInsightsServiceProvider);
  return await insightsService.generateInsights(
    healthData: healthData,
    energyLogs: energyLogs,
    workoutLogs: workoutLogs,
  );
});

/// Provider for energy logs (last 30 days)
final energyLogsLast30DaysProvider = FutureProvider<List<EnergyLog>>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final now = DateTime.now();
  final startDate = now.subtract(const Duration(days: 30));

  try {
    final repository = ref.watch(moodEnergyRepositoryProvider);
    return await repository.getLogsInRange(userId, startDate, now);
  } catch (_) {
    return [];
  }
});

/// Provider for workout logs (last 30 days)
final workoutLogsLast30DaysProvider = FutureProvider<List<WorkoutLog>>((ref) async {
  final userId = ref.watch(_currentUserIdProvider);
  if (userId == null) return [];

  final now = DateTime.now();
  final startDate = now.subtract(const Duration(days: 30));

  try {
    final repository = ref.watch(workoutRepositoryProvider);
    return await repository.getUserWorkoutLogs(
      userId,
      startDate: startDate,
      endDate: now,
    );
  } catch (_) {
    return [];
  }
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
