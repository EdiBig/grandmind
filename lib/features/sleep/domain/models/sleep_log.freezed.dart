// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SleepLog _$SleepLogFromJson(Map<String, dynamic> json) {
  return _SleepLog.fromJson(json);
}

/// @nodoc
mixin _$SleepLog {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get logDate =>
      throw _privateConstructorUsedError; // The date this sleep is for
  double get hoursSlept =>
      throw _privateConstructorUsedError; // Total hours of sleep
  int? get quality => throw _privateConstructorUsedError; // 1-5 scale
  @TimestampConverter()
  DateTime? get bedTime =>
      throw _privateConstructorUsedError; // When went to bed
  @TimestampConverter()
  DateTime? get wakeTime => throw _privateConstructorUsedError; // When woke up
  List<String> get tags => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String get source =>
      throw _privateConstructorUsedError; // 'manual', 'apple_health', 'google_fit'
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SleepLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SleepLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SleepLogCopyWith<SleepLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SleepLogCopyWith<$Res> {
  factory $SleepLogCopyWith(SleepLog value, $Res Function(SleepLog) then) =
      _$SleepLogCopyWithImpl<$Res, SleepLog>;
  @useResult
  $Res call(
      {String id,
      String userId,
      @TimestampConverter() DateTime logDate,
      double hoursSlept,
      int? quality,
      @TimestampConverter() DateTime? bedTime,
      @TimestampConverter() DateTime? wakeTime,
      List<String> tags,
      String? notes,
      String source,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$SleepLogCopyWithImpl<$Res, $Val extends SleepLog>
    implements $SleepLogCopyWith<$Res> {
  _$SleepLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SleepLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? logDate = null,
    Object? hoursSlept = null,
    Object? quality = freezed,
    Object? bedTime = freezed,
    Object? wakeTime = freezed,
    Object? tags = null,
    Object? notes = freezed,
    Object? source = null,
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
      logDate: null == logDate
          ? _value.logDate
          : logDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hoursSlept: null == hoursSlept
          ? _value.hoursSlept
          : hoursSlept // ignore: cast_nullable_to_non_nullable
              as double,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as int?,
      bedTime: freezed == bedTime
          ? _value.bedTime
          : bedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      wakeTime: freezed == wakeTime
          ? _value.wakeTime
          : wakeTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$SleepLogImplCopyWith<$Res>
    implements $SleepLogCopyWith<$Res> {
  factory _$$SleepLogImplCopyWith(
          _$SleepLogImpl value, $Res Function(_$SleepLogImpl) then) =
      __$$SleepLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      @TimestampConverter() DateTime logDate,
      double hoursSlept,
      int? quality,
      @TimestampConverter() DateTime? bedTime,
      @TimestampConverter() DateTime? wakeTime,
      List<String> tags,
      String? notes,
      String source,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$SleepLogImplCopyWithImpl<$Res>
    extends _$SleepLogCopyWithImpl<$Res, _$SleepLogImpl>
    implements _$$SleepLogImplCopyWith<$Res> {
  __$$SleepLogImplCopyWithImpl(
      _$SleepLogImpl _value, $Res Function(_$SleepLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of SleepLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? logDate = null,
    Object? hoursSlept = null,
    Object? quality = freezed,
    Object? bedTime = freezed,
    Object? wakeTime = freezed,
    Object? tags = null,
    Object? notes = freezed,
    Object? source = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$SleepLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      logDate: null == logDate
          ? _value.logDate
          : logDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      hoursSlept: null == hoursSlept
          ? _value.hoursSlept
          : hoursSlept // ignore: cast_nullable_to_non_nullable
              as double,
      quality: freezed == quality
          ? _value.quality
          : quality // ignore: cast_nullable_to_non_nullable
              as int?,
      bedTime: freezed == bedTime
          ? _value.bedTime
          : bedTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      wakeTime: freezed == wakeTime
          ? _value.wakeTime
          : wakeTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$SleepLogImpl extends _SleepLog {
  const _$SleepLogImpl(
      {required this.id,
      required this.userId,
      @TimestampConverter() required this.logDate,
      required this.hoursSlept,
      this.quality,
      @TimestampConverter() this.bedTime,
      @TimestampConverter() this.wakeTime,
      final List<String> tags = const [],
      this.notes,
      this.source = 'manual',
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt})
      : _tags = tags,
        super._();

  factory _$SleepLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$SleepLogImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @TimestampConverter()
  final DateTime logDate;
// The date this sleep is for
  @override
  final double hoursSlept;
// Total hours of sleep
  @override
  final int? quality;
// 1-5 scale
  @override
  @TimestampConverter()
  final DateTime? bedTime;
// When went to bed
  @override
  @TimestampConverter()
  final DateTime? wakeTime;
// When woke up
  final List<String> _tags;
// When woke up
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? notes;
  @override
  @JsonKey()
  final String source;
// 'manual', 'apple_health', 'google_fit'
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'SleepLog(id: $id, userId: $userId, logDate: $logDate, hoursSlept: $hoursSlept, quality: $quality, bedTime: $bedTime, wakeTime: $wakeTime, tags: $tags, notes: $notes, source: $source, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SleepLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.logDate, logDate) || other.logDate == logDate) &&
            (identical(other.hoursSlept, hoursSlept) ||
                other.hoursSlept == hoursSlept) &&
            (identical(other.quality, quality) || other.quality == quality) &&
            (identical(other.bedTime, bedTime) || other.bedTime == bedTime) &&
            (identical(other.wakeTime, wakeTime) ||
                other.wakeTime == wakeTime) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.source, source) || other.source == source) &&
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
      logDate,
      hoursSlept,
      quality,
      bedTime,
      wakeTime,
      const DeepCollectionEquality().hash(_tags),
      notes,
      source,
      createdAt,
      updatedAt);

  /// Create a copy of SleepLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SleepLogImplCopyWith<_$SleepLogImpl> get copyWith =>
      __$$SleepLogImplCopyWithImpl<_$SleepLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SleepLogImplToJson(
      this,
    );
  }
}

abstract class _SleepLog extends SleepLog {
  const factory _SleepLog(
      {required final String id,
      required final String userId,
      @TimestampConverter() required final DateTime logDate,
      required final double hoursSlept,
      final int? quality,
      @TimestampConverter() final DateTime? bedTime,
      @TimestampConverter() final DateTime? wakeTime,
      final List<String> tags,
      final String? notes,
      final String source,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$SleepLogImpl;
  const _SleepLog._() : super._();

  factory _SleepLog.fromJson(Map<String, dynamic> json) =
      _$SleepLogImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  @TimestampConverter()
  DateTime get logDate; // The date this sleep is for
  @override
  double get hoursSlept; // Total hours of sleep
  @override
  int? get quality; // 1-5 scale
  @override
  @TimestampConverter()
  DateTime? get bedTime; // When went to bed
  @override
  @TimestampConverter()
  DateTime? get wakeTime; // When woke up
  @override
  List<String> get tags;
  @override
  String? get notes;
  @override
  String get source; // 'manual', 'apple_health', 'google_fit'
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of SleepLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SleepLogImplCopyWith<_$SleepLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
