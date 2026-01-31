import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../shared/services/analytics_service.dart';
import '../../domain/models/sleep_log.dart';

final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  final analytics = ref.watch(analyticsProvider);
  return SleepRepository(analytics: analytics);
});

class SleepRepository {
  SleepRepository({AnalyticsService? analytics})
      : _analytics = analytics ?? AnalyticsService();

  static const String _collection = 'sleep_logs';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analytics;

  /// Create a new sleep log
  Future<String> createLog(SleepLog log) async {
    final data = log.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    data.remove('id');

    final docRef = await _firestore.collection(_collection).add(data);

    // Track analytics
    await _analytics.logEvent(
      name: 'sleep_logged',
      parameters: {
        'hours': log.hoursSlept,
        'quality': log.quality ?? 0,
        'source': log.source,
        'has_tags': log.tags.isNotEmpty,
      },
    );

    return docRef.id;
  }

  /// Update an existing sleep log
  Future<void> updateLog(String logId, SleepLog log) async {
    final data = log.toJson();
    data['updatedAt'] = FieldValue.serverTimestamp();
    data.remove('id');
    await _firestore.collection(_collection).doc(logId).update(data);
  }

  /// Delete a sleep log
  Future<void> deleteLog(String logId) async {
    await _firestore.collection(_collection).doc(logId).delete();
  }

  /// Get sleep log for a specific date
  Future<SleepLog?> getLogForDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('logDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('logDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('logDate', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return SleepLog.fromJson({
      ...snapshot.docs.first.data(),
      'id': snapshot.docs.first.id,
    });
  }

  /// Get today's sleep log
  Future<SleepLog?> getTodayLog(String userId) async {
    return getLogForDate(userId, DateTime.now());
  }

  /// Stream today's sleep log for real-time updates
  Stream<SleepLog?> watchTodayLog(String userId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('logDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('logDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('logDate', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return SleepLog.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    });
  }

  /// Get logs for a date range
  Future<List<SleepLog>> getLogsInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('logDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('logDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('logDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SleepLog.fromJson({
              ...doc.data(),
              'id': doc.id,
            }))
        .toList();
  }

  /// Get weekly sleep statistics
  Future<Map<String, dynamic>> getWeeklyStats(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final logs = await getLogsInRange(userId, weekAgo, now);

    if (logs.isEmpty) {
      return {
        'averageHours': 0.0,
        'averageQuality': 0.0,
        'totalLogs': 0,
        'bestNight': null,
        'worstNight': null,
      };
    }

    final totalHours = logs.fold<double>(0, (acc, log) => acc + log.hoursSlept);
    final qualityLogs = logs.where((l) => l.quality != null).toList();
    final totalQuality = qualityLogs.fold<int>(0, (acc, log) => acc + log.quality!);

    final sortedByHours = List<SleepLog>.from(logs)
      ..sort((a, b) => b.hoursSlept.compareTo(a.hoursSlept));

    return {
      'averageHours': totalHours / logs.length,
      'averageQuality': qualityLogs.isEmpty ? 0.0 : totalQuality / qualityLogs.length,
      'totalLogs': logs.length,
      'bestNight': sortedByHours.first,
      'worstNight': sortedByHours.last,
    };
  }

  /// Create or update sleep log for a date (upsert)
  Future<String> upsertLog(SleepLog log) async {
    final existing = await getLogForDate(log.userId, log.logDate);

    if (existing != null) {
      await updateLog(existing.id, log.copyWith(id: existing.id));
      return existing.id;
    } else {
      return createLog(log);
    }
  }
}
