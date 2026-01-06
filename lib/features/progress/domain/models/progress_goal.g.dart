// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressGoalImpl _$$ProgressGoalImplFromJson(Map<String, dynamic> json) =>
    _$ProgressGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      type: $enumDecode(_$GoalTypeEnumMap, json['type']),
      startValue: (json['startValue'] as num).toDouble(),
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num).toDouble(),
      startDate: const TimestampConverter().fromJson(json['startDate']),
      targetDate:
          const NullableTimestampConverter().fromJson(json['targetDate']),
      completedDate:
          const NullableTimestampConverter().fromJson(json['completedDate']),
      status: $enumDecodeNullable(_$GoalStatusEnumMap, json['status']) ??
          GoalStatus.active,
      measurementType: $enumDecodeNullable(
          _$MeasurementTypeEnumMap, json['measurementType']),
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$ProgressGoalImplToJson(_$ProgressGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'type': _$GoalTypeEnumMap[instance.type]!,
      'startValue': instance.startValue,
      'targetValue': instance.targetValue,
      'currentValue': instance.currentValue,
      'startDate': const TimestampConverter().toJson(instance.startDate),
      'targetDate':
          const NullableTimestampConverter().toJson(instance.targetDate),
      'completedDate':
          const NullableTimestampConverter().toJson(instance.completedDate),
      'status': _$GoalStatusEnumMap[instance.status]!,
      'measurementType': _$MeasurementTypeEnumMap[instance.measurementType],
      'unit': instance.unit,
      'notes': instance.notes,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$GoalTypeEnumMap = {
  GoalType.weight: 'weight',
  GoalType.measurement: 'measurement',
  GoalType.custom: 'custom',
};

const _$GoalStatusEnumMap = {
  GoalStatus.active: 'active',
  GoalStatus.completed: 'completed',
  GoalStatus.abandoned: 'abandoned',
};

const _$MeasurementTypeEnumMap = {
  MeasurementType.waist: 'waist',
  MeasurementType.chest: 'chest',
  MeasurementType.hips: 'hips',
  MeasurementType.leftArm: 'leftArm',
  MeasurementType.rightArm: 'rightArm',
  MeasurementType.leftThigh: 'leftThigh',
  MeasurementType.rightThigh: 'rightThigh',
  MeasurementType.neck: 'neck',
  MeasurementType.shoulders: 'shoulders',
  MeasurementType.calves: 'calves',
};
