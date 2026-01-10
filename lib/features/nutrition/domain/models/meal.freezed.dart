// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Meal _$MealFromJson(Map<String, dynamic> json) {
  return _Meal.fromJson(json);
}

/// @nodoc
mixin _$Meal {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  MealType get mealType => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get mealDate =>
      throw _privateConstructorUsedError; // Normalized to start of day for querying
  @TimestampConverter()
  DateTime get loggedAt =>
      throw _privateConstructorUsedError; // Actual timestamp when logged
  List<MealEntry> get entries =>
      throw _privateConstructorUsedError; // Food items in this meal
  String? get notes => throw _privateConstructorUsedError;
  String? get photoUrl =>
      throw _privateConstructorUsedError; // Firebase Storage URL for meal photo
  double get totalCalories => throw _privateConstructorUsedError;
  double get totalProtein => throw _privateConstructorUsedError;
  double get totalCarbs => throw _privateConstructorUsedError;
  double get totalFat => throw _privateConstructorUsedError;

  /// Serializes this Meal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealCopyWith<Meal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealCopyWith<$Res> {
  factory $MealCopyWith(Meal value, $Res Function(Meal) then) =
      _$MealCopyWithImpl<$Res, Meal>;
  @useResult
  $Res call(
      {String id,
      String userId,
      MealType mealType,
      @TimestampConverter() DateTime mealDate,
      @TimestampConverter() DateTime loggedAt,
      List<MealEntry> entries,
      String? notes,
      String? photoUrl,
      double totalCalories,
      double totalProtein,
      double totalCarbs,
      double totalFat});
}

/// @nodoc
class _$MealCopyWithImpl<$Res, $Val extends Meal>
    implements $MealCopyWith<$Res> {
  _$MealCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? mealType = null,
    Object? mealDate = null,
    Object? loggedAt = null,
    Object? entries = null,
    Object? notes = freezed,
    Object? photoUrl = freezed,
    Object? totalCalories = null,
    Object? totalProtein = null,
    Object? totalCarbs = null,
    Object? totalFat = null,
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
      mealType: null == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as MealType,
      mealDate: null == mealDate
          ? _value.mealDate
          : mealDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      loggedAt: null == loggedAt
          ? _value.loggedAt
          : loggedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<MealEntry>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MealImplCopyWith<$Res> implements $MealCopyWith<$Res> {
  factory _$$MealImplCopyWith(
          _$MealImpl value, $Res Function(_$MealImpl) then) =
      __$$MealImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      MealType mealType,
      @TimestampConverter() DateTime mealDate,
      @TimestampConverter() DateTime loggedAt,
      List<MealEntry> entries,
      String? notes,
      String? photoUrl,
      double totalCalories,
      double totalProtein,
      double totalCarbs,
      double totalFat});
}

