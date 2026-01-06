// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Workout _$WorkoutFromJson(Map<String, dynamic> json) {
  return _Workout.fromJson(json);
}

/// @nodoc
mixin _$Workout {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  WorkoutDifficulty get difficulty => throw _privateConstructorUsedError;
  int get estimatedDuration => throw _privateConstructorUsedError; // in minutes
  List<Exercise> get exercises => throw _privateConstructorUsedError;
  WorkoutCategory get category => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  List<String>? get tags => throw _privateConstructorUsedError;
  int? get caloriesBurned => throw _privateConstructorUsedError;
  String? get equipment => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String? get createdBy => throw _privateConstructorUsedError;

  /// Serializes this Workout to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutCopyWith<Workout> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutCopyWith<$Res> {
  factory $WorkoutCopyWith(Workout value, $Res Function(Workout) then) =
      _$WorkoutCopyWithImpl<$Res, Workout>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      WorkoutDifficulty difficulty,
      int estimatedDuration,
      List<Exercise> exercises,
      WorkoutCategory category,
      String? imageUrl,
      List<String>? tags,
      int? caloriesBurned,
      String? equipment,
      DateTime? createdAt,
      String? createdBy});
}

/// @nodoc
class _$WorkoutCopyWithImpl<$Res, $Val extends Workout>
    implements $WorkoutCopyWith<$Res> {
  _$WorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? difficulty = null,
    Object? estimatedDuration = null,
    Object? exercises = null,
    Object? category = null,
    Object? imageUrl = freezed,
    Object? tags = freezed,
    Object? caloriesBurned = freezed,
    Object? equipment = freezed,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
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
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WorkoutDifficulty,
      estimatedDuration: null == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as WorkoutCategory,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      caloriesBurned: freezed == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int?,
      equipment: freezed == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutImplCopyWith<$Res> implements $WorkoutCopyWith<$Res> {
  factory _$$WorkoutImplCopyWith(
          _$WorkoutImpl value, $Res Function(_$WorkoutImpl) then) =
      __$$WorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      WorkoutDifficulty difficulty,
      int estimatedDuration,
      List<Exercise> exercises,
      WorkoutCategory category,
      String? imageUrl,
      List<String>? tags,
      int? caloriesBurned,
      String? equipment,
      DateTime? createdAt,
      String? createdBy});
}

/// @nodoc
class __$$WorkoutImplCopyWithImpl<$Res>
    extends _$WorkoutCopyWithImpl<$Res, _$WorkoutImpl>
    implements _$$WorkoutImplCopyWith<$Res> {
  __$$WorkoutImplCopyWithImpl(
      _$WorkoutImpl _value, $Res Function(_$WorkoutImpl) _then)
      : super(_value, _then);

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? difficulty = null,
    Object? estimatedDuration = null,
    Object? exercises = null,
    Object? category = null,
    Object? imageUrl = freezed,
    Object? tags = freezed,
    Object? caloriesBurned = freezed,
    Object? equipment = freezed,
    Object? createdAt = freezed,
    Object? createdBy = freezed,
  }) {
    return _then(_$WorkoutImpl(
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
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WorkoutDifficulty,
      estimatedDuration: null == estimatedDuration
          ? _value.estimatedDuration
          : estimatedDuration // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as WorkoutCategory,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      caloriesBurned: freezed == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int?,
      equipment: freezed == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdBy: freezed == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutImpl implements _Workout {
  const _$WorkoutImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.difficulty,
      required this.estimatedDuration,
      required final List<Exercise> exercises,
      required this.category,
      this.imageUrl,
      final List<String>? tags,
      this.caloriesBurned,
      this.equipment,
      this.createdAt,
      this.createdBy})
      : _exercises = exercises,
        _tags = tags;

  factory _$WorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final WorkoutDifficulty difficulty;
  @override
  final int estimatedDuration;
// in minutes
  final List<Exercise> _exercises;
// in minutes
  @override
  List<Exercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  final WorkoutCategory category;
  @override
  final String? imageUrl;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final int? caloriesBurned;
  @override
  final String? equipment;
  @override
  final DateTime? createdAt;
  @override
  final String? createdBy;

  @override
  String toString() {
    return 'Workout(id: $id, name: $name, description: $description, difficulty: $difficulty, estimatedDuration: $estimatedDuration, exercises: $exercises, category: $category, imageUrl: $imageUrl, tags: $tags, caloriesBurned: $caloriesBurned, equipment: $equipment, createdAt: $createdAt, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.estimatedDuration, estimatedDuration) ||
                other.estimatedDuration == estimatedDuration) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.caloriesBurned, caloriesBurned) ||
                other.caloriesBurned == caloriesBurned) &&
            (identical(other.equipment, equipment) ||
                other.equipment == equipment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      difficulty,
      estimatedDuration,
      const DeepCollectionEquality().hash(_exercises),
      category,
      imageUrl,
      const DeepCollectionEquality().hash(_tags),
      caloriesBurned,
      equipment,
      createdAt,
      createdBy);

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      __$$WorkoutImplCopyWithImpl<_$WorkoutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutImplToJson(
      this,
    );
  }
}

abstract class _Workout implements Workout {
  const factory _Workout(
      {required final String id,
      required final String name,
      required final String description,
      required final WorkoutDifficulty difficulty,
      required final int estimatedDuration,
      required final List<Exercise> exercises,
      required final WorkoutCategory category,
      final String? imageUrl,
      final List<String>? tags,
      final int? caloriesBurned,
      final String? equipment,
      final DateTime? createdAt,
      final String? createdBy}) = _$WorkoutImpl;

  factory _Workout.fromJson(Map<String, dynamic> json) = _$WorkoutImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  WorkoutDifficulty get difficulty;
  @override
  int get estimatedDuration; // in minutes
  @override
  List<Exercise> get exercises;
  @override
  WorkoutCategory get category;
  @override
  String? get imageUrl;
  @override
  List<String>? get tags;
  @override
  int? get caloriesBurned;
  @override
  String? get equipment;
  @override
  DateTime? get createdAt;
  @override
  String? get createdBy;

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
