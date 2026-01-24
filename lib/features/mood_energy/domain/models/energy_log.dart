import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'energy_log.freezed.dart';
part 'energy_log.g.dart';

@freezed
class EnergyLog with _$EnergyLog {
  const EnergyLog._();

  const factory EnergyLog({
    required String id,
    required String userId,
    @TimestampConverter() required DateTime loggedAt,
    int? energyLevel, // 1-5 scale
    int? moodRating, // 1-5 scale (1=bad, 5=great)
    @Default([]) List<String> contextTags,
    String? notes,
    String? source, // 'manual', 'workout', 'habit', etc.
  }) = _EnergyLog;

  factory EnergyLog.fromJson(Map<String, dynamic> json) =>
      _$EnergyLogFromJson(json);

  // Computed property for average energy (if we track before/after in future)
  double? get averageEnergy {
    if (energyLevel != null) return energyLevel!.toDouble();
    return null;
  }

  // Helper to get mood emoji
  String get moodEmoji {
    if (moodRating == null) return '😐';
    switch (moodRating!) {
      case 1:
        return '😢'; // Very sad
      case 2:
        return '😕'; // Sad
      case 3:
        return '😐'; // Neutral
      case 4:
        return '🙂'; // Happy
      case 5:
        return '😄'; // Very happy
      default:
        return '😐';
    }
  }

  // Helper to get energy level description
  String get energyDescription {
    if (energyLevel == null) return 'Not logged';
    switch (energyLevel!) {
      case 1:
        return 'Exhausted';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Energized';
      default:
        return 'Unknown';
    }
  }

  // Helper to get mood description
  String get moodDescription {
    if (moodRating == null) return 'Not logged';
    switch (moodRating!) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent';
      default:
        return 'Unknown';
    }
  }
}
