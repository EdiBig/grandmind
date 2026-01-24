import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for managing health data deletion (GDPR compliance)
class HealthDataDeletionService {
  final FirebaseFirestore _firestore;

  HealthDataDeletionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get count of health data records in a date range
  Future<int> getHealthDataCountInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

      final snapshot = await _firestore
          .collection('health_data')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error counting health data: $e');
      }
      return 0;
    }
  }

  /// Delete health data in a date range
  Future<int> deleteHealthDataInRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final start = DateTime(startDate.year, startDate.month, startDate.day);
      final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);

      // Get all documents in range
      final snapshot = await _firestore
          .collection('health_data')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

      // Batch delete (Firestore allows up to 500 operations per batch)
      int deletedCount = 0;
      final batches = <WriteBatch>[];
      WriteBatch currentBatch = _firestore.batch();
      int operationCount = 0;

      for (final doc in snapshot.docs) {
        currentBatch.delete(doc.reference);
        operationCount++;
        deletedCount++;

        if (operationCount == 500) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
          operationCount = 0;
        }
      }

      // Add the last batch if it has operations
      if (operationCount > 0) {
        batches.add(currentBatch);
      }

      // Execute all batches
      for (final batch in batches) {
        await batch.commit();
      }

      if (kDebugMode) {
        debugPrint('Deleted $deletedCount health data records');
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting health data: $e');
      }
      rethrow;
    }
  }

  /// Delete all health data for a user
  Future<int> deleteAllHealthData(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('health_data')
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) {
        return 0;
      }

      int deletedCount = 0;
      final batches = <WriteBatch>[];
      WriteBatch currentBatch = _firestore.batch();
      int operationCount = 0;

      for (final doc in snapshot.docs) {
        currentBatch.delete(doc.reference);
        operationCount++;
        deletedCount++;

        if (operationCount == 500) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
          operationCount = 0;
        }
      }

      if (operationCount > 0) {
        batches.add(currentBatch);
      }

      for (final batch in batches) {
        await batch.commit();
      }

      if (kDebugMode) {
        debugPrint('Deleted all $deletedCount health data records for user');
      }

      return deletedCount;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting all health data: $e');
      }
      rethrow;
    }
  }

  /// Get date range of user's health data
  Future<DateRange?> getHealthDataDateRange(String userId) async {
    try {
      // Get earliest record
      final earliestSnapshot = await _firestore
          .collection('health_data')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: false)
          .limit(1)
          .get();

      if (earliestSnapshot.docs.isEmpty) {
        return null;
      }

      // Get latest record
      final latestSnapshot = await _firestore
          .collection('health_data')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      final earliestData = earliestSnapshot.docs.first.data();
      final latestData = latestSnapshot.docs.first.data();

      final earliestDate = (earliestData['date'] as Timestamp).toDate();
      final latestDate = (latestData['date'] as Timestamp).toDate();

      return DateRange(start: earliestDate, end: latestDate);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting health data date range: $e');
      }
      return null;
    }
  }
}

/// Simple date range class
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({required this.start, required this.end});

  int get dayCount => end.difference(start).inDays + 1;
}
