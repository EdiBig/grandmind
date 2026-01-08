// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NutritionGoal _$NutritionGoalFromJson(Map<String, dynamic> json) {
  return _NutritionGoal.fromJson(json);
}

/// @nodoc
mixin _$NutritionGoal {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get dailyCalories => throw _privateConstructorUsedError;
  double get dailyProteinGrams => throw _privateConstructorUsedError;
  double get dailyCarbsGrams => throw _privateConstructorUsedError;
  double get dailyFatGrams => throw _privateConstructorUsedError;
  int get dailyWaterGlasses => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdAt => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this NutritionGoal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NutritionGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NutritionGoalCopyWith<NutritionGoal> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NutritionGoalCopyWith<$Res> {
  factory $NutritionGoalCopyWith(
          NutritionGoal value, $Res Function(NutritionGoal) then) =
      _$NutritionGoalCopyWithImpl<$Res, NutritionGoal>;
  @useResult
  $Res call(
      {String id,
      String userId,
      double dailyCalories,
      double dailyProteinGrams,
      double dailyCarbsGrams,
      double dailyFatGrams,
      int dailyWaterGlasses,
      @TimestampConverter() DateTime createdAt,
      @NullableTimestampConverter() DateTime? updatedAt,
      bool isActive});
}

/// @nodoc
class _$NutritionGoalCopyWithImpl<$Res, $Val extends NutritionGoal>
    implements $NutritionGoalCopyWith<$Res> {
  _$NutritionGoalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NutritionGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? dailyCalories = null,
    Object? dailyProteinGrams = null,
    Object? dailyCarbsGrams = null,
    Object? dailyFatGrams = null,
    Object? dailyWaterGlasses = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isActive = null,
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
      dailyCalories: null == dailyCalories
          ? _value.dailyCalories
          : dailyCalories // ignore: cast_nullable_to_non_nullable
              as double,
      dailyProteinGrams: null == dailyProteinGrams
          ? _value.dailyProteinGrams
          : dailyProteinGrams // ignore: cast_nullable_to_non_nullable
              as double,
      dailyCarbsGrams: null == dailyCarbsGrams
          ? _value.dailyCarbsGrams
          : dailyCarbsGrams // ignore: cast_nullable_to_non_nullable
              as double,
      dailyFatGrams: null == dailyFatGrams
          ? _value.dailyFatGrams
          : dailyFatGrams // ignore: cast_nullable_to_non_nullable
              as double,
      dailyWaterGlasses: null == dailyWaterGlasses
          ? _value.dailyWaterGlasses
          : dailyWaterGlasses // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NutritionGoalImplCopyWith<$Res>
    implements $NutritionGoalCopyWith<$Res> {
  factory _$$NutritionGoalImplCopyWith(
          _$NutritionGoalImpl value, $Res Function(_$NutritionGoalImpl) then) =
      __$$NutritionGoalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      double dailyCalories,
      double dailyProteinGrams,
      double dailyCarbsGrams,
      double dailyFatGrams,
      int dailyWaterGlasses,
      @TimestampConverter() DateTime createdAt,
      @NullableTimestampConverter() DateTime? updatedAt,
      bool isActive});
}

