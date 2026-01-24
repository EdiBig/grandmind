import 'package:cloud_firestore/cloud_firestore.dart';

enum ChallengeType {
  community,
  pod,
}

enum ChallengeGoalType {
  steps,
  workouts,
  habit,
  distance,
}

enum ChallengeVisibility {
  public,
  private,
  inviteOnly,
}

enum ChallengeTheme {
  winter,
  spring,
  summer,
  fall,
  custom,
}

class ChallengeModel {
  const ChallengeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.goalType,
    required this.goalTarget,
    required this.goalUnit,
    required this.startDate,
    required this.endDate,
    required this.visibility,
    required this.hasRankings,
    required this.hasActivityFeed,
    required this.allowMemberInvites,
    required this.theme,
    required this.coverImageUrl,
    required this.createdBy,
    required this.createdAt,
    required this.participantCount,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final ChallengeType type;
  final ChallengeGoalType goalType;
  final int goalTarget;
  final String goalUnit;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeVisibility visibility;
  final bool hasRankings;
  final bool hasActivityFeed;
  final bool allowMemberInvites;
  final ChallengeTheme theme;
  final String? coverImageUrl;
  final String? createdBy;
  final DateTime createdAt;
  final int participantCount;
  final bool isActive;

  factory ChallengeModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ChallengeModel(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: _parseEnum(data['type'], ChallengeType.values,
          fallback: ChallengeType.community),
      goalType: _parseEnum(data['goalType'], ChallengeGoalType.values,
          fallback: ChallengeGoalType.workouts),
      goalTarget: (data['goalTarget'] as num?)?.toInt() ?? 0,
      goalUnit: data['goalUnit'] as String? ?? 'workouts',
      startDate: _parseTimestampOrNow(data['startDate']),
      endDate: _parseTimestampOrNow(data['endDate']),
      visibility: _parseEnum(data['visibility'], ChallengeVisibility.values,
          fallback: ChallengeVisibility.inviteOnly),
      hasRankings: data['hasRankings'] as bool? ?? true,
      hasActivityFeed: data['hasActivityFeed'] as bool? ?? false,
      allowMemberInvites: data['allowMemberInvites'] as bool? ?? true,
      theme: _parseEnum(data['theme'], ChallengeTheme.values,
          fallback: ChallengeTheme.custom),
      coverImageUrl: data['coverImageUrl'] as String?,
      createdBy: data['createdBy'] as String?,
      createdAt: _parseTimestampOrNow(data['createdAt']),
      participantCount: (data['participantCount'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'type': type.name,
      'goalType': goalType.name,
      'goalTarget': goalTarget,
      'goalUnit': goalUnit,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'visibility': visibility.name,
      'hasRankings': hasRankings,
      'hasActivityFeed': hasActivityFeed,
      'allowMemberInvites': allowMemberInvites,
      'theme': theme.name,
      'coverImageUrl': coverImageUrl,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'participantCount': participantCount,
      'isActive': isActive,
    };
  }

  bool get isLive =>
      isActive &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);
}

T _parseEnum<T>(
  dynamic value,
  List<T> values, {
  required T fallback,
}) {
  if (value is String) {
    for (final entry in values) {
      if ((entry as Enum).name == value) {
        return entry;
      }
    }
  }
  return fallback;
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
