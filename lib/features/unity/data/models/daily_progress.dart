import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

/// Represents a user's progress for a single day in a challenge
class DailyProgress {
  const DailyProgress({
    required this.date,
    required this.rawValue,
    this.adjustedValue,
    this.readinessScore,
    this.multiplier = 1.0,
    this.dailyTarget,
    this.targetMet = false,
    this.isRestDay = false,
    this.restDayReason,
    this.note,
    this.recordedAt,
    this.sourceType,
    this.sourceId,
  });

  /// The date this progress is for (normalized to start of day)
  final DateTime date;

  /// Raw value recorded (before any adjustments)
  final double rawValue;

  /// Value after applying readiness multiplier
  final double? adjustedValue;

  /// User's readiness/energy score (0-100)
  final double? readinessScore;

  /// Multiplier applied based on readiness
  final double multiplier;

  /// Target for this specific day (may be adapted)
  final double? dailyTarget;

  /// Whether the daily target was met
  final bool targetMet;

  /// Whether this was marked as a rest day
  final bool isRestDay;

  /// Reason for rest day if applicable
  final RestDayReason? restDayReason;

  /// Optional note from the user
  final String? note;

  /// When this progress was recorded
  final DateTime? recordedAt;

  /// Source of the progress data (e.g., 'health_kit', 'manual', 'workout')
  final String? sourceType;

  /// ID of the source (e.g., workout ID)
  final String? sourceId;

  /// Get the effective value (adjusted if available, otherwise raw)
  double get effectiveValue => adjustedValue ?? rawValue;

  /// Calculate progress toward daily target as percentage
  double get progressPercent {
    if (dailyTarget == null || dailyTarget! <= 0) return 0;
    return (effectiveValue / dailyTarget!).clamp(0.0, 1.0);
  }

  /// Date string in YYYY-MM-DD format (used as document ID)
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  factory DailyProgress.fromFirestore(Map<String, dynamic> data, String dateKey) {
    // Parse date from key or field
    DateTime parsedDate;
    if (data['date'] != null) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else {
      final parts = dateKey.split('-');
      parsedDate = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }

    return DailyProgress(
      date: parsedDate,
      rawValue: (data['rawValue'] as num?)?.toDouble() ?? 0,
      adjustedValue: (data['adjustedValue'] as num?)?.toDouble(),
      readinessScore: (data['readinessScore'] as num?)?.toDouble(),
      multiplier: (data['multiplier'] as num?)?.toDouble() ?? 1.0,
      dailyTarget: (data['dailyTarget'] as num?)?.toDouble(),
      targetMet: data['targetMet'] as bool? ?? false,
      isRestDay: data['isRestDay'] as bool? ?? false,
      restDayReason: data['restDayReason'] != null
          ? RestDayReason.values.firstWhere(
              (r) => r.name == data['restDayReason'],
              orElse: () => RestDayReason.other,
            )
          : null,
      note: data['note'] as String?,
      recordedAt: (data['recordedAt'] as Timestamp?)?.toDate(),
      sourceType: data['sourceType'] as String?,
      sourceId: data['sourceId'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'rawValue': rawValue,
      if (adjustedValue != null) 'adjustedValue': adjustedValue,
      if (readinessScore != null) 'readinessScore': readinessScore,
      'multiplier': multiplier,
      if (dailyTarget != null) 'dailyTarget': dailyTarget,
      'targetMet': targetMet,
      'isRestDay': isRestDay,
      if (restDayReason != null) 'restDayReason': restDayReason!.name,
      if (note != null) 'note': note,
      'recordedAt': recordedAt != null
          ? Timestamp.fromDate(recordedAt!)
          : FieldValue.serverTimestamp(),
      if (sourceType != null) 'sourceType': sourceType,
      if (sourceId != null) 'sourceId': sourceId,
    };
  }

  DailyProgress copyWith({
    DateTime? date,
    double? rawValue,
    double? adjustedValue,
    double? readinessScore,
    double? multiplier,
    double? dailyTarget,
    bool? targetMet,
    bool? isRestDay,
    RestDayReason? restDayReason,
    String? note,
    DateTime? recordedAt,
    String? sourceType,
    String? sourceId,
  }) {
    return DailyProgress(
      date: date ?? this.date,
      rawValue: rawValue ?? this.rawValue,
      adjustedValue: adjustedValue ?? this.adjustedValue,
      readinessScore: readinessScore ?? this.readinessScore,
      multiplier: multiplier ?? this.multiplier,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      targetMet: targetMet ?? this.targetMet,
      isRestDay: isRestDay ?? this.isRestDay,
      restDayReason: restDayReason ?? this.restDayReason,
      note: note ?? this.note,
      recordedAt: recordedAt ?? this.recordedAt,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  /// Create a rest day entry
  factory DailyProgress.restDay({
    required DateTime date,
    required RestDayReason reason,
    String? note,
    double? dailyTarget,
  }) {
    return DailyProgress(
      date: date,
      rawValue: 0,
      isRestDay: true,
      restDayReason: reason,
      note: note,
      dailyTarget: dailyTarget,
      targetMet: true, // Rest days count as "meeting" the target
      recordedAt: DateTime.now(),
    );
  }

  /// Apply readiness-based adjustment to the progress
  DailyProgress withReadinessAdjustment(double readiness) {
    // Calculate multiplier based on readiness score
    double mult;
    if (readiness >= 85) {
      mult = 1.2; // Push day bonus
    } else if (readiness >= 70) {
      mult = 1.0; // Normal day
    } else if (readiness >= 50) {
      mult = 0.8; // Moderate day
    } else if (readiness >= 30) {
      mult = 0.6; // Easy day
    } else {
      mult = 0.4; // Rest day level
    }

    return copyWith(
      readinessScore: readiness,
      multiplier: mult,
      adjustedValue: rawValue * mult,
    );
  }
}
