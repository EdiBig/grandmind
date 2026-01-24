// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_insights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthInsightsImpl _$$HealthInsightsImplFromJson(Map<String, dynamic> json) =>
    _$HealthInsightsImpl(
      summary: json['summary'] as String,
      keyInsights: (json['keyInsights'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      statistics: HealthInsightsStatistics.fromJson(
          json['statistics'] as Map<String, dynamic>),
      correlations: (json['correlations'] as List<dynamic>)
          .map((e) => HealthCorrelation.fromJson(e as Map<String, dynamic>))
          .toList(),
      trends: HealthTrends.fromJson(json['trends'] as Map<String, dynamic>),
      weeklyComparison: WeeklyComparison.fromJson(
          json['weeklyComparison'] as Map<String, dynamic>),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );

Map<String, dynamic> _$$HealthInsightsImplToJson(
        _$HealthInsightsImpl instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'keyInsights': instance.keyInsights,
      'suggestions': instance.suggestions,
      'statistics': instance.statistics.toJson(),
      'correlations': instance.correlations.map((e) => e.toJson()).toList(),
      'trends': instance.trends.toJson(),
      'weeklyComparison': instance.weeklyComparison.toJson(),
      'generatedAt': instance.generatedAt.toIso8601String(),
    };

_$HealthInsightsStatisticsImpl _$$HealthInsightsStatisticsImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthInsightsStatisticsImpl(
      avgSteps: (json['avgSteps'] as num).toDouble(),
      avgSleepHours: (json['avgSleepHours'] as num).toDouble(),
      avgCalories: (json['avgCalories'] as num).toDouble(),
      avgDistanceKm: (json['avgDistanceKm'] as num).toDouble(),
      avgHeartRate: (json['avgHeartRate'] as num?)?.toDouble(),
      avgMoodRating: (json['avgMoodRating'] as num?)?.toDouble(),
      avgEnergyLevel: (json['avgEnergyLevel'] as num?)?.toDouble(),
      daysWithData: (json['daysWithData'] as num).toInt(),
      totalWorkouts: (json['totalWorkouts'] as num).toInt(),
    );

Map<String, dynamic> _$$HealthInsightsStatisticsImplToJson(
        _$HealthInsightsStatisticsImpl instance) =>
    <String, dynamic>{
      'avgSteps': instance.avgSteps,
      'avgSleepHours': instance.avgSleepHours,
      'avgCalories': instance.avgCalories,
      'avgDistanceKm': instance.avgDistanceKm,
      'avgHeartRate': instance.avgHeartRate,
      'avgMoodRating': instance.avgMoodRating,
      'avgEnergyLevel': instance.avgEnergyLevel,
      'daysWithData': instance.daysWithData,
      'totalWorkouts': instance.totalWorkouts,
    };

_$HealthCorrelationImpl _$$HealthCorrelationImplFromJson(
        Map<String, dynamic> json) =>
    _$HealthCorrelationImpl(
      metric1: json['metric1'] as String,
      metric2: json['metric2'] as String,
      coefficient: (json['coefficient'] as num).toDouble(),
      strength: $enumDecode(_$CorrelationStrengthEnumMap, json['strength']),
      interpretation: json['interpretation'] as String,
    );

Map<String, dynamic> _$$HealthCorrelationImplToJson(
        _$HealthCorrelationImpl instance) =>
    <String, dynamic>{
      'metric1': instance.metric1,
      'metric2': instance.metric2,
      'coefficient': instance.coefficient,
      'strength': _$CorrelationStrengthEnumMap[instance.strength]!,
      'interpretation': instance.interpretation,
    };

const _$CorrelationStrengthEnumMap = {
  CorrelationStrength.strong: 'strong',
  CorrelationStrength.moderate: 'moderate',
  CorrelationStrength.weak: 'weak',
  CorrelationStrength.negligible: 'negligible',
};

_$HealthTrendsImpl _$$HealthTrendsImplFromJson(Map<String, dynamic> json) =>
    _$HealthTrendsImpl(
      steps: $enumDecode(_$TrendDirectionEnumMap, json['steps']),
      sleep: $enumDecode(_$TrendDirectionEnumMap, json['sleep']),
      calories: $enumDecode(_$TrendDirectionEnumMap, json['calories']),
      activity: $enumDecode(_$TrendDirectionEnumMap, json['activity']),
      mood: $enumDecodeNullable(_$TrendDirectionEnumMap, json['mood']),
      energy: $enumDecodeNullable(_$TrendDirectionEnumMap, json['energy']),
      weight: $enumDecodeNullable(_$TrendDirectionEnumMap, json['weight']),
    );

Map<String, dynamic> _$$HealthTrendsImplToJson(_$HealthTrendsImpl instance) =>
    <String, dynamic>{
      'steps': _$TrendDirectionEnumMap[instance.steps]!,
      'sleep': _$TrendDirectionEnumMap[instance.sleep]!,
      'calories': _$TrendDirectionEnumMap[instance.calories]!,
      'activity': _$TrendDirectionEnumMap[instance.activity]!,
      'mood': _$TrendDirectionEnumMap[instance.mood],
      'energy': _$TrendDirectionEnumMap[instance.energy],
      'weight': _$TrendDirectionEnumMap[instance.weight],
    };

const _$TrendDirectionEnumMap = {
  TrendDirection.improving: 'improving',
  TrendDirection.stable: 'stable',
  TrendDirection.declining: 'declining',
  TrendDirection.insufficient: 'insufficient',
};

_$WeeklyComparisonImpl _$$WeeklyComparisonImplFromJson(
        Map<String, dynamic> json) =>
    _$WeeklyComparisonImpl(
      stepsChange: (json['stepsChange'] as num).toDouble(),
      sleepChange: (json['sleepChange'] as num).toDouble(),
      caloriesChange: (json['caloriesChange'] as num).toDouble(),
      distanceChange: (json['distanceChange'] as num).toDouble(),
      workoutsThisWeek: (json['workoutsThisWeek'] as num).toInt(),
      workoutsLastWeek: (json['workoutsLastWeek'] as num).toInt(),
      moodChange: (json['moodChange'] as num?)?.toDouble(),
      energyChange: (json['energyChange'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$WeeklyComparisonImplToJson(
        _$WeeklyComparisonImpl instance) =>
    <String, dynamic>{
      'stepsChange': instance.stepsChange,
      'sleepChange': instance.sleepChange,
      'caloriesChange': instance.caloriesChange,
      'distanceChange': instance.distanceChange,
      'workoutsThisWeek': instance.workoutsThisWeek,
      'workoutsLastWeek': instance.workoutsLastWeek,
      'moodChange': instance.moodChange,
      'energyChange': instance.energyChange,
    };
