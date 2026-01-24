import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../domain/models/energy_log.dart';

final moodEnergyRepositoryProvider = Provider<MoodEnergyRepository>((ref) {
  final analytics = ref.watch(analyticsProvider);
  return MoodEnergyRepository(analytics: analytics);
});

class MoodEnergyRepository {
  MoodEnergyRepository({AnalyticsService? analytics})
      : _analytics = analytics ?? AnalyticsService();

  static const String _collection = 'mood_energy_logs';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analytics;

  /// Create a new mood/energy log
  Future<String> createLog(EnergyLog log) async {
    final data = log.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    // Remove 'id' field as Firestore will generate it
    data.remove('id');
    final docRef = await _firestore.collection(_collection).add(data);

    // Track analytics
    if (log.energyLevel != null || log.moodRating != null) {
      await _analytics.logMoodLogged(
        energyLevel: log.energyLevel ?? 3,
        moodRating: log.moodRating,
      );
    }

    return docRef.id;
  }

  /// Update an existing mood/energy log
  Future<void> updateLog(String logId, EnergyLog log) async {
    final data = log.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    data.remove('id'); // Don't update the ID field
    await _firestore.collection(_collection).doc(logId).update(data);
  }

  /// Delete a mood/energy log
  Future<void> deleteLog(String logId) async {
    await _firestore.collection(_collection).doc(logId).delete();
  }

  /// Get logs for a specific date range
  Future<List<EnergyLog>> getLogsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end =
        DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('loggedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('loggedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => EnergyLog.fromJson({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();
  }

  /// Get today's mood/energy log (if exists)
  Future<EnergyLog?> getTodayLog(String userId) async {
    final now = DateTime.now();
    final logs = await getLogsInRange(userId, now, now);
    return logs.isEmpty ? null : logs.first;
  }

  /// Stream of today's log for real-time updates
  Stream<EnergyLog?> watchTodayLog(String userId) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('loggedAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('loggedAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return EnergyLog.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    });
  }

  /// Get weekly average mood/energy
  Future<Map<String, double>> getWeeklyAverages(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final logs = await getLogsInRange(userId, weekAgo, now);

    if (logs.isEmpty) {
      return {'mood': 0, 'energy': 0};
    }

    final moodValues =
        logs.where((l) => l.moodRating != null).map((l) => l.moodRating!);
    final energyValues =
        logs.where((l) => l.energyLevel != null).map((l) => l.energyLevel!);

    final avgMood = moodValues.isEmpty
        ? 0.0
        : moodValues.reduce((a, b) => a + b) / moodValues.length;
    final avgEnergy = energyValues.isEmpty
        ? 0.0
        : energyValues.reduce((a, b) => a + b) / energyValues.length;

    return {'mood': avgMood, 'energy': avgEnergy};
  }
}
