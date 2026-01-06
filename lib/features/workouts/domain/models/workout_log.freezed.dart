// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutLog _$WorkoutLogFromJson(Map<String, dynamic> json) {
  return _WorkoutLog.fromJson(json);
}

/// @nodoc
mixin _$WorkoutLog {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get workoutId => throw _privateConstructorUsedError;
  String get workoutName => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  int get duration =>
      throw _privateConstructorUsedError; // actual duration in minutes
  List<ExerciseLog> get exercises => throw _privateConstructorUsedError;
  int? get caloriesBurned => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  WorkoutDifficulty? get difficulty => throw _privateConstructorUsedError;
  WorkoutCategory? get category => throw _privateConstructorUsedError;

  /// Serializes this WorkoutLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutLogCopyWith<WorkoutLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutLogCopyWith<$Res> {
  factory $WorkoutLogCopyWith(
          WorkoutLog value, $Res Function(WorkoutLog) then) =
      _$WorkoutLogCopyWithImpl<$Res, WorkoutLog>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String workoutId,
      String workoutName,
      DateTime startedAt,
      DateTime? completedAt,
      int duration,
      List<ExerciseLog> exercises,
      int? caloriesBurned,
      String? notes,
      WorkoutDifficulty? difficulty,
      WorkoutCategory? category});
}

/// @nodoc
class _$WorkoutLogCopyWithImpl<$Res, $Val extends WorkoutLog>
    implements $WorkoutLogCopyWith<$Res> {
  _$WorkoutLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? workoutId = null,
    Object? workoutName = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? duration = null,
    Object? exercises = null,
    Object? caloriesBurned = freezed,
    Object? notes = freezed,
    Object? difficulty = freezed,
    Object? category = freezed,
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
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseLog>,
      caloriesBurned: freezed == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WorkoutDifficulty?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as WorkoutCategory?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutLogImplCopyWith<$Res>
    implements $WorkoutLogCopyWith<$Res> {
  factory _$$WorkoutLogImplCopyWith(
          _$WorkoutLogImpl value, $Res Function(_$WorkoutLogImpl) then) =
      __$$WorkoutLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String workoutId,
      String workoutName,
      DateTime startedAt,
      DateTime? completedAt,
      int duration,
      List<ExerciseLog> exercises,
      int? caloriesBurned,
      String? notes,
      WorkoutDifficulty? difficulty,
      WorkoutCategory? category});
}

/// @nodoc
class __$$WorkoutLogImplCopyWithImpl<$Res>
    extends _$WorkoutLogCopyWithImpl<$Res, _$WorkoutLogImpl>
    implements _$$WorkoutLogImplCopyWith<$Res> {
  __$$WorkoutLogImplCopyWithImpl(
      _$WorkoutLogImpl _value, $Res Function(_$WorkoutLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? workoutId = null,
    Object? workoutName = null,
    Object? startedAt = null,
    Object? completedAt = freezed,
    Object? duration = null,
    Object? exercises = null,
    Object? caloriesBurned = freezed,
    Object? notes = freezed,
    Object? difficulty = freezed,
    Object? category = freezed,
  }) {
    return _then(_$WorkoutLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutId: null == workoutId
          ? _value.workoutId
          : workoutId // ignore: cast_nullable_to_non_nullable
              as String,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<ExerciseLog>,
      caloriesBurned: freezed == caloriesBurned
          ? _value.caloriesBurned
          : caloriesBurned // ignore: cast_nullable_to_non_nullable
              as int?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as WorkoutDifficulty?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as WorkoutCategory?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutLogImpl implements _WorkoutLog {
  const _$WorkoutLogImpl(
      {required this.id,
      required this.userId,
      required this.workoutId,
      required this.workoutName,
      required this.startedAt,
      this.completedAt,
      required this.duration,
      required final List<ExerciseLog> exercises,
      this.caloriesBurned,
      this.notes,
      this.difficulty,
      this.category})
      : _exercises = exercises;

  factory _$WorkoutLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutLogImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String workoutId;
  @override
  final String workoutName;
  @override
  final DateTime startedAt;
  @override
  final DateTime? completedAt;
  @override
  final int duration;
// actual duration in minutes
  final List<ExerciseLog> _exercises;
// actual duration in minutes
  @override
  List<ExerciseLog> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  final int? caloriesBurned;
  @override
  final String? notes;
  @override
  final WorkoutDifficulty? difficulty;
  @override
  final WorkoutCategory? category;

  @override
  String toString() {
    return 'WorkoutLog(id: $id, userId: $userId, workoutId: $workoutId, workoutName: $workoutName, startedAt: $startedAt, completedAt: $completedAt, duration: $duration, exercises: $exercises, caloriesBurned: $caloriesBurned, notes: $notes, difficulty: $difficulty, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.workoutId, workoutId) ||
                other.workoutId == workoutId) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises) &&
            (identical(other.caloriesBurned, caloriesBurned) ||
                other.caloriesBurned == caloriesBurned) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      workoutId,
      workoutName,
      startedAt,
      completedAt,
      duration,
      const DeepCollectionEquality().hash(_exercises),
      caloriesBurned,
      notes,
      difficulty,
      category);

  /// Create a copy of WorkoutLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutLogImplCopyWith<_$WorkoutLogImpl> get copyWith =>
      __$$WorkoutLogImplCopyWithImpl<_$WorkoutLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutLogImplToJson(
      this,
    );
  }
}

