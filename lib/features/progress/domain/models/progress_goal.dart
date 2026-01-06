import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';
import 'measurement_entry.dart';

part 'progress_goal.freezed.dart';
part 'progress_goal.g.dart';

/// Enum for goal types
enum GoalType {
  weight,
  measurement,
  custom;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case GoalType.weight:
        return 'Weight Goal';
      case GoalType.measurement:
        return 'Measurement Goal';
      case GoalType.custom:
        return 'Custom Goal';
    }
  }
}

/// Enum for goal status
enum GoalStatus {
  active,
  completed,
  abandoned;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.abandoned:
        return 'Abandoned';
    }
  }
}

/// Model for progress goal
/// Supports weight goals, measurement goals, and custom goals
/// Auto-updates when user logs weight or measurements
@freezed
class ProgressGoal with _$ProgressGoal {
  const factory ProgressGoal({
    required String id,
    required String userId,
    required String title,
    required GoalType type,
    required double startValue,
    required double targetValue,
    required double currentValue,
    @TimestampConverter() required DateTime startDate,
    @NullableTimestampConverter() DateTime? targetDate,
    @NullableTimestampConverter() DateTime? completedDate,
    @Default(GoalStatus.active) GoalStatus status,
    MeasurementType? measurementType, // If type is measurement
    String? unit, // e.g., 'kg', 'cm', 'glasses'
    String? notes,
    @TimestampConverter() required DateTime createdAt,
  }) = _ProgressGoal;

  const ProgressGoal._();

  /// Calculate progress percentage (0-100)
  double get progressPercentage {
    if (targetValue == startValue) return 100.0;

    final progress =
        ((currentValue - startValue) / (targetValue - startValue)) * 100;
    return progress.clamp(0.0, 100.0);
  }

  /// Calculate remaining value to goal
  double get remainingValue => (targetValue - currentValue).abs();

  /// Check if goal is completed (reached target)
  bool get isCompleted => progressPercentage >= 100.0;

  /// Check if goal is overdue (past target date and not completed)
  bool get isOverdue {
    if (targetDate == null || status == GoalStatus.completed) return false;
    return DateTime.now().isAfter(targetDate!) && !isCompleted;
  }

  /// Get days remaining until target date (null if no target date)
  int? get daysRemaining {
    if (targetDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(targetDate!)) return 0;
    return targetDate!.difference(now).inDays;
  }

  /// Get days since goal started
  int get daysSinceStart {
    return DateTime.now().difference(startDate).inDays;
  }

  /// Get display string for goal progress
  String getProgressDisplay({bool includeUnit = true}) {
    final unitStr = unit != null && includeUnit && unit!.isNotEmpty ? ' $unit' : '';
    return '${currentValue.toStringAsFixed(1)}$unitStr / ${targetValue.toStringAsFixed(1)}$unitStr';
  }

  factory ProgressGoal.fromJson(Map<String, dynamic> json) =>
      _$ProgressGoalFromJson(json);
}
