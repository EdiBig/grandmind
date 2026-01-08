import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'water_log.freezed.dart';
part 'water_log.g.dart';

/// Water intake log for a specific day
/// Tracks glasses of water consumed vs daily target
@freezed
class WaterLog with _$WaterLog {
  const factory WaterLog({
    required String id,
    required String userId,
    @TimestampConverter() required DateTime date, // Normalized to start of day
    @TimestampConverter() required DateTime loggedAt, // Last update timestamp
    @Default(0) int glassesConsumed, // Number of 250ml glasses consumed
    @Default(8) int targetGlasses, // Daily goal (default 8 glasses = 2L)
  }) = _WaterLog;

  const WaterLog._();

  factory WaterLog.fromJson(Map<String, dynamic> json) =>
      _$WaterLogFromJson(json);

  /// Calculate total liters consumed (250ml per glass)
  double get totalLiters => glassesConsumed * 0.25;

  /// Calculate progress percentage towards goal
  double get progressPercentage =>
      targetGlasses > 0 ? (glassesConsumed / targetGlasses * 100).clamp(0, 100) : 0;

  /// Check if daily goal has been achieved
  bool get goalAchieved => glassesConsumed >= targetGlasses;

  /// Get remaining glasses to reach goal
  int get remainingGlasses => (targetGlasses - glassesConsumed).clamp(0, targetGlasses);
}