abstract class _WorkoutLog implements WorkoutLog {
  const factory _WorkoutLog(
      {required final String id,
      required final String userId,
      required final String workoutId,
      required final String workoutName,
      required final DateTime startedAt,
      final DateTime? completedAt,
      required final int duration,
      required final List<ExerciseLog> exercises,
      final int? caloriesBurned,
      final String? notes,
      final WorkoutDifficulty? difficulty,
      final WorkoutCategory? category}) = _$WorkoutLogImpl;

  factory _WorkoutLog.fromJson(Map<String, dynamic> json) =
      _$WorkoutLogImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get workoutId;
  @override
  String get workoutName;
  @override
  DateTime get startedAt;
  @override
  DateTime? get completedAt;
  @override
  int get duration; // actual duration in minutes
  @override
  List<ExerciseLog> get exercises;
  @override
  int? get caloriesBurned;
  @override
  String? get notes;
  @override
  WorkoutDifficulty? get difficulty;
  @override
  WorkoutCategory? get category;

  /// Create a copy of WorkoutLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutLogImplCopyWith<_$WorkoutLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExerciseLog _$ExerciseLogFromJson(Map<String, dynamic> json) {
  return _ExerciseLog.fromJson(json);
}

/// @nodoc
mixin _$ExerciseLog {
  String get exerciseId => throw _privateConstructorUsedError;
  String get exerciseName => throw _privateConstructorUsedError;
  ExerciseType get type => throw _privateConstructorUsedError;
  List<SetLog> get sets => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this ExerciseLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseLogCopyWith<ExerciseLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseLogCopyWith<$Res> {
  factory $ExerciseLogCopyWith(
          ExerciseLog value, $Res Function(ExerciseLog) then) =
      _$ExerciseLogCopyWithImpl<$Res, ExerciseLog>;
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      ExerciseType type,
      List<SetLog> sets,
      String? notes});
}

/// @nodoc
class _$ExerciseLogCopyWithImpl<$Res, $Val extends ExerciseLog>
    implements $ExerciseLogCopyWith<$Res> {
  _$ExerciseLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? type = null,
    Object? sets = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetLog>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseLogImplCopyWith<$Res>
    implements $ExerciseLogCopyWith<$Res> {
  factory _$$ExerciseLogImplCopyWith(
          _$ExerciseLogImpl value, $Res Function(_$ExerciseLogImpl) then) =
      __$$ExerciseLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String exerciseId,
      String exerciseName,
      ExerciseType type,
      List<SetLog> sets,
      String? notes});
}

