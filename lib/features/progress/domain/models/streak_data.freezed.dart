// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StreakData _$StreakDataFromJson(Map<String, dynamic> json) {
  return _StreakData.fromJson(json);
}

/// @nodoc
mixin _$StreakData {
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  int get totalActiveDays => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get lastActiveDate => throw _privateConstructorUsedError;
  List<DateTime> get activeDatesThisMonth => throw _privateConstructorUsedError;
  int get graceDays => throw _privateConstructorUsedError;

  /// Serializes this StreakData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakDataCopyWith<StreakData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakDataCopyWith<$Res> {
  factory $StreakDataCopyWith(
          StreakData value, $Res Function(StreakData) then) =
      _$StreakDataCopyWithImpl<$Res, StreakData>;
  @useResult
  $Res call(
      {int currentStreak,
      int longestStreak,
      int totalActiveDays,
      @NullableTimestampConverter() DateTime? lastActiveDate,
      List<DateTime> activeDatesThisMonth,
      int graceDays});
}

/// @nodoc
class _$StreakDataCopyWithImpl<$Res, $Val extends StreakData>
    implements $StreakDataCopyWith<$Res> {
  _$StreakDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalActiveDays = null,
    Object? lastActiveDate = freezed,
    Object? activeDatesThisMonth = null,
    Object? graceDays = null,
  }) {
    return _then(_value.copyWith(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalActiveDays: null == totalActiveDays
          ? _value.totalActiveDays
          : totalActiveDays // ignore: cast_nullable_to_non_nullable
              as int,
      lastActiveDate: freezed == lastActiveDate
          ? _value.lastActiveDate
          : lastActiveDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeDatesThisMonth: null == activeDatesThisMonth
          ? _value.activeDatesThisMonth
          : activeDatesThisMonth // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      graceDays: null == graceDays
          ? _value.graceDays
          : graceDays // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakDataImplCopyWith<$Res>
    implements $StreakDataCopyWith<$Res> {
  factory _$$StreakDataImplCopyWith(
          _$StreakDataImpl value, $Res Function(_$StreakDataImpl) then) =
      __$$StreakDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int currentStreak,
      int longestStreak,
      int totalActiveDays,
      @NullableTimestampConverter() DateTime? lastActiveDate,
      List<DateTime> activeDatesThisMonth,
      int graceDays});
}

/// @nodoc
class __$$StreakDataImplCopyWithImpl<$Res>
    extends _$StreakDataCopyWithImpl<$Res, _$StreakDataImpl>
    implements _$$StreakDataImplCopyWith<$Res> {
  __$$StreakDataImplCopyWithImpl(
      _$StreakDataImpl _value, $Res Function(_$StreakDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalActiveDays = null,
    Object? lastActiveDate = freezed,
    Object? activeDatesThisMonth = null,
    Object? graceDays = null,
  }) {
    return _then(_$StreakDataImpl(
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalActiveDays: null == totalActiveDays
          ? _value.totalActiveDays
          : totalActiveDays // ignore: cast_nullable_to_non_nullable
              as int,
      lastActiveDate: freezed == lastActiveDate
          ? _value.lastActiveDate
          : lastActiveDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeDatesThisMonth: null == activeDatesThisMonth
          ? _value._activeDatesThisMonth
          : activeDatesThisMonth // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      graceDays: null == graceDays
          ? _value.graceDays
          : graceDays // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakDataImpl extends _StreakData {
  const _$StreakDataImpl(
      {required this.currentStreak,
      required this.longestStreak,
      required this.totalActiveDays,
      @NullableTimestampConverter() this.lastActiveDate,
      final List<DateTime> activeDatesThisMonth = const [],
      this.graceDays = 1})
      : _activeDatesThisMonth = activeDatesThisMonth,
        super._();

  factory _$StreakDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakDataImplFromJson(json);

  @override
  final int currentStreak;
  @override
  final int longestStreak;
  @override
  final int totalActiveDays;
  @override
  @NullableTimestampConverter()
  final DateTime? lastActiveDate;
  final List<DateTime> _activeDatesThisMonth;
  @override
  @JsonKey()
  List<DateTime> get activeDatesThisMonth {
    if (_activeDatesThisMonth is EqualUnmodifiableListView)
      return _activeDatesThisMonth;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeDatesThisMonth);
  }

  @override
  @JsonKey()
  final int graceDays;

  @override
  String toString() {
    return 'StreakData(currentStreak: $currentStreak, longestStreak: $longestStreak, totalActiveDays: $totalActiveDays, lastActiveDate: $lastActiveDate, activeDatesThisMonth: $activeDatesThisMonth, graceDays: $graceDays)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakDataImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.totalActiveDays, totalActiveDays) ||
                other.totalActiveDays == totalActiveDays) &&
            (identical(other.lastActiveDate, lastActiveDate) ||
                other.lastActiveDate == lastActiveDate) &&
            const DeepCollectionEquality()
                .equals(other._activeDatesThisMonth, _activeDatesThisMonth) &&
            (identical(other.graceDays, graceDays) ||
                other.graceDays == graceDays));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      currentStreak,
      longestStreak,
      totalActiveDays,
      lastActiveDate,
      const DeepCollectionEquality().hash(_activeDatesThisMonth),
      graceDays);

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakDataImplCopyWith<_$StreakDataImpl> get copyWith =>
      __$$StreakDataImplCopyWithImpl<_$StreakDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakDataImplToJson(
      this,
    );
  }
}

