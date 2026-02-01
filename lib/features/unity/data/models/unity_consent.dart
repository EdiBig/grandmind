import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Represents a user's consent for Unity features
class UnityConsent {
  const UnityConsent({
    required this.id,
    required this.userId,
    required this.type,
    required this.granted,
    required this.grantedAt,
    this.revokedAt,
    this.challengeId,
    this.version = 1,
    this.ipAddress,
    this.userAgent,
  });

  final String id;
  final String userId;
  final ConsentType type;
  final bool granted;
  final DateTime grantedAt;
  final DateTime? revokedAt;

  /// Optional: consent for a specific challenge
  final String? challengeId;

  /// Version of the consent text (for tracking updates)
  final int version;

  /// For audit trail
  final String? ipAddress;
  final String? userAgent;

  /// Whether consent is currently active
  bool get isActive => granted && revokedAt == null;

  /// Whether this is a required consent
  bool get isRequired => type.isRequired;

  factory UnityConsent.fromFirestore(Map<String, dynamic> data, String id) {
    return UnityConsent(
      id: id,
      userId: data['userId'] as String? ?? '',
      type: ConsentType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => ConsentType.dataSharing,
      ),
      granted: data['granted'] as bool? ?? false,
      grantedAt:
          (data['grantedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      revokedAt: (data['revokedAt'] as Timestamp?)?.toDate(),
      challengeId: data['challengeId'] as String?,
      version: data['version'] as int? ?? 1,
      ipAddress: data['ipAddress'] as String?,
      userAgent: data['userAgent'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'granted': granted,
      'grantedAt': Timestamp.fromDate(grantedAt),
      if (revokedAt != null) 'revokedAt': Timestamp.fromDate(revokedAt!),
      if (challengeId != null) 'challengeId': challengeId,
      'version': version,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (userAgent != null) 'userAgent': userAgent,
    };
  }

  UnityConsent copyWith({
    String? id,
    String? userId,
    ConsentType? type,
    bool? granted,
    DateTime? grantedAt,
    DateTime? revokedAt,
    String? challengeId,
    int? version,
    String? ipAddress,
    String? userAgent,
  }) {
    return UnityConsent(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      granted: granted ?? this.granted,
      grantedAt: grantedAt ?? this.grantedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      challengeId: challengeId ?? this.challengeId,
      version: version ?? this.version,
      ipAddress: ipAddress ?? this.ipAddress,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  /// Revoke this consent
  UnityConsent revoke() {
    return copyWith(revokedAt: DateTime.now());
  }

  /// Create a new consent grant
  factory UnityConsent.grant({
    required String userId,
    required ConsentType type,
    String? challengeId,
    int version = 1,
  }) {
    return UnityConsent(
      id: '',
      userId: userId,
      type: type,
      granted: true,
      grantedAt: DateTime.now(),
      challengeId: challengeId,
      version: version,
    );
  }
}

/// Collection of consents for display/validation
class ConsentCollection {
  const ConsentCollection({
    this.consents = const [],
  });

  final List<UnityConsent> consents;

  /// Check if a specific consent type is granted
  bool hasConsent(ConsentType type, {String? challengeId}) {
    return consents.any((c) =>
        c.type == type &&
        c.isActive &&
        (challengeId == null || c.challengeId == challengeId));
  }

  /// Check if all required consents are granted
  bool get hasAllRequired {
    for (final type in ConsentType.values) {
      if (type.isRequired && !hasConsent(type)) {
        return false;
      }
    }
    return true;
  }

  /// Get missing required consents
  List<ConsentType> get missingRequired {
    return ConsentType.values
        .where((type) => type.isRequired && !hasConsent(type))
        .toList();
  }

  /// Get all active consents
  List<UnityConsent> get activeConsents =>
      consents.where((c) => c.isActive).toList();

  /// Get consent for a specific type
  UnityConsent? getConsent(ConsentType type, {String? challengeId}) {
    try {
      return consents.firstWhere(
        (c) =>
            c.type == type &&
            c.isActive &&
            (challengeId == null || c.challengeId == challengeId),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Consent text versions for audit trail
class ConsentText {
  ConsentText({
    required this.type,
    required this.version,
    required this.title,
    required this.description,
    required this.fullText,
    required this.effectiveDate,
  });

  final ConsentType type;
  final int version;
  final String title;
  final String description;
  final String fullText;
  final DateTime effectiveDate;

  static final Map<ConsentType, ConsentText> currentVersions = {
    ConsentType.healthDisclaimer: ConsentText(
      type: ConsentType.healthDisclaimer,
      version: 1,
      title: 'Health & Safety Disclaimer',
      description:
          'I understand the physical nature of this challenge and will listen to my body.',
      fullText: '''
By participating in this challenge, you acknowledge that:

1. You are participating voluntarily and at your own risk.
2. You should consult a physician before starting any exercise program.
3. You will listen to your body and stop if you experience pain or discomfort.
4. Rest days are encouraged and do not break your streak.
5. Progress is personal - there is no pressure to keep up with others.

Your health and wellbeing come first. Always.
''',
      effectiveDate: DateTime(2024, 1, 1),
    ),
    ConsentType.dataSharing: ConsentText(
      type: ConsentType.dataSharing,
      version: 1,
      title: 'Data Sharing Consent',
      description:
          'I consent to sharing my progress data with other challenge participants.',
      fullText: '''
To participate in Unity challenges, we need your consent to:

1. Share your progress with other challenge participants.
2. Display your activity in challenge feeds (if enabled).
3. Show your position in rankings (if enabled).
4. Send you notifications about challenge activity.

You can control what is shared in your Unity settings at any time.
You can enable Whisper Mode to participate anonymously.
''',
      effectiveDate: DateTime(2024, 1, 1),
    ),
    ConsentType.rankingsDisplay: ConsentText(
      type: ConsentType.rankingsDisplay,
      version: 1,
      title: 'Rankings Display',
      description: 'Show my progress in challenge rankings.',
      fullText: '''
If you opt in to rankings display:

1. Your progress will be visible to other participants.
2. Your chosen display name will be shown.
3. You can opt out at any time in settings.

Note: You can still participate fully without appearing in rankings.
''',
      effectiveDate: DateTime(2024, 1, 1),
    ),
    ConsentType.activityFeed: ConsentText(
      type: ConsentType.activityFeed,
      version: 1,
      title: 'Activity Feed',
      description: 'Share my activities in the challenge feed.',
      fullText: '''
If you opt in to the activity feed:

1. Your workouts and check-ins will appear in the challenge feed.
2. Other participants can send you cheers.
3. You can post updates and celebrate milestones.
4. You can opt out at any time in settings.

Note: You can enable Whisper Mode to post anonymously.
''',
      effectiveDate: DateTime(2024, 1, 1),
    ),
    ConsentType.ageVerification: ConsentText(
      type: ConsentType.ageVerification,
      version: 1,
      title: 'Age Verification',
      description: 'I confirm that I meet the minimum age requirement.',
      fullText: '''
Unity requires users to be at least 13 years old to participate.

Users aged 13-15 have limited features and require parental consent.
Users aged 16+ have access to all features.

By continuing, you confirm that you meet the minimum age requirement.
''',
      effectiveDate: DateTime(2024, 1, 1),
    ),
    ConsentType.parentalConsent: ConsentText(
      type: ConsentType.parentalConsent,
      version: 1,
      title: 'Parental Consent',
      description: 'Parent/guardian consent for users aged 13-15.',
      fullText: '''
For users aged 13-15, a parent or guardian must consent to:

1. The user participating in Unity challenges.
2. Limited data sharing with other participants.
3. The user receiving cheers and encouragement from others.

Parents can manage their child's Unity settings at any time.
''',
      effectiveDate: DateTime(2024, 1, 1),
    ),
  };
}
