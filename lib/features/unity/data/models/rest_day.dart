import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Represents a rest day logged by a user
class RestDay {
  const RestDay({
    required this.id,
    required this.userId,
    required this.date,
    required this.reason,
    this.challengeId,
    this.note,
    this.createdAt,
    this.protectsStreak = true,
  });

  final String id;
  final String userId;
  final DateTime date;
  final RestDayReason reason;
  final String? challengeId;
  final String? note;
  final DateTime? createdAt;

  /// Whether this rest day protects the user's streak
  final bool protectsStreak;

  /// Date key in YYYY-MM-DD format
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get encouraging message for this rest day
  String get encouragement => reason.encouragement;

  factory RestDay.fromFirestore(Map<String, dynamic> data, String id) {
    return RestDay(
      id: id,
      userId: data['userId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reason: RestDayReason.values.firstWhere(
        (r) => r.name == data['reason'],
        orElse: () => RestDayReason.other,
      ),
      challengeId: data['challengeId'] as String?,
      note: data['note'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      protectsStreak: data['protectsStreak'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'reason': reason.name,
      if (challengeId != null) 'challengeId': challengeId,
      if (note != null) 'note': note,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'protectsStreak': protectsStreak,
    };
  }

  RestDay copyWith({
    String? id,
    String? userId,
    DateTime? date,
    RestDayReason? reason,
    String? challengeId,
    String? note,
    DateTime? createdAt,
    bool? protectsStreak,
  }) {
    return RestDay(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      challengeId: challengeId ?? this.challengeId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      protectsStreak: protectsStreak ?? this.protectsStreak,
    );
  }
}

/// Weekly rest day tracking for a participation
class WeeklyRestDayStatus {
  const WeeklyRestDayStatus({
    required this.weekStart,
    this.restDays = const [],
    this.maxAllowed = 2,
  });

  final DateTime weekStart;
  final List<RestDay> restDays;
  final int maxAllowed;

  /// Number of rest days used this week
  int get used => restDays.length;

  /// Number of rest days remaining
  int get remaining => maxAllowed - used;

  /// Whether the user can take another rest day
  bool get canTakeRestDay => remaining > 0;

  /// Whether a specific date is a rest day
  bool isRestDay(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return restDays.any((r) => r.dateKey == dateKey);
  }

  /// Get rest day for a specific date if exists
  RestDay? getRestDay(DateTime date) {
    final dateKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    try {
      return restDays.firstWhere((r) => r.dateKey == dateKey);
    } catch (_) {
      return null;
    }
  }

  /// Calculate the start of the week for a given date (Monday)
  static DateTime getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Check if a date is in this week
  bool isInWeek(DateTime date) {
    final dateWeekStart = getWeekStart(date);
    return dateWeekStart.year == weekStart.year &&
        dateWeekStart.month == weekStart.month &&
        dateWeekStart.day == weekStart.day;
  }
}

/// Rest day policy configuration
class RestDayPolicy {
  const RestDayPolicy({
    this.enabled = true,
    this.maxPerWeek = 2,
    this.protectsStreak = true,
    this.requiresReason = true,
    this.allowedReasons,
  });

  final bool enabled;
  final int maxPerWeek;
  final bool protectsStreak;
  final bool requiresReason;
  final List<RestDayReason>? allowedReasons;

  /// Get allowed reasons (or all if not specified)
  List<RestDayReason> get effectiveAllowedReasons =>
      allowedReasons ?? RestDayReason.values;

  factory RestDayPolicy.fromFirestore(Map<String, dynamic> data) {
    return RestDayPolicy(
      enabled: data['enabled'] as bool? ?? true,
      maxPerWeek: data['maxPerWeek'] as int? ?? 2,
      protectsStreak: data['protectsStreak'] as bool? ?? true,
      requiresReason: data['requiresReason'] as bool? ?? true,
      allowedReasons: (data['allowedReasons'] as List<dynamic>?)
          ?.map((r) => RestDayReason.values.firstWhere(
                (rr) => rr.name == r,
                orElse: () => RestDayReason.other,
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'enabled': enabled,
      'maxPerWeek': maxPerWeek,
      'protectsStreak': protectsStreak,
      'requiresReason': requiresReason,
      if (allowedReasons != null)
        'allowedReasons': allowedReasons!.map((r) => r.name).toList(),
    };
  }
}
