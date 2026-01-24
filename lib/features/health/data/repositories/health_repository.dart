import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../domain/models/health_data.dart';
import '../../domain/models/weekly_health_stats.dart';
import '../services/health_service.dart';
import '../services/health_deduplication_service.dart';

// Re-export HealthDataSource for convenience
export '../../domain/models/health_data.dart' show HealthDataSource, HealthSourceDetails;

/// Repository for managing health data with Firestore persistence
class HealthRepository {
  final FirebaseFirestore _firestore;
  final HealthService _healthService;
  final AnalyticsService _analytics;
  final HealthDeduplicationService _deduplicationService;

  HealthRepository({
    FirebaseFirestore? firestore,
    required HealthService healthService,
    AnalyticsService? analytics,
    HealthDeduplicationService? deduplicationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _healthService = healthService,
        _analytics = analytics ?? AnalyticsService(),
        _deduplicationService = deduplicationService ?? HealthDeduplicationService();

  /// Collection reference for health data
  CollectionReference<Map<String, dynamic>> _healthDataCollection(
      String userId) {
    return _firestore.collection('health_data');
  }

  /// Sync today's health data from HealthKit/Google Fit to Firestore
  Future<HealthData?> syncTodayHealthData(String userId) async {
    try {
      // Check permissions first
      final hasPermissions = await _healthService.hasPermissions();
      if (!hasPermissions) {
        if (kDebugMode) {
          debugPrint('Health permissions not granted');
        }
        return null;
      }

      // Get today's health summary with source from HealthKit/Google Fit
      final summaryWithSource = await _healthService.getTodaySummaryWithSource();
      final summary = summaryWithSource.summary;
      final source = summaryWithSource.source;
      final sourceDetails = summaryWithSource.sourceDetails;

      // Create HealthData model
      final today = DateTime.now();
      final dateId =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final docId = '${userId}_$dateId';

      final healthData = HealthData(
        id: docId,
        userId: userId,
        date: DateTime(today.year, today.month, today.day),
        steps: summary.steps,
        distanceMeters: summary.distanceMeters,
        caloriesBurned: summary.caloriesBurned,
        averageHeartRate: summary.averageHeartRate,
        sleepHours: summary.sleepHours,
        source: source,
        sourceDetails: sourceDetails,
        syncedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Smart merge with existing data
      final mergedData = await _smartMergeHealthData(userId, docId, healthData);

      // Track analytics
      final analyticsSource = defaultTargetPlatform == TargetPlatform.iOS
          ? 'apple_health'
          : 'google_fit';
      await _analytics.logHealthSynced(
        source: analyticsSource,
        dataType: 'daily_summary',
      );

      if (kDebugMode) {
        debugPrint('Health data synced successfully for $dateId with source: ${source.name}');
      }

      return mergedData;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing health data: $e');
      }
      return null;
    }
  }

  /// Smart merge health data with existing record if present
  Future<HealthData> _smartMergeHealthData(
    String userId,
    String docId,
    HealthData incoming,
  ) async {
    try {
      final doc = await _healthDataCollection(userId).doc(docId).get();

      if (!doc.exists) {
        // No existing data, save the incoming data
        await _healthDataCollection(userId).doc(docId).set(incoming.toJson());
        return incoming;
      }

      // Existing data found, perform smart merge
      final existing = HealthData.fromJson(doc.data()!);
      final merged = _deduplicationService.smartMerge(existing, incoming);

      // Save the merged data
      await _healthDataCollection(userId).doc(docId).set(merged.toJson());

      if (kDebugMode) {
        debugPrint(
          'Smart merged health data: '
          'existing source=${existing.source.name}, '
          'incoming source=${incoming.source.name}, '
          'merged source=${merged.source.name}',
        );
      }

      return merged;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error in smart merge, falling back to simple save: $e');
      }
      // Fallback to simple save
      await _healthDataCollection(userId).doc(docId).set(incoming.toJson());
      return incoming;
    }
  }

  /// Get health data for a specific date
  Future<HealthData?> getHealthDataByDate(
      String userId, DateTime date) async {
    try {
      final dateId =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final docId = '${userId}_$dateId';

      final doc = await _healthDataCollection(userId).doc(docId).get();

      if (!doc.exists) {
        return null;
      }

      return HealthData.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching health data: $e');
      }
      return null;
    }
  }

