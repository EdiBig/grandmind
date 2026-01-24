// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_insights.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthInsights _$HealthInsightsFromJson(Map<String, dynamic> json) {
  return _HealthInsights.fromJson(json);
}

/// @nodoc
mixin _$HealthInsights {
  String get summary => throw _privateConstructorUsedError;
  List<String> get keyInsights => throw _privateConstructorUsedError;
  List<String> get suggestions => throw _privateConstructorUsedError;
  HealthInsightsStatistics get statistics => throw _privateConstructorUsedError;
  List<HealthCorrelation> get correlations =>
      throw _privateConstructorUsedError;
  HealthTrends get trends => throw _privateConstructorUsedError;
  WeeklyComparison get weeklyComparison => throw _privateConstructorUsedError;
  DateTime get generatedAt => throw _privateConstructorUsedError;

  /// Serializes this HealthInsights to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthInsightsCopyWith<HealthInsights> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthInsightsCopyWith<$Res> {
  factory $HealthInsightsCopyWith(
          HealthInsights value, $Res Function(HealthInsights) then) =
      _$HealthInsightsCopyWithImpl<$Res, HealthInsights>;
  @useResult
  $Res call(
      {String summary,
      List<String> keyInsights,
      List<String> suggestions,
      HealthInsightsStatistics statistics,
      List<HealthCorrelation> correlations,
      HealthTrends trends,
      WeeklyComparison weeklyComparison,
      DateTime generatedAt});

  $HealthInsightsStatisticsCopyWith<$Res> get statistics;
  $HealthTrendsCopyWith<$Res> get trends;
  $WeeklyComparisonCopyWith<$Res> get weeklyComparison;
}

