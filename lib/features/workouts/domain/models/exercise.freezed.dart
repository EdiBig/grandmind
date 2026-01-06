// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Exercise _$ExerciseFromJson(Map<String, dynamic> json) {
  return _Exercise.fromJson(json);
}

/// @nodoc
mixin _$Exercise {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  ExerciseType get type => throw _privateConstructorUsedError;
  List<String>? get muscleGroups => throw _privateConstructorUsedError;
  String? get equipment => throw _privateConstructorUsedError;
  ExerciseMetrics? get metrics => throw _privateConstructorUsedError;

  /// Serializes this Exercise to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseCopyWith<Exercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) then) =
      _$ExerciseCopyWithImpl<$Res, Exercise>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String? videoUrl,
      String? imageUrl,
      ExerciseType type,
      List<String>? muscleGroups,
      String? equipment,
      ExerciseMetrics? metrics});

  $ExerciseMetricsCopyWith<$Res>? get metrics;
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res, $Val extends Exercise>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? videoUrl = freezed,
    Object? imageUrl = freezed,
    Object? type = null,
    Object? muscleGroups = freezed,
    Object? equipment = freezed,
    Object? metrics = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      muscleGroups: freezed == muscleGroups
          ? _value.muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      equipment: freezed == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as String?,
      metrics: freezed == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as ExerciseMetrics?,
    ) as $Val);
  }

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExerciseMetricsCopyWith<$Res>? get metrics {
    if (_value.metrics == null) {
      return null;
    }

    return $ExerciseMetricsCopyWith<$Res>(_value.metrics!, (value) {
      return _then(_value.copyWith(metrics: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExerciseImplCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$$ExerciseImplCopyWith(
          _$ExerciseImpl value, $Res Function(_$ExerciseImpl) then) =
      __$$ExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String? videoUrl,
      String? imageUrl,
      ExerciseType type,
      List<String>? muscleGroups,
      String? equipment,
      ExerciseMetrics? metrics});

  @override
  $ExerciseMetricsCopyWith<$Res>? get metrics;
}

/// @nodoc
class __$$ExerciseImplCopyWithImpl<$Res>
    extends _$ExerciseCopyWithImpl<$Res, _$ExerciseImpl>
    implements _$$ExerciseImplCopyWith<$Res> {
  __$$ExerciseImplCopyWithImpl(
      _$ExerciseImpl _value, $Res Function(_$ExerciseImpl) _then)
      : super(_value, _then);

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? videoUrl = freezed,
    Object? imageUrl = freezed,
    Object? type = null,
    Object? muscleGroups = freezed,
    Object? equipment = freezed,
    Object? metrics = freezed,
  }) {
    return _then(_$ExerciseImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      muscleGroups: freezed == muscleGroups
          ? _value._muscleGroups
          : muscleGroups // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      equipment: freezed == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as String?,
      metrics: freezed == metrics
          ? _value.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as ExerciseMetrics?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseImpl implements _Exercise {
  const _$ExerciseImpl(
      {required this.id,
      required this.name,
      required this.description,
      this.videoUrl,
      this.imageUrl,
      required this.type,
      final List<String>? muscleGroups,
      this.equipment,
      this.metrics})
      : _muscleGroups = muscleGroups;

  factory _$ExerciseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String? videoUrl;
  @override
  final String? imageUrl;
  @override
  final ExerciseType type;
  final List<String>? _muscleGroups;
  @override
  List<String>? get muscleGroups {
    final value = _muscleGroups;
    if (value == null) return null;
    if (_muscleGroups is EqualUnmodifiableListView) return _muscleGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? equipment;
  @override
  final ExerciseMetrics? metrics;

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, description: $description, videoUrl: $videoUrl, imageUrl: $imageUrl, type: $type, muscleGroups: $muscleGroups, equipment: $equipment, metrics: $metrics)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._muscleGroups, _muscleGroups) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.metrics, metrics) || other.metrics == metrics));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      videoUrl,
      imageUrl,
      type,
      const DeepCollectionEquality().hash(_muscleGroups),
      equipment,
      metrics);

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      __$$ExerciseImplCopyWithImpl<_$ExerciseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseImplToJson(
      this,
    );
  }
}

abstract class _Exercise implements Exercise {
  const factory _Exercise(
      {required final String id,
      required final String name,
      required final String description,
      final String? videoUrl,
      final String? imageUrl,
      required final ExerciseType type,
      final List<String>? muscleGroups,
      final String? equipment,
      final ExerciseMetrics? metrics}) = _$ExerciseImpl;