/// @nodoc
class __$$ExerciseLogImplCopyWithImpl<$Res>
    extends _$ExerciseLogCopyWithImpl<$Res, _$ExerciseLogImpl>
    implements _$$ExerciseLogImplCopyWith<$Res> {
  __$$ExerciseLogImplCopyWithImpl(
      _$ExerciseLogImpl _value, $Res Function(_$ExerciseLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExerciseLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? exerciseName = null,
    Object? type = null,
    Object? sets = null,
    Object? notes = freezed,
  }) {
    return _then(_$ExerciseLogImpl(
      exerciseId: null == exerciseId
          ? _value.exerciseId
          : exerciseId // ignore: cast_nullable_to_non_nullable
              as String,
      exerciseName: null == exerciseName
          ? _value.exerciseName
          : exerciseName // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ExerciseType,
      sets: null == sets
          ? _value._sets
          : sets // ignore: cast_nullable_to_non_nullable
              as List<SetLog>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseLogImpl implements _ExerciseLog {
  const _$ExerciseLogImpl(
      {required this.exerciseId,
      required this.exerciseName,
      required this.type,
      required final List<SetLog> sets,
      this.notes})
      : _sets = sets;

  factory _$ExerciseLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseLogImplFromJson(json);

  @override
  final String exerciseId;
  @override
  final String exerciseName;
  @override
  final ExerciseType type;
  final List<SetLog> _sets;
  @override
  List<SetLog> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  @override
  final String? notes;

  @override
  String toString() {
    return 'ExerciseLog(exerciseId: $exerciseId, exerciseName: $exerciseName, type: $type, sets: $sets, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseLogImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, exerciseId, exerciseName, type,
      const DeepCollectionEquality().hash(_sets), notes);

  /// Create a copy of ExerciseLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseLogImplCopyWith<_$ExerciseLogImpl> get copyWith =>
      __$$ExerciseLogImplCopyWithImpl<_$ExerciseLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseLogImplToJson(
      this,
    );
  }
}

abstract class _ExerciseLog implements ExerciseLog {
  const factory _ExerciseLog(
      {required final String exerciseId,
      required final String exerciseName,
      required final ExerciseType type,
      required final List<SetLog> sets,
      final String? notes}) = _$ExerciseLogImpl;

  factory _ExerciseLog.fromJson(Map<String, dynamic> json) =
      _$ExerciseLogImpl.fromJson;

  @override
  String get exerciseId;
  @override
  String get exerciseName;
  @override
  ExerciseType get type;
  @override
  List<SetLog> get sets;
  @override
  String? get notes;

  /// Create a copy of ExerciseLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseLogImplCopyWith<_$ExerciseLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SetLog _$SetLogFromJson(Map<String, dynamic> json) {
  return _SetLog.fromJson(json);
}

/// @nodoc
mixin _$SetLog {
  int get setNumber => throw _privateConstructorUsedError;
  int? get reps => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError; // in seconds
  double? get distance => throw _privateConstructorUsedError; // in km
  double? get weight => throw _privateConstructorUsedError; // in kg
  bool? get completed => throw _privateConstructorUsedError;

  /// Serializes this SetLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetLogCopyWith<SetLog> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetLogCopyWith<$Res> {
  factory $SetLogCopyWith(SetLog value, $Res Function(SetLog) then) =
      _$SetLogCopyWithImpl<$Res, SetLog>;
  @useResult
  $Res call(
      {int setNumber,
      int? reps,
      int? duration,
      double? distance,
      double? weight,
      bool? completed});
}

/// @nodoc
class _$SetLogCopyWithImpl<$Res, $Val extends SetLog>
    implements $SetLogCopyWith<$Res> {
  _$SetLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setNumber = null,
    Object? reps = freezed,
    Object? duration = freezed,
    Object? distance = freezed,
    Object? weight = freezed,
    Object? completed = freezed,
  }) {
    return _then(_value.copyWith(
      setNumber: null == setNumber
          ? _value.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
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
      completed: freezed == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SetLogImplCopyWith<$Res> implements $SetLogCopyWith<$Res> {
  factory _$$SetLogImplCopyWith(
          _$SetLogImpl value, $Res Function(_$SetLogImpl) then) =
      __$$SetLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int setNumber,
      int? reps,
      int? duration,
      double? distance,
      double? weight,
      bool? completed});
}

/// @nodoc
class __$$SetLogImplCopyWithImpl<$Res>
    extends _$SetLogCopyWithImpl<$Res, _$SetLogImpl>
    implements _$$SetLogImplCopyWith<$Res> {
  __$$SetLogImplCopyWithImpl(
      _$SetLogImpl _value, $Res Function(_$SetLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of SetLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? setNumber = null,
    Object? reps = freezed,
    Object? duration = freezed,
    Object? distance = freezed,
    Object? weight = freezed,
    Object? completed = freezed,
  }) {
    return _then(_$SetLogImpl(
      setNumber: null == setNumber
          ? _value.setNumber
          : setNumber // ignore: cast_nullable_to_non_nullable
              as int,
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
      completed: freezed == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SetLogImpl implements _SetLog {
  const _$SetLogImpl(
      {required this.setNumber,
      this.reps,
      this.duration,
      this.distance,
      this.weight,
      this.completed});

  factory _$SetLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetLogImplFromJson(json);

  @override
  final int setNumber;
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
  final bool? completed;

  @override
  String toString() {
    return 'SetLog(setNumber: $setNumber, reps: $reps, duration: $duration, distance: $distance, weight: $weight, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetLogImpl &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, setNumber, reps, duration, distance, weight, completed);

  /// Create a copy of SetLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetLogImplCopyWith<_$SetLogImpl> get copyWith =>
      __$$SetLogImplCopyWithImpl<_$SetLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetLogImplToJson(
      this,
    );
  }
}

abstract class _SetLog implements SetLog {
  const factory _SetLog(
      {required final int setNumber,
      final int? reps,
      final int? duration,
      final double? distance,
      final double? weight,
      final bool? completed}) = _$SetLogImpl;

  factory _SetLog.fromJson(Map<String, dynamic> json) = _$SetLogImpl.fromJson;

  @override
  int get setNumber;
  @override
  int? get reps;
  @override
  int? get duration; // in seconds
  @override
  double? get distance; // in km
  @override
  double? get weight; // in kg
  @override
  bool? get completed;

  /// Create a copy of SetLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetLogImplCopyWith<_$SetLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
