import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge_notification_model.dart';
import '../models/challenge_consent_model.dart';
import '../repositories/challenge_gdpr_repository.dart';

/// Service for managing challenge notifications
class ChallengeNotificationService {
  final FirebaseFirestore _firestore;
  final ChallengeGDPRRepository _gdprRepository;

  ChallengeNotificationService({
    FirebaseFirestore? firestore,
    required ChallengeGDPRRepository gdprRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _gdprRepository = gdprRepository;

  static const String _notificationsCollection = 'challengeNotifications';
  static const String _preferencesCollection = 'challengeNotificationPrefs';

  // ============================================================
  // NOTIFICATION CREATION
  // ============================================================

  /// Create and send a notification
  Future<void> _sendNotification({
    required String userId,
    required String challengeId,
    required ChallengeNotificationType type,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    String? actionUrl,
    String? imageUrl,
  }) async {
    // Check if user has consent for notifications
    final consent = await _gdprRepository.getUserConsent(userId);
    if (consent == null ||
        !consent.hasConsent(ConsentType.challengeNotifications)) {
      return; // User hasn't consented to notifications
    }

    // Check user's notification preferences
    final prefs = await getNotificationPreferences(userId);
    if (!prefs.isTypeEnabled(type)) {
      return; // User disabled this notification type
    }

    // Check quiet hours
    if (prefs.isQuietTime() && priority != NotificationPriority.high) {
      // Store notification but don't push during quiet hours
      // Could be sent later or shown when app is opened
    }

    final notification = ChallengeNotification(
      id: '',
      userId: userId,
      challengeId: challengeId,
      type: type,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      priority: priority,
      data: data,
      actionUrl: actionUrl,
      imageUrl: imageUrl,
    );

    // Store notification
    final docRef = await _firestore
        .collection(_notificationsCollection)
        .add(notification.toFirestore());

    // Trigger push notification via Cloud Function
    // The actual push is handled by Firebase Cloud Messaging
    await _triggerPushNotification(
      userId: userId,
      notificationId: docRef.id,
      payload: notification.toPushPayload(),
    );
  }

  /// Trigger push notification (writes to a queue for Cloud Functions)
  Future<void> _triggerPushNotification({
    required String userId,
    required String notificationId,
    required Map<String, dynamic> payload,
  }) async {
    // Write to push queue - Cloud Function will pick this up
    await _firestore.collection('pushNotificationQueue').add({
      'userId': userId,
      'notificationId': notificationId,
      'payload': payload,
      'createdAt': FieldValue.serverTimestamp(),
      'processed': false,
    });
  }

  // ============================================================
  // SPECIFIC NOTIFICATION TYPES
  // ============================================================

  /// Send invitation notification
  Future<void> sendInvitationNotification({
    required String inviteeId,
    required String challengeId,
    required String challengeName,
    required String inviterName,
    required String invitationId,
  }) async {
    await _sendNotification(
      userId: inviteeId,
      challengeId: challengeId,
      type: ChallengeNotificationType.invitation,
      title: 'Challenge Invitation',
      body: '$inviterName invited you to join "$challengeName"',
      priority: NotificationPriority.high,
      data: {
        'invitationId': invitationId,
        'inviterName': inviterName,
      },
      actionUrl: '/unity/$challengeId',
    );
  }

  /// Send notification when invitation is accepted
  Future<void> sendInvitationAcceptedNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required String acceptedByName,
  }) async {
    await _sendNotification(
      userId: userId,
      challengeId: challengeId,
      type: ChallengeNotificationType.participantJoined,
      title: 'Invitation Accepted',
      body: '$acceptedByName joined "$challengeName"',
      data: {
        'acceptedByName': acceptedByName,
      },
      actionUrl: '/unity/$challengeId',
    );
  }

