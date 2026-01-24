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

HealthSourceDetails _$HealthSourceDetailsFromJson(Map<String, dynamic> json) {
  return _HealthSourceDetails.fromJson(json);
}

/// @nodoc
mixin _$HealthSourceDetails {
  String? get deviceName => throw _privateConstructorUsedError;
  String? get deviceModel => throw _privateConstructorUsedError;
  String? get appName => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get originalTimestamp => throw _privateConstructorUsedError;

  /// Serializes this HealthSourceDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthSourceDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthSourceDetailsCopyWith<HealthSourceDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthSourceDetailsCopyWith<$Res> {
  factory $HealthSourceDetailsCopyWith(
          HealthSourceDetails value, $Res Function(HealthSourceDetails) then) =
      _$HealthSourceDetailsCopyWithImpl<$Res, HealthSourceDetails>;
  @useResult
  $Res call(
      {String? deviceName,
      String? deviceModel,
      String? appName,
      @TimestampConverter() DateTime? originalTimestamp});
}

/// @nodoc
class _$HealthSourceDetailsCopyWithImpl<$Res, $Val extends HealthSourceDetails>
    implements $HealthSourceDetailsCopyWith<$Res> {
  _$HealthSourceDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthSourceDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceName = freezed,
    Object? deviceModel = freezed,
    Object? appName = freezed,
    Object? originalTimestamp = freezed,
  }) {
    return _then(_value.copyWith(
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceModel: freezed == deviceModel
          ? _value.deviceModel
          : deviceModel // ignore: cast_nullable_to_non_nullable
              as String?,
      appName: freezed == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
      originalTimestamp: freezed == originalTimestamp
          ? _value.originalTimestamp
          : originalTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthSourceDetailsImplCopyWith<$Res>
    implements $HealthSourceDetailsCopyWith<$Res> {
  factory _$$HealthSourceDetailsImplCopyWith(_$HealthSourceDetailsImpl value,
          $Res Function(_$HealthSourceDetailsImpl) then) =
      __$$HealthSourceDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? deviceName,
      String? deviceModel,
      String? appName,
      @TimestampConverter() DateTime? originalTimestamp});
}

/// @nodoc
class __$$HealthSourceDetailsImplCopyWithImpl<$Res>
    extends _$HealthSourceDetailsCopyWithImpl<$Res, _$HealthSourceDetailsImpl>
    implements _$$HealthSourceDetailsImplCopyWith<$Res> {
  __$$HealthSourceDetailsImplCopyWithImpl(_$HealthSourceDetailsImpl _value,
      $Res Function(_$HealthSourceDetailsImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthSourceDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? deviceName = freezed,
    Object? deviceModel = freezed,
    Object? appName = freezed,
    Object? originalTimestamp = freezed,
  }) {
    return _then(_$HealthSourceDetailsImpl(
      deviceName: freezed == deviceName
          ? _value.deviceName
          : deviceName // ignore: cast_nullable_to_non_nullable
              as String?,
      deviceModel: freezed == deviceModel
          ? _value.deviceModel
          : deviceModel // ignore: cast_nullable_to_non_nullable
              as String?,
      appName: freezed == appName
          ? _value.appName
          : appName // ignore: cast_nullable_to_non_nullable
              as String?,
      originalTimestamp: freezed == originalTimestamp
          ? _value.originalTimestamp
          : originalTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthSourceDetailsImpl implements _HealthSourceDetails {
  const _$HealthSourceDetailsImpl(
      {this.deviceName,
      this.deviceModel,
      this.appName,
      @TimestampConverter() this.originalTimestamp});

  factory _$HealthSourceDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthSourceDetailsImplFromJson(json);

  @override
  final String? deviceName;
  @override
  final String? deviceModel;
  @override
  final String? appName;
  @override
  @TimestampConverter()
  final DateTime? originalTimestamp;

  @override
  String toString() {
    return 'HealthSourceDetails(deviceName: $deviceName, deviceModel: $deviceModel, appName: $appName, originalTimestamp: $originalTimestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthSourceDetailsImpl &&
            (identical(other.deviceName, deviceName) ||
                other.deviceName == deviceName) &&
            (identical(other.deviceModel, deviceModel) ||
                other.deviceModel == deviceModel) &&
            (identical(other.appName, appName) || other.appName == appName) &&
            (identical(other.originalTimestamp, originalTimestamp) ||
                other.originalTimestamp == originalTimestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, deviceName, deviceModel, appName, originalTimestamp);

  /// Create a copy of HealthSourceDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthSourceDetailsImplCopyWith<_$HealthSourceDetailsImpl> get copyWith =>
      __$$HealthSourceDetailsImplCopyWithImpl<_$HealthSourceDetailsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthSourceDetailsImplToJson(
      this,
    );
  }
}

abstract class _HealthSourceDetails implements HealthSourceDetails {
  const factory _HealthSourceDetails(
          {final String? deviceName,
          final String? deviceModel,
          final String? appName,
          @TimestampConverter() final DateTime? originalTimestamp}) =
      _$HealthSourceDetailsImpl;

  factory _HealthSourceDetails.fromJson(Map<String, dynamic> json) =
      _$HealthSourceDetailsImpl.fromJson;

  @override
  String? get deviceName;
  @override
  String? get deviceModel;
  @override
  String? get appName;
  @override
  @TimestampConverter()
  DateTime? get originalTimestamp;

  /// Create a copy of HealthSourceDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthSourceDetailsImplCopyWith<_$HealthSourceDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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
  HealthDataSource get source => throw _privateConstructorUsedError;
  HealthSourceDetails? get sourceDetails => throw _privateConstructorUsedError;
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
      HealthDataSource source,
      HealthSourceDetails? sourceDetails,
      @TimestampConverter() DateTime syncedAt,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});

  $HealthSourceDetailsCopyWith<$Res>? get sourceDetails;
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
    Object? source = null,
    Object? sourceDetails = freezed,
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
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as HealthDataSource,
      sourceDetails: freezed == sourceDetails
          ? _value.sourceDetails
          : sourceDetails // ignore: cast_nullable_to_non_nullable
              as HealthSourceDetails?,
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

  /// Create a copy of HealthData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $HealthSourceDetailsCopyWith<$Res>? get sourceDetails {
    if (_value.sourceDetails == null) {
      return null;
    }

    return $HealthSourceDetailsCopyWith<$Res>(_value.sourceDetails!, (value) {
      return _then(_value.copyWith(sourceDetails: value) as $Val);
    });
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
      HealthDataSource source,
      HealthSourceDetails? sourceDetails,
      @TimestampConverter() DateTime syncedAt,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});

  @override
  $HealthSourceDetailsCopyWith<$Res>? get sourceDetails;
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
    Object? source = null,
    Object? sourceDetails = freezed,
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
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as HealthDataSource,
      sourceDetails: freezed == sourceDetails
          ? _value.sourceDetails
          : sourceDetails // ignore: cast_nullable_to_non_nullable
              as HealthSourceDetails?,
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
      this.source = HealthDataSource.unknown,
      this.sourceDetails,
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
  @JsonKey()
  final HealthDataSource source;
  @override
  final HealthSourceDetails? sourceDetails;
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
    return 'HealthData(id: $id, userId: $userId, date: $date, steps: $steps, distanceMeters: $distanceMeters, caloriesBurned: $caloriesBurned, averageHeartRate: $averageHeartRate, sleepHours: $sleepHours, weight: $weight, source: $source, sourceDetails: $sourceDetails, syncedAt: $syncedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
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
            (identical(other.source, source) || other.source == source) &&
            (identical(other.sourceDetails, sourceDetails) ||
                other.sourceDetails == sourceDetails) &&
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
      source,
      sourceDetails,
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
      final HealthDataSource source,
      final HealthSourceDetails? sourceDetails,
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
  HealthDataSource get source;
  @override
  HealthSourceDetails? get sourceDetails;
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
