import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/health_data.dart';
import '../../domain/models/weekly_health_stats.dart';
import '../services/health_service.dart';

/// Repository for managing health data with Firestore persistence
class HealthRepository {
  final FirebaseFirestore _firestore;
  final HealthService _healthService;

  HealthRepository({
    FirebaseFirestore? firestore,
    required HealthService healthService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _healthService = healthService;

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
          print('Health permissions not granted');
        }
        return null;
      }

      // Get today's health summary from HealthKit/Google Fit
      final summary = await _healthService.getTodaySummary();

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
        syncedAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _healthDataCollection(userId)
          .doc(docId)
          .set(healthData.toJson(), SetOptions(merge: true));

      if (kDebugMode) {
        print('Health data synced successfully for $dateId');
      }

      return healthData;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing health data: $e');
      }
      return null;
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
        print('Error fetching health data: $e');
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
        print('Error fetching health data range: $e');
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

  /// Update weight for a specific date
  Future<void> updateWeight(
    String userId,
    DateTime date,
    double weightKg,
  ) async {
    try {
      // Write to HealthKit/Google Fit
      await _healthService.writeWeight(weightKg, date);

      // Update in Firestore
      final dateId =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final docId = '${userId}_$dateId';

      await _healthDataCollection(userId).doc(docId).set({
        'weight': weightKg,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (kDebugMode) {
        print('Weight updated successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating weight: $e');
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
        print('Health data deleted for $dateId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting health data: $e');
      }
      rethrow;
    }
  }
}
