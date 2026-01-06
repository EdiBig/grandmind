// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthData _$HealthDataFromJson(Map<String, dynamic> json) {
  return _HealthData.fromJson(json);
}

/// @nodoc
mixin _$HealthData {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError;
  int get steps => throw _privateConstructorUsedError;
  double get distanceMeters => throw _privateConstructorUsedError;
  double get caloriesBurned => throw _privateConstructorUsedError;
  double? get averageHeartRate => throw _privateConstructorUsedError;
  double get sleepHours => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get syncedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this HealthData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthDataCopyWith<HealthData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthDataCopyWith<$Res> {
  factory $HealthDataCopyWith(
          HealthData value, $Res Function(HealthData) then) =
      _$HealthDataCopyWithImpl<$Res, HealthData>;
  @useResult
  $Res call(
      {String id,
      String userId,
      @TimestampConverter() DateTime date,
      int steps,
      double distanceMeters,
      double caloriesBurned,
      double? averageHeartRate,
      double sleepHours,
      double? weight,
      @TimestampConverter() DateTime syncedAt,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$HealthDataCopyWithImpl<$Res, $Val extends HealthData>
    implements $HealthDataCopyWith<$Res> {
  _$HealthDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? steps = null,
    Object? distanceMeters = null,
    Object? caloriesBurned = null,
    Object? averageHeartRate = freezed,
    Object? sleepHours = null,
    Object? weight = freezed,
    Object? syncedAt = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as double,
      caloriesBurned: null == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as double,
      averageHeartRate: freezed == averageHeartRate
          ? _value.averageHeartRate
          : averageHeartRate // ignore: cast_nullable_to_non_nullable
              as double?,
      sleepHours: null == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      syncedAt: null == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthDataImplCopyWith<$Res>
    implements $HealthDataCopyWith<$Res> {
  factory _$$HealthDataImplCopyWith(
          _$HealthDataImpl value, $Res Function(_$HealthDataImpl) then) =
      __$$HealthDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      @TimestampConverter() DateTime date,
      int steps,
      double distanceMeters,
      double caloriesBurned,
      double? averageHeartRate,
      double sleepHours,
      double? weight,
      @TimestampConverter() DateTime syncedAt,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$HealthDataImplCopyWithImpl<$Res>
    extends _$HealthDataCopyWithImpl<$Res, _$HealthDataImpl>
    implements _$$HealthDataImplCopyWith<$Res> {
  __$$HealthDataImplCopyWithImpl(
      _$HealthDataImpl _value, $Res Function(_$HealthDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? steps = null,
    Object? distanceMeters = null,
    Object? caloriesBurned = null,
    Object? averageHeartRate = freezed,
    Object? sleepHours = null,
    Object? weight = freezed,
    Object? syncedAt = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$HealthDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as int,
      distanceMeters: null == distanceMeters
          ? _value.distanceMeters
          : distanceMeters // ignore: cast_nullable_to_non_nullable
              as double,
      caloriesBurned: null == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as double,
      averageHeartRate: freezed == averageHeartRate
          ? _value.averageHeartRate
          : averageHeartRate // ignore: cast_nullable_to_non_nullable
              as double?,
      sleepHours: null == sleepHours
          ? _value.sleepHours
          : sleepHours // ignore: cast_nullable_to_non_nullable
              as double,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      syncedAt: null == syncedAt
          ? _value.syncedAt
          : syncedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthDataImpl extends _HealthData {
  const _$HealthDataImpl(
      {required this.id,
      required this.userId,
      @TimestampConverter() required this.date,
      required this.steps,
      required this.distanceMeters,
      required this.caloriesBurned,
      this.averageHeartRate,
      required this.sleepHours,
      this.weight,
      @TimestampConverter() required this.syncedAt,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt})
      : super._();

  factory _$HealthDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthDataImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final int steps;
  @override
  final double distanceMeters;
  @override
  final double caloriesBurned;
  @override
  final double? averageHeartRate;
  @override
  final double sleepHours;
  @override
  final double? weight;
  @override
  @TimestampConverter()
  final DateTime syncedAt;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'HealthData(id: $id, userId: $userId, date: $date, steps: $steps, distanceMeters: $distanceMeters, caloriesBurned: $caloriesBurned, averageHeartRate: $averageHeartRate, sleepHours: $sleepHours, weight: $weight, syncedAt: $syncedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.steps, steps) || other.steps == steps) &&
            (identical(other.distanceMeters, distanceMeters) ||
                other.distanceMeters == distanceMeters) &&
            (identical(other.caloriesBurned, caloriesBurned) ||
                other.caloriesBurned == caloriesBurned) &&
            (identical(other.averageHeartRate, averageHeartRate) ||
                other.averageHeartRate == averageHeartRate) &&
            (identical(other.sleepHours, sleepHours) ||
                other.sleepHours == sleepHours) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.syncedAt, syncedAt) ||
                other.syncedAt == syncedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      date,
      steps,
      distanceMeters,
      caloriesBurned,
      averageHeartRate,
      sleepHours,
      weight,
      syncedAt,
      createdAt,
      updatedAt);

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthDataImplCopyWith<_$HealthDataImpl> get copyWith =>
      __$$HealthDataImplCopyWithImpl<_$HealthDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthDataImplToJson(
      this,
    );
  }
}

abstract class _HealthData extends HealthData {
  const factory _HealthData(
      {required final String id,
      required final String userId,
      @TimestampConverter() required final DateTime date,
      required final int steps,
      required final double distanceMeters,
      required final double caloriesBurned,
      final double? averageHeartRate,
      required final double sleepHours,
      final double? weight,
      @TimestampConverter() required final DateTime syncedAt,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$HealthDataImpl;
  const _HealthData._() : super._();

  factory _HealthData.fromJson(Map<String, dynamic> json) =
      _$HealthDataImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  @TimestampConverter()
  DateTime get date;
  @override
  int get steps;
  @override
  double get distanceMeters;
  @override
  double get caloriesBurned;
  @override
  double? get averageHeartRate;
  @override
  double get sleepHours;
  @override
  double? get weight;
  @override
  @TimestampConverter()
  DateTime get syncedAt;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthDataImplCopyWith<_$HealthDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
