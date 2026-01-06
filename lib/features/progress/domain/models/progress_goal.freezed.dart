// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgressGoal _$ProgressGoalFromJson(Map<String, dynamic> json) {
  return _ProgressGoal.fromJson(json);
}

/// @nodoc
mixin _$ProgressGoal {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  GoalType get type => throw _privateConstructorUsedError;
  double get startValue => throw _privateConstructorUsedError;
  double get targetValue => throw _privateConstructorUsedError;
  double get currentValue => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get startDate => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get targetDate => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get completedDate => throw _privateConstructorUsedError;
  GoalStatus get status => throw _privateConstructorUsedError;
  MeasurementType? get measurementType =>
      throw _privateConstructorUsedError; // If type is measurement
  String? get unit =>
      throw _privateConstructorUsedError; // e.g., 'kg', 'cm', 'glasses'
  String? get notes => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ProgressGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressGoalCopyWith<ProgressGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressGoalCopyWith<$Res> {
  factory $ProgressGoalCopyWith(
          ProgressGoal value, $Res Function(ProgressGoal) then) =
      _$ProgressGoalCopyWithImpl<$Res, ProgressGoal>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      GoalType type,
      double startValue,
      double targetValue,
      double currentValue,
      @TimestampConverter() DateTime startDate,
      @NullableTimestampConverter() DateTime? targetDate,
      @NullableTimestampConverter() DateTime? completedDate,
      GoalStatus status,
      MeasurementType? measurementType,
      String? unit,
      String? notes,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class _$ProgressGoalCopyWithImpl<$Res, $Val extends ProgressGoal>
    implements $ProgressGoalCopyWith<$Res> {
  _$ProgressGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? type = null,
    Object? startValue = null,
    Object? targetValue = null,
    Object? currentValue = null,
    Object? startDate = null,
    Object? targetDate = freezed,
    Object? completedDate = freezed,
    Object? status = null,
    Object? measurementType = freezed,
    Object? unit = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GoalType,
      startValue: null == startValue
          ? _value.startValue
          : startValue // ignore: cast_nullable_to_non_nullable
              as double,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      targetDate: freezed == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedDate: freezed == completedDate
          ? _value.completedDate
          : completedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GoalStatus,
      measurementType: freezed == measurementType
          ? _value.measurementType
          : measurementType // ignore: cast_nullable_to_non_nullable
              as MeasurementType?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressGoalImplCopyWith<$Res>
    implements $ProgressGoalCopyWith<$Res> {
  factory _$$ProgressGoalImplCopyWith(
          _$ProgressGoalImpl value, $Res Function(_$ProgressGoalImpl) then) =
      __$$ProgressGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String title,
      GoalType type,
      double startValue,
      double targetValue,
      double currentValue,
      @TimestampConverter() DateTime startDate,
      @NullableTimestampConverter() DateTime? targetDate,
      @NullableTimestampConverter() DateTime? completedDate,
      GoalStatus status,
      MeasurementType? measurementType,
      String? unit,
      String? notes,
      @TimestampConverter() DateTime createdAt});
}

/// @nodoc
class __$$ProgressGoalImplCopyWithImpl<$Res>
    extends _$ProgressGoalCopyWithImpl<$Res, _$ProgressGoalImpl>
    implements _$$ProgressGoalImplCopyWith<$Res> {
  __$$ProgressGoalImplCopyWithImpl(
      _$ProgressGoalImpl _value, $Res Function(_$ProgressGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgressGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? title = null,
    Object? type = null,
    Object? startValue = null,
    Object? targetValue = null,
    Object? currentValue = null,
    Object? startDate = null,
    Object? targetDate = freezed,
    Object? completedDate = freezed,
    Object? status = null,
    Object? measurementType = freezed,
    Object? unit = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$ProgressGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as GoalType,
      startValue: null == startValue
          ? _value.startValue
          : startValue // ignore: cast_nullable_to_non_nullable
              as double,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      targetDate: freezed == targetDate
          ? _value.targetDate
          : targetDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      completedDate: freezed == completedDate
          ? _value.completedDate
          : completedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GoalStatus,
      measurementType: freezed == measurementType
          ? _value.measurementType
          : measurementType // ignore: cast_nullable_to_non_nullable
              as MeasurementType?,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressGoalImpl extends _ProgressGoal {
  const _$ProgressGoalImpl(
      {required this.id,
      required this.userId,
      required this.title,
      required this.type,
      required this.startValue,
      required this.targetValue,
      required this.currentValue,
      @TimestampConverter() required this.startDate,
      @NullableTimestampConverter() this.targetDate,
      @NullableTimestampConverter() this.completedDate,
      this.status = GoalStatus.active,
      this.measurementType,
      this.unit,
      this.notes,
      @TimestampConverter() required this.createdAt})
      : super._();

  factory _$ProgressGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressGoalImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final GoalType type;
  @override
  final double startValue;
  @override
  final double targetValue;
  @override
  final double currentValue;
  @override
  @TimestampConverter()
  final DateTime startDate;
  @override
  @NullableTimestampConverter()
  final DateTime? targetDate;
  @override
  @NullableTimestampConverter()
  final DateTime? completedDate;
  @override
  @JsonKey()
  final GoalStatus status;
  @override
  final MeasurementType? measurementType;
// If type is measurement
  @override
  final String? unit;
// e.g., 'kg', 'cm', 'glasses'
  @override
  final String? notes;
  @override
  @TimestampConverter()
  final DateTime createdAt;

  @override
  String toString() {
    return 'ProgressGoal(id: $id, userId: $userId, title: $title, type: $type, startValue: $startValue, targetValue: $targetValue, currentValue: $currentValue, startDate: $startDate, targetDate: $targetDate, completedDate: $completedDate, status: $status, measurementType: $measurementType, unit: $unit, notes: $notes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startValue, startValue) ||
                other.startValue == startValue) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.targetDate, targetDate) ||
                other.targetDate == targetDate) &&
            (identical(other.completedDate, completedDate) ||
                other.completedDate == completedDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.measurementType, measurementType) ||
                other.measurementType == measurementType) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      title,
      type,
      startValue,
      targetValue,
      currentValue,
      startDate,
      targetDate,
      completedDate,
      status,
      measurementType,
      unit,
      notes,
      createdAt);

  /// Create a copy of ProgressGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressGoalImplCopyWith<_$ProgressGoalImpl> get copyWith =>
      __$$ProgressGoalImplCopyWithImpl<_$ProgressGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressGoalImplToJson(
      this,
    );
  }
}

