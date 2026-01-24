import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/notification_preference.dart';

/// Repository for managing notification preferences and history
class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Collection reference for notification preferences
  CollectionReference<Map<String, dynamic>> _preferencesCollection(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notification_preferences');
  }

  /// Collection reference for notification history
  CollectionReference<Map<String, dynamic>> _historyCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notification_history');
  }

  // ==================== PREFERENCES ====================

  /// Create a new notification preference
  Future<NotificationPreference> createPreference(
    String userId,
    NotificationPreference preference,
  ) async {
    try {
      final docRef = _preferencesCollection(userId).doc();
      final newPreference = preference.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(newPreference.toJson());

      if (kDebugMode) {
        debugPrint('Notification preference created: ${newPreference.id}');
      }

      return newPreference;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error creating notification preference: $e');
      }
      rethrow;
    }
  }

  /// Get a single notification preference by ID
  Future<NotificationPreference?> getPreference(
    String userId,
    String preferenceId,
  ) async {
    try {
      final doc =
          await _preferencesCollection(userId).doc(preferenceId).get();

      if (!doc.exists) return null;

      return NotificationPreference.fromJson(doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching notification preference: $e');
      }
      return null;
    }
  }

  /// Get all notification preferences for a user
  Future<List<NotificationPreference>> getAllPreferences(String userId) async {
    try {
      final snapshot = await _preferencesCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationPreference.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching notification preferences: $e');
      }
      return [];
    }
  }

  /// Get preferences by type
  Future<List<NotificationPreference>> getPreferencesByType(
    String userId,
    ReminderType type,
  ) async {
    try {
      final snapshot = await _preferencesCollection(userId)
          .where('type', isEqualTo: type.name)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationPreference.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching preferences by type: $e');
      }
      return [];
    }
  }

  /// Get enabled preferences
  Future<List<NotificationPreference>> getEnabledPreferences(
      String userId) async {
    try {
      final snapshot = await _preferencesCollection(userId)
          .where('enabled', isEqualTo: true)
          .orderBy('hour')
          .orderBy('minute')
          .get();

      return snapshot.docs
          .map((doc) => NotificationPreference.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching enabled preferences: $e');
      }
      return [];
    }
  }

  /// Update a notification preference
  Future<void> updatePreference(
    String userId,
    NotificationPreference preference,
  ) async {
    try {
      final updatedPreference = preference.copyWith(
        updatedAt: DateTime.now(),
      );

      await _preferencesCollection(userId)
          .doc(preference.id)
          .update(updatedPreference.toJson());

      if (kDebugMode) {
        debugPrint('Notification preference updated: ${preference.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating notification preference: $e');
      }
      rethrow;
    }
  }

  /// Toggle preference enabled status
  Future<void> togglePreference(
    String userId,
    String preferenceId,
    bool enabled,
  ) async {
    try {
      await _preferencesCollection(userId).doc(preferenceId).update({
        'enabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        debugPrint('Notification preference toggled: $preferenceId to $enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error toggling notification preference: $e');
      }
      rethrow;
    }
  }

  /// Delete a notification preference
  Future<void> deletePreference(String userId, String preferenceId) async {
    try {
      await _preferencesCollection(userId).doc(preferenceId).delete();

      if (kDebugMode) {
        debugPrint('Notification preference deleted: $preferenceId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting notification preference: $e');
      }
      rethrow;
    }
  }

  /// Stream of notification preferences
  Stream<List<NotificationPreference>> watchPreferences(String userId) {
    return _preferencesCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationPreference.fromJson(doc.data()))
            .toList());
  }

  // ==================== HISTORY ====================

  /// Log a sent notification
  Future<void> logNotification(
    String userId,
    NotificationHistory history,
  ) async {
    try {
      final docRef = _historyCollection(userId).doc();
      final newHistory = history.copyWith(
        id: docRef.id,
      );

      await docRef.set(newHistory.toJson());

      if (kDebugMode) {
        debugPrint('Notification logged: ${newHistory.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error logging notification: $e');
      }
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String userId, String historyId) async {
    try {
      await _historyCollection(userId).doc(historyId).update({
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking notification as read: $e');
      }
    }
  }

  /// Mark notification as actioned
  Future<void> markAsActioned(
    String userId,
    String historyId,
    String action,
  ) async {
    try {
      await _historyCollection(userId).doc(historyId).update({
        'actionedAt': FieldValue.serverTimestamp(),
        'action': action,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error marking notification as actioned: $e');
      }
    }
  }

  /// Get notification history
  Future<List<NotificationHistory>> getHistory(
    String userId, {
    int limit = 50,
  }) async {
    try {
      final snapshot = await _historyCollection(userId)
          .orderBy('sentAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => NotificationHistory.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching notification history: $e');
      }
      return [];
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount(String userId) async {
    try {
      final snapshot = await _historyCollection(userId)
          .where('readAt', isNull: true)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching unread count: $e');
      }
      return 0;
    }
  }

  /// Stream of notification history
  Stream<List<NotificationHistory>> watchHistory(
    String userId, {
    int limit = 50,
  }) {
    return _historyCollection(userId)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationHistory.fromJson(doc.data()))
            .toList());
  }

  /// Clear old notification history (older than specified days)
  Future<void> clearOldHistory(String userId, {int daysToKeep = 30}) async {
    try {
      final cutoffDate =
          DateTime.now().subtract(Duration(days: daysToKeep));

      final snapshot = await _historyCollection(userId)
          .where('sentAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();

      if (kDebugMode) {
        debugPrint('Cleared ${snapshot.docs.length} old notifications');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing old history: $e');
      }
    }
  }
}
