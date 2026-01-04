import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'habit_log.freezed.dart';
part 'habit_log.g.dart';

/// Habit log model for tracking daily completions
@freezed
class HabitLog with _$HabitLog {
  const factory HabitLog({
    required String id,
    required String habitId,
    required String userId,
    @TimestampConverter() required DateTime date, // Date of completion (normalized to start of day)
    @TimestampConverter() required DateTime completedAt, // Actual timestamp when marked complete
    @Default(1) int count, // Number of times completed (for quantifiable habits)
    String? notes,
  }) = _HabitLog;

  factory HabitLog.fromJson(Map<String, dynamic> json) =>
      _$HabitLogFromJson(json);
}
