// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_nutrition_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DailyNutritionSummary _$DailyNutritionSummaryFromJson(
    Map<String, dynamic> json) {
  return _DailyNutritionSummary.fromJson(json);
}

/// @nodoc
mixin _$DailyNutritionSummary {
  String get userId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get date =>
      throw _privateConstructorUsedError; // Day being summarized
  double get totalCalories => throw _privateConstructorUsedError;
  double get totalProtein => throw _privateConstructorUsedError;
  double get totalCarbs => throw _privateConstructorUsedError;
  double get totalFat => throw _privateConstructorUsedError;
  int get waterGlasses => throw _privateConstructorUsedError;
  int get mealsLogged =>
      throw _privateConstructorUsedError; // Number of meals logged this day
  Map<MealType, double>? get caloriesByMeal =>
      throw _privateConstructorUsedError; // Calories breakdown by meal type
  NutritionGoal? get goal => throw _privateConstructorUsedError;

  /// Serializes this DailyNutritionSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyNutritionSummaryCopyWith<DailyNutritionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyNutritionSummaryCopyWith<$Res> {
  factory $DailyNutritionSummaryCopyWith(DailyNutritionSummary value,
          $Res Function(DailyNutritionSummary) then) =
      _$DailyNutritionSummaryCopyWithImpl<$Res, DailyNutritionSummary>;
  @useResult
  $Res call(
      {String userId,
      @TimestampConverter() DateTime date,
      double totalCalories,
      double totalProtein,
      double totalCarbs,
      double totalFat,
      int waterGlasses,
      int mealsLogged,
      Map<MealType, double>? caloriesByMeal,
      NutritionGoal? goal});

  $NutritionGoalCopyWith<$Res>? get goal;
}

