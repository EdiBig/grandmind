// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_goal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NutritionGoalImpl _$$NutritionGoalImplFromJson(Map<String, dynamic> json) =>
    _$NutritionGoalImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      dailyCalories: (json['dailyCalories'] as num?)?.toDouble() ?? 2000.0,
      dailyProteinGrams:
          (json['dailyProteinGrams'] as num?)?.toDouble() ?? 150.0,
      dailyCarbsGrams: (json['dailyCarbsGrams'] as num?)?.toDouble() ?? 250.0,
      dailyFatGrams: (json['dailyFatGrams'] as num?)?.toDouble() ?? 65.0,
      dailyWaterGlasses: (json['dailyWaterGlasses'] as num?)?.toInt() ?? 8,
      createdAt: const TimestampConverter().fromJson(json['createdAt']),
      updatedAt: const NullableTimestampConverter().fromJson(json['updatedAt']),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$NutritionGoalImplToJson(_$NutritionGoalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'dailyCalories': instance.dailyCalories,
      'dailyProteinGrams': instance.dailyProteinGrams,
      'dailyCarbsGrams': instance.dailyCarbsGrams,
      'dailyFatGrams': instance.dailyFatGrams,
      'dailyWaterGlasses': instance.dailyWaterGlasses,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt':
          const NullableTimestampConverter().toJson(instance.updatedAt),
      'isActive': instance.isActive,
    };
