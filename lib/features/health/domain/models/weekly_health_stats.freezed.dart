// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_health_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeeklyHealthStats _$WeeklyHealthStatsFromJson(Map<String, dynamic> json) {
  return _WeeklyHealthStats.fromJson(json);
}

/// @nodoc
mixin _$WeeklyHealthStats {
  int get totalSteps => throw _privateConstructorUsedError;
  double get totalDistanceKm => throw _privateConstructorUsedError;
  double get totalCalories => throw _privateConstructorUsedError;
  double get averageHeartRate => throw _privateConstructorUsedError;
  double get averageSleepHours => throw _privateConstructorUsedError;
  int get daysWithData => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get weekStartDate => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get weekEndDate => throw _privateConstructorUsedError;

  /// Serializes this WeeklyHealthStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyHealthStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyHealthStatsCopyWith<WeeklyHealthStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyHealthStatsCopyWith<$Res> {
  factory $WeeklyHealthStatsCopyWith(
          WeeklyHealthStats value, $Res Function(WeeklyHealthStats) then) =
      _$WeeklyHealthStatsCopyWithImpl<$Res, WeeklyHealthStats>;
  @useResult
  $Res call(
      {int totalSteps,
      double totalDistanceKm,
      double totalCalories,
      double averageHeartRate,
      double averageSleepHours,
      int daysWithData,
      @TimestampConverter() DateTime weekStartDate,
      @TimestampConverter() DateTime weekEndDate});
}

