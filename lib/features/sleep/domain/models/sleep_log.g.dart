// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sleep_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SleepLogImpl _$$SleepLogImplFromJson(Map<String, dynamic> json) =>
    _$SleepLogImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      logDate: const TimestampConverter().fromJson(json['logDate']),
      hoursSlept: (json['hoursSlept'] as num).toDouble(),
      quality: (json['quality'] as num?)?.toInt(),
      bedTime: const TimestampConverter().fromJson(json['bedTime']),
      wakeTime: const TimestampConverter().fromJson(json['wakeTime']),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      notes: json['notes'] as String?,
      source: json['source'] as String? ?? 'manual',
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$SleepLogImplToJson(_$SleepLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'logDate': const TimestampConverter().toJson(instance.logDate),
      'hoursSlept': instance.hoursSlept,
      'quality': instance.quality,
      'bedTime': _$JsonConverterToJson<dynamic, DateTime>(
          instance.bedTime, const TimestampConverter().toJson),
      'wakeTime': _$JsonConverterToJson<dynamic, DateTime>(
          instance.wakeTime, const TimestampConverter().toJson),
      'tags': instance.tags,
      'notes': instance.notes,
      'source': instance.source,
      'createdAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.createdAt, const TimestampConverter().toJson),
      'updatedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
