// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealImpl _$$MealImplFromJson(Map<String, dynamic> json) => _$MealImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      mealType: $enumDecode(_$MealTypeEnumMap, json['mealType']),
      mealDate: const TimestampConverter().fromJson(json['mealDate']),
      loggedAt: const TimestampConverter().fromJson(json['loggedAt']),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
      photoUrl: json['photoUrl'] as String?,
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$MealImplToJson(_$MealImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'mealDate': const TimestampConverter().toJson(instance.mealDate),
      'loggedAt': const TimestampConverter().toJson(instance.loggedAt),
      'entries': instance.entries.map((e) => e.toJson()).toList(),
      'notes': instance.notes,
      'photoUrl': instance.photoUrl,
      'totalCalories': instance.totalCalories,
      'totalProtein': instance.totalProtein,
      'totalCarbs': instance.totalCarbs,
      'totalFat': instance.totalFat,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};

_$MealEntryImpl _$$MealEntryImplFromJson(Map<String, dynamic> json) =>
    _$MealEntryImpl(
      foodItem: FoodItem.fromJson(json['foodItem'] as Map<String, dynamic>),
      servings: (json['servings'] as num?)?.toDouble() ?? 1.0,
      customServingSize: json['customServingSize'] as String?,
    );

Map<String, dynamic> _$$MealEntryImplToJson(_$MealEntryImpl instance) =>
    <String, dynamic>{
      'foodItem': instance.foodItem.toJson(),
      'servings': instance.servings,
      'customServingSize': instance.customServingSize,
    };
