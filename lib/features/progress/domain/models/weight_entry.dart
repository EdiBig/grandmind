import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'weight_entry.freezed.dart';
part 'weight_entry.g.dart';

/// Model for weight entry
/// Weight is always stored in kilograms (kg) internally
/// UI can convert to lbs based on user preferences
@freezed
class WeightEntry with _$WeightEntry {
  const factory WeightEntry({
    required String id,
    required String userId,
    required double weight, // Always in kg
    @TimestampConverter() required DateTime date, // Allows backdating
    @TimestampConverter() required DateTime createdAt,
    String? notes,
  }) = _WeightEntry;

  factory WeightEntry.fromJson(Map<String, dynamic> json) =>
      _$WeightEntryFromJson(json);
}
