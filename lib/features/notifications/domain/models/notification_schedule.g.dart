// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_schedule.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationScheduleImpl _$$NotificationScheduleImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationScheduleImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      title: json['title'] as String,
      body: json['body'] as String,
      scheduledTime: const TimestampConverter().fromJson(json['scheduledTime']),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurrencePattern: json['recurrencePattern'] as String?,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      timeOfDay: json['timeOfDay'] == null
          ? null
          : TimeOfDayData.fromJson(json['timeOfDay'] as Map<String, dynamic>),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$NotificationScheduleImplToJson(
        _$NotificationScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'title': instance.title,
      'body': instance.body,
      'scheduledTime':
          const TimestampConverter().toJson(instance.scheduledTime),
      'isRecurring': instance.isRecurring,
      'recurrencePattern': instance.recurrencePattern,
      'daysOfWeek': instance.daysOfWeek,
      'timeOfDay': instance.timeOfDay?.toJson(),
      'isActive': instance.isActive,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
      'metadata': instance.metadata,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.workoutReminder: 'workoutReminder',
  NotificationType.habitCheckIn: 'habitCheckIn',
  NotificationType.moodEnergyCheckIn: 'moodEnergyCheckIn',
  NotificationType.motivational: 'motivational',
  NotificationType.achievement: 'achievement',
  NotificationType.goalMilestone: 'goalMilestone',
  NotificationType.inactivityNudge: 'inactivityNudge',
  NotificationType.custom: 'custom',
};

_$TimeOfDayDataImpl _$$TimeOfDayDataImplFromJson(Map<String, dynamic> json) =>
    _$TimeOfDayDataImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
    );

Map<String, dynamic> _$$TimeOfDayDataImplToJson(_$TimeOfDayDataImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };
