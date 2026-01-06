// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ProgressPhoto _$ProgressPhotoFromJson(Map<String, dynamic> json) {
  return _ProgressPhoto.fromJson(json);
}

/// @nodoc
mixin _$ProgressPhoto {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get imageUrl =>
      throw _privateConstructorUsedError; // Firebase Storage URL (full image)
  String get thumbnailUrl =>
      throw _privateConstructorUsedError; // Compressed thumbnail for gallery
  PhotoAngle get angle => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date => throw _privateConstructorUsedError; // Allows backdating
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double? get weight =>
      throw _privateConstructorUsedError; // Optional weight at time of photo (in kg)
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this ProgressPhoto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressPhotoCopyWith<ProgressPhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressPhotoCopyWith<$Res> {
  factory $ProgressPhotoCopyWith(
          ProgressPhoto value, $Res Function(ProgressPhoto) then) =
      _$ProgressPhotoCopyWithImpl<$Res, ProgressPhoto>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String imageUrl,
      String thumbnailUrl,
      PhotoAngle angle,
      @TimestampConverter() DateTime date,
      @TimestampConverter() DateTime createdAt,
      String? notes,
      double? weight,
      Map<String, dynamic> metadata});
}

/// @nodoc
class _$ProgressPhotoCopyWithImpl<$Res, $Val extends ProgressPhoto>
    implements $ProgressPhotoCopyWith<$Res> {
  _$ProgressPhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = null,
    Object? angle = null,
    Object? date = null,
    Object? createdAt = null,
    Object? notes = freezed,
    Object? weight = freezed,
    Object? metadata = null,
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
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      angle: null == angle
          ? _value.angle
          : angle // ignore: cast_nullable_to_non_nullable
              as PhotoAngle,
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
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressPhotoImplCopyWith<$Res>
    implements $ProgressPhotoCopyWith<$Res> {
  factory _$$ProgressPhotoImplCopyWith(
          _$ProgressPhotoImpl value, $Res Function(_$ProgressPhotoImpl) then) =
      __$$ProgressPhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String imageUrl,
      String thumbnailUrl,
      PhotoAngle angle,
      @TimestampConverter() DateTime date,
      @TimestampConverter() DateTime createdAt,
      String? notes,
      double? weight,
      Map<String, dynamic> metadata});
}

/// @nodoc
class __$$ProgressPhotoImplCopyWithImpl<$Res>
    extends _$ProgressPhotoCopyWithImpl<$Res, _$ProgressPhotoImpl>
    implements _$$ProgressPhotoImplCopyWith<$Res> {
  __$$ProgressPhotoImplCopyWithImpl(
      _$ProgressPhotoImpl _value, $Res Function(_$ProgressPhotoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProgressPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? imageUrl = null,
    Object? thumbnailUrl = null,
    Object? angle = null,
    Object? date = null,
    Object? createdAt = null,
    Object? notes = freezed,
    Object? weight = freezed,
    Object? metadata = null,
  }) {
    return _then(_$ProgressPhotoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: null == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String,
      angle: null == angle
          ? _value.angle
          : angle // ignore: cast_nullable_to_non_nullable
              as PhotoAngle,
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
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressPhotoImpl implements _ProgressPhoto {
  const _$ProgressPhotoImpl(
      {required this.id,
      required this.userId,
      required this.imageUrl,
      required this.thumbnailUrl,
      required this.angle,
      @TimestampConverter() required this.date,
      @TimestampConverter() required this.createdAt,
      this.notes,
      this.weight,
      final Map<String, dynamic> metadata = const {}})
      : _metadata = metadata;

  factory _$ProgressPhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressPhotoImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String imageUrl;
// Firebase Storage URL (full image)
  @override
  final String thumbnailUrl;
// Compressed thumbnail for gallery
  @override
  final PhotoAngle angle;
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
  final double? weight;
// Optional weight at time of photo (in kg)
  final Map<String, dynamic> _metadata;
// Optional weight at time of photo (in kg)
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'ProgressPhoto(id: $id, userId: $userId, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, angle: $angle, date: $date, createdAt: $createdAt, notes: $notes, weight: $weight, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressPhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.angle, angle) || other.angle == angle) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      imageUrl,
      thumbnailUrl,
      angle,
      date,
      createdAt,
      notes,
      weight,
      const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of ProgressPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressPhotoImplCopyWith<_$ProgressPhotoImpl> get copyWith =>
      __$$ProgressPhotoImplCopyWithImpl<_$ProgressPhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressPhotoImplToJson(
      this,
    );
  }
}

abstract class _ProgressPhoto implements ProgressPhoto {
  const factory _ProgressPhoto(
      {required final String id,
      required final String userId,
      required final String imageUrl,
      required final String thumbnailUrl,
      required final PhotoAngle angle,
      @TimestampConverter() required final DateTime date,
      @TimestampConverter() required final DateTime createdAt,
      final String? notes,
      final double? weight,
      final Map<String, dynamic> metadata}) = _$ProgressPhotoImpl;

  factory _ProgressPhoto.fromJson(Map<String, dynamic> json) =
      _$ProgressPhotoImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get imageUrl; // Firebase Storage URL (full image)
  @override
  String get thumbnailUrl; // Compressed thumbnail for gallery
  @override
  PhotoAngle get angle;
  @override
  @TimestampConverter()
  DateTime get date; // Allows backdating
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  String? get notes;
  @override
  double? get weight; // Optional weight at time of photo (in kg)
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of ProgressPhoto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressPhotoImplCopyWith<_$ProgressPhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
