// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_nutrition_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyNutritionSummaryImpl _$$DailyNutritionSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyNutritionSummaryImpl(
      userId: json['userId'] as String,
      date: const TimestampConverter().fromJson(json['date']),
      totalCalories: (json['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (json['totalProtein'] as num?)?.toDouble() ?? 0.0,
      totalCarbs: (json['totalCarbs'] as num?)?.toDouble() ?? 0.0,
      totalFat: (json['totalFat'] as num?)?.toDouble() ?? 0.0,
      waterGlasses: (json['waterGlasses'] as num?)?.toInt() ?? 0,
      mealsLogged: (json['mealsLogged'] as num?)?.toInt() ?? 0,
      caloriesByMeal: (json['caloriesByMeal'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry($enumDecode(_$MealTypeEnumMap, k), (e as num).toDouble()),
      ),
      goal: json['goal'] == null
          ? null
          : NutritionGoal.fromJson(json['goal'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DailyNutritionSummaryImplToJson(
        _$DailyNutritionSummaryImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'date': const TimestampConverter().toJson(instance.date),
      'totalCalories': instance.totalCalories,
      'totalProtein': instance.totalProtein,
      'totalCarbs': instance.totalCarbs,
      'totalFat': instance.totalFat,
      'waterGlasses': instance.waterGlasses,
      'mealsLogged': instance.mealsLogged,
      'caloriesByMeal': instance.caloriesByMeal
          ?.map((k, e) => MapEntry(_$MealTypeEnumMap[k]!, e)),
      'goal': instance.goal?.toJson(),
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};
