import 'package:health/health.dart';
import 'package:flutter/foundation.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/models/health_data.dart';

/// Service for managing health data integration with HealthKit (iOS) and Health Connect (Android)
class HealthService {
  final Health _health = Health();
  late final Future<void> _configureFuture = _health.configure();
  static const String _healthConnectPackage =
      'com.google.android.apps.healthdata';

  // Health data types we want to access
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.WEIGHT,
    HealthDataType.WORKOUT,
  ];

  static const List<HealthDataType> _writeTypes = [
    HealthDataType.WEIGHT,
    HealthDataType.WORKOUT,
  ];

  List<HealthDataType> _requestedTypes() {
    if (kIsWeb) {
      return _types;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _types.where((type) => type != HealthDataType.SLEEP_IN_BED).toList();
    }
    return _types;
  }

  /// Request permissions for health data access
  Future<bool> requestAuthorization() async {
    final types = _requestedTypes();
    final permissions = types
        .map(
          (type) => _writeTypes.contains(type)
              ? HealthDataAccess.READ_WRITE
              : HealthDataAccess.READ,
        )
        .toList();

    try {
      await _configureFuture;
      final healthConnectReady = await _ensureHealthConnectAvailable();
      if (!healthConnectReady) {
        return false;
      }

      final granted =
          await _health.requestAuthorization(types, permissions: permissions);
      if (kDebugMode) {
        debugPrint('Health authorization: $granted');
      }
      return granted;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting health authorization: $e');
      }
      return false;
    }
  }

  Future<bool> _ensureHealthConnectAvailable() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    try {
      final status = await _health.getHealthConnectSdkStatus();
      if (status == HealthConnectSdkStatus.sdkAvailable) {
        return true;
      }
      if (kDebugMode) {
        debugPrint('Health Connect not available: $status');
      }
      await _health.installHealthConnect();
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Health Connect check failed: $e');
      }
      return false;
    }
  }

  Future<HealthConnectSdkStatus?> getHealthConnectStatus() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return null;
    }
    try {
      return await _health.getHealthConnectSdkStatus();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Health Connect status error: $e');
      }
      return null;
    }
  }

  Future<void> installHealthConnect() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;      
    try {
      await _health.installHealthConnect();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Health Connect install failed: $e');
      }
    }
  }

  Future<bool> openHealthConnectSettings() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    final settingsIntent = AndroidIntent(
      action: 'androidx.health.connect.client.action.HEALTH_CONNECT_SETTINGS',
    );
    if (await _tryLaunch(settingsIntent)) {
      return true;
    }

    final appIntent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.LAUNCHER',
      package: _healthConnectPackage,
    );
    if (await _tryLaunch(appIntent)) {
      return true;
    }

    final appSettingsIntent = AndroidIntent(
      action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
      data: 'package:$_healthConnectPackage',
    );
    if (await _tryLaunch(appSettingsIntent)) {
      return true;
    }

    await installHealthConnect();
    return false;
  }

  Future<bool> _tryLaunch(AndroidIntent intent) async {
    try {
      final canResolve = await intent.canResolveActivity();
      if (canResolve == true) {
        await intent.launch();
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Health Connect intent launch failed: $e');
      }
    }
    return false;
  }

  /// Open system settings to allow users to enable health permissions
  /// On iOS, opens the Health app settings; on Android, opens Health Connect settings
  Future<bool> openHealthSettings() async {
    if (kIsWeb) return false;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // On iOS, open the Settings app to the Health section
      // Users can then navigate to Kinesa to enable permissions
      try {
        final uri = Uri.parse('app-settings:');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
          return true;
        }
        // Fallback: try opening Health app directly
        final healthUri = Uri.parse('x-apple-health://');
        if (await canLaunchUrl(healthUri)) {
          await launchUrl(healthUri);
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error opening iOS settings: $e');
        }
      }
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return await openHealthConnectSettings();
    }

    return false;
  }

  /// Check if we have authorization for at least core health data types
  /// Returns true if we have permission for steps (the minimum required)
  Future<bool> hasPermissions() async {
    try {
      await _configureFuture;
      // Check if we have at least steps permission (core health data)
      final stepsPermission = await _health.hasPermissions([HealthDataType.STEPS]);
      return stepsPermission == true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking health permissions: $e');
      }
      return false;
    }
  }

  /// Check permissions for all requested types (more detailed check)
  Future<Map<HealthDataType, bool>> getDetailedPermissions() async {
    final permissions = <HealthDataType, bool>{};
    try {
      await _configureFuture;
      for (var type in _requestedTypes()) {
        final status = await _health.hasPermissions([type]);
        permissions[type] = status == true;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking detailed permissions: $e');
      }
    }
    return permissions;
  }

  /// Get steps for today
  Future<int?> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      await _configureFuture;
      final steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching steps: $e');
      }
      return null;
    }
  }

  /// Get total steps for a date range
  Future<int> getSteps(DateTime startDate, DateTime endDate) async {
    try {
      await _configureFuture;
      final steps = await _health.getTotalStepsInInterval(startDate, endDate);
      return steps ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get distance for a date range (in meters)
  Future<double> getDistance(DateTime startDate, DateTime endDate) async {
    try {
      await _configureFuture;
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.DISTANCE_DELTA],
        startTime: startDate,
        endTime: endDate,
      );

      double totalDistance = 0.0;
      for (var point in healthData) {
        if (point.value is NumericHealthValue) {
          totalDistance += (point.value as NumericHealthValue).numericValue;
        }
      }
      return totalDistance;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get calories burned for a date range
  Future<double> getCaloriesBurned(DateTime startDate, DateTime endDate) async {
    try {
      await _configureFuture;
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: startDate,
        endTime: endDate,
      );

      double totalCalories = 0.0;
      for (var point in healthData) {
        if (point.value is NumericHealthValue) {
          totalCalories += (point.value as NumericHealthValue).numericValue;
        }
      }
      return totalCalories;
    } catch (e) {
      return 0.0;
    }
  }

  /// Get average heart rate for a date range
  Future<double?> getAverageHeartRate(DateTime startDate, DateTime endDate) async {
    try {
      await _configureFuture;
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startDate,
        endTime: endDate,
      );

      if (healthData.isEmpty) return null;

      double total = 0.0;
      int count = 0;
      for (var point in healthData) {
        if (point.value is NumericHealthValue) {
          total += (point.value as NumericHealthValue).numericValue;
          count++;
        }
      }
      return count > 0 ? total / count : null;
    } catch (e) {
      return null;
    }
  }

  /// Get sleep duration for a date range (in hours)
  Future<double> getSleepHours(DateTime startDate, DateTime endDate) async {
    try {
      await _configureFuture;
      final sleepTypes = defaultTargetPlatform == TargetPlatform.android
          ? [HealthDataType.SLEEP_ASLEEP]
          : [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_IN_BED];
      final healthData = await _health.getHealthDataFromTypes(
        types: sleepTypes,
        startTime: startDate,
        endTime: endDate,
      );

      double totalMinutes = 0.0;
      for (var point in healthData) {
        if (point.type == HealthDataType.SLEEP_ASLEEP) {
          final duration = point.dateTo.difference(point.dateFrom).abs();
          totalMinutes += duration.inMinutes.toDouble();
        }
      }
      return totalMinutes / 60.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Write a workout to health data
  Future<bool> writeWorkout({
    required HealthWorkoutActivityType activityType,
    required DateTime startTime,
    required DateTime endTime,
    int? totalEnergyBurned,
    double? totalDistance,
  }) async {
    try {
      await _configureFuture;
      final success = await _health.writeWorkoutData(
        activityType: activityType,
        start: startTime,
        end: endTime,
        totalEnergyBurned: totalEnergyBurned,
        totalDistance: totalDistance?.toInt(),
      );
      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error writing workout: $e');
      }
      return false;
    }
  }

  /// Write weight to health data
  Future<bool> writeWeight(double weightKg, DateTime date) async {
    try {
      await _configureFuture;
      final success = await _health.writeHealthData(
        value: weightKg,
        type: HealthDataType.WEIGHT,
        startTime: date,
        endTime: date,
      );
      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error writing weight: $e');
      }
      return false;
    }
  }

  /// Get today's health summary
  Future<HealthSummary> getTodaySummary() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final steps = await getTodaySteps() ?? 0;
    final distance = await getDistance(startOfDay, now);
    final calories = await getCaloriesBurned(startOfDay, now);
    final heartRate = await getAverageHeartRate(startOfDay, now);

    // Get sleep from yesterday night to this morning
    final sleepStart = startOfDay.subtract(const Duration(hours: 12));
    final sleep = await getSleepHours(sleepStart, now);

    return HealthSummary(
      steps: steps,
      distanceMeters: distance,
      caloriesBurned: calories,
      averageHeartRate: heartRate,
      sleepHours: sleep,
      date: startOfDay,
    );
  }

  /// Get the current health data source based on platform
  HealthDataSource getCurrentSource() {
    if (kIsWeb) {
      return HealthDataSource.unknown;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return HealthDataSource.appleHealth;
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return HealthDataSource.googleFit;
    }
    return HealthDataSource.unknown;
  }

  /// Get device information for source details
  Future<HealthSourceDetails> getSourceDetails() async {
    if (kIsWeb) {
      return const HealthSourceDetails(
        deviceName: 'Web Browser',
        appName: 'Kinesa',
      );
    }

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return HealthSourceDetails(
          deviceName: iosInfo.name,
          deviceModel: iosInfo.model,
          appName: 'Kinesa',
          originalTimestamp: DateTime.now(),
        );
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return HealthSourceDetails(
          deviceName: androidInfo.device,
          deviceModel: androidInfo.model,
          appName: 'Kinesa',
          originalTimestamp: DateTime.now(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting device info: $e');
      }
    }

    return HealthSourceDetails(
      appName: 'Kinesa',
      originalTimestamp: DateTime.now(),
    );
  }

  /// Get today's health summary with source information
  Future<HealthSummaryWithSource> getTodaySummaryWithSource() async {
    final summary = await getTodaySummary();
    final source = getCurrentSource();
    final sourceDetails = await getSourceDetails();

    return HealthSummaryWithSource(
      summary: summary,
      source: source,
      sourceDetails: sourceDetails,
    );
  }

  Future<List<HealthDataPoint>> getHealthData({
    required DateTime startTime,
    required DateTime endTime,
    required List<HealthDataType> types,
  }) async {
    try {
      await _configureFuture;
      final healthData = await _health.getHealthDataFromTypes(
        startTime: startTime,
        endTime: endTime,
        types: types,
      );
      return healthData;
    } catch (e) {
      return [];
    }
  }

  Future<bool> writeHealthData({
    required HealthDataType type,
    required double value,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      await _configureFuture;
      final success = await _health.writeHealthData(
        value: value,
        type: type,
        startTime: startTime,
        endTime: endTime,
      );
      return success;
    } catch (e) {
      return false;
    }
  }
}

/// Model for health data summary
class HealthSummary {
  final int steps;
  final double distanceMeters;
  final double caloriesBurned;
  final double? averageHeartRate;
  final double sleepHours;
  final DateTime date;

  HealthSummary({
    required this.steps,
    required this.distanceMeters,
    required this.caloriesBurned,
    required this.averageHeartRate,
    required this.sleepHours,
    required this.date,
  });

  double get distanceKm => distanceMeters / 1000.0;

  bool get hasMeaningfulData =>
      steps > 0 || distanceMeters > 0 || caloriesBurned > 0 || sleepHours > 0;
}

/// Model for health data summary with source information
class HealthSummaryWithSource {
  final HealthSummary summary;
  final HealthDataSource source;
  final HealthSourceDetails sourceDetails;

  HealthSummaryWithSource({
    required this.summary,
    required this.source,
    required this.sourceDetails,
  });
}
