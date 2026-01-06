// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressPhotoImpl _$$ProgressPhotoImplFromJson(Map<String, dynamic> json) =>
    _$ProgressPhotoImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      angle: $enumDecode(_$PhotoAngleEnumMap, json['angle']),
      date: const TimestampConverter().fromJson(json['date']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      notes: json['notes'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$ProgressPhotoImplToJson(_$ProgressPhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'angle': _$PhotoAngleEnumMap[instance.angle]!,
      'date': const TimestampConverter().toJson(instance.date),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'notes': instance.notes,
      'weight': instance.weight,
      'metadata': instance.metadata,
    };

const _$PhotoAngleEnumMap = {
  PhotoAngle.front: 'front',
  PhotoAngle.side: 'side',
  PhotoAngle.back: 'back',
  PhotoAngle.other: 'other',
};