/// @nodoc
class __$$MealImplCopyWithImpl<$Res>
    extends _$MealCopyWithImpl<$Res, _$MealImpl>
    implements _$$MealImplCopyWith<$Res> {
  __$$MealImplCopyWithImpl(_$MealImpl _value, $Res Function(_$MealImpl) _then)
      : super(_value, _then);

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? mealType = null,
    Object? mealDate = null,
    Object? loggedAt = null,
    Object? entries = null,
    Object? notes = freezed,
    Object? photoUrl = freezed,
    Object? totalCalories = null,
    Object? totalProtein = null,
    Object? totalCarbs = null,
    Object? totalFat = null,
  }) {
    return _then(_$MealImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      mealType: null == mealType
          ? _value.mealType
          : mealType // ignore: cast_nullable_to_non_nullable
              as MealType,
      mealDate: null == mealDate
          ? _value.mealDate
          : mealDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      loggedAt: null == loggedAt
          ? _value.loggedAt
          : loggedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<MealEntry>,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
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
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$MealImpl extends _Meal {
  const _$MealImpl(
      {required this.id,
      required this.userId,
      required this.mealType,
      @TimestampConverter() required this.mealDate,
      @TimestampConverter() required this.loggedAt,
      required final List<MealEntry> entries,
      this.notes,
      this.photoUrl,
      this.totalCalories = 0.0,
      this.totalProtein = 0.0,
      this.totalCarbs = 0.0,
      this.totalFat = 0.0})
      : _entries = entries,
        super._();

  factory _$MealImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final MealType mealType;
  @override
  @TimestampConverter()
  final DateTime mealDate;
// Normalized to start of day for querying
  @override
  @TimestampConverter()
  final DateTime loggedAt;
// Actual timestamp when logged
  final List<MealEntry> _entries;
// Actual timestamp when logged
  @override
  List<MealEntry> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

// Food items in this meal
  @override
  final String? notes;
  @override
  final String? photoUrl;
// Firebase Storage URL for meal photo
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
  String toString() {
    return 'Meal(id: $id, userId: $userId, mealType: $mealType, mealDate: $mealDate, loggedAt: $loggedAt, entries: $entries, notes: $notes, photoUrl: $photoUrl, totalCalories: $totalCalories, totalProtein: $totalProtein, totalCarbs: $totalCarbs, totalFat: $totalFat)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.mealType, mealType) ||
                other.mealType == mealType) &&
            (identical(other.mealDate, mealDate) ||
                other.mealDate == mealDate) &&
            (identical(other.loggedAt, loggedAt) ||
                other.loggedAt == loggedAt) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.totalCalories, totalCalories) ||
                other.totalCalories == totalCalories) &&
            (identical(other.totalProtein, totalProtein) ||
                other.totalProtein == totalProtein) &&
            (identical(other.totalCarbs, totalCarbs) ||
                other.totalCarbs == totalCarbs) &&
            (identical(other.totalFat, totalFat) ||
                other.totalFat == totalFat));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      mealType,
      mealDate,
      loggedAt,
      const DeepCollectionEquality().hash(_entries),
      notes,
      photoUrl,
      totalCalories,
      totalProtein,
      totalCarbs,
      totalFat);

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealImplCopyWith<_$MealImpl> get copyWith =>
      __$$MealImplCopyWithImpl<_$MealImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealImplToJson(
      this,
    );
  }
}

abstract class _Meal extends Meal {
  const factory _Meal(
      {required final String id,
      required final String userId,
      required final MealType mealType,
      @TimestampConverter() required final DateTime mealDate,
      @TimestampConverter() required final DateTime loggedAt,
      required final List<MealEntry> entries,
      final String? notes,
      final String? photoUrl,
      final double totalCalories,
      final double totalProtein,
      final double totalCarbs,
      final double totalFat}) = _$MealImpl;
  const _Meal._() : super._();