abstract class _ProgressGoal extends ProgressGoal {
  const factory _ProgressGoal(
          {required final String id,
          required final String userId,
          required final String title,
          required final GoalType type,
          required final double startValue,
          required final double targetValue,
          required final double currentValue,
          @TimestampConverter() required final DateTime startDate,
          @NullableTimestampConverter() final DateTime? targetDate,
          @NullableTimestampConverter() final DateTime? completedDate,
          final GoalStatus status,
          final MeasurementType? measurementType,
          final String? unit,
          final String? notes,
          @TimestampConverter() required final DateTime createdAt}) =
      _$ProgressGoalImpl;
  const _ProgressGoal._() : super._();

  factory _ProgressGoal.fromJson(Map<String, dynamic> json) =
      _$ProgressGoalImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get title;
  @override
  GoalType get type;
  @override
  double get startValue;
  @override
  double get targetValue;
  @override
  double get currentValue;
  @override
  @TimestampConverter()
  DateTime get startDate;
  @override
  @NullableTimestampConverter()
  DateTime? get targetDate;
  @override
  @NullableTimestampConverter()
  DateTime? get completedDate;
  @override
  GoalStatus get status;
  @override
  MeasurementType? get measurementType; // If type is measurement
  @override
  String? get unit; // e.g., 'kg', 'cm', 'glasses'
  @override
  String? get notes;
  @override
  @TimestampConverter()
  DateTime get createdAt;

  /// Create a copy of ProgressGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressGoalImplCopyWith<_$ProgressGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
