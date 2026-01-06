// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPreferenceImpl _$$NotificationPreferenceImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationPreferenceImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$ReminderTypeEnumMap, json['type']),
      enabled: json['enabled'] as bool,
      title: json['title'] as String,
      message: json['message'] as String,
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      linkedEntityId: json['linkedEntityId'] as String?,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
    );

Map<String, dynamic> _$$NotificationPreferenceImplToJson(
        _$NotificationPreferenceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': _$ReminderTypeEnumMap[instance.type]!,
      'enabled': instance.enabled,
      'title': instance.title,
      'message': instance.message,
      'daysOfWeek': instance.daysOfWeek,
      'hour': instance.hour,
      'minute': instance.minute,
      'linkedEntityId': instance.linkedEntityId,
      'createdAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.createdAt, const TimestampConverter().toJson),
      'updatedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
    };

const _$ReminderTypeEnumMap = {
  ReminderType.workout: 'workout',
  ReminderType.habit: 'habit',
  ReminderType.water: 'water',
  ReminderType.meal: 'meal',
  ReminderType.sleep: 'sleep',
  ReminderType.meditation: 'meditation',
  ReminderType.custom: 'custom',
};

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

_$NotificationHistoryImpl _$$NotificationHistoryImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationHistoryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      preferenceId: json['preferenceId'] as String,
      type: $enumDecode(_$ReminderTypeEnumMap, json['type']),
      title: json['title'] as String,
      message: json['message'] as String,
      sentAt: const TimestampConverter().fromJson(json['sentAt']),
      readAt: const TimestampConverter().fromJson(json['readAt']),
      actionedAt: const TimestampConverter().fromJson(json['actionedAt']),
      action: json['action'] as String?,
    );

Map<String, dynamic> _$$NotificationHistoryImplToJson(
        _$NotificationHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'preferenceId': instance.preferenceId,
      'type': _$ReminderTypeEnumMap[instance.type]!,
      'title': instance.title,
      'message': instance.message,
      'sentAt': const TimestampConverter().toJson(instance.sentAt),
      'readAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.readAt, const TimestampConverter().toJson),
      'actionedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.actionedAt, const TimestampConverter().toJson),
      'action': instance.action,
    };