  /// Send milestone achievement notification
  Future<void> sendMilestoneNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required int percentage,
    required bool isGoalComplete,
  }) async {
    final title = isGoalComplete ? 'Goal Completed!' : 'Milestone Reached!';
    final body = isGoalComplete
        ? 'Congratulations! You completed your goal in "$challengeName"'
        : 'You reached $percentage% of your goal in "$challengeName"';

    await _sendNotification(
      userId: userId,
      challengeId: challengeId,
      type: isGoalComplete
          ? ChallengeNotificationType.goalCompleted
          : ChallengeNotificationType.milestoneAchieved,
      title: title,
      body: body,
      priority: NotificationPriority.high,
      data: {
        'percentage': percentage,
        'isGoalComplete': isGoalComplete,
      },
      actionUrl: '/unity/$challengeId',
    );
  }

  /// Send encouragement notification
  Future<void> sendEncouragementNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required String fromUserName,
  }) async {
    await _sendNotification(
      userId: userId,
      challengeId: challengeId,
      type: ChallengeNotificationType.encouragementReceived,
      title: 'You received encouragement!',
      body: '$fromUserName cheered you on in "$challengeName"',
      data: {
        'fromUserName': fromUserName,
      },
      actionUrl: '/unity/$challengeId/feed',
    );
  }

  /// Send rank change notification
  Future<void> sendRankChangeNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required int oldRank,
    required int newRank,
  }) async {
    final movedUp = newRank < oldRank;
    final title = movedUp ? 'You moved up!' : 'Rank Update';
    final body = movedUp
        ? 'You\'re now #$newRank in "$challengeName"'
        : 'You\'re now #$newRank in "$challengeName". Keep going!';

    await _sendNotification(
      userId: userId,
      challengeId: challengeId,
      type: ChallengeNotificationType.rankChanged,
      title: title,
      body: body,
      priority: movedUp ? NotificationPriority.normal : NotificationPriority.low,
      data: {
        'oldRank': oldRank,
        'newRank': newRank,
        'movedUp': movedUp,
      },
      actionUrl: '/unity/$challengeId/rankings',
    );
  }

  /// Send challenge starting notification
  Future<void> sendChallengeStartingNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required int daysUntilStart,
  }) async {
    await _sendNotification(
      userId: userId,
      challengeId: challengeId,
      type: ChallengeNotificationType.challengeStarting,
      title: 'Challenge Starting Soon',
      body: '"$challengeName" starts in $daysUntilStart days. Get ready!',
      data: {
        'daysUntilStart': daysUntilStart,
      },
      actionUrl: '/unity/$challengeId',
    );
  }

  /// Send challenge started notification
  Future<void> sendChallengeStartedNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
  }) async {
    await _sendNotification(
      userId: userId,
      challengeId: challengeId,
      type: ChallengeNotificationType.challengeStarted,
      title: 'Challenge Started!',
      body: '"$challengeName" has begun. Time to start logging progress!',
      priority: NotificationPriority.high,
      actionUrl: '/unity/$challengeId',
    );
  }

  /// Send challenge ending soon notification
  Future<void> sendChallengeEndingNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required int daysRemaining,
  }) async {
    await _sendNotification(
      userId: userId,
      challengeId: challengeId,
      type: ChallengeNotificationType.challengeEnding,
      title: 'Challenge Ending Soon',
      body: 'Only $daysRemaining days left in "$challengeName". Push to the finish!',
      data: {
        'daysRemaining': daysRemaining,
      },
      actionUrl: '/unity/$challengeId',
    );
  }

  /// Send daily reminder notification
  Future<void> sendDailyReminderNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required int currentProgress,
    required int goalTarget,
  }) async {
    final percentage = ((currentProgress / goalTarget) * 100).toInt();

    await _sendNotification(
      userId: userId,
      challengeId: challengeId,
      type: ChallengeNotificationType.dailyReminder,
      title: 'Daily Challenge Reminder',
      body: 'You\'re at $percentage% in "$challengeName". Log your progress!',
      priority: NotificationPriority.low,
      data: {
        'currentProgress': currentProgress,
        'goalTarget': goalTarget,
        'percentage': percentage,
      },
      actionUrl: '/unity/$challengeId',
    );
  }

  /// Send streak at risk notification
  Future<void> sendStreakAtRiskNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required int daysInactive,
  }) async {
    await _sendNotification(
      userId: userId,
      challengeId: challengeId,
      type: ChallengeNotificationType.streakAtRisk,
      title: 'Don\'t break your streak!',
      body: 'You haven\'t logged progress in "$challengeName" for $daysInactive days',
      priority: NotificationPriority.normal,
      data: {
        'daysInactive': daysInactive,
      },
      actionUrl: '/unity/$challengeId',
    );
  }

  // ============================================================
  // NOTIFICATION MANAGEMENT
  // ============================================================

  /// Get notifications for a user
  Stream<List<ChallengeNotification>> getNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChallengeNotification.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  /// Get unread notification count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection(_notificationsCollection)
        .doc(notificationId)
        .update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    final unread = await _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore
        .collection(_notificationsCollection)
        .doc(notificationId)
        .delete();
  }

  /// Delete all notifications for a user
  Future<void> deleteAllNotifications(String userId) async {
    final notifications = await _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in notifications.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ============================================================
  // NOTIFICATION PREFERENCES
  // ============================================================

  /// Get notification preferences for a user
  Future<ChallengeNotificationPreferences> getNotificationPreferences(
      String userId) async {
    final doc =
        await _firestore.collection(_preferencesCollection).doc(userId).get();

    if (!doc.exists || doc.data() == null) {
      return const ChallengeNotificationPreferences();
    }

    return ChallengeNotificationPreferences.fromMap(doc.data()!);
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences({
    required String userId,
    required ChallengeNotificationPreferences preferences,
  }) async {
    await _firestore
        .collection(_preferencesCollection)
        .doc(userId)
        .set(preferences.toMap());
  }
}

/// Provider for notification service
final challengeNotificationServiceProvider =
    Provider<ChallengeNotificationService>((ref) {
  final gdprRepository = ref.watch(challengeGDPRRepositoryProvider);
  return ChallengeNotificationService(gdprRepository: gdprRepository);
});

/// Provider for user's challenge notifications
final challengeNotificationsProvider =
    StreamProvider.family<List<ChallengeNotification>, String>(
  (ref, userId) {
    final service = ref.watch(challengeNotificationServiceProvider);
    return service.getNotifications(userId);
  },
);

/// Provider for unread notification count
final challengeUnreadCountProvider = StreamProvider.family<int, String>(
  (ref, userId) {
    final service = ref.watch(challengeNotificationServiceProvider);
    return service.getUnreadCount(userId);
  },
);

/// Provider for notification preferences
final challengeNotificationPrefsProvider =
    FutureProvider.family<ChallengeNotificationPreferences, String>(
  (ref, userId) async {
    final service = ref.watch(challengeNotificationServiceProvider);
    return service.getNotificationPreferences(userId);
  },
);
