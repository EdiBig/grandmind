// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Habit _$HabitFromJson(Map<String, dynamic> json) {
  return _Habit.fromJson(json);
}

/// @nodoc
mixin _$Habit {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  HabitFrequency get frequency => throw _privateConstructorUsedError;
  HabitIcon get icon => throw _privateConstructorUsedError;
  HabitColor get color => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get targetCount =>
      throw _privateConstructorUsedError; // For quantifiable habits (e.g., 8 glasses of water)
  String? get unit =>
      throw _privateConstructorUsedError; // e.g., "glasses", "minutes", "steps"
  List<int> get daysOfWeek =>
      throw _privateConstructorUsedError; // For weekly habits: 1=Monday, 7=Sunday
  @NullableTimestampConverter()
  DateTime? get lastCompletedAt => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;

  /// Serializes this Habit to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitCopyWith<Habit> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitCopyWith<$Res> {
  factory $HabitCopyWith(Habit value, $Res Function(Habit) then) =
      _$HabitCopyWithImpl<$Res, Habit>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String description,
      HabitFrequency frequency,
      HabitIcon icon,
      HabitColor color,
      @TimestampConverter() DateTime createdAt,
      bool isActive,
      int targetCount,
      String? unit,
      List<int> daysOfWeek,
      @NullableTimestampConverter() DateTime? lastCompletedAt,
      int currentStreak,
      int longestStreak});
}

/// @nodoc
class _$HabitCopyWithImpl<$Res, $Val extends Habit>
    implements $HabitCopyWith<$Res> {
  _$HabitCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = null,
    Object? frequency = null,
    Object? icon = null,
    Object? color = null,
    Object? createdAt = null,
    Object? isActive = null,
    Object? targetCount = null,
    Object? unit = freezed,
    Object? daysOfWeek = null,
    Object? lastCompletedAt = freezed,
    Object? currentStreak = null,
    Object? longestStreak = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as HabitFrequency,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as HabitIcon,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as HabitColor,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      targetCount: null == targetCount
          ? _value.targetCount
          : targetCount // ignore: cast_nullable_to_non_nullable
              as int,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      daysOfWeek: null == daysOfWeek
          ? _value.daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      lastCompletedAt: freezed == lastCompletedAt
          ? _value.lastCompletedAt
          : lastCompletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitImplCopyWith<$Res> implements $HabitCopyWith<$Res> {
  factory _$$HabitImplCopyWith(
          _$HabitImpl value, $Res Function(_$HabitImpl) then) =
      __$$HabitImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String name,
      String description,
      HabitFrequency frequency,
      HabitIcon icon,
      HabitColor color,
      @TimestampConverter() DateTime createdAt,
      bool isActive,
      int targetCount,
      String? unit,
      List<int> daysOfWeek,
      @NullableTimestampConverter() DateTime? lastCompletedAt,
      int currentStreak,
      int longestStreak});
}