/// @nodoc
class __$$NutritionGoalImplCopyWithImpl<$Res>
    extends _$NutritionGoalCopyWithImpl<$Res, _$NutritionGoalImpl>
    implements _$$NutritionGoalImplCopyWith<$Res> {
  __$$NutritionGoalImplCopyWithImpl(
      _$NutritionGoalImpl _value, $Res Function(_$NutritionGoalImpl) _then)
      : super(_value, _then);

  /// Create a copy of NutritionGoal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? dailyCalories = null,
    Object? dailyProteinGrams = null,
    Object? dailyCarbsGrams = null,
    Object? dailyFatGrams = null,
    Object? dailyWaterGlasses = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? isActive = null,
  }) {
    return _then(_$NutritionGoalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      dailyCalories: null == dailyCalories
          ? _value.dailyCalories
          : dailyCalories // ignore: cast_nullable_to_non_nullable
              as double,
      dailyProteinGrams: null == dailyProteinGrams
          ? _value.dailyProteinGrams
          : dailyProteinGrams // ignore: cast_nullable_to_non_nullable
              as double,
      dailyCarbsGrams: null == dailyCarbsGrams
          ? _value.dailyCarbsGrams
          : dailyCarbsGrams // ignore: cast_nullable_to_non_nullable
              as double,
      dailyFatGrams: null == dailyFatGrams
          ? _value.dailyFatGrams
          : dailyFatGrams // ignore: cast_nullable_to_non_nullable
              as double,
      dailyWaterGlasses: null == dailyWaterGlasses
          ? _value.dailyWaterGlasses
          : dailyWaterGlasses // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NutritionGoalImpl extends _NutritionGoal {
  const _$NutritionGoalImpl(
      {required this.id,
      required this.userId,
      this.dailyCalories = 2000.0,
      this.dailyProteinGrams = 150.0,
      this.dailyCarbsGrams = 250.0,
      this.dailyFatGrams = 65.0,
      this.dailyWaterGlasses = 8,
      @TimestampConverter() required this.createdAt,
      @NullableTimestampConverter() this.updatedAt,
      this.isActive = true})
      : super._();

  factory _$NutritionGoalImpl.fromJson(Map<String, dynamic> json) =>
      _$$NutritionGoalImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @JsonKey()
  final double dailyCalories;
  @override
  @JsonKey()
  final double dailyProteinGrams;
  @override
  @JsonKey()
  final double dailyCarbsGrams;
  @override
  @JsonKey()
  final double dailyFatGrams;
  @override
  @JsonKey()
  final int dailyWaterGlasses;
  @override
  @TimestampConverter()
  final DateTime createdAt;
  @override
  @NullableTimestampConverter()
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'NutritionGoal(id: $id, userId: $userId, dailyCalories: $dailyCalories, dailyProteinGrams: $dailyProteinGrams, dailyCarbsGrams: $dailyCarbsGrams, dailyFatGrams: $dailyFatGrams, dailyWaterGlasses: $dailyWaterGlasses, createdAt: $createdAt, updatedAt: $updatedAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionGoalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.dailyCalories, dailyCalories) ||
                other.dailyCalories == dailyCalories) &&
            (identical(other.dailyProteinGrams, dailyProteinGrams) ||
                other.dailyProteinGrams == dailyProteinGrams) &&
            (identical(other.dailyCarbsGrams, dailyCarbsGrams) ||
                other.dailyCarbsGrams == dailyCarbsGrams) &&
            (identical(other.dailyFatGrams, dailyFatGrams) ||
                other.dailyFatGrams == dailyFatGrams) &&
            (identical(other.dailyWaterGlasses, dailyWaterGlasses) ||
                other.dailyWaterGlasses == dailyWaterGlasses) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      dailyCalories,
      dailyProteinGrams,
      dailyCarbsGrams,
      dailyFatGrams,
      dailyWaterGlasses,
      createdAt,
      updatedAt,
      isActive);

  /// Create a copy of NutritionGoal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionGoalImplCopyWith<_$NutritionGoalImpl> get copyWith =>
      __$$NutritionGoalImplCopyWithImpl<_$NutritionGoalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NutritionGoalImplToJson(
      this,
    );
  }
}

abstract class _NutritionGoal extends NutritionGoal {
  const factory _NutritionGoal(
      {required final String id,
      required final String userId,
      final double dailyCalories,
      final double dailyProteinGrams,
      final double dailyCarbsGrams,
      final double dailyFatGrams,
      final int dailyWaterGlasses,
      @TimestampConverter() required final DateTime createdAt,
      @NullableTimestampConverter() final DateTime? updatedAt,
      final bool isActive}) = _$NutritionGoalImpl;
  const _NutritionGoal._() : super._();

  factory _NutritionGoal.fromJson(Map<String, dynamic> json) =
      _$NutritionGoalImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  double get dailyCalories;
  @override
  double get dailyProteinGrams;
  @override
  double get dailyCarbsGrams;
  @override
  double get dailyFatGrams;
  @override
  int get dailyWaterGlasses;
  @override
  @TimestampConverter()
  DateTime get createdAt;
  @override
  @NullableTimestampConverter()
  DateTime? get updatedAt;
  @override
  bool get isActive;

  /// Create a copy of NutritionGoal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionGoalImplCopyWith<_$NutritionGoalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
