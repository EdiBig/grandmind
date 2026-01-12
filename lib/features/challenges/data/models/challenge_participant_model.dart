import 'package:cloud_firestore/cloud_firestore.dart';

class ChallengeParticipantModel {
  const ChallengeParticipantModel({
    required this.id,
    required this.challengeId,
    required this.userId,
    required this.joinedAt,
    required this.leftAt,
    required this.currentProgress,
    required this.lastActivityAt,
    required this.optInRankings,
    required this.optInActivityFeed,
    required this.displayName,
    required this.healthDisclaimerAccepted,
    required this.dataSharingConsent,
  });

  final String id;
  final String challengeId;
  final String userId;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final int currentProgress;
  final DateTime? lastActivityAt;
  final bool optInRankings;
  final bool optInActivityFeed;
  final String displayName;
  final bool healthDisclaimerAccepted;
  final bool dataSharingConsent;

  factory ChallengeParticipantModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return ChallengeParticipantModel(
      id: id,
      challengeId: data['challengeId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      joinedAt: _parseTimestampOrNow(data['joinedAt']),
      leftAt: _parseTimestamp(data['leftAt']),
      currentProgress: (data['currentProgress'] as num?)?.toInt() ?? 0,
      lastActivityAt: _parseTimestamp(data['lastActivityAt']),
      optInRankings: data['optInRankings'] as bool? ?? true,
      optInActivityFeed: data['optInActivityFeed'] as bool? ?? true,
      displayName: data['displayName'] as String? ?? '',
      healthDisclaimerAccepted:
          data['healthDisclaimerAccepted'] as bool? ?? false,
      dataSharingConsent: data['dataSharingConsent'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengeId': challengeId,
      'userId': userId,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'leftAt': leftAt != null ? Timestamp.fromDate(leftAt!) : null,
      'currentProgress': currentProgress,
      'lastActivityAt':
          lastActivityAt != null ? Timestamp.fromDate(lastActivityAt!) : null,
      'optInRankings': optInRankings,
      'optInActivityFeed': optInActivityFeed,
      'displayName': displayName,
      'healthDisclaimerAccepted': healthDisclaimerAccepted,
      'dataSharingConsent': dataSharingConsent,
    };
  }
}

DateTime _parseTimestampOrNow(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return DateTime.now();
}

DateTime? _parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}
