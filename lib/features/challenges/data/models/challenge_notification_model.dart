import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of challenge notifications
enum ChallengeNotificationType {
  /// New invitation received
  invitation,

  /// Challenge is starting soon
  challengeStarting,

  /// Challenge has started
  challengeStarted,

  /// Challenge is ending soon
  challengeEnding,

  /// Challenge has ended
  challengeEnded,

  /// User achieved a milestone
  milestoneAchieved,

  /// User received encouragement
  encouragementReceived,

  /// Rank changed (moved up or down)
  rankChanged,

  /// Daily reminder to log progress
  dailyReminder,

  /// Streak at risk (no activity for X days)
  streakAtRisk,

  /// New participant joined
  participantJoined,

  /// Someone completed the challenge goal
  goalCompleted,

  /// Weekly summary available
  weeklySummary,
}

/// Priority levels for notifications
enum NotificationPriority {
  low,
  normal,
  high,
}

/// Model for challenge notifications
class ChallengeNotification {
  const ChallengeNotification({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.priority,
    this.data,
    this.isRead = false,
    this.readAt,
    this.actionUrl,
    this.imageUrl,
  });

  final String id;
  final String userId;
  final String challengeId;
  final ChallengeNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final NotificationPriority priority;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? readAt;
  final String? actionUrl;
  final String? imageUrl;

  factory ChallengeNotification.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ChallengeNotification(
      id: id,
      userId: data['userId'] as String? ?? '',
      challengeId: data['challengeId'] as String? ?? '',
      type: ChallengeNotificationType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => ChallengeNotificationType.dailyReminder,
      ),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      createdAt: _parseTimestamp(data['createdAt']),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.name == (data['priority'] as String?),
        orElse: () => NotificationPriority.normal,
      ),
      data: data['data'] as Map<String, dynamic>?,
      isRead: data['isRead'] as bool? ?? false,
      readAt: data['readAt'] != null ? _parseTimestamp(data['readAt']) : null,
      actionUrl: data['actionUrl'] as String?,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'challengeId': challengeId,
      'type': type.name,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'priority': priority.name,
      if (data != null) 'data': data,
      'isRead': isRead,
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  /// Convert to push notification payload
  Map<String, dynamic> toPushPayload() {
    return {
      'notification': {
        'title': title,
        'body': body,
        if (imageUrl != null) 'image': imageUrl,
      },
      'data': {
        'type': 'challenge',
        'notificationType': type.name,
        'challengeId': challengeId,
        'notificationId': id,
        if (actionUrl != null) 'actionUrl': actionUrl,
        ...?data,
      },
    };
  }

  ChallengeNotification markAsRead() {
    return ChallengeNotification(
      id: id,
      userId: userId,
      challengeId: challengeId,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      priority: priority,
      data: data,
      isRead: true,
      readAt: DateTime.now(),
      actionUrl: actionUrl,
      imageUrl: imageUrl,
    );
  }
}

/// Notification preferences for challenges
class ChallengeNotificationPreferences {
  const ChallengeNotificationPreferences({
    this.invitations = true,
    this.challengeUpdates = true,
    this.milestones = true,
    this.encouragement = true,
    this.rankChanges = true,
    this.dailyReminders = false,
    this.weeklySummary = true,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  final bool invitations;
  final bool challengeUpdates;
  final bool milestones;
  final bool encouragement;
  final bool rankChanges;
  final bool dailyReminders;
  final bool weeklySummary;
  final int? quietHoursStart; // Hour in 24h format
  final int? quietHoursEnd;

  factory ChallengeNotificationPreferences.fromMap(Map<String, dynamic> data) {
    return ChallengeNotificationPreferences(
      invitations: data['invitations'] as bool? ?? true,
      challengeUpdates: data['challengeUpdates'] as bool? ?? true,
      milestones: data['milestones'] as bool? ?? true,
      encouragement: data['encouragement'] as bool? ?? true,
      rankChanges: data['rankChanges'] as bool? ?? true,
      dailyReminders: data['dailyReminders'] as bool? ?? false,
      weeklySummary: data['weeklySummary'] as bool? ?? true,
      quietHoursStart: data['quietHoursStart'] as int?,
      quietHoursEnd: data['quietHoursEnd'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'invitations': invitations,
      'challengeUpdates': challengeUpdates,
      'milestones': milestones,
      'encouragement': encouragement,
      'rankChanges': rankChanges,
      'dailyReminders': dailyReminders,
      'weeklySummary': weeklySummary,
      if (quietHoursStart != null) 'quietHoursStart': quietHoursStart,
      if (quietHoursEnd != null) 'quietHoursEnd': quietHoursEnd,
    };
  }

  /// Check if notification type is enabled
  bool isTypeEnabled(ChallengeNotificationType type) {
    switch (type) {
      case ChallengeNotificationType.invitation:
        return invitations;
      case ChallengeNotificationType.challengeStarting:
      case ChallengeNotificationType.challengeStarted:
      case ChallengeNotificationType.challengeEnding:
      case ChallengeNotificationType.challengeEnded:
      case ChallengeNotificationType.participantJoined:
        return challengeUpdates;
      case ChallengeNotificationType.milestoneAchieved:
      case ChallengeNotificationType.goalCompleted:
        return milestones;
      case ChallengeNotificationType.encouragementReceived:
        return encouragement;
      case ChallengeNotificationType.rankChanged:
        return rankChanges;
      case ChallengeNotificationType.dailyReminder:
      case ChallengeNotificationType.streakAtRisk:
        return dailyReminders;
      case ChallengeNotificationType.weeklySummary:
        return weeklySummary;
    }
  }

  /// Check if current time is within quiet hours
  bool isQuietTime() {
    if (quietHoursStart == null || quietHoursEnd == null) return false;

    final now = DateTime.now();
    final currentHour = now.hour;

    if (quietHoursStart! < quietHoursEnd!) {
      // Simple case: quiet hours don't span midnight
      return currentHour >= quietHoursStart! && currentHour < quietHoursEnd!;
    } else {
      // Quiet hours span midnight (e.g., 22:00 - 07:00)
      return currentHour >= quietHoursStart! || currentHour < quietHoursEnd!;
    }
  }

  ChallengeNotificationPreferences copyWith({
    bool? invitations,
    bool? challengeUpdates,
    bool? milestones,
    bool? encouragement,
    bool? rankChanges,
    bool? dailyReminders,
    bool? weeklySummary,
    int? quietHoursStart,
    int? quietHoursEnd,
  }) {
    return ChallengeNotificationPreferences(
      invitations: invitations ?? this.invitations,
      challengeUpdates: challengeUpdates ?? this.challengeUpdates,
      milestones: milestones ?? this.milestones,
      encouragement: encouragement ?? this.encouragement,
      rankChanges: rankChanges ?? this.rankChanges,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }
}

DateTime _parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.now();
}