  factory _Exercise.fromJson(Map<String, dynamic> json) =
      _$ExerciseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String? get videoUrl;
  @override
  String? get imageUrl;
  @override
  ExerciseType get type;
  @override
  List<String>? get muscleGroups;
  @override
  String? get equipment;
  @override
  ExerciseMetrics? get metrics;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExerciseMetrics _$ExerciseMetricsFromJson(Map<String, dynamic> json) {
  return _ExerciseMetrics.fromJson(json);
}

/// @nodoc
mixin _$ExerciseMetrics {
  int? get sets => throw _privateConstructorUsedError;
  int? get reps => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError; // in seconds
  double? get distance => throw _privateConstructorUsedError; // in km
  double? get weight => throw _privateConstructorUsedError; // in kg
  int? get restTime => throw _privateConstructorUsedError;

  /// Serializes this ExerciseMetrics to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseMetricsCopyWith<ExerciseMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseMetricsCopyWith<$Res> {
  factory $ExerciseMetricsCopyWith(
          ExerciseMetrics value, $Res Function(ExerciseMetrics) then) =
      _$ExerciseMetricsCopyWithImpl<$Res, ExerciseMetrics>;
  @useResult
  $Res call(
      {int? sets,
      int? reps,
      int? duration,
      double? distance,
      double? weight,
      int? restTime});
}

/// @nodoc
class _$ExerciseMetricsCopyWithImpl<$Res, $Val extends ExerciseMetrics>
    implements $ExerciseMetricsCopyWith<$Res> {
  _$ExerciseMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sets = freezed,
    Object? reps = freezed,
    Object? duration = freezed,
    Object? distance = freezed,
    Object? weight = freezed,
    Object? restTime = freezed,
  }) {
    return _then(_value.copyWith(
      sets: freezed == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int?,
      reps: freezed == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      restTime: freezed == restTime
          ? _value.restTime
          : restTime // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseMetricsImplCopyWith<$Res>
    implements $ExerciseMetricsCopyWith<$Res> {
  factory _$$ExerciseMetricsImplCopyWith(_$ExerciseMetricsImpl value,
          $Res Function(_$ExerciseMetricsImpl) then) =
      __$$ExerciseMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? sets,
      int? reps,
      int? duration,
      double? distance,
      double? weight,
      int? restTime});
}

/// @nodoc
class __$$ExerciseMetricsImplCopyWithImpl<$Res>
    extends _$ExerciseMetricsCopyWithImpl<$Res, _$ExerciseMetricsImpl>
    implements _$$ExerciseMetricsImplCopyWith<$Res> {
  __$$ExerciseMetricsImplCopyWithImpl(
      _$ExerciseMetricsImpl _value, $Res Function(_$ExerciseMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExerciseMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sets = freezed,
    Object? reps = freezed,
    Object? duration = freezed,
    Object? distance = freezed,
    Object? weight = freezed,
    Object? restTime = freezed,
  }) {
    return _then(_$ExerciseMetricsImpl(
      sets: freezed == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int?,
      reps: freezed == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as int?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      restTime: freezed == restTime
          ? _value.restTime
          : restTime // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseMetricsImpl implements _ExerciseMetrics {
  const _$ExerciseMetricsImpl(
      {this.sets,
      this.reps,
      this.duration,
      this.distance,
      this.weight,
      this.restTime});

  factory _$ExerciseMetricsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseMetricsImplFromJson(json);

  @override
  final int? sets;
  @override
  final int? reps;
  @override
  final int? duration;
// in seconds
  @override
  final double? distance;
// in km
  @override
  final double? weight;
// in kg
  @override
  final int? restTime;

  @override
  String toString() {
    return 'ExerciseMetrics(sets: $sets, reps: $reps, duration: $duration, distance: $distance, weight: $weight, restTime: $restTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseMetricsImpl &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.restTime, restTime) ||
                other.restTime == restTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, sets, reps, duration, distance, weight, restTime);

  /// Create a copy of ExerciseMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseMetricsImplCopyWith<_$ExerciseMetricsImpl> get copyWith =>
      __$$ExerciseMetricsImplCopyWithImpl<_$ExerciseMetricsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseMetricsImplToJson(
      this,
    );
  }
}

abstract class _ExerciseMetrics implements ExerciseMetrics {
  const factory _ExerciseMetrics(
      {final int? sets,
      final int? reps,
      final int? duration,
      final double? distance,
      final double? weight,
      final int? restTime}) = _$ExerciseMetricsImpl;

  factory _ExerciseMetrics.fromJson(Map<String, dynamic> json) =
      _$ExerciseMetricsImpl.fromJson;

  @override
  int? get sets;
  @override
  int? get reps;
  @override
  int? get duration; // in seconds
  @override
  double? get distance; // in km
  @override
  double? get weight; // in kg
  @override
  int? get restTime;

  /// Create a copy of ExerciseMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseMetricsImplCopyWith<_$ExerciseMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
