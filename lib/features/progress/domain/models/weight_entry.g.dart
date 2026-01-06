// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeightEntryImpl _$$WeightEntryImplFromJson(Map<String, dynamic> json) =>
    _$WeightEntryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weight: (json['weight'] as num).toDouble(),
      date: const TimestampConverter().fromJson(json['date']),
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$WeightEntryImplToJson(_$WeightEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'weight': instance.weight,
      'date': const TimestampConverter().toJson(instance.date),
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'notes': instance.notes,
    };