/// @nodoc
class _$HealthInsightsCopyWithImpl<$Res, $Val extends HealthInsights>
    implements $HealthInsightsCopyWith<$Res> {
  _$HealthInsightsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? keyInsights = null,
    Object? suggestions = null,
    Object? statistics = null,
    Object? correlations = null,
    Object? trends = null,
    Object? weeklyComparison = null,
    Object? generatedAt = null,
  }) {
    return _then(_value.copyWith(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      keyInsights: null == keyInsights
          ? _value.keyInsights
          : keyInsights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      suggestions: null == suggestions
          ? _value.suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      statistics: null == statistics
          ? _value.statistics
          : statistics // ignore: cast_nullable_to_non_nullable
              as HealthInsightsStatistics,
      correlations: null == correlations
          ? _value.correlations
          : correlations // ignore: cast_nullable_to_non_nullable
              as List<HealthCorrelation>,
      trends: null == trends
          ? _value.trends
          : trends // ignore: cast_nullable_to_non_nullable
              as HealthTrends,
      weeklyComparison: null == weeklyComparison
          ? _value.weeklyComparison
          : weeklyComparison // ignore: cast_nullable_to_non_nullable
              as WeeklyComparison,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of HealthInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthInsightsStatisticsCopyWith<$Res> get statistics {
    return $HealthInsightsStatisticsCopyWith<$Res>(_value.statistics, (value) {
      return _then(_value.copyWith(statistics: value) as $Val);
    });
  }

  /// Create a copy of HealthInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthTrendsCopyWith<$Res> get trends {
    return $HealthTrendsCopyWith<$Res>(_value.trends, (value) {
      return _then(_value.copyWith(trends: value) as $Val);
    });
  }

  /// Create a copy of HealthInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WeeklyComparisonCopyWith<$Res> get weeklyComparison {
    return $WeeklyComparisonCopyWith<$Res>(_value.weeklyComparison, (value) {
      return _then(_value.copyWith(weeklyComparison: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HealthInsightsImplCopyWith<$Res>
    implements $HealthInsightsCopyWith<$Res> {
  factory _$$HealthInsightsImplCopyWith(_$HealthInsightsImpl value,
          $Res Function(_$HealthInsightsImpl) then) =
      __$$HealthInsightsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String summary,
      List<String> keyInsights,
      List<String> suggestions,
      HealthInsightsStatistics statistics,
      List<HealthCorrelation> correlations,
      HealthTrends trends,
      WeeklyComparison weeklyComparison,
      DateTime generatedAt});

  @override
  $HealthInsightsStatisticsCopyWith<$Res> get statistics;
  @override
  $HealthTrendsCopyWith<$Res> get trends;
  @override
  $WeeklyComparisonCopyWith<$Res> get weeklyComparison;
}

/// @nodoc
class __$$HealthInsightsImplCopyWithImpl<$Res>
    extends _$HealthInsightsCopyWithImpl<$Res, _$HealthInsightsImpl>
    implements _$$HealthInsightsImplCopyWith<$Res> {
  __$$HealthInsightsImplCopyWithImpl(
      _$HealthInsightsImpl _value, $Res Function(_$HealthInsightsImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? summary = null,
    Object? keyInsights = null,
    Object? suggestions = null,
    Object? statistics = null,
    Object? correlations = null,
    Object? trends = null,
    Object? weeklyComparison = null,
    Object? generatedAt = null,
  }) {
    return _then(_$HealthInsightsImpl(
      summary: null == summary
          ? _value.summary
          : summary // ignore: cast_nullable_to_non_nullable
              as String,
      keyInsights: null == keyInsights
          ? _value._keyInsights
          : keyInsights // ignore: cast_nullable_to_non_nullable
              as List<String>,
      suggestions: null == suggestions
          ? _value._suggestions
          : suggestions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      statistics: null == statistics
          ? _value.statistics
          : statistics // ignore: cast_nullable_to_non_nullable
              as HealthInsightsStatistics,
      correlations: null == correlations
          ? _value._correlations
          : correlations // ignore: cast_nullable_to_non_nullable
              as List<HealthCorrelation>,
      trends: null == trends
          ? _value.trends
          : trends // ignore: cast_nullable_to_non_nullable
              as HealthTrends,
      weeklyComparison: null == weeklyComparison
          ? _value.weeklyComparison
          : weeklyComparison // ignore: cast_nullable_to_non_nullable
              as WeeklyComparison,
      generatedAt: null == generatedAt
          ? _value.generatedAt
          : generatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthInsightsImpl implements _HealthInsights {
  const _$HealthInsightsImpl(
      {required this.summary,
      required final List<String> keyInsights,
      required final List<String> suggestions,
      required this.statistics,
      required final List<HealthCorrelation> correlations,
      required this.trends,
      required this.weeklyComparison,
      required this.generatedAt})
      : _keyInsights = keyInsights,
        _suggestions = suggestions,
        _correlations = correlations;

  factory _$HealthInsightsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthInsightsImplFromJson(json);

  @override
  final String summary;
  final List<String> _keyInsights;
  @override
  List<String> get keyInsights {
    if (_keyInsights is EqualUnmodifiableListView) return _keyInsights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keyInsights);
  }

  final List<String> _suggestions;
  @override
  List<String> get suggestions {
    if (_suggestions is EqualUnmodifiableListView) return _suggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_suggestions);
  }

  @override
  final HealthInsightsStatistics statistics;
  final List<HealthCorrelation> _correlations;
  @override
  List<HealthCorrelation> get correlations {
    if (_correlations is EqualUnmodifiableListView) return _correlations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_correlations);
  }

  @override
  final HealthTrends trends;
  @override
  final WeeklyComparison weeklyComparison;
  @override
  final DateTime generatedAt;

  @override
  String toString() {
    return 'HealthInsights(summary: $summary, keyInsights: $keyInsights, suggestions: $suggestions, statistics: $statistics, correlations: $correlations, trends: $trends, weeklyComparison: $weeklyComparison, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthInsightsImpl &&
            (identical(other.summary, summary) || other.summary == summary) &&
            const DeepCollectionEquality()
                .equals(other._keyInsights, _keyInsights) &&
            const DeepCollectionEquality()
                .equals(other._suggestions, _suggestions) &&
            (identical(other.statistics, statistics) ||
                other.statistics == statistics) &&
            const DeepCollectionEquality()
                .equals(other._correlations, _correlations) &&
            (identical(other.trends, trends) || other.trends == trends) &&
            (identical(other.weeklyComparison, weeklyComparison) ||
                other.weeklyComparison == weeklyComparison) &&
            (identical(other.generatedAt, generatedAt) ||
                other.generatedAt == generatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      summary,
      const DeepCollectionEquality().hash(_keyInsights),
      const DeepCollectionEquality().hash(_suggestions),
      statistics,
      const DeepCollectionEquality().hash(_correlations),
      trends,
      weeklyComparison,
      generatedAt);

  /// Create a copy of HealthInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthInsightsImplCopyWith<_$HealthInsightsImpl> get copyWith =>
      __$$HealthInsightsImplCopyWithImpl<_$HealthInsightsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthInsightsImplToJson(
      this,
    );
  }
}

abstract class _HealthInsights implements HealthInsights {
  const factory _HealthInsights(
      {required final String summary,
      required final List<String> keyInsights,
      required final List<String> suggestions,
      required final HealthInsightsStatistics statistics,
      required final List<HealthCorrelation> correlations,
      required final HealthTrends trends,
      required final WeeklyComparison weeklyComparison,
      required final DateTime generatedAt}) = _$HealthInsightsImpl;

  factory _HealthInsights.fromJson(Map<String, dynamic> json) =
      _$HealthInsightsImpl.fromJson;

  @override
  String get summary;
  @override
  List<String> get keyInsights;
  @override
  List<String> get suggestions;
  @override
  HealthInsightsStatistics get statistics;
  @override
  List<HealthCorrelation> get correlations;
  @override
  HealthTrends get trends;
  @override
  WeeklyComparison get weeklyComparison;
  @override
  DateTime get generatedAt;

  /// Create a copy of HealthInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthInsightsImplCopyWith<_$HealthInsightsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthInsightsStatistics _$HealthInsightsStatisticsFromJson(
    Map<String, dynamic> json) {
  return _HealthInsightsStatistics.fromJson(json);
}

/// @nodoc
mixin _$HealthInsightsStatistics {
  double get avgSteps => throw _privateConstructorUsedError;
  double get avgSleepHours => throw _privateConstructorUsedError;
  double get avgCalories => throw _privateConstructorUsedError;
  double get avgDistanceKm => throw _privateConstructorUsedError;
  double? get avgHeartRate => throw _privateConstructorUsedError;
  double? get avgMoodRating => throw _privateConstructorUsedError;
  double? get avgEnergyLevel => throw _privateConstructorUsedError;
  int get daysWithData => throw _privateConstructorUsedError;
  int get totalWorkouts => throw _privateConstructorUsedError;

  /// Serializes this HealthInsightsStatistics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthInsightsStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthInsightsStatisticsCopyWith<HealthInsightsStatistics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthInsightsStatisticsCopyWith<$Res> {
  factory $HealthInsightsStatisticsCopyWith(HealthInsightsStatistics value,
          $Res Function(HealthInsightsStatistics) then) =
      _$HealthInsightsStatisticsCopyWithImpl<$Res, HealthInsightsStatistics>;
  @useResult
  $Res call(
      {double avgSteps,
      double avgSleepHours,
      double avgCalories,
      double avgDistanceKm,
      double? avgHeartRate,
      double? avgMoodRating,
      double? avgEnergyLevel,
      int daysWithData,
      int totalWorkouts});
}

/// @nodoc
class _$HealthInsightsStatisticsCopyWithImpl<$Res,
        $Val extends HealthInsightsStatistics>
    implements $HealthInsightsStatisticsCopyWith<$Res> {
  _$HealthInsightsStatisticsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthInsightsStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgSteps = null,
    Object? avgSleepHours = null,
    Object? avgCalories = null,
    Object? avgDistanceKm = null,
    Object? avgHeartRate = freezed,
    Object? avgMoodRating = freezed,
    Object? avgEnergyLevel = freezed,
    Object? daysWithData = null,
    Object? totalWorkouts = null,
  }) {
    return _then(_value.copyWith(
      avgSteps: null == avgSteps
          ? _value.avgSteps
          : avgSteps // ignore: cast_nullable_to_non_nullable
              as double,
      avgSleepHours: null == avgSleepHours
          ? _value.avgSleepHours
          : avgSleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      avgCalories: null == avgCalories
          ? _value.avgCalories
          : avgCalories // ignore: cast_nullable_to_non_nullable
              as double,
      avgDistanceKm: null == avgDistanceKm
          ? _value.avgDistanceKm
          : avgDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      avgHeartRate: freezed == avgHeartRate
          ? _value.avgHeartRate
          : avgHeartRate // ignore: cast_nullable_to_non_nullable
              as double?,
      avgMoodRating: freezed == avgMoodRating
          ? _value.avgMoodRating
          : avgMoodRating // ignore: cast_nullable_to_non_nullable
              as double?,
      avgEnergyLevel: freezed == avgEnergyLevel
          ? _value.avgEnergyLevel
          : avgEnergyLevel // ignore: cast_nullable_to_non_nullable
              as double?,
      daysWithData: null == daysWithData
          ? _value.daysWithData
          : daysWithData // ignore: cast_nullable_to_non_nullable
              as int,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthInsightsStatisticsImplCopyWith<$Res>
    implements $HealthInsightsStatisticsCopyWith<$Res> {
  factory _$$HealthInsightsStatisticsImplCopyWith(
          _$HealthInsightsStatisticsImpl value,
          $Res Function(_$HealthInsightsStatisticsImpl) then) =
      __$$HealthInsightsStatisticsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double avgSteps,
      double avgSleepHours,
      double avgCalories,
      double avgDistanceKm,
      double? avgHeartRate,
      double? avgMoodRating,
      double? avgEnergyLevel,
      int daysWithData,
      int totalWorkouts});
}

/// @nodoc
class __$$HealthInsightsStatisticsImplCopyWithImpl<$Res>
    extends _$HealthInsightsStatisticsCopyWithImpl<$Res,
        _$HealthInsightsStatisticsImpl>
    implements _$$HealthInsightsStatisticsImplCopyWith<$Res> {
  __$$HealthInsightsStatisticsImplCopyWithImpl(
      _$HealthInsightsStatisticsImpl _value,
      $Res Function(_$HealthInsightsStatisticsImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthInsightsStatistics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgSteps = null,
    Object? avgSleepHours = null,
    Object? avgCalories = null,
    Object? avgDistanceKm = null,
    Object? avgHeartRate = freezed,
    Object? avgMoodRating = freezed,
    Object? avgEnergyLevel = freezed,
    Object? daysWithData = null,
    Object? totalWorkouts = null,
  }) {
    return _then(_$HealthInsightsStatisticsImpl(
      avgSteps: null == avgSteps
          ? _value.avgSteps
          : avgSteps // ignore: cast_nullable_to_non_nullable
              as double,
      avgSleepHours: null == avgSleepHours
          ? _value.avgSleepHours
          : avgSleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      avgCalories: null == avgCalories
          ? _value.avgCalories
          : avgCalories // ignore: cast_nullable_to_non_nullable
              as double,
      avgDistanceKm: null == avgDistanceKm
          ? _value.avgDistanceKm
          : avgDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      avgHeartRate: freezed == avgHeartRate
          ? _value.avgHeartRate
          : avgHeartRate // ignore: cast_nullable_to_non_nullable
              as double?,
      avgMoodRating: freezed == avgMoodRating
          ? _value.avgMoodRating
          : avgMoodRating // ignore: cast_nullable_to_non_nullable
              as double?,
      avgEnergyLevel: freezed == avgEnergyLevel
          ? _value.avgEnergyLevel
          : avgEnergyLevel // ignore: cast_nullable_to_non_nullable
              as double?,
      daysWithData: null == daysWithData
          ? _value.daysWithData
          : daysWithData // ignore: cast_nullable_to_non_nullable
              as int,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthInsightsStatisticsImpl implements _HealthInsightsStatistics {
  const _$HealthInsightsStatisticsImpl(
      {required this.avgSteps,
      required this.avgSleepHours,
      required this.avgCalories,
      required this.avgDistanceKm,
      this.avgHeartRate,
      this.avgMoodRating,
      this.avgEnergyLevel,
      required this.daysWithData,
      required this.totalWorkouts});

  factory _$HealthInsightsStatisticsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthInsightsStatisticsImplFromJson(json);

  @override
  final double avgSteps;
  @override
  final double avgSleepHours;
  @override
  final double avgCalories;
  @override
  final double avgDistanceKm;
  @override
  final double? avgHeartRate;
  @override
  final double? avgMoodRating;
  @override
  final double? avgEnergyLevel;
  @override
  final int daysWithData;
  @override
  final int totalWorkouts;

  @override
  String toString() {
    return 'HealthInsightsStatistics(avgSteps: $avgSteps, avgSleepHours: $avgSleepHours, avgCalories: $avgCalories, avgDistanceKm: $avgDistanceKm, avgHeartRate: $avgHeartRate, avgMoodRating: $avgMoodRating, avgEnergyLevel: $avgEnergyLevel, daysWithData: $daysWithData, totalWorkouts: $totalWorkouts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthInsightsStatisticsImpl &&
            (identical(other.avgSteps, avgSteps) ||
                other.avgSteps == avgSteps) &&
            (identical(other.avgSleepHours, avgSleepHours) ||
                other.avgSleepHours == avgSleepHours) &&
            (identical(other.avgCalories, avgCalories) ||
                other.avgCalories == avgCalories) &&
            (identical(other.avgDistanceKm, avgDistanceKm) ||
                other.avgDistanceKm == avgDistanceKm) &&
            (identical(other.avgHeartRate, avgHeartRate) ||
                other.avgHeartRate == avgHeartRate) &&
            (identical(other.avgMoodRating, avgMoodRating) ||
                other.avgMoodRating == avgMoodRating) &&
            (identical(other.avgEnergyLevel, avgEnergyLevel) ||
                other.avgEnergyLevel == avgEnergyLevel) &&
            (identical(other.daysWithData, daysWithData) ||
                other.daysWithData == daysWithData) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      avgSteps,
      avgSleepHours,
      avgCalories,
      avgDistanceKm,
      avgHeartRate,
      avgMoodRating,
      avgEnergyLevel,
      daysWithData,
      totalWorkouts);

  /// Create a copy of HealthInsightsStatistics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthInsightsStatisticsImplCopyWith<_$HealthInsightsStatisticsImpl>
      get copyWith => __$$HealthInsightsStatisticsImplCopyWithImpl<
          _$HealthInsightsStatisticsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthInsightsStatisticsImplToJson(
      this,
    );
  }
}

abstract class _HealthInsightsStatistics implements HealthInsightsStatistics {
  const factory _HealthInsightsStatistics(
      {required final double avgSteps,
      required final double avgSleepHours,
      required final double avgCalories,
      required final double avgDistanceKm,
      final double? avgHeartRate,
      final double? avgMoodRating,
      final double? avgEnergyLevel,
      required final int daysWithData,
      required final int totalWorkouts}) = _$HealthInsightsStatisticsImpl;

  factory _HealthInsightsStatistics.fromJson(Map<String, dynamic> json) =
      _$HealthInsightsStatisticsImpl.fromJson;

  @override
  double get avgSteps;
  @override
  double get avgSleepHours;
  @override
  double get avgCalories;
  @override
  double get avgDistanceKm;
  @override
  double? get avgHeartRate;
  @override
  double? get avgMoodRating;
  @override
  double? get avgEnergyLevel;
  @override
  int get daysWithData;
  @override
  int get totalWorkouts;

  /// Create a copy of HealthInsightsStatistics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthInsightsStatisticsImplCopyWith<_$HealthInsightsStatisticsImpl>
      get copyWith => throw _privateConstructorUsedError;
}

HealthCorrelation _$HealthCorrelationFromJson(Map<String, dynamic> json) {
  return _HealthCorrelation.fromJson(json);
}

/// @nodoc
mixin _$HealthCorrelation {
  String get metric1 => throw _privateConstructorUsedError;
  String get metric2 => throw _privateConstructorUsedError;
  double get coefficient => throw _privateConstructorUsedError;
  CorrelationStrength get strength => throw _privateConstructorUsedError;
  String get interpretation => throw _privateConstructorUsedError;

  /// Serializes this HealthCorrelation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthCorrelation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthCorrelationCopyWith<HealthCorrelation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthCorrelationCopyWith<$Res> {
  factory $HealthCorrelationCopyWith(
          HealthCorrelation value, $Res Function(HealthCorrelation) then) =
      _$HealthCorrelationCopyWithImpl<$Res, HealthCorrelation>;
  @useResult
  $Res call(
      {String metric1,
      String metric2,
      double coefficient,
      CorrelationStrength strength,
      String interpretation});
}

/// @nodoc
class _$HealthCorrelationCopyWithImpl<$Res, $Val extends HealthCorrelation>
    implements $HealthCorrelationCopyWith<$Res> {
  _$HealthCorrelationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthCorrelation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric1 = null,
    Object? metric2 = null,
    Object? coefficient = null,
    Object? strength = null,
    Object? interpretation = null,
  }) {
    return _then(_value.copyWith(
      metric1: null == metric1
          ? _value.metric1
          : metric1 // ignore: cast_nullable_to_non_nullable
              as String,
      metric2: null == metric2
          ? _value.metric2
          : metric2 // ignore: cast_nullable_to_non_nullable
              as String,
      coefficient: null == coefficient
          ? _value.coefficient
          : coefficient // ignore: cast_nullable_to_non_nullable
              as double,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as CorrelationStrength,
      interpretation: null == interpretation
          ? _value.interpretation
          : interpretation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthCorrelationImplCopyWith<$Res>
    implements $HealthCorrelationCopyWith<$Res> {
  factory _$$HealthCorrelationImplCopyWith(_$HealthCorrelationImpl value,
          $Res Function(_$HealthCorrelationImpl) then) =
      __$$HealthCorrelationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String metric1,
      String metric2,
      double coefficient,
      CorrelationStrength strength,
      String interpretation});
}

/// @nodoc
class __$$HealthCorrelationImplCopyWithImpl<$Res>
    extends _$HealthCorrelationCopyWithImpl<$Res, _$HealthCorrelationImpl>
    implements _$$HealthCorrelationImplCopyWith<$Res> {
  __$$HealthCorrelationImplCopyWithImpl(_$HealthCorrelationImpl _value,
      $Res Function(_$HealthCorrelationImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthCorrelation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? metric1 = null,
    Object? metric2 = null,
    Object? coefficient = null,
    Object? strength = null,
    Object? interpretation = null,
  }) {
    return _then(_$HealthCorrelationImpl(
      metric1: null == metric1
          ? _value.metric1
          : metric1 // ignore: cast_nullable_to_non_nullable
              as String,
      metric2: null == metric2
          ? _value.metric2
          : metric2 // ignore: cast_nullable_to_non_nullable
              as String,
      coefficient: null == coefficient
          ? _value.coefficient
          : coefficient // ignore: cast_nullable_to_non_nullable
              as double,
      strength: null == strength
          ? _value.strength
          : strength // ignore: cast_nullable_to_non_nullable
              as CorrelationStrength,
      interpretation: null == interpretation
          ? _value.interpretation
          : interpretation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthCorrelationImpl implements _HealthCorrelation {
  const _$HealthCorrelationImpl(
      {required this.metric1,
      required this.metric2,
      required this.coefficient,
      required this.strength,
      required this.interpretation});

  factory _$HealthCorrelationImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthCorrelationImplFromJson(json);

  @override
  final String metric1;
  @override
  final String metric2;
  @override
  final double coefficient;
  @override
  final CorrelationStrength strength;
  @override
  final String interpretation;

  @override
  String toString() {
    return 'HealthCorrelation(metric1: $metric1, metric2: $metric2, coefficient: $coefficient, strength: $strength, interpretation: $interpretation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthCorrelationImpl &&
            (identical(other.metric1, metric1) || other.metric1 == metric1) &&
            (identical(other.metric2, metric2) || other.metric2 == metric2) &&
            (identical(other.coefficient, coefficient) ||
                other.coefficient == coefficient) &&
            (identical(other.strength, strength) ||
                other.strength == strength) &&
            (identical(other.interpretation, interpretation) ||
                other.interpretation == interpretation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, metric1, metric2, coefficient, strength, interpretation);

  /// Create a copy of HealthCorrelation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthCorrelationImplCopyWith<_$HealthCorrelationImpl> get copyWith =>
      __$$HealthCorrelationImplCopyWithImpl<_$HealthCorrelationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthCorrelationImplToJson(
      this,
    );
  }
}

abstract class _HealthCorrelation implements HealthCorrelation {
  const factory _HealthCorrelation(
      {required final String metric1,
      required final String metric2,
      required final double coefficient,
      required final CorrelationStrength strength,
      required final String interpretation}) = _$HealthCorrelationImpl;

  factory _HealthCorrelation.fromJson(Map<String, dynamic> json) =
      _$HealthCorrelationImpl.fromJson;

  @override
  String get metric1;
  @override
  String get metric2;
  @override
  double get coefficient;
  @override
  CorrelationStrength get strength;
  @override
  String get interpretation;

  /// Create a copy of HealthCorrelation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthCorrelationImplCopyWith<_$HealthCorrelationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HealthTrends _$HealthTrendsFromJson(Map<String, dynamic> json) {
  return _HealthTrends.fromJson(json);
}

/// @nodoc
mixin _$HealthTrends {
  TrendDirection get steps => throw _privateConstructorUsedError;
  TrendDirection get sleep => throw _privateConstructorUsedError;
  TrendDirection get calories => throw _privateConstructorUsedError;
  TrendDirection get activity => throw _privateConstructorUsedError;
  TrendDirection? get mood => throw _privateConstructorUsedError;
  TrendDirection? get energy => throw _privateConstructorUsedError;
  TrendDirection? get weight => throw _privateConstructorUsedError;

  /// Serializes this HealthTrends to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthTrends
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthTrendsCopyWith<HealthTrends> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthTrendsCopyWith<$Res> {
  factory $HealthTrendsCopyWith(
          HealthTrends value, $Res Function(HealthTrends) then) =
      _$HealthTrendsCopyWithImpl<$Res, HealthTrends>;
  @useResult
  $Res call(
      {TrendDirection steps,
      TrendDirection sleep,
      TrendDirection calories,
      TrendDirection activity,
      TrendDirection? mood,
      TrendDirection? energy,
      TrendDirection? weight});
}

/// @nodoc
class _$HealthTrendsCopyWithImpl<$Res, $Val extends HealthTrends>
    implements $HealthTrendsCopyWith<$Res> {
  _$HealthTrendsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthTrends
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? steps = null,
    Object? sleep = null,
    Object? calories = null,
    Object? activity = null,
    Object? mood = freezed,
    Object? energy = freezed,
    Object? weight = freezed,
  }) {
    return _then(_value.copyWith(
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      sleep: null == sleep
          ? _value.sleep
          : sleep // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      activity: null == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      mood: freezed == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as TrendDirection?,
      energy: freezed == energy
          ? _value.energy
          : energy // ignore: cast_nullable_to_non_nullable
              as TrendDirection?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as TrendDirection?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthTrendsImplCopyWith<$Res>
    implements $HealthTrendsCopyWith<$Res> {
  factory _$$HealthTrendsImplCopyWith(
          _$HealthTrendsImpl value, $Res Function(_$HealthTrendsImpl) then) =
      __$$HealthTrendsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TrendDirection steps,
      TrendDirection sleep,
      TrendDirection calories,
      TrendDirection activity,
      TrendDirection? mood,
      TrendDirection? energy,
      TrendDirection? weight});
}

/// @nodoc
class __$$HealthTrendsImplCopyWithImpl<$Res>
    extends _$HealthTrendsCopyWithImpl<$Res, _$HealthTrendsImpl>
    implements _$$HealthTrendsImplCopyWith<$Res> {
  __$$HealthTrendsImplCopyWithImpl(
      _$HealthTrendsImpl _value, $Res Function(_$HealthTrendsImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthTrends
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? steps = null,
    Object? sleep = null,
    Object? calories = null,
    Object? activity = null,
    Object? mood = freezed,
    Object? energy = freezed,
    Object? weight = freezed,
  }) {
    return _then(_$HealthTrendsImpl(
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      sleep: null == sleep
          ? _value.sleep
          : sleep // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      activity: null == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as TrendDirection,
      mood: freezed == mood
          ? _value.mood
          : mood // ignore: cast_nullable_to_non_nullable
              as TrendDirection?,
      energy: freezed == energy
          ? _value.energy
          : energy // ignore: cast_nullable_to_non_nullable
              as TrendDirection?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as TrendDirection?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthTrendsImpl implements _HealthTrends {
  const _$HealthTrendsImpl(
      {required this.steps,
      required this.sleep,
      required this.calories,
      required this.activity,
      this.mood,
      this.energy,
      this.weight});

  factory _$HealthTrendsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthTrendsImplFromJson(json);

  @override
  final TrendDirection steps;
  @override
  final TrendDirection sleep;
  @override
  final TrendDirection calories;
  @override
  final TrendDirection activity;
  @override
  final TrendDirection? mood;
  @override
  final TrendDirection? energy;
  @override
  final TrendDirection? weight;

  @override
  String toString() {
    return 'HealthTrends(steps: $steps, sleep: $sleep, calories: $calories, activity: $activity, mood: $mood, energy: $energy, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthTrendsImpl &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.sleep, sleep) || other.sleep == sleep) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.energy, energy) || other.energy == energy) &&
            (identical(other.weight, weight) || other.weight == weight));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, steps, sleep, calories, activity, mood, energy, weight);

  /// Create a copy of HealthTrends
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthTrendsImplCopyWith<_$HealthTrendsImpl> get copyWith =>
      __$$HealthTrendsImplCopyWithImpl<_$HealthTrendsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthTrendsImplToJson(
      this,
    );
  }
}

abstract class _HealthTrends implements HealthTrends {
  const factory _HealthTrends(
      {required final TrendDirection steps,
      required final TrendDirection sleep,
      required final TrendDirection calories,
      required final TrendDirection activity,
      final TrendDirection? mood,
      final TrendDirection? energy,
      final TrendDirection? weight}) = _$HealthTrendsImpl;

  factory _HealthTrends.fromJson(Map<String, dynamic> json) =
      _$HealthTrendsImpl.fromJson;

  @override
  TrendDirection get steps;
  @override
  TrendDirection get sleep;
  @override
  TrendDirection get calories;
  @override
  TrendDirection get activity;
  @override
  TrendDirection? get mood;
  @override
  TrendDirection? get energy;
  @override
  TrendDirection? get weight;

  /// Create a copy of HealthTrends
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthTrendsImplCopyWith<_$HealthTrendsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyComparison _$WeeklyComparisonFromJson(Map<String, dynamic> json) {
  return _WeeklyComparison.fromJson(json);
}

/// @nodoc
mixin _$WeeklyComparison {
  double get stepsChange =>
      throw _privateConstructorUsedError; // Percentage change
  double get sleepChange => throw _privateConstructorUsedError;
  double get caloriesChange => throw _privateConstructorUsedError;
  double get distanceChange => throw _privateConstructorUsedError;
  int get workoutsThisWeek => throw _privateConstructorUsedError;
  int get workoutsLastWeek => throw _privateConstructorUsedError;
  double? get moodChange => throw _privateConstructorUsedError;
  double? get energyChange => throw _privateConstructorUsedError;

  /// Serializes this WeeklyComparison to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyComparisonCopyWith<WeeklyComparison> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyComparisonCopyWith<$Res> {
  factory $WeeklyComparisonCopyWith(
          WeeklyComparison value, $Res Function(WeeklyComparison) then) =
      _$WeeklyComparisonCopyWithImpl<$Res, WeeklyComparison>;
  @useResult
  $Res call(
      {double stepsChange,
      double sleepChange,
      double caloriesChange,
      double distanceChange,
      int workoutsThisWeek,
      int workoutsLastWeek,
      double? moodChange,
      double? energyChange});
}

/// @nodoc
class _$WeeklyComparisonCopyWithImpl<$Res, $Val extends WeeklyComparison>
    implements $WeeklyComparisonCopyWith<$Res> {
  _$WeeklyComparisonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stepsChange = null,
    Object? sleepChange = null,
    Object? caloriesChange = null,
    Object? distanceChange = null,
    Object? workoutsThisWeek = null,
    Object? workoutsLastWeek = null,
    Object? moodChange = freezed,
    Object? energyChange = freezed,
  }) {
    return _then(_value.copyWith(
      stepsChange: null == stepsChange
          ? _value.stepsChange
          : stepsChange // ignore: cast_nullable_to_non_nullable
              as double,
      sleepChange: null == sleepChange
          ? _value.sleepChange
          : sleepChange // ignore: cast_nullable_to_non_nullable
              as double,
      caloriesChange: null == caloriesChange
          ? _value.caloriesChange
          : caloriesChange // ignore: cast_nullable_to_non_nullable
              as double,
      distanceChange: null == distanceChange
          ? _value.distanceChange
          : distanceChange // ignore: cast_nullable_to_non_nullable
              as double,
      workoutsThisWeek: null == workoutsThisWeek
          ? _value.workoutsThisWeek
          : workoutsThisWeek // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsLastWeek: null == workoutsLastWeek
          ? _value.workoutsLastWeek
          : workoutsLastWeek // ignore: cast_nullable_to_non_nullable
              as int,
      moodChange: freezed == moodChange
          ? _value.moodChange
          : moodChange // ignore: cast_nullable_to_non_nullable
              as double?,
      energyChange: freezed == energyChange
          ? _value.energyChange
          : energyChange // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyComparisonImplCopyWith<$Res>
    implements $WeeklyComparisonCopyWith<$Res> {
  factory _$$WeeklyComparisonImplCopyWith(_$WeeklyComparisonImpl value,
          $Res Function(_$WeeklyComparisonImpl) then) =
      __$$WeeklyComparisonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double stepsChange,
      double sleepChange,
      double caloriesChange,
      double distanceChange,
      int workoutsThisWeek,
      int workoutsLastWeek,
      double? moodChange,
      double? energyChange});
}

/// @nodoc
class __$$WeeklyComparisonImplCopyWithImpl<$Res>
    extends _$WeeklyComparisonCopyWithImpl<$Res, _$WeeklyComparisonImpl>
    implements _$$WeeklyComparisonImplCopyWith<$Res> {
  __$$WeeklyComparisonImplCopyWithImpl(_$WeeklyComparisonImpl _value,
      $Res Function(_$WeeklyComparisonImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeeklyComparison
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? stepsChange = null,
    Object? sleepChange = null,
    Object? caloriesChange = null,
    Object? distanceChange = null,
    Object? workoutsThisWeek = null,
    Object? workoutsLastWeek = null,
    Object? moodChange = freezed,
    Object? energyChange = freezed,
  }) {
    return _then(_$WeeklyComparisonImpl(
      stepsChange: null == stepsChange
          ? _value.stepsChange
          : stepsChange // ignore: cast_nullable_to_non_nullable
              as double,
      sleepChange: null == sleepChange
          ? _value.sleepChange
          : sleepChange // ignore: cast_nullable_to_non_nullable
              as double,
      caloriesChange: null == caloriesChange
          ? _value.caloriesChange
          : caloriesChange // ignore: cast_nullable_to_non_nullable
              as double,
      distanceChange: null == distanceChange
          ? _value.distanceChange
          : distanceChange // ignore: cast_nullable_to_non_nullable
              as double,
      workoutsThisWeek: null == workoutsThisWeek
          ? _value.workoutsThisWeek
          : workoutsThisWeek // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsLastWeek: null == workoutsLastWeek
          ? _value.workoutsLastWeek
          : workoutsLastWeek // ignore: cast_nullable_to_non_nullable
              as int,
      moodChange: freezed == moodChange
          ? _value.moodChange
          : moodChange // ignore: cast_nullable_to_non_nullable
              as double?,
      energyChange: freezed == energyChange
          ? _value.energyChange
          : energyChange // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyComparisonImpl implements _WeeklyComparison {
  const _$WeeklyComparisonImpl(
      {required this.stepsChange,
      required this.sleepChange,
      required this.caloriesChange,
      required this.distanceChange,
      required this.workoutsThisWeek,
      required this.workoutsLastWeek,
      this.moodChange,
      this.energyChange});

  factory _$WeeklyComparisonImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyComparisonImplFromJson(json);

  @override
  final double stepsChange;
// Percentage change
  @override
  final double sleepChange;
  @override
  final double caloriesChange;
  @override
  final double distanceChange;
  @override
  final int workoutsThisWeek;
  @override
  final int workoutsLastWeek;
  @override
  final double? moodChange;
  @override
  final double? energyChange;

  @override
  String toString() {
    return 'WeeklyComparison(stepsChange: $stepsChange, sleepChange: $sleepChange, caloriesChange: $caloriesChange, distanceChange: $distanceChange, workoutsThisWeek: $workoutsThisWeek, workoutsLastWeek: $workoutsLastWeek, moodChange: $moodChange, energyChange: $energyChange)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyComparisonImpl &&
            (identical(other.stepsChange, stepsChange) ||
                other.stepsChange == stepsChange) &&
            (identical(other.sleepChange, sleepChange) ||
                other.sleepChange == sleepChange) &&
            (identical(other.caloriesChange, caloriesChange) ||
                other.caloriesChange == caloriesChange) &&
            (identical(other.distanceChange, distanceChange) ||
                other.distanceChange == distanceChange) &&
            (identical(other.workoutsThisWeek, workoutsThisWeek) ||
                other.workoutsThisWeek == workoutsThisWeek) &&
            (identical(other.workoutsLastWeek, workoutsLastWeek) ||
                other.workoutsLastWeek == workoutsLastWeek) &&
            (identical(other.moodChange, moodChange) ||
                other.moodChange == moodChange) &&
            (identical(other.energyChange, energyChange) ||
                other.energyChange == energyChange));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      stepsChange,
      sleepChange,
      caloriesChange,
      distanceChange,
      workoutsThisWeek,
      workoutsLastWeek,
      moodChange,
      energyChange);

  /// Create a copy of WeeklyComparison
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyComparisonImplCopyWith<_$WeeklyComparisonImpl> get copyWith =>
      __$$WeeklyComparisonImplCopyWithImpl<_$WeeklyComparisonImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyComparisonImplToJson(
      this,
    );
  }
}

abstract class _WeeklyComparison implements WeeklyComparison {
  const factory _WeeklyComparison(
      {required final double stepsChange,
      required final double sleepChange,
      required final double caloriesChange,
      required final double distanceChange,
      required final int workoutsThisWeek,
      required final int workoutsLastWeek,
      final double? moodChange,
      final double? energyChange}) = _$WeeklyComparisonImpl;

  factory _WeeklyComparison.fromJson(Map<String, dynamic> json) =
      _$WeeklyComparisonImpl.fromJson;

  @override
  double get stepsChange; // Percentage change
  @override
  double get sleepChange;
  @override
  double get caloriesChange;
  @override
  double get distanceChange;
  @override
  int get workoutsThisWeek;
  @override
  int get workoutsLastWeek;
  @override
  double? get moodChange;
  @override
  double? get energyChange;

  /// Create a copy of WeeklyComparison
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyComparisonImplCopyWith<_$WeeklyComparisonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
