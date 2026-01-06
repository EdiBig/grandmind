// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MeasurementEntryImpl _$$MeasurementEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$MeasurementEntryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      measurements: (json['measurements'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toDouble()),
          ) ??
          const {},
      date: const TimestampConverter().fromJson(json['date']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$MeasurementEntryImplToJson(
        _$MeasurementEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'measurements': instance.measurements,
      'date': const TimestampConverter().toJson(instance.date),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'notes': instance.notes,
    };
