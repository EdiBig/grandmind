import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of content that can be reported
enum ReportableContentType {
  challenge,
  activity,
  participant,
  message,
}

/// Reasons for reporting
enum ReportReason {
  spam,
  harassment,
  inappropriateContent,
  falseInformation,
  hateSpeech,
  violence,
  privacyViolation,
  cheating,
  other,
}

/// Status of a report
enum ReportStatus {
  pending,
  underReview,
  resolved,
  dismissed,
}

/// Action taken on a report
enum ReportAction {
  none,
  warning,
  contentRemoved,
  userSuspended,
  userBanned,
}

/// Model for content reports
class ChallengeReport {
  const ChallengeReport({
    required this.id,
    required this.reporterId,
    required this.contentType,
    required this.contentId,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.challengeId,
    this.reportedUserId,
    this.description,
    this.reviewedAt,
    this.reviewedBy,
    this.actionTaken,
    this.actionNotes,
  });

  final String id;
  final String reporterId;
  final ReportableContentType contentType;
  final String contentId;
  final ReportReason reason;
  final ReportStatus status;
  final DateTime createdAt;
  final String? challengeId;
  final String? reportedUserId;
  final String? description;
  final DateTime? reviewedAt;
  final String? reviewedBy;
  final ReportAction? actionTaken;
  final String? actionNotes;

  factory ChallengeReport.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ChallengeReport(
      id: id,
      reporterId: data['reporterId'] as String? ?? '',
      contentType: ReportableContentType.values.firstWhere(
        (e) => e.name == (data['contentType'] as String?),
        orElse: () => ReportableContentType.activity,
      ),
      contentId: data['contentId'] as String? ?? '',
      reason: ReportReason.values.firstWhere(
        (e) => e.name == (data['reason'] as String?),
        orElse: () => ReportReason.other,
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String?),
        orElse: () => ReportStatus.pending,
      ),
      createdAt: _parseTimestamp(data['createdAt']),
      challengeId: data['challengeId'] as String?,
      reportedUserId: data['reportedUserId'] as String?,
      description: data['description'] as String?,
      reviewedAt: data['reviewedAt'] != null
          ? _parseTimestamp(data['reviewedAt'])
          : null,
      reviewedBy: data['reviewedBy'] as String?,
      actionTaken: data['actionTaken'] != null
          ? ReportAction.values.firstWhere(
              (e) => e.name == (data['actionTaken'] as String?),
              orElse: () => ReportAction.none,
            )
          : null,
      actionNotes: data['actionNotes'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reporterId': reporterId,
      'contentType': contentType.name,
      'contentId': contentId,
      'reason': reason.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (challengeId != null) 'challengeId': challengeId,
      if (reportedUserId != null) 'reportedUserId': reportedUserId,
      if (description != null) 'description': description,
      if (reviewedAt != null) 'reviewedAt': Timestamp.fromDate(reviewedAt!),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (actionTaken != null) 'actionTaken': actionTaken!.name,
      if (actionNotes != null) 'actionNotes': actionNotes,
    };
  }

  /// Get human-readable reason
  String get reasonDisplay {
    switch (reason) {
      case ReportReason.spam:
        return 'Spam or misleading';
      case ReportReason.harassment:
        return 'Harassment or bullying';
      case ReportReason.inappropriateContent:
        return 'Inappropriate content';
      case ReportReason.falseInformation:
        return 'False information';
      case ReportReason.hateSpeech:
        return 'Hate speech';
      case ReportReason.violence:
        return 'Violence or threats';
      case ReportReason.privacyViolation:
        return 'Privacy violation';
      case ReportReason.cheating:
        return 'Cheating or unfair play';
      case ReportReason.other:
        return 'Other';
    }
  }
}

/// Model for blocked users
class BlockedUser {
  const BlockedUser({
    required this.id,
    required this.blockerId,
    required this.blockedUserId,
    required this.createdAt,
    this.reason,
  });

  final String id;
  final String blockerId;
  final String blockedUserId;
  final DateTime createdAt;
  final String? reason;

  factory BlockedUser.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return BlockedUser(
      id: id,
      blockerId: data['blockerId'] as String? ?? '',
      blockedUserId: data['blockedUserId'] as String? ?? '',
      createdAt: _parseTimestamp(data['createdAt']),
      reason: data['reason'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'blockerId': blockerId,
      'blockedUserId': blockedUserId,
      'createdAt': Timestamp.fromDate(createdAt),
      if (reason != null) 'reason': reason,
    };
  }
}

/// Challenge moderation settings (for challenge creators)
class ChallengeModerationSettings {
  const ChallengeModerationSettings({
    this.autoModerateActivityFeed = true,
    this.requireApprovalToJoin = false,
    this.allowParticipantInvites = true,
    this.hideOffensiveContent = true,
    this.muteNewParticipants = false,
    this.muteNewParticipantsDuration = const Duration(hours: 24),
    this.bannedWords = const [],
  });

  final bool autoModerateActivityFeed;
  final bool requireApprovalToJoin;
  final bool allowParticipantInvites;
  final bool hideOffensiveContent;
  final bool muteNewParticipants;
  final Duration muteNewParticipantsDuration;
  final List<String> bannedWords;

  factory ChallengeModerationSettings.fromMap(Map<String, dynamic> data) {
    return ChallengeModerationSettings(
      autoModerateActivityFeed:
          data['autoModerateActivityFeed'] as bool? ?? true,
      requireApprovalToJoin: data['requireApprovalToJoin'] as bool? ?? false,
      allowParticipantInvites:
          data['allowParticipantInvites'] as bool? ?? true,
      hideOffensiveContent: data['hideOffensiveContent'] as bool? ?? true,
      muteNewParticipants: data['muteNewParticipants'] as bool? ?? false,
      muteNewParticipantsDuration: Duration(
        hours: (data['muteNewParticipantsDurationHours'] as num?)?.toInt() ?? 24,
      ),
      bannedWords: (data['bannedWords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'autoModerateActivityFeed': autoModerateActivityFeed,
      'requireApprovalToJoin': requireApprovalToJoin,
      'allowParticipantInvites': allowParticipantInvites,
      'hideOffensiveContent': hideOffensiveContent,
      'muteNewParticipants': muteNewParticipants,
      'muteNewParticipantsDurationHours': muteNewParticipantsDuration.inHours,
      'bannedWords': bannedWords,
    };
  }

  ChallengeModerationSettings copyWith({
    bool? autoModerateActivityFeed,
    bool? requireApprovalToJoin,
    bool? allowParticipantInvites,
    bool? hideOffensiveContent,
    bool? muteNewParticipants,
    Duration? muteNewParticipantsDuration,
    List<String>? bannedWords,
  }) {
    return ChallengeModerationSettings(
      autoModerateActivityFeed:
          autoModerateActivityFeed ?? this.autoModerateActivityFeed,
      requireApprovalToJoin:
          requireApprovalToJoin ?? this.requireApprovalToJoin,
      allowParticipantInvites:
          allowParticipantInvites ?? this.allowParticipantInvites,
      hideOffensiveContent: hideOffensiveContent ?? this.hideOffensiveContent,
      muteNewParticipants: muteNewParticipants ?? this.muteNewParticipants,
      muteNewParticipantsDuration:
          muteNewParticipantsDuration ?? this.muteNewParticipantsDuration,
      bannedWords: bannedWords ?? this.bannedWords,
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
