import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'sleep_log.freezed.dart';
part 'sleep_log.g.dart';

/// Sleep quality rating
enum SleepQuality {
  terrible(1, 'Terrible', '😫'),
  poor(2, 'Poor', '😴'),
  fair(3, 'Fair', '😐'),
  good(4, 'Good', '🙂'),
  excellent(5, 'Excellent', '😊');

  final int value;
  final String label;
  final String emoji;

  const SleepQuality(this.value, this.label, this.emoji);

  static SleepQuality fromValue(int value) {
    return SleepQuality.values.firstWhere(
      (q) => q.value == value,
      orElse: () => SleepQuality.fair,
    );
  }
}

/// Common sleep context tags
class SleepTags {
  static const List<String> all = [
    'Restless',
    'Deep sleep',
    'Interrupted',
    'Dreams',
    'Nightmares',
    'Woke up refreshed',
    'Hard to wake',
    'Slept in',
    'Early wake',
    'Nap',
    'Caffeine late',
    'Screen time',
    'Exercise helped',
    'Stress',
  ];
}

@freezed
class SleepLog with _$SleepLog {
  const SleepLog._();

  const factory SleepLog({
    required String id,
    required String userId,
    @TimestampConverter() required DateTime logDate, // The date this sleep is for
    required double hoursSlept, // Total hours of sleep
    int? quality, // 1-5 scale
    @TimestampConverter() DateTime? bedTime, // When went to bed
    @TimestampConverter() DateTime? wakeTime, // When woke up
    @Default([]) List<String> tags,
    String? notes,
    @Default('manual') String source, // 'manual', 'apple_health', 'google_fit'
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) = _SleepLog;

  factory SleepLog.fromJson(Map<String, dynamic> json) =>
      _$SleepLogFromJson(json);

  /// Get quality enum from value
  SleepQuality? get qualityEnum =>
      quality != null ? SleepQuality.fromValue(quality!) : null;

  /// Get quality description
  String get qualityDescription {
    if (quality == null) return 'Not rated';
    return SleepQuality.fromValue(quality!).label;
  }

  /// Get quality emoji
  String get qualityEmoji {
    if (quality == null) return '😴';
    return SleepQuality.fromValue(quality!).emoji;
  }

  /// Format hours as readable string
  String get hoursFormatted {
    final hours = hoursSlept.floor();
    final minutes = ((hoursSlept - hours) * 60).round();
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }

  /// Check if this is considered good sleep (7+ hours and quality >= 4)
  bool get isGoodSleep => hoursSlept >= 7 && (quality == null || quality! >= 4);

  /// Check if this is poor sleep
  bool get isPoorSleep => hoursSlept < 6 || (quality != null && quality! <= 2);

  /// Get sleep duration category
  String get durationCategory {
    if (hoursSlept < 5) return 'Very short';
    if (hoursSlept < 6) return 'Short';
    if (hoursSlept < 7) return 'Below average';
    if (hoursSlept < 8) return 'Average';
    if (hoursSlept < 9) return 'Good';
    return 'Long';
  }
}
