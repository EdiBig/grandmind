// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'measurement_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MeasurementEntry _$MeasurementEntryFromJson(Map<String, dynamic> json) {
  return _MeasurementEntry.fromJson(json);
}

/// @nodoc
mixin _$MeasurementEntry {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  Map<String, double> get measurements =>
      throw _privateConstructorUsedError; // Key: MeasurementType.name, Value: cm
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError; // Allows backdating
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this MeasurementEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MeasurementEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeasurementEntryCopyWith<MeasurementEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeasurementEntryCopyWith<$Res> {
  factory $MeasurementEntryCopyWith(
          MeasurementEntry value, $Res Function(MeasurementEntry) then) =
      _$MeasurementEntryCopyWithImpl<$Res, MeasurementEntry>;
  @useResult
  $Res call(
      {String id,
      String userId,
      Map<String, double> measurements,
      @TimestampConverter() DateTime date,
      @TimestampConverter() DateTime createdAt,
      String? notes});
}

/// @nodoc
class _$MeasurementEntryCopyWithImpl<$Res, $Val extends MeasurementEntry>
    implements $MeasurementEntryCopyWith<$Res> {
  _$MeasurementEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeasurementEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? measurements = null,
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
      measurements: null == measurements
          ? _value.measurements
          : measurements // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
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
abstract class _$$MeasurementEntryImplCopyWith<$Res>
    implements $MeasurementEntryCopyWith<$Res> {
  factory _$$MeasurementEntryImplCopyWith(_$MeasurementEntryImpl value,
          $Res Function(_$MeasurementEntryImpl) then) =
      __$$MeasurementEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      Map<String, double> measurements,
      @TimestampConverter() DateTime date,
      @TimestampConverter() DateTime createdAt,
      String? notes});
}

/// @nodoc
class __$$MeasurementEntryImplCopyWithImpl<$Res>
    extends _$MeasurementEntryCopyWithImpl<$Res, _$MeasurementEntryImpl>
    implements _$$MeasurementEntryImplCopyWith<$Res> {
  __$$MeasurementEntryImplCopyWithImpl(_$MeasurementEntryImpl _value,
      $Res Function(_$MeasurementEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of MeasurementEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? measurements = null,
    Object? date = null,
    Object? createdAt = null,
    Object? notes = freezed,
  }) {
    return _then(_$MeasurementEntryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      measurements: null == measurements
          ? _value._measurements
          : measurements // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
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
class _$MeasurementEntryImpl implements _MeasurementEntry {
  const _$MeasurementEntryImpl(
      {required this.id,
      required this.userId,
      final Map<String, double> measurements = const {},
      @TimestampConverter() required this.date,
      @TimestampConverter() required this.createdAt,
      this.notes})
      : _measurements = measurements;

  factory _$MeasurementEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MeasurementEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  final Map<String, double> _measurements;
  @override
  @JsonKey()
  Map<String, double> get measurements {
    if (_measurements is EqualUnmodifiableMapView) return _measurements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_measurements);
  }

// Key: MeasurementType.name, Value: cm
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
    return 'MeasurementEntry(id: $id, userId: $userId, measurements: $measurements, date: $date, createdAt: $createdAt, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeasurementEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            const DeepCollectionEquality()
                .equals(other._measurements, _measurements) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      const DeepCollectionEquality().hash(_measurements),
      date,
      createdAt,
      notes);

  /// Create a copy of MeasurementEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeasurementEntryImplCopyWith<_$MeasurementEntryImpl> get copyWith =>
      __$$MeasurementEntryImplCopyWithImpl<_$MeasurementEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MeasurementEntryImplToJson(
      this,
    );
  }
}

abstract class _MeasurementEntry implements MeasurementEntry {
  const factory _MeasurementEntry(
      {required final String id,
      required final String userId,
      final Map<String, double> measurements,
      @TimestampConverter() required final DateTime date,
      @TimestampConverter() required final DateTime createdAt,
      final String? notes}) = _$MeasurementEntryImpl;

  factory _MeasurementEntry.fromJson(Map<String, dynamic> json) =
      _$MeasurementEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  Map<String, double> get measurements; // Key: MeasurementType.name, Value: cm
  @override
  @TimestampConverter()
  DateTime get date; // Allows backdating
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  String? get notes;

  /// Create a copy of MeasurementEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeasurementEntryImplCopyWith<_$MeasurementEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
