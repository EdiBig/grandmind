// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthDataImpl _$$HealthDataImplFromJson(Map<String, dynamic> json) =>
    _$HealthDataImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: const TimestampConverter().fromJson(json['date']),
      steps: (json['steps'] as num).toInt(),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      caloriesBurned: (json['caloriesBurned'] as num).toDouble(),
      averageHeartRate: (json['averageHeartRate'] as num?)?.toDouble(),
      sleepHours: (json['sleepHours'] as num).toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      syncedAt: const TimestampConverter().fromJson(json['syncedAt']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$HealthDataImplToJson(_$HealthDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': const TimestampConverter().toJson(instance.date),
      'steps': instance.steps,
      'distanceMeters': instance.distanceMeters,
      'caloriesBurned': instance.caloriesBurned,
      'averageHeartRate': instance.averageHeartRate,
      'sleepHours': instance.sleepHours,
      'weight': instance.weight,
      'syncedAt': const TimestampConverter().toJson(instance.syncedAt),
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