  /// Get health data for a date range
  Future<List<HealthData>> getHealthDataRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _healthDataCollection(userId)
          .where('userId', isEqualTo: userId)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HealthData.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching health data range: $e');
      }
      return [];
    }
  }

  /// Get last 7 days of health data
  Future<List<HealthData>> getLast7DaysData(String userId) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));
    return getHealthDataRange(userId, startDate, now);
  }

  /// Get last 30 days of health data
  Future<List<HealthData>> getLast30DaysData(String userId) async {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    return getHealthDataRange(userId, startDate, now);
  }

  /// Stream health data for a date range
  Stream<List<HealthData>> watchHealthDataRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return _healthDataCollection(userId)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => HealthData.fromJson(doc.data())).toList());
  }

  /// Get weekly statistics
  Future<WeeklyHealthStats> getWeeklyStats(String userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final weekData = await getHealthDataRange(userId, weekStartDate, now);

    if (weekData.isEmpty) {
      return WeeklyHealthStats(
        totalSteps: 0,
        totalDistanceKm: 0,
        totalCalories: 0,
        averageHeartRate: 0,
        averageSleepHours: 0,
        daysWithData: 0,
        weekStartDate: weekStartDate,
        weekEndDate: now,
      );
    }

    int totalSteps = 0;
    double totalDistance = 0;
    double totalCalories = 0;
    double totalHeartRate = 0;
    int heartRateCount = 0;
    double totalSleep = 0;

    for (var data in weekData) {
      totalSteps += data.steps;
      totalDistance += data.distanceKm;
      totalCalories += data.caloriesBurned;
      totalSleep += data.sleepHours;

      if (data.averageHeartRate != null) {
        totalHeartRate += data.averageHeartRate!;
        heartRateCount++;
      }
    }

    return WeeklyHealthStats(
      totalSteps: totalSteps,
      totalDistanceKm: totalDistance,
      totalCalories: totalCalories,
      averageHeartRate: heartRateCount > 0 ? totalHeartRate / heartRateCount : 0,
      averageSleepHours: weekData.isNotEmpty ? totalSleep / weekData.length : 0,
      daysWithData: weekData.length,
      weekStartDate: weekStartDate,
      weekEndDate: now,
    );
  }

  /// Get daily points for charts (last N days)
  Future<List<DailyHealthPoint>> getDailyPointsForChart(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final healthData = await getHealthDataRange(userId, startDate, now);

    return healthData.map((data) {
      return DailyHealthPoint(
        date: data.date,
        steps: data.steps,
        distanceKm: data.distanceKm,
        calories: data.caloriesBurned,
        heartRate: data.averageHeartRate,
        sleepHours: data.sleepHours,
      );
    }).toList();
  }

  /// Update weight for a specific date (manual entry)
  Future<void> updateWeight(
    String userId,
    DateTime date,
    double weightKg,
  ) async {
    try {
      // Write to HealthKit/Google Fit
      await _healthService.writeWeight(weightKg, date);

      // Get source details for manual entry
      final sourceDetails = await _healthService.getSourceDetails();

      // Update in Firestore with manual source
      final dateId =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final docId = '${userId}_$dateId';

      await _healthDataCollection(userId).doc(docId).set({
        'weight': weightKg,
        'source': HealthDataSource.manual.name,
        'sourceDetails': sourceDetails.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        debugPrint('Weight updated successfully with manual source');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating weight: $e');
      }
      rethrow;
    }
  }

  /// Delete health data for a specific date
  Future<void> deleteHealthData(String userId, DateTime date) async {
    try {
      final dateId =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final docId = '${userId}_$dateId';

      await _healthDataCollection(userId).doc(docId).delete();

      if (kDebugMode) {
        debugPrint('Health data deleted for $dateId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting health data: $e');
      }
      rethrow;
    }
  }
}
