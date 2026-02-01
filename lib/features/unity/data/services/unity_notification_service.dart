import '../models/models.dart';
import '../repositories/repositories.dart';

/// Service for Unity notifications
class UnityNotificationService {
  UnityNotificationService({
    required UnitySettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  final UnitySettingsRepository _settingsRepository;

  /// Check if user should receive a notification
  Future<bool> shouldNotify({
    required String userId,
    required UnityNotificationType type,
    String? circleId,
    String? challengeId,
  }) async {
    final settings = await _settingsRepository.getSettings(userId);

    // Check quiet hours
    if (settings.isInQuietHours) {
      return false;
    }

    // Check notification type settings
    switch (type) {
      case UnityNotificationType.challengeStart:
      case UnityNotificationType.challengeEnd:
      case UnityNotificationType.challengeReminder:
      case UnityNotificationType.challengeProgress:
        if (!settings.receiveChallengeNotifications) return false;
        if (challengeId != null && settings.isChallengeMuted(challengeId)) {
          return false;
        }
        break;

      case UnityNotificationType.cheerReceived:
        if (!settings.receiveCheerNotifications) return false;
        break;

      case UnityNotificationType.milestoneUnlocked:
      case UnityNotificationType.challengeComplete:
        if (!settings.receiveMilestoneNotifications) return false;
        break;

      case UnityNotificationType.circleActivity:
      case UnityNotificationType.circleInvite:
      case UnityNotificationType.circleMention:
        if (!settings.receiveCircleActivityNotifications) return false;
        if (circleId != null && settings.isCircleMuted(circleId)) {
          return false;
        }
        break;
    }

    return true;
  }

  /// Create a notification payload
  UnityNotification createNotification({
    required String userId,
    required UnityNotificationType type,
    required String title,
    required String body,
    String? circleId,
    String? challengeId,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) {
    return UnityNotification(
      id: '',
      userId: userId,
      type: type,
      title: title,
      body: body,
      circleId: circleId,
      challengeId: challengeId,
      actionUrl: actionUrl,
      data: data ?? {},
      createdAt: DateTime.now(),
      isRead: false,
    );
  }

  /// Create a cheer notification
  UnityNotification createCheerNotification({
    required String receiverId,
    required String senderName,
    required CheerType cheerType,
    String? challengeId,
    bool isAnonymous = false,
  }) {
    final displaySender = isAnonymous ? 'Someone' : senderName;

    return createNotification(
      userId: receiverId,
      type: UnityNotificationType.cheerReceived,
      title: cheerType.emoji,
      body: '$displaySender sent you a cheer: ${cheerType.message}',
      challengeId: challengeId,
      data: {
        'cheerType': cheerType.name,
        'isAnonymous': isAnonymous,
      },
    );
  }

  /// Create a milestone notification
  UnityNotification createMilestoneNotification({
    required String userId,
    required String milestoneName,
    required String challengeName,
    required String challengeId,
    int xpReward = 0,
  }) {
    return createNotification(
      userId: userId,
      type: UnityNotificationType.milestoneUnlocked,
      title: 'Milestone Unlocked! \u{1F3C6}',
      body: 'You unlocked "$milestoneName" in $challengeName!',
      challengeId: challengeId,
      actionUrl: '/challenge/$challengeId',
      data: {
        'milestoneName': milestoneName,
        'xpReward': xpReward,
      },
    );
  }

  /// Create a challenge complete notification
  UnityNotification createChallengeCompleteNotification({
    required String userId,
    required String challengeName,
    required String challengeId,
    required DifficultyTier tier,
    int xpReward = 0,
  }) {
    return createNotification(
      userId: userId,
      type: UnityNotificationType.challengeComplete,
      title: 'Challenge Complete! \u{1F389}',
      body:
          'You completed "$challengeName" at ${tier.displayName} level! +$xpReward XP',
      challengeId: challengeId,
      actionUrl: '/challenge/$challengeId',
      data: {
        'tier': tier.name,
        'xpReward': xpReward,
      },
    );
  }

  /// Create a circle invite notification
  UnityNotification createCircleInviteNotification({
    required String userId,
    required String circleId,
    required String circleName,
    required String inviterName,
  }) {
    return createNotification(
      userId: userId,
      type: UnityNotificationType.circleInvite,
      title: 'Circle Invitation',
      body: '$inviterName invited you to join "$circleName"',
      circleId: circleId,
      actionUrl: '/circle/$circleId/invite',
      data: {
        'inviterName': inviterName,
      },
    );
  }

  /// Create a challenge reminder notification
  UnityNotification createChallengeReminderNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required int daysRemaining,
    required double percentComplete,
  }) {
    String body;
    if (daysRemaining == 1) {
      body =
          'Last day of "$challengeName"! You\'re at ${percentComplete.toStringAsFixed(0)}%';
    } else if (daysRemaining <= 3) {
      body =
          '$daysRemaining days left in "$challengeName" - ${percentComplete.toStringAsFixed(0)}% complete';
    } else {
      body =
          'Keep going! "$challengeName" is ${percentComplete.toStringAsFixed(0)}% complete';
    }

    return createNotification(
      userId: userId,
      type: UnityNotificationType.challengeReminder,
      title: 'Challenge Reminder',
      body: body,
      challengeId: challengeId,
      actionUrl: '/challenge/$challengeId',
      data: {
        'daysRemaining': daysRemaining,
        'percentComplete': percentComplete,
      },
    );
  }

  /// Create encouragement notification for rest day
  UnityNotification createRestDayEncouragementNotification({
    required String userId,
    required String challengeId,
    required String challengeName,
    required RestDayReason reason,
  }) {
    return createNotification(
      userId: userId,
      type: UnityNotificationType.challengeProgress,
      title: 'Rest Day \u{1F33F}',
      body: '${reason.encouragement} Your streak in "$challengeName" is safe.',
      challengeId: challengeId,
      data: {
        'restDayReason': reason.name,
      },
    );
  }

  /// Get notification channel for a type
  String getChannelId(UnityNotificationType type) {
    switch (type) {
      case UnityNotificationType.challengeStart:
      case UnityNotificationType.challengeEnd:
      case UnityNotificationType.challengeReminder:
      case UnityNotificationType.challengeProgress:
        return 'unity_challenges';
      case UnityNotificationType.cheerReceived:
        return 'unity_cheers';
      case UnityNotificationType.milestoneUnlocked:
      case UnityNotificationType.challengeComplete:
        return 'unity_achievements';
      case UnityNotificationType.circleActivity:
      case UnityNotificationType.circleInvite:
      case UnityNotificationType.circleMention:
        return 'unity_circles';
    }
  }

  /// Get notification priority
  NotificationPriority getPriority(UnityNotificationType type) {
    switch (type) {
      case UnityNotificationType.challengeComplete:
      case UnityNotificationType.milestoneUnlocked:
        return NotificationPriority.high;
      case UnityNotificationType.cheerReceived:
      case UnityNotificationType.circleInvite:
        return NotificationPriority.normal;
      case UnityNotificationType.challengeReminder:
      case UnityNotificationType.circleActivity:
        return NotificationPriority.low;
      default:
        return NotificationPriority.normal;
    }
  }
}

/// Types of Unity notifications
enum UnityNotificationType {
  challengeStart,
  challengeEnd,
  challengeReminder,
  challengeProgress,
  challengeComplete,
  cheerReceived,
  milestoneUnlocked,
  circleActivity,
  circleInvite,
  circleMention,
}

extension UnityNotificationTypeExtension on UnityNotificationType {
  String get displayName {
    switch (this) {
      case UnityNotificationType.challengeStart:
        return 'Challenge Started';
      case UnityNotificationType.challengeEnd:
        return 'Challenge Ended';
      case UnityNotificationType.challengeReminder:
        return 'Challenge Reminder';
      case UnityNotificationType.challengeProgress:
        return 'Progress Update';
      case UnityNotificationType.challengeComplete:
        return 'Challenge Complete';
      case UnityNotificationType.cheerReceived:
        return 'Cheer Received';
      case UnityNotificationType.milestoneUnlocked:
        return 'Milestone Unlocked';
      case UnityNotificationType.circleActivity:
        return 'Circle Activity';
      case UnityNotificationType.circleInvite:
        return 'Circle Invitation';
      case UnityNotificationType.circleMention:
        return 'Mentioned in Circle';
    }
  }
}

/// Notification priority levels
enum NotificationPriority {
  low,
  normal,
  high,
}

/// Unity notification model
class UnityNotification {
  const UnityNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.circleId,
    this.challengeId,
    this.actionUrl,
    this.data = const {},
    required this.createdAt,
    required this.isRead,
    this.readAt,
  });

  final String id;
  final String userId;
  final UnityNotificationType type;
  final String title;
  final String body;
  final String? circleId;
  final String? challengeId;
  final String? actionUrl;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;
  final DateTime? readAt;
}
