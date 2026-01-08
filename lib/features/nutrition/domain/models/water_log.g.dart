// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WaterLogImpl _$$WaterLogImplFromJson(Map<String, dynamic> json) =>
    _$WaterLogImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: const TimestampConverter().fromJson(json['date']),
      loggedAt: const TimestampConverter().fromJson(json['loggedAt']),
      glassesConsumed: (json['glassesConsumed'] as num?)?.toInt() ?? 0,
      targetGlasses: (json['targetGlasses'] as num?)?.toInt() ?? 8,
    );

Map<String, dynamic> _$$WaterLogImplToJson(_$WaterLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': const TimestampConverter().toJson(instance.date),
      'loggedAt': const TimestampConverter().toJson(instance.loggedAt),
      'glassesConsumed': instance.glassesConsumed,
      'targetGlasses': instance.targetGlasses,
    };
