// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'energy_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EnergyLog _$EnergyLogFromJson(Map<String, dynamic> json) {
  return _EnergyLog.fromJson(json);
}

/// @nodoc
mixin _$EnergyLog {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get loggedAt => throw _privateConstructorUsedError;
  int? get energyLevel => throw _privateConstructorUsedError; // 1-5 scale
  int? get moodRating =>
      throw _privateConstructorUsedError; // 1-5 scale (1=bad, 5=great)
  List<String> get contextTags => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get source => throw _privateConstructorUsedError;

  /// Serializes this EnergyLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EnergyLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnergyLogCopyWith<EnergyLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnergyLogCopyWith<$Res> {
  factory $EnergyLogCopyWith(EnergyLog value, $Res Function(EnergyLog) then) =
      _$EnergyLogCopyWithImpl<$Res, EnergyLog>;
  @useResult
  $Res call(
      {String id,
      String userId,
      @TimestampConverter() DateTime loggedAt,
      int? energyLevel,
      int? moodRating,
      List<String> contextTags,
      String? notes,
      String? source});
}

/// @nodoc
class _$EnergyLogCopyWithImpl<$Res, $Val extends EnergyLog>
    implements $EnergyLogCopyWith<$Res> {
  _$EnergyLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnergyLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? loggedAt = null,
    Object? energyLevel = freezed,
    Object? moodRating = freezed,
    Object? contextTags = null,
    Object? notes = freezed,
    Object? source = freezed,
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
      loggedAt: null == loggedAt
          ? _value.loggedAt
          : loggedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      energyLevel: freezed == energyLevel
          ? _value.energyLevel
          : energyLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      moodRating: freezed == moodRating
          ? _value.moodRating
          : moodRating // ignore: cast_nullable_to_non_nullable
              as int?,
      contextTags: null == contextTags
          ? _value.contextTags
          : contextTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EnergyLogImplCopyWith<$Res>
    implements $EnergyLogCopyWith<$Res> {
  factory _$$EnergyLogImplCopyWith(
          _$EnergyLogImpl value, $Res Function(_$EnergyLogImpl) then) =
      __$$EnergyLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      @TimestampConverter() DateTime loggedAt,
      int? energyLevel,
      int? moodRating,
      List<String> contextTags,
      String? notes,
      String? source});
}

/// @nodoc
class __$$EnergyLogImplCopyWithImpl<$Res>
    extends _$EnergyLogCopyWithImpl<$Res, _$EnergyLogImpl>
    implements _$$EnergyLogImplCopyWith<$Res> {
  __$$EnergyLogImplCopyWithImpl(
      _$EnergyLogImpl _value, $Res Function(_$EnergyLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of EnergyLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? loggedAt = null,
    Object? energyLevel = freezed,
    Object? moodRating = freezed,
    Object? contextTags = null,
    Object? notes = freezed,
    Object? source = freezed,
  }) {
    return _then(_$EnergyLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      loggedAt: null == loggedAt
          ? _value.loggedAt
          : loggedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      energyLevel: freezed == energyLevel
          ? _value.energyLevel
          : energyLevel // ignore: cast_nullable_to_non_nullable
              as int?,
      moodRating: freezed == moodRating
          ? _value.moodRating
          : moodRating // ignore: cast_nullable_to_non_nullable
              as int?,
      contextTags: null == contextTags
          ? _value._contextTags
          : contextTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      source: freezed == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EnergyLogImpl extends _EnergyLog {
  const _$EnergyLogImpl(
      {required this.id,
      required this.userId,
      @TimestampConverter() required this.loggedAt,
      this.energyLevel,
      this.moodRating,
      final List<String> contextTags = const [],
      this.notes,
      this.source})
      : _contextTags = contextTags,
        super._();

  factory _$EnergyLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnergyLogImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @TimestampConverter()
  final DateTime loggedAt;
  @override
  final int? energyLevel;
// 1-5 scale
  @override
  final int? moodRating;
// 1-5 scale (1=bad, 5=great)
  final List<String> _contextTags;
// 1-5 scale (1=bad, 5=great)
  @override
  @JsonKey()
  List<String> get contextTags {
    if (_contextTags is EqualUnmodifiableListView) return _contextTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contextTags);
  }

  @override
  final String? notes;
  @override
  final String? source;

  @override
  String toString() {
    return 'EnergyLog(id: $id, userId: $userId, loggedAt: $loggedAt, energyLevel: $energyLevel, moodRating: $moodRating, contextTags: $contextTags, notes: $notes, source: $source)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnergyLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.loggedAt, loggedAt) ||
                other.loggedAt == loggedAt) &&
            (identical(other.energyLevel, energyLevel) ||
                other.energyLevel == energyLevel) &&
            (identical(other.moodRating, moodRating) ||
                other.moodRating == moodRating) &&
            const DeepCollectionEquality()
                .equals(other._contextTags, _contextTags) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.source, source) || other.source == source));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      loggedAt,
      energyLevel,
      moodRating,
      const DeepCollectionEquality().hash(_contextTags),
      notes,
      source);

  /// Create a copy of EnergyLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnergyLogImplCopyWith<_$EnergyLogImpl> get copyWith =>
      __$$EnergyLogImplCopyWithImpl<_$EnergyLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnergyLogImplToJson(
      this,
    );
  }
}

abstract class _EnergyLog extends EnergyLog {
  const factory _EnergyLog(
      {required final String id,
      required final String userId,
      @TimestampConverter() required final DateTime loggedAt,
      final int? energyLevel,
      final int? moodRating,
      final List<String> contextTags,
      final String? notes,
      final String? source}) = _$EnergyLogImpl;
  const _EnergyLog._() : super._();

  factory _EnergyLog.fromJson(Map<String, dynamic> json) =
      _$EnergyLogImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  @TimestampConverter()
  DateTime get loggedAt;
  @override
  int? get energyLevel; // 1-5 scale
  @override
  int? get moodRating; // 1-5 scale (1=bad, 5=great)
  @override
  List<String> get contextTags;
  @override
  String? get notes;
  @override
  String? get source;

  /// Create a copy of EnergyLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnergyLogImplCopyWith<_$EnergyLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