abstract class _StreakData extends StreakData {
  const factory _StreakData(
      {required final int currentStreak,
      required final int longestStreak,
      required final int totalActiveDays,
      @NullableTimestampConverter() final DateTime? lastActiveDate,
      final List<DateTime> activeDatesThisMonth,
      final int graceDays}) = _$StreakDataImpl;
  const _StreakData._() : super._();

  factory _StreakData.fromJson(Map<String, dynamic> json) =
      _$StreakDataImpl.fromJson;

  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  int get totalActiveDays;
  @override
  @NullableTimestampConverter()
  DateTime? get lastActiveDate;
  @override
  List<DateTime> get activeDatesThisMonth;
  @override
  int get graceDays;

  /// Create a copy of StreakData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakDataImplCopyWith<_$StreakDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityDay _$ActivityDayFromJson(Map<String, dynamic> json) {
  return _ActivityDay.fromJson(json);
}

/// @nodoc
mixin _$ActivityDay {
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  int get workoutCount => throw _privateConstructorUsedError;
  int get habitsCompleted => throw _privateConstructorUsedError;
  int get habitsTotal => throw _privateConstructorUsedError;
  bool get weightLogged => throw _privateConstructorUsedError;
  bool get measurementsLogged => throw _privateConstructorUsedError;
  int get activityScore => throw _privateConstructorUsedError;

  /// Serializes this ActivityDay to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityDayCopyWith<ActivityDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityDayCopyWith<$Res> {
  factory $ActivityDayCopyWith(
          ActivityDay value, $Res Function(ActivityDay) then) =
      _$ActivityDayCopyWithImpl<$Res, ActivityDay>;
  @useResult
  $Res call(
      {@TimestampConverter() DateTime date,
      int workoutCount,
      int habitsCompleted,
      int habitsTotal,
      bool weightLogged,
      bool measurementsLogged,
      int activityScore});
}

/// @nodoc
class _$ActivityDayCopyWithImpl<$Res, $Val extends ActivityDay>
    implements $ActivityDayCopyWith<$Res> {
  _$ActivityDayCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? workoutCount = null,
    Object? habitsCompleted = null,
    Object? habitsTotal = null,
    Object? weightLogged = null,
    Object? measurementsLogged = null,
    Object? activityScore = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      habitsCompleted: null == habitsCompleted
          ? _value.habitsCompleted
          : habitsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      habitsTotal: null == habitsTotal
          ? _value.habitsTotal
          : habitsTotal // ignore: cast_nullable_to_non_nullable
              as int,
      weightLogged: null == weightLogged
          ? _value.weightLogged
          : weightLogged // ignore: cast_nullable_to_non_nullable
              as bool,
      measurementsLogged: null == measurementsLogged
          ? _value.measurementsLogged
          : measurementsLogged // ignore: cast_nullable_to_non_nullable
              as bool,
      activityScore: null == activityScore
          ? _value.activityScore
          : activityScore // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ActivityDayImplCopyWith<$Res>
    implements $ActivityDayCopyWith<$Res> {
  factory _$$ActivityDayImplCopyWith(
          _$ActivityDayImpl value, $Res Function(_$ActivityDayImpl) then) =
      __$$ActivityDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@TimestampConverter() DateTime date,
      int workoutCount,
      int habitsCompleted,
      int habitsTotal,
      bool weightLogged,
      bool measurementsLogged,
      int activityScore});
}