/// @nodoc
class _$DailyNutritionSummaryCopyWithImpl<$Res,
        $Val extends DailyNutritionSummary>
    implements $DailyNutritionSummaryCopyWith<$Res> {
  _$DailyNutritionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? date = null,
    Object? totalCalories = null,
    Object? totalProtein = null,
    Object? totalCarbs = null,
    Object? totalFat = null,
    Object? waterGlasses = null,
    Object? mealsLogged = null,
    Object? caloriesByMeal = freezed,
    Object? goal = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalCalories: null == totalCalories
          ? _value.totalCalories
          : totalCalories // ignore: cast_nullable_to_non_nullable
              as double,
      totalProtein: null == totalProtein
          ? _value.totalProtein
          : totalProtein // ignore: cast_nullable_to_non_nullable
              as double,
      totalCarbs: null == totalCarbs
          ? _value.totalCarbs
          : totalCarbs // ignore: cast_nullable_to_non_nullable
              as double,
      totalFat: null == totalFat
          ? _value.totalFat
          : totalFat // ignore: cast_nullable_to_non_nullable
              as double,
      waterGlasses: null == waterGlasses
          ? _value.waterGlasses
          : waterGlasses // ignore: cast_nullable_to_non_nullable
              as int,
      mealsLogged: null == mealsLogged
          ? _value.mealsLogged
          : mealsLogged // ignore: cast_nullable_to_non_nullable
              as int,
      caloriesByMeal: freezed == caloriesByMeal
          ? _value.caloriesByMeal
          : caloriesByMeal // ignore: cast_nullable_to_non_nullable
              as Map<MealType, double>?,
      goal: freezed == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as NutritionGoal?,
    ) as $Val);
  }

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionGoalCopyWith<$Res>? get goal {
    if (_value.goal == null) {
      return null;
    }

    return $NutritionGoalCopyWith<$Res>(_value.goal!, (value) {
      return _then(_value.copyWith(goal: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyNutritionSummaryImplCopyWith<$Res>
    implements $DailyNutritionSummaryCopyWith<$Res> {
  factory _$$DailyNutritionSummaryImplCopyWith(
          _$DailyNutritionSummaryImpl value,
          $Res Function(_$DailyNutritionSummaryImpl) then) =
      __$$DailyNutritionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      @TimestampConverter() DateTime date,
      double totalCalories,
      double totalProtein,
      double totalCarbs,
      double totalFat,
      int waterGlasses,
      int mealsLogged,
      Map<MealType, double>? caloriesByMeal,
      NutritionGoal? goal});

  @override
  $NutritionGoalCopyWith<$Res>? get goal;
}

/// @nodoc
class __$$DailyNutritionSummaryImplCopyWithImpl<$Res>
    extends _$DailyNutritionSummaryCopyWithImpl<$Res,
        _$DailyNutritionSummaryImpl>
    implements _$$DailyNutritionSummaryImplCopyWith<$Res> {
  __$$DailyNutritionSummaryImplCopyWithImpl(_$DailyNutritionSummaryImpl _value,
      $Res Function(_$DailyNutritionSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? date = null,
    Object? totalCalories = null,
    Object? totalProtein = null,
    Object? totalCarbs = null,
    Object? totalFat = null,
    Object? waterGlasses = null,
    Object? mealsLogged = null,
    Object? caloriesByMeal = freezed,
    Object? goal = freezed,
  }) {
    return _then(_$DailyNutritionSummaryImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalCalories: null == totalCalories
          ? _value.totalCalories
          : totalCalories // ignore: cast_nullable_to_non_nullable
              as double,
      totalProtein: null == totalProtein
          ? _value.totalProtein
          : totalProtein // ignore: cast_nullable_to_non_nullable
              as double,
      totalCarbs: null == totalCarbs
          ? _value.totalCarbs
          : totalCarbs // ignore: cast_nullable_to_non_nullable
              as double,
      totalFat: null == totalFat
          ? _value.totalFat
          : totalFat // ignore: cast_nullable_to_non_nullable
              as double,
      waterGlasses: null == waterGlasses
          ? _value.waterGlasses
          : waterGlasses // ignore: cast_nullable_to_non_nullable
              as int,
      mealsLogged: null == mealsLogged
          ? _value.mealsLogged
          : mealsLogged // ignore: cast_nullable_to_non_nullable
              as int,
      caloriesByMeal: freezed == caloriesByMeal
          ? _value._caloriesByMeal
          : caloriesByMeal // ignore: cast_nullable_to_non_nullable
              as Map<MealType, double>?,
      goal: freezed == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as NutritionGoal?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyNutritionSummaryImpl extends _DailyNutritionSummary {
  const _$DailyNutritionSummaryImpl(
      {required this.userId,
      @TimestampConverter() required this.date,
      this.totalCalories = 0.0,
      this.totalProtein = 0.0,
      this.totalCarbs = 0.0,
      this.totalFat = 0.0,
      this.waterGlasses = 0,
      this.mealsLogged = 0,
      final Map<MealType, double>? caloriesByMeal,
      this.goal})
      : _caloriesByMeal = caloriesByMeal,
        super._();

  factory _$DailyNutritionSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyNutritionSummaryImplFromJson(json);

  @override
  final String userId;
  @override
  @TimestampConverter()
  final DateTime date;
// Day being summarized
  @override
  @JsonKey()
  final double totalCalories;
  @override
  @JsonKey()
  final double totalProtein;
  @override
  @JsonKey()
  final double totalCarbs;
  @override
  @JsonKey()
  final double totalFat;
  @override
  @JsonKey()
  final int waterGlasses;
  @override
  @JsonKey()
  final int mealsLogged;
// Number of meals logged this day
  final Map<MealType, double>? _caloriesByMeal;
// Number of meals logged this day
  @override
  Map<MealType, double>? get caloriesByMeal {
    final value = _caloriesByMeal;
    if (value == null) return null;
    if (_caloriesByMeal is EqualUnmodifiableMapView) return _caloriesByMeal;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Calories breakdown by meal type
  @override
  final NutritionGoal? goal;

  @override
  String toString() {
    return 'DailyNutritionSummary(userId: $userId, date: $date, totalCalories: $totalCalories, totalProtein: $totalProtein, totalCarbs: $totalCarbs, totalFat: $totalFat, waterGlasses: $waterGlasses, mealsLogged: $mealsLogged, caloriesByMeal: $caloriesByMeal, goal: $goal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyNutritionSummaryImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.totalCalories, totalCalories) ||
                other.totalCalories == totalCalories) &&
            (identical(other.totalProtein, totalProtein) ||
                other.totalProtein == totalProtein) &&
            (identical(other.totalCarbs, totalCarbs) ||
                other.totalCarbs == totalCarbs) &&
            (identical(other.totalFat, totalFat) ||
                other.totalFat == totalFat) &&
            (identical(other.waterGlasses, waterGlasses) ||
                other.waterGlasses == waterGlasses) &&
            (identical(other.mealsLogged, mealsLogged) ||
                other.mealsLogged == mealsLogged) &&
            const DeepCollectionEquality()
                .equals(other._caloriesByMeal, _caloriesByMeal) &&
            (identical(other.goal, goal) || other.goal == goal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      date,
      totalCalories,
      totalProtein,
      totalCarbs,
      totalFat,
      waterGlasses,
      mealsLogged,
      const DeepCollectionEquality().hash(_caloriesByMeal),
      goal);

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyNutritionSummaryImplCopyWith<_$DailyNutritionSummaryImpl>
      get copyWith => __$$DailyNutritionSummaryImplCopyWithImpl<
          _$DailyNutritionSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyNutritionSummaryImplToJson(
      this,
    );
  }
}

abstract class _DailyNutritionSummary extends DailyNutritionSummary {
  const factory _DailyNutritionSummary(
      {required final String userId,
      @TimestampConverter() required final DateTime date,
      final double totalCalories,
      final double totalProtein,
      final double totalCarbs,
      final double totalFat,
      final int waterGlasses,
      final int mealsLogged,
      final Map<MealType, double>? caloriesByMeal,
      final NutritionGoal? goal}) = _$DailyNutritionSummaryImpl;
  const _DailyNutritionSummary._() : super._();

  factory _DailyNutritionSummary.fromJson(Map<String, dynamic> json) =
      _$DailyNutritionSummaryImpl.fromJson;

  @override
  String get userId;
  @override
  @TimestampConverter()
  DateTime get date; // Day being summarized
  @override
  double get totalCalories;
  @override
  double get totalProtein;
  @override
  double get totalCarbs;
  @override
  double get totalFat;
  @override
  int get waterGlasses;
  @override
  int get mealsLogged; // Number of meals logged this day
  @override
  Map<MealType, double>? get caloriesByMeal; // Calories breakdown by meal type
  @override
  NutritionGoal? get goal;

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyNutritionSummaryImplCopyWith<_$DailyNutritionSummaryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