/// @nodoc
class _$WeeklyHealthStatsCopyWithImpl<$Res, $Val extends WeeklyHealthStats>
    implements $WeeklyHealthStatsCopyWith<$Res> {
  _$WeeklyHealthStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyHealthStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSteps = null,
    Object? totalDistanceKm = null,
    Object? totalCalories = null,
    Object? averageHeartRate = null,
    Object? averageSleepHours = null,
    Object? daysWithData = null,
    Object? weekStartDate = null,
    Object? weekEndDate = null,
  }) {
    return _then(_value.copyWith(
      totalSteps: null == totalSteps
          ? _value.totalSteps
          : totalSteps // ignore: cast_nullable_to_non_nullable
              as int,
      totalDistanceKm: null == totalDistanceKm
          ? _value.totalDistanceKm
          : totalDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      totalCalories: null == totalCalories
          ? _value.totalCalories
          : totalCalories // ignore: cast_nullable_to_non_nullable
              as double,
      averageHeartRate: null == averageHeartRate
          ? _value.averageHeartRate
          : averageHeartRate // ignore: cast_nullable_to_non_nullable
              as double,
      averageSleepHours: null == averageSleepHours
          ? _value.averageSleepHours
          : averageSleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      daysWithData: null == daysWithData
          ? _value.daysWithData
          : daysWithData // ignore: cast_nullable_to_non_nullable
              as int,
      weekStartDate: null == weekStartDate
          ? _value.weekStartDate
          : weekStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEndDate: null == weekEndDate
          ? _value.weekEndDate
          : weekEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyHealthStatsImplCopyWith<$Res>
    implements $WeeklyHealthStatsCopyWith<$Res> {
  factory _$$WeeklyHealthStatsImplCopyWith(_$WeeklyHealthStatsImpl value,
          $Res Function(_$WeeklyHealthStatsImpl) then) =
      __$$WeeklyHealthStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int totalSteps,
      double totalDistanceKm,
      double totalCalories,
      double averageHeartRate,
      double averageSleepHours,
      int daysWithData,
      @TimestampConverter() DateTime weekStartDate,
      @TimestampConverter() DateTime weekEndDate});
}

/// @nodoc
class __$$WeeklyHealthStatsImplCopyWithImpl<$Res>
    extends _$WeeklyHealthStatsCopyWithImpl<$Res, _$WeeklyHealthStatsImpl>
    implements _$$WeeklyHealthStatsImplCopyWith<$Res> {
  __$$WeeklyHealthStatsImplCopyWithImpl(_$WeeklyHealthStatsImpl _value,
      $Res Function(_$WeeklyHealthStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeeklyHealthStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalSteps = null,
    Object? totalDistanceKm = null,
    Object? totalCalories = null,
    Object? averageHeartRate = null,
    Object? averageSleepHours = null,
    Object? daysWithData = null,
    Object? weekStartDate = null,
    Object? weekEndDate = null,
  }) {
    return _then(_$WeeklyHealthStatsImpl(
      totalSteps: null == totalSteps
          ? _value.totalSteps
          : totalSteps // ignore: cast_nullable_to_non_nullable
              as int,
      totalDistanceKm: null == totalDistanceKm
          ? _value.totalDistanceKm
          : totalDistanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      totalCalories: null == totalCalories
          ? _value.totalCalories
          : totalCalories // ignore: cast_nullable_to_non_nullable
              as double,
      averageHeartRate: null == averageHeartRate
          ? _value.averageHeartRate
          : averageHeartRate // ignore: cast_nullable_to_non_nullable
              as double,
      averageSleepHours: null == averageSleepHours
          ? _value.averageSleepHours
          : averageSleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      daysWithData: null == daysWithData
          ? _value.daysWithData
          : daysWithData // ignore: cast_nullable_to_non_nullable
              as int,
      weekStartDate: null == weekStartDate
          ? _value.weekStartDate
          : weekStartDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      weekEndDate: null == weekEndDate
          ? _value.weekEndDate
          : weekEndDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyHealthStatsImpl extends _WeeklyHealthStats {
  const _$WeeklyHealthStatsImpl(
      {required this.totalSteps,
      required this.totalDistanceKm,
      required this.totalCalories,
      required this.averageHeartRate,
      required this.averageSleepHours,
      required this.daysWithData,
      @TimestampConverter() required this.weekStartDate,
      @TimestampConverter() required this.weekEndDate})
      : super._();

  factory _$WeeklyHealthStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyHealthStatsImplFromJson(json);

  @override
  final int totalSteps;
  @override
  final double totalDistanceKm;
  @override
  final double totalCalories;
  @override
  final double averageHeartRate;
  @override
  final double averageSleepHours;
  @override
  final int daysWithData;
  @override
  @TimestampConverter()
  final DateTime weekStartDate;
  @override
  @TimestampConverter()
  final DateTime weekEndDate;

  @override
  String toString() {
    return 'WeeklyHealthStats(totalSteps: $totalSteps, totalDistanceKm: $totalDistanceKm, totalCalories: $totalCalories, averageHeartRate: $averageHeartRate, averageSleepHours: $averageSleepHours, daysWithData: $daysWithData, weekStartDate: $weekStartDate, weekEndDate: $weekEndDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyHealthStatsImpl &&
            (identical(other.totalSteps, totalSteps) ||
                other.totalSteps == totalSteps) &&
            (identical(other.totalDistanceKm, totalDistanceKm) ||
                other.totalDistanceKm == totalDistanceKm) &&
            (identical(other.totalCalories, totalCalories) ||
                other.totalCalories == totalCalories) &&
            (identical(other.averageHeartRate, averageHeartRate) ||
                other.averageHeartRate == averageHeartRate) &&
            (identical(other.averageSleepHours, averageSleepHours) ||
                other.averageSleepHours == averageSleepHours) &&
            (identical(other.daysWithData, daysWithData) ||
                other.daysWithData == daysWithData) &&
            (identical(other.weekStartDate, weekStartDate) ||
                other.weekStartDate == weekStartDate) &&
            (identical(other.weekEndDate, weekEndDate) ||
                other.weekEndDate == weekEndDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      totalSteps,
      totalDistanceKm,
      totalCalories,
      averageHeartRate,
      averageSleepHours,
      daysWithData,
      weekStartDate,
      weekEndDate);

  /// Create a copy of WeeklyHealthStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyHealthStatsImplCopyWith<_$WeeklyHealthStatsImpl> get copyWith =>
      __$$WeeklyHealthStatsImplCopyWithImpl<_$WeeklyHealthStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyHealthStatsImplToJson(
      this,
    );
  }
}

abstract class _WeeklyHealthStats extends WeeklyHealthStats {
  const factory _WeeklyHealthStats(
          {required final int totalSteps,
          required final double totalDistanceKm,
          required final double totalCalories,
          required final double averageHeartRate,
          required final double averageSleepHours,
          required final int daysWithData,
          @TimestampConverter() required final DateTime weekStartDate,
          @TimestampConverter() required final DateTime weekEndDate}) =
      _$WeeklyHealthStatsImpl;
  const _WeeklyHealthStats._() : super._();

  factory _WeeklyHealthStats.fromJson(Map<String, dynamic> json) =
      _$WeeklyHealthStatsImpl.fromJson;

  @override
  int get totalSteps;
  @override
  double get totalDistanceKm;
  @override
  double get totalCalories;
  @override
  double get averageHeartRate;
  @override
  double get averageSleepHours;
  @override
  int get daysWithData;
  @override
  @TimestampConverter()
  DateTime get weekStartDate;
  @override
  @TimestampConverter()
  DateTime get weekEndDate;

  /// Create a copy of WeeklyHealthStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyHealthStatsImplCopyWith<_$WeeklyHealthStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyHealthPoint _$DailyHealthPointFromJson(Map<String, dynamic> json) {
  return _DailyHealthPoint.fromJson(json);
}

/// @nodoc
mixin _$DailyHealthPoint {
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  int get steps => throw _privateConstructorUsedError;
  double get distanceKm => throw _privateConstructorUsedError;
  double get calories => throw _privateConstructorUsedError;
  double? get heartRate => throw _privateConstructorUsedError;
  double get sleepHours => throw _privateConstructorUsedError;

  /// Serializes this DailyHealthPoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyHealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyHealthPointCopyWith<DailyHealthPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyHealthPointCopyWith<$Res> {
  factory $DailyHealthPointCopyWith(
          DailyHealthPoint value, $Res Function(DailyHealthPoint) then) =
      _$DailyHealthPointCopyWithImpl<$Res, DailyHealthPoint>;
  @useResult
  $Res call(
      {@TimestampConverter() DateTime date,
      int steps,
      double distanceKm,
      double calories,
      double? heartRate,
      double sleepHours});
}

/// @nodoc
class _$DailyHealthPointCopyWithImpl<$Res, $Val extends DailyHealthPoint>
    implements $DailyHealthPointCopyWith<$Res> {
  _$DailyHealthPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyHealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? steps = null,
    Object? distanceKm = null,
    Object? calories = null,
    Object? heartRate = freezed,
    Object? sleepHours = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as double,
      heartRate: freezed == heartRate
          ? _value.heartRate
          : heartRate // ignore: cast_nullable_to_non_nullable
              as double?,
      sleepHours: null == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyHealthPointImplCopyWith<$Res>
    implements $DailyHealthPointCopyWith<$Res> {
  factory _$$DailyHealthPointImplCopyWith(_$DailyHealthPointImpl value,
          $Res Function(_$DailyHealthPointImpl) then) =
      __$$DailyHealthPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@TimestampConverter() DateTime date,
      int steps,
      double distanceKm,
      double calories,
      double? heartRate,
      double sleepHours});
}

/// @nodoc
class __$$DailyHealthPointImplCopyWithImpl<$Res>
    extends _$DailyHealthPointCopyWithImpl<$Res, _$DailyHealthPointImpl>
    implements _$$DailyHealthPointImplCopyWith<$Res> {
  __$$DailyHealthPointImplCopyWithImpl(_$DailyHealthPointImpl _value,
      $Res Function(_$DailyHealthPointImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyHealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? steps = null,
    Object? distanceKm = null,
    Object? calories = null,
    Object? heartRate = freezed,
    Object? sleepHours = null,
  }) {
    return _then(_$DailyHealthPointImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as double,
      heartRate: freezed == heartRate
          ? _value.heartRate
          : heartRate // ignore: cast_nullable_to_non_nullable
              as double?,
      sleepHours: null == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyHealthPointImpl implements _DailyHealthPoint {
  const _$DailyHealthPointImpl(
      {@TimestampConverter() required this.date,
      required this.steps,
      required this.distanceKm,
      required this.calories,
      this.heartRate,
      required this.sleepHours});

  factory _$DailyHealthPointImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyHealthPointImplFromJson(json);

  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final int steps;
  @override
  final double distanceKm;
  @override
  final double calories;
  @override
  final double? heartRate;
  @override
  final double sleepHours;

  @override
  String toString() {
    return 'DailyHealthPoint(date: $date, steps: $steps, distanceKm: $distanceKm, calories: $calories, heartRate: $heartRate, sleepHours: $sleepHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyHealthPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.heartRate, heartRate) ||
                other.heartRate == heartRate) &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, date, steps, distanceKm, calories, heartRate, sleepHours);

  /// Create a copy of DailyHealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyHealthPointImplCopyWith<_$DailyHealthPointImpl> get copyWith =>
      __$$DailyHealthPointImplCopyWithImpl<_$DailyHealthPointImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyHealthPointImplToJson(
      this,
    );
  }
}

abstract class _DailyHealthPoint implements DailyHealthPoint {
  const factory _DailyHealthPoint(
      {@TimestampConverter() required final DateTime date,
      required final int steps,
      required final double distanceKm,
      required final double calories,
      final double? heartRate,
      required final double sleepHours}) = _$DailyHealthPointImpl;

  factory _DailyHealthPoint.fromJson(Map<String, dynamic> json) =
      _$DailyHealthPointImpl.fromJson;

  @override
  @TimestampConverter()
  DateTime get date;
  @override
  int get steps;
  @override
  double get distanceKm;
  @override
  double get calories;
  @override
  double? get heartRate;
  @override
  double get sleepHours;

  /// Create a copy of DailyHealthPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyHealthPointImplCopyWith<_$DailyHealthPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
