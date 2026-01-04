// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitLogImpl _$$HabitLogImplFromJson(Map<String, dynamic> json) =>
    _$HabitLogImpl(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      userId: json['userId'] as String,
      date: const TimestampConverter().fromJson(json['date']),
      completedAt: const TimestampConverter().fromJson(json['completedAt']),
      count: (json['count'] as num?)?.toInt() ?? 1,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$HabitLogImplToJson(_$HabitLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'habitId': instance.habitId,
      'userId': instance.userId,
      'date': const TimestampConverter().toJson(instance.date),
      'completedAt': const TimestampConverter().toJson(instance.completedAt),
      'count': instance.count,
      'notes': instance.notes,
    };
