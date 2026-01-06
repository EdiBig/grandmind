// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeightEntry _$WeightEntryFromJson(Map<String, dynamic> json) {
  return _WeightEntry.fromJson(json);
}

/// @nodoc
mixin _$WeightEntry {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError; // Always in kg
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError; // Allows backdating
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this WeightEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeightEntryCopyWith<WeightEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightEntryCopyWith<$Res> {
  factory $WeightEntryCopyWith(
          WeightEntry value, $Res Function(WeightEntry) then) =
      _$WeightEntryCopyWithImpl<$Res, WeightEntry>;
  @useResult
  $Res call(
      {String id,
      String userId,
      double weight,
      @TimestampConverter() DateTime date,
      @TimestampConverter() DateTime createdAt,
      String? notes});
}

/// @nodoc
class _$WeightEntryCopyWithImpl<$Res, $Val extends WeightEntry>
    implements $WeightEntryCopyWith<$Res> {
  _$WeightEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weight = null,
    Object? date = null,
    Object? createdAt = null,
    Object? notes = freezed,
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
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeightEntryImplCopyWith<$Res>
    implements $WeightEntryCopyWith<$Res> {
  factory _$$WeightEntryImplCopyWith(
          _$WeightEntryImpl value, $Res Function(_$WeightEntryImpl) then) =
      __$$WeightEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      double weight,
      @TimestampConverter() DateTime date,
      @TimestampConverter() DateTime createdAt,
      String? notes});
}

/// @nodoc
class __$$WeightEntryImplCopyWithImpl<$Res>
    extends _$WeightEntryCopyWithImpl<$Res, _$WeightEntryImpl>
    implements _$$WeightEntryImplCopyWith<$Res> {
  __$$WeightEntryImplCopyWithImpl(
      _$WeightEntryImpl _value, $Res Function(_$WeightEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? weight = null,
    Object? date = null,
    Object? createdAt = null,
    Object? notes = freezed,
  }) {
    return _then(_$WeightEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WeightEntryImpl implements _WeightEntry {
  const _$WeightEntryImpl(
      {required this.id,
      required this.userId,
      required this.weight,
      @TimestampConverter() required this.date,
      @TimestampConverter() required this.createdAt,
      this.notes});

  factory _$WeightEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final double weight;
// Always in kg
  @override
  @TimestampConverter()
  final DateTime date;
// Allows backdating
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  final String? notes;

  @override
  String toString() {
    return 'WeightEntry(id: $id, userId: $userId, weight: $weight, date: $date, createdAt: $createdAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, weight, date, createdAt, notes);

  /// Create a copy of WeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightEntryImplCopyWith<_$WeightEntryImpl> get copyWith =>
      __$$WeightEntryImplCopyWithImpl<_$WeightEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightEntryImplToJson(
      this,
    );
  }
}

abstract class _WeightEntry implements WeightEntry {
  const factory _WeightEntry(
      {required final String id,
      required final String userId,
      required final double weight,
      @TimestampConverter() required final DateTime date,
      @TimestampConverter() required final DateTime createdAt,
      final String? notes}) = _$WeightEntryImpl;

  factory _WeightEntry.fromJson(Map<String, dynamic> json) =
      _$WeightEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  double get weight; // Always in kg
  @override
  @TimestampConverter()
  DateTime get date; // Allows backdating
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  String? get notes;

  /// Create a copy of WeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeightEntryImplCopyWith<_$WeightEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