  factory _Meal.fromJson(Map<String, dynamic> json) = _$MealImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  MealType get mealType;
  @override
  @TimestampConverter()
  DateTime get mealDate; // Normalized to start of day for querying
  @override
  @TimestampConverter()
  DateTime get loggedAt; // Actual timestamp when logged
  @override
  List<MealEntry> get entries; // Food items in this meal
  @override
  String? get notes;
  @override
  String? get photoUrl; // Firebase Storage URL for meal photo
  @override
  double get totalCalories;
  @override
  double get totalProtein;
  @override
  double get totalCarbs;
  @override
  double get totalFat;

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealImplCopyWith<_$MealImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MealEntry _$MealEntryFromJson(Map<String, dynamic> json) {
  return _MealEntry.fromJson(json);
}

/// @nodoc
mixin _$MealEntry {
  FoodItem get foodItem => throw _privateConstructorUsedError;
  double get servings =>
      throw _privateConstructorUsedError; // Number of servings consumed
  String? get customServingSize => throw _privateConstructorUsedError;

  /// Serializes this MealEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealEntryCopyWith<MealEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealEntryCopyWith<$Res> {
  factory $MealEntryCopyWith(MealEntry value, $Res Function(MealEntry) then) =
      _$MealEntryCopyWithImpl<$Res, MealEntry>;
  @useResult
  $Res call({FoodItem foodItem, double servings, String? customServingSize});

  $FoodItemCopyWith<$Res> get foodItem;
}

/// @nodoc
class _$MealEntryCopyWithImpl<$Res, $Val extends MealEntry>
    implements $MealEntryCopyWith<$Res> {
  _$MealEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodItem = null,
    Object? servings = null,
    Object? customServingSize = freezed,
  }) {
    return _then(_value.copyWith(
      foodItem: null == foodItem
          ? _value.foodItem
          : foodItem // ignore: cast_nullable_to_non_nullable
              as FoodItem,
      servings: null == servings
          ? _value.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as double,
      customServingSize: freezed == customServingSize
          ? _value.customServingSize
          : customServingSize // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of MealEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FoodItemCopyWith<$Res> get foodItem {
    return $FoodItemCopyWith<$Res>(_value.foodItem, (value) {
      return _then(_value.copyWith(foodItem: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MealEntryImplCopyWith<$Res>
    implements $MealEntryCopyWith<$Res> {
  factory _$$MealEntryImplCopyWith(
          _$MealEntryImpl value, $Res Function(_$MealEntryImpl) then) =
      __$$MealEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({FoodItem foodItem, double servings, String? customServingSize});

  @override
  $FoodItemCopyWith<$Res> get foodItem;
}

/// @nodoc
class __$$MealEntryImplCopyWithImpl<$Res>
    extends _$MealEntryCopyWithImpl<$Res, _$MealEntryImpl>
    implements _$$MealEntryImplCopyWith<$Res> {
  __$$MealEntryImplCopyWithImpl(
      _$MealEntryImpl _value, $Res Function(_$MealEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of MealEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodItem = null,
    Object? servings = null,
    Object? customServingSize = freezed,
  }) {
    return _then(_$MealEntryImpl(
      foodItem: null == foodItem
          ? _value.foodItem
          : foodItem // ignore: cast_nullable_to_non_nullable
              as FoodItem,
      servings: null == servings
          ? _value.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as double,
      customServingSize: freezed == customServingSize
          ? _value.customServingSize
          : customServingSize // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$MealEntryImpl implements _MealEntry {
  const _$MealEntryImpl(
      {required this.foodItem, this.servings = 1.0, this.customServingSize});

  factory _$MealEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealEntryImplFromJson(json);

  @override
  final FoodItem foodItem;
  @override
  @JsonKey()
  final double servings;
// Number of servings consumed
  @override
  final String? customServingSize;

  @override
  String toString() {
    return 'MealEntry(foodItem: $foodItem, servings: $servings, customServingSize: $customServingSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealEntryImpl &&
            (identical(other.foodItem, foodItem) ||
                other.foodItem == foodItem) &&
            (identical(other.servings, servings) ||
                other.servings == servings) &&
            (identical(other.customServingSize, customServingSize) ||
                other.customServingSize == customServingSize));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, foodItem, servings, customServingSize);

  /// Create a copy of MealEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealEntryImplCopyWith<_$MealEntryImpl> get copyWith =>
      __$$MealEntryImplCopyWithImpl<_$MealEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealEntryImplToJson(
      this,
    );
  }
}

abstract class _MealEntry implements MealEntry {
  const factory _MealEntry(
      {required final FoodItem foodItem,
      final double servings,
      final String? customServingSize}) = _$MealEntryImpl;

  factory _MealEntry.fromJson(Map<String, dynamic> json) =
      _$MealEntryImpl.fromJson;

  @override
  FoodItem get foodItem;
  @override
  double get servings; // Number of servings consumed
  @override
  String? get customServingSize;

  /// Create a copy of MealEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealEntryImplCopyWith<_$MealEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