/// @nodoc
class __$$ActivityDayImplCopyWithImpl<$Res>
    extends _$ActivityDayCopyWithImpl<$Res, _$ActivityDayImpl>
    implements _$$ActivityDayImplCopyWith<$Res> {
  __$$ActivityDayImplCopyWithImpl(
      _$ActivityDayImpl _value, $Res Function(_$ActivityDayImpl) _then)
      : super(_value, _then);

  /// Create a copy of ActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? workoutCount = null,
    Object? habitsCompleted = null,
    Object? habitsTotal = null,
    Object? weightLogged = null,
    Object? measurementsLogged = null,
    Object? activityScore = null,
  }) {
    return _then(_$ActivityDayImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      habitsCompleted: null == habitsCompleted
          ? _value.habitsCompleted
          : habitsCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      habitsTotal: null == habitsTotal
          ? _value.habitsTotal
          : habitsTotal // ignore: cast_nullable_to_non_nullable
              as int,
      weightLogged: null == weightLogged
          ? _value.weightLogged
          : weightLogged // ignore: cast_nullable_to_non_nullable
              as bool,
      measurementsLogged: null == measurementsLogged
          ? _value.measurementsLogged
          : measurementsLogged // ignore: cast_nullable_to_non_nullable
              as bool,
      activityScore: null == activityScore
          ? _value.activityScore
          : activityScore // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityDayImpl extends _ActivityDay {
  const _$ActivityDayImpl(
      {@TimestampConverter() required this.date,
      required this.workoutCount,
      required this.habitsCompleted,
      required this.habitsTotal,
      required this.weightLogged,
      required this.measurementsLogged,
      this.activityScore = 0})
      : super._();

  factory _$ActivityDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityDayImplFromJson(json);

  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final int workoutCount;
  @override
  final int habitsCompleted;
  @override
  final int habitsTotal;
  @override
  final bool weightLogged;
  @override
  final bool measurementsLogged;
  @override
  @JsonKey()
  final int activityScore;

  @override
  String toString() {
    return 'ActivityDay(date: $date, workoutCount: $workoutCount, habitsCompleted: $habitsCompleted, habitsTotal: $habitsTotal, weightLogged: $weightLogged, measurementsLogged: $measurementsLogged, activityScore: $activityScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityDayImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.workoutCount, workoutCount) ||
                other.workoutCount == workoutCount) &&
            (identical(other.habitsCompleted, habitsCompleted) ||
                other.habitsCompleted == habitsCompleted) &&
            (identical(other.habitsTotal, habitsTotal) ||
                other.habitsTotal == habitsTotal) &&
            (identical(other.weightLogged, weightLogged) ||
                other.weightLogged == weightLogged) &&
            (identical(other.measurementsLogged, measurementsLogged) ||
                other.measurementsLogged == measurementsLogged) &&
            (identical(other.activityScore, activityScore) ||
                other.activityScore == activityScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      workoutCount,
      habitsCompleted,
      habitsTotal,
      weightLogged,
      measurementsLogged,
      activityScore);

  /// Create a copy of ActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityDayImplCopyWith<_$ActivityDayImpl> get copyWith =>
      __$$ActivityDayImplCopyWithImpl<_$ActivityDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityDayImplToJson(
      this,
    );
  }
}

abstract class _ActivityDay extends ActivityDay {
  const factory _ActivityDay(
      {@TimestampConverter() required final DateTime date,
      required final int workoutCount,
      required final int habitsCompleted,
      required final int habitsTotal,
      required final bool weightLogged,
      required final bool measurementsLogged,
      final int activityScore}) = _$ActivityDayImpl;
  const _ActivityDay._() : super._();

  factory _ActivityDay.fromJson(Map<String, dynamic> json) =
      _$ActivityDayImpl.fromJson;

  @override
  @TimestampConverter()
  DateTime get date;
  @override
  int get workoutCount;
  @override
  int get habitsCompleted;
  @override
  int get habitsTotal;
  @override
  bool get weightLogged;
  @override
  bool get measurementsLogged;
  @override
  int get activityScore;

  /// Create a copy of ActivityDay
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityDayImplCopyWith<_$ActivityDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
