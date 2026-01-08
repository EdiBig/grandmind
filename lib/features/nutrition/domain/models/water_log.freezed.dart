// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'water_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WaterLog _$WaterLogFromJson(Map<String, dynamic> json) {
  return _WaterLog.fromJson(json);
}

/// @nodoc
mixin _$WaterLog {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date =>
      throw _privateConstructorUsedError; // Normalized to start of day
  @TimestampConverter()
  DateTime get loggedAt =>
      throw _privateConstructorUsedError; // Last update timestamp
  int get glassesConsumed =>
      throw _privateConstructorUsedError; // Number of 250ml glasses consumed
  int get targetGlasses => throw _privateConstructorUsedError;

  /// Serializes this WaterLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WaterLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WaterLogCopyWith<WaterLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WaterLogCopyWith<$Res> {
  factory $WaterLogCopyWith(WaterLog value, $Res Function(WaterLog) then) =
      _$WaterLogCopyWithImpl<$Res, WaterLog>;
  @useResult
  $Res call(
      {String id,
      String userId,
      @TimestampConverter() DateTime date,
      @TimestampConverter() DateTime loggedAt,
      int glassesConsumed,
      int targetGlasses});
}

/// @nodoc
class _$WaterLogCopyWithImpl<$Res, $Val extends WaterLog>
    implements $WaterLogCopyWith<$Res> {
  _$WaterLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WaterLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? loggedAt = null,
    Object? glassesConsumed = null,
    Object? targetGlasses = null,
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
      loggedAt: null == loggedAt
          ? _value.loggedAt
          : loggedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      glassesConsumed: null == glassesConsumed
          ? _value.glassesConsumed
          : glassesConsumed // ignore: cast_nullable_to_non_nullable
              as int,
      targetGlasses: null == targetGlasses
          ? _value.targetGlasses
          : targetGlasses // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WaterLogImplCopyWith<$Res>
    implements $WaterLogCopyWith<$Res> {
  factory _$$WaterLogImplCopyWith(
          _$WaterLogImpl value, $Res Function(_$WaterLogImpl) then) =
      __$$WaterLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      @TimestampConverter() DateTime date,
      @TimestampConverter() DateTime loggedAt,
      int glassesConsumed,
      int targetGlasses});
}

/// @nodoc
class __$$WaterLogImplCopyWithImpl<$Res>
    extends _$WaterLogCopyWithImpl<$Res, _$WaterLogImpl>
    implements _$$WaterLogImplCopyWith<$Res> {
  __$$WaterLogImplCopyWithImpl(
      _$WaterLogImpl _value, $Res Function(_$WaterLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of WaterLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? loggedAt = null,
    Object? glassesConsumed = null,
    Object? targetGlasses = null,
  }) {
    return _then(_$WaterLogImpl(
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
      loggedAt: null == loggedAt
          ? _value.loggedAt
          : loggedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      glassesConsumed: null == glassesConsumed
          ? _value.glassesConsumed
          : glassesConsumed // ignore: cast_nullable_to_non_nullable
              as int,
      targetGlasses: null == targetGlasses
          ? _value.targetGlasses
          : targetGlasses // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WaterLogImpl extends _WaterLog {
  const _$WaterLogImpl(
      {required this.id,
      required this.userId,
      @TimestampConverter() required this.date,
      @TimestampConverter() required this.loggedAt,
      this.glassesConsumed = 0,
      this.targetGlasses = 8})
      : super._();

  factory _$WaterLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$WaterLogImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @TimestampConverter()
  final DateTime date;
// Normalized to start of day
  @override
  @TimestampConverter()
  final DateTime loggedAt;
// Last update timestamp
  @override
  @JsonKey()
  final int glassesConsumed;
// Number of 250ml glasses consumed
  @override
  @JsonKey()
  final int targetGlasses;

  @override
  String toString() {
    return 'WaterLog(id: $id, userId: $userId, date: $date, loggedAt: $loggedAt, glassesConsumed: $glassesConsumed, targetGlasses: $targetGlasses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WaterLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.loggedAt, loggedAt) ||
                other.loggedAt == loggedAt) &&
            (identical(other.glassesConsumed, glassesConsumed) ||
                other.glassesConsumed == glassesConsumed) &&
            (identical(other.targetGlasses, targetGlasses) ||
                other.targetGlasses == targetGlasses));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, date, loggedAt, glassesConsumed, targetGlasses);

  /// Create a copy of WaterLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WaterLogImplCopyWith<_$WaterLogImpl> get copyWith =>
      __$$WaterLogImplCopyWithImpl<_$WaterLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WaterLogImplToJson(
      this,
    );
  }
}

abstract class _WaterLog extends WaterLog {
  const factory _WaterLog(
      {required final String id,
      required final String userId,
      @TimestampConverter() required final DateTime date,
      @TimestampConverter() required final DateTime loggedAt,
      final int glassesConsumed,
      final int targetGlasses}) = _$WaterLogImpl;
  const _WaterLog._() : super._();

  factory _WaterLog.fromJson(Map<String, dynamic> json) =
      _$WaterLogImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  @TimestampConverter()
  DateTime get date; // Normalized to start of day
  @override
  @TimestampConverter()
  DateTime get loggedAt; // Last update timestamp
  @override
  int get glassesConsumed; // Number of 250ml glasses consumed
  @override
  int get targetGlasses;

  /// Create a copy of WaterLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WaterLogImplCopyWith<_$WaterLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
