import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/utils/timestamp_converter.dart';

part 'progress_photo.freezed.dart';
part 'progress_photo.g.dart';

/// Enum for photo angles
enum PhotoAngle {
  front,
  side,
  back,
  other;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case PhotoAngle.front:
        return 'Front';
      case PhotoAngle.side:
        return 'Side';
      case PhotoAngle.back:
        return 'Back';
      case PhotoAngle.other:
        return 'Other';
    }
  }
}

/// Model for progress photo
/// Stores both full image URL and thumbnail URL for performance
/// Limit: One photo per angle per day (enforced in repository)
@freezed
class ProgressPhoto with _$ProgressPhoto {
  const factory ProgressPhoto({
    required String id,
    required String userId,
    required String imageUrl, // Firebase Storage URL (full image)
    required String thumbnailUrl, // Compressed thumbnail for gallery
    required PhotoAngle angle,
    @TimestampConverter() required DateTime date, // Allows backdating
    @TimestampConverter() required DateTime createdAt,
    String? notes,
    double? weight, // Optional weight at time of photo (in kg)
    @Default({}) Map<String, dynamic> metadata, // Image dimensions, file size, etc.
  }) = _ProgressPhoto;

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) =>
      _$ProgressPhotoFromJson(json);
}
