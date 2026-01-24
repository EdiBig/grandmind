// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'energy_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EnergyLogImpl _$$EnergyLogImplFromJson(Map<String, dynamic> json) =>
    _$EnergyLogImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      loggedAt: const TimestampConverter().fromJson(json['loggedAt']),
      energyLevel: (json['energyLevel'] as num?)?.toInt(),
      moodRating: (json['moodRating'] as num?)?.toInt(),
      contextTags: (json['contextTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      source: json['source'] as String?,
    );

Map<String, dynamic> _$$EnergyLogImplToJson(_$EnergyLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'loggedAt': const TimestampConverter().toJson(instance.loggedAt),
      'energyLevel': instance.energyLevel,
      'moodRating': instance.moodRating,
      'contextTags': instance.contextTags,
      'notes': instance.notes,
      'source': instance.source,
    };