/// @nodoc
class __$$HabitImplCopyWithImpl<$Res>
    extends _$HabitCopyWithImpl<$Res, _$HabitImpl>
    implements _$$HabitImplCopyWith<$Res> {
  __$$HabitImplCopyWithImpl(
      _$HabitImpl _value, $Res Function(_$HabitImpl) _then)
      : super(_value, _then);

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? description = null,
    Object? frequency = null,
    Object? icon = null,
    Object? color = null,
    Object? createdAt = null,
    Object? isActive = null,
    Object? targetCount = null,
    Object? unit = freezed,
    Object? daysOfWeek = null,
    Object? lastCompletedAt = freezed,
    Object? currentStreak = null,
    Object? longestStreak = null,
  }) {
    return _then(_$HabitImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as HabitFrequency,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as HabitIcon,
      color: null == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as HabitColor,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      targetCount: null == targetCount
          ? _value.targetCount
          : targetCount // ignore: cast_nullable_to_non_nullable
              as int,
      unit: freezed == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String?,
      daysOfWeek: null == daysOfWeek
          ? _value._daysOfWeek
          : daysOfWeek // ignore: cast_nullable_to_non_nullable
              as List<int>,
      lastCompletedAt: freezed == lastCompletedAt
          ? _value.lastCompletedAt
          : lastCompletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitImpl implements _Habit {
  const _$HabitImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.description,
      required this.frequency,
      required this.icon,
      required this.color,
      @TimestampConverter() required this.createdAt,
      this.isActive = true,
      this.targetCount = 0,
      this.unit,
      final List<int> daysOfWeek = const [],
      @NullableTimestampConverter() this.lastCompletedAt,
      this.currentStreak = 0,
      this.longestStreak = 0})
      : _daysOfWeek = daysOfWeek;

  factory _$HabitImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String description;
  @override
  final HabitFrequency frequency;
  @override
  final HabitIcon icon;
  @override
  final HabitColor color;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int targetCount;
// For quantifiable habits (e.g., 8 glasses of water)
  @override
  final String? unit;
// e.g., "glasses", "minutes", "steps"
  final List<int> _daysOfWeek;
// e.g., "glasses", "minutes", "steps"
  @override
  @JsonKey()
  List<int> get daysOfWeek {
    if (_daysOfWeek is EqualUnmodifiableListView) return _daysOfWeek;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_daysOfWeek);
  }

// For weekly habits: 1=Monday, 7=Sunday
  @override
  @NullableTimestampConverter()
  final DateTime? lastCompletedAt;
  @override
  @JsonKey()
  final int currentStreak;
  @override
  @JsonKey()
  final int longestStreak;

  @override
  String toString() {
    return 'Habit(id: $id, userId: $userId, name: $name, description: $description, frequency: $frequency, icon: $icon, color: $color, createdAt: $createdAt, isActive: $isActive, targetCount: $targetCount, unit: $unit, daysOfWeek: $daysOfWeek, lastCompletedAt: $lastCompletedAt, currentStreak: $currentStreak, longestStreak: $longestStreak)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.targetCount, targetCount) ||
                other.targetCount == targetCount) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            const DeepCollectionEquality()
                .equals(other._daysOfWeek, _daysOfWeek) &&
            (identical(other.lastCompletedAt, lastCompletedAt) ||
                other.lastCompletedAt == lastCompletedAt) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      name,
      description,
      frequency,
      icon,
      color,
      createdAt,
      isActive,
      targetCount,
      unit,
      const DeepCollectionEquality().hash(_daysOfWeek),
      lastCompletedAt,
      currentStreak,
      longestStreak);

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitImplCopyWith<_$HabitImpl> get copyWith =>
      __$$HabitImplCopyWithImpl<_$HabitImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitImplToJson(
      this,
    );
  }
}

abstract class _Habit implements Habit {
  const factory _Habit(
      {required final String id,
      required final String userId,
      required final String name,
      required final String description,
      required final HabitFrequency frequency,
      required final HabitIcon icon,
      required final HabitColor color,
      @TimestampConverter() required final DateTime createdAt,
      final bool isActive,
      final int targetCount,
      final String? unit,
      final List<int> daysOfWeek,
      @NullableTimestampConverter() final DateTime? lastCompletedAt,
      final int currentStreak,
      final int longestStreak}) = _$HabitImpl;

  factory _Habit.fromJson(Map<String, dynamic> json) = _$HabitImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get description;
  @override
  HabitFrequency get frequency;
  @override
  HabitIcon get icon;
  @override
  HabitColor get color;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  bool get isActive;
  @override
  int get targetCount; // For quantifiable habits (e.g., 8 glasses of water)
  @override
  String? get unit; // e.g., "glasses", "minutes", "steps"
  @override
  List<int> get daysOfWeek; // For weekly habits: 1=Monday, 7=Sunday
  @override
  @NullableTimestampConverter()
  DateTime? get lastCompletedAt;
  @override
  int get currentStreak;
  @override
  int get longestStreak;

  /// Create a copy of Habit
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitImplCopyWith<_$HabitImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
