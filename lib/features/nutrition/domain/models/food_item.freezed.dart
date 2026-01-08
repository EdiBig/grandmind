// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FoodItem _$FoodItemFromJson(Map<String, dynamic> json) {
  return _FoodItem.fromJson(json);
}

/// @nodoc
mixin _$FoodItem {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get calories => throw _privateConstructorUsedError;
  double get proteinGrams => throw _privateConstructorUsedError;
  double get carbsGrams => throw _privateConstructorUsedError;
  double get fatGrams => throw _privateConstructorUsedError;
  double get fiberGrams => throw _privateConstructorUsedError;
  double get sugarGrams => throw _privateConstructorUsedError;
  double get servingSizeGrams => throw _privateConstructorUsedError;
  String? get servingSizeUnit =>
      throw _privateConstructorUsedError; // e.g., "cup", "tbsp", "piece", "ml"
  String? get brand => throw _privateConstructorUsedError;
  String? get barcode =>
      throw _privateConstructorUsedError; // For future barcode scanning feature
  bool get isCustom =>
      throw _privateConstructorUsedError; // User-created custom food
  bool get isVerified =>
      throw _privateConstructorUsedError; // Admin-verified food from database
  FoodCategory? get category => throw _privateConstructorUsedError;
  @NullableTimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this FoodItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FoodItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FoodItemCopyWith<FoodItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodItemCopyWith<$Res> {
  factory $FoodItemCopyWith(FoodItem value, $Res Function(FoodItem) then) =
      _$FoodItemCopyWithImpl<$Res, FoodItem>;
  @useResult
  $Res call(
      {String id,
      String name,
      String userId,
      double calories,
      double proteinGrams,
      double carbsGrams,
      double fatGrams,
      double fiberGrams,
      double sugarGrams,
      double servingSizeGrams,
      String? servingSizeUnit,
      String? brand,
      String? barcode,
      bool isCustom,
      bool isVerified,
      FoodCategory? category,
      @NullableTimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$FoodItemCopyWithImpl<$Res, $Val extends FoodItem>
    implements $FoodItemCopyWith<$Res> {
  _$FoodItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FoodItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? userId = null,
    Object? calories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? fiberGrams = null,
    Object? sugarGrams = null,
    Object? servingSizeGrams = null,
    Object? servingSizeUnit = freezed,
    Object? brand = freezed,
    Object? barcode = freezed,
    Object? isCustom = null,
    Object? isVerified = null,
    Object? category = freezed,
    Object? createdAt = freezed,
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
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as double,
      proteinGrams: null == proteinGrams
          ? _value.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as double,
      carbsGrams: null == carbsGrams
          ? _value.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as double,
      fatGrams: null == fatGrams
          ? _value.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as double,
      fiberGrams: null == fiberGrams
          ? _value.fiberGrams
          : fiberGrams // ignore: cast_nullable_to_non_nullable
              as double,
      sugarGrams: null == sugarGrams
          ? _value.sugarGrams
          : sugarGrams // ignore: cast_nullable_to_non_nullable
              as double,
      servingSizeGrams: null == servingSizeGrams
          ? _value.servingSizeGrams
          : servingSizeGrams // ignore: cast_nullable_to_non_nullable
              as double,
      servingSizeUnit: freezed == servingSizeUnit
          ? _value.servingSizeUnit
          : servingSizeUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FoodCategory?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FoodItemImplCopyWith<$Res>
    implements $FoodItemCopyWith<$Res> {
  factory _$$FoodItemImplCopyWith(
          _$FoodItemImpl value, $Res Function(_$FoodItemImpl) then) =
      __$$FoodItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String userId,
      double calories,
      double proteinGrams,
      double carbsGrams,
      double fatGrams,
      double fiberGrams,
      double sugarGrams,
      double servingSizeGrams,
      String? servingSizeUnit,
      String? brand,
      String? barcode,
      bool isCustom,
      bool isVerified,
      FoodCategory? category,
      @NullableTimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$FoodItemImplCopyWithImpl<$Res>
    extends _$FoodItemCopyWithImpl<$Res, _$FoodItemImpl>
    implements _$$FoodItemImplCopyWith<$Res> {
  __$$FoodItemImplCopyWithImpl(
      _$FoodItemImpl _value, $Res Function(_$FoodItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of FoodItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? userId = null,
    Object? calories = null,
    Object? proteinGrams = null,
    Object? carbsGrams = null,
    Object? fatGrams = null,
    Object? fiberGrams = null,
    Object? sugarGrams = null,
    Object? servingSizeGrams = null,
    Object? servingSizeUnit = freezed,
    Object? brand = freezed,
    Object? barcode = freezed,
    Object? isCustom = null,
    Object? isVerified = null,
    Object? category = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$FoodItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as double,
      proteinGrams: null == proteinGrams
          ? _value.proteinGrams
          : proteinGrams // ignore: cast_nullable_to_non_nullable
              as double,
      carbsGrams: null == carbsGrams
          ? _value.carbsGrams
          : carbsGrams // ignore: cast_nullable_to_non_nullable
              as double,
      fatGrams: null == fatGrams
          ? _value.fatGrams
          : fatGrams // ignore: cast_nullable_to_non_nullable
              as double,
      fiberGrams: null == fiberGrams
          ? _value.fiberGrams
          : fiberGrams // ignore: cast_nullable_to_non_nullable
              as double,
      sugarGrams: null == sugarGrams
          ? _value.sugarGrams
          : sugarGrams // ignore: cast_nullable_to_non_nullable
              as double,
      servingSizeGrams: null == servingSizeGrams
          ? _value.servingSizeGrams
          : servingSizeGrams // ignore: cast_nullable_to_non_nullable
              as double,
      servingSizeUnit: freezed == servingSizeUnit
          ? _value.servingSizeUnit
          : servingSizeUnit // ignore: cast_nullable_to_non_nullable
              as String?,
      brand: freezed == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String?,
      barcode: freezed == barcode
          ? _value.barcode
          : barcode // ignore: cast_nullable_to_non_nullable
              as String?,
      isCustom: null == isCustom
          ? _value.isCustom
          : isCustom // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FoodCategory?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FoodItemImpl implements _FoodItem {
  const _$FoodItemImpl(
      {required this.id,
      required this.name,
      required this.userId,
      this.calories = 0.0,
      this.proteinGrams = 0.0,
      this.carbsGrams = 0.0,
      this.fatGrams = 0.0,
      this.fiberGrams = 0.0,
      this.sugarGrams = 0.0,
      this.servingSizeGrams = 100.0,
      this.servingSizeUnit,
      this.brand,
      this.barcode,
      this.isCustom = false,
      this.isVerified = false,
      this.category,
      @NullableTimestampConverter() this.createdAt});

  factory _$FoodItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$FoodItemImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String userId;
  @override
  @JsonKey()
  final double calories;
  @override
  @JsonKey()
  final double proteinGrams;
  @override
  @JsonKey()
  final double carbsGrams;
  @override
  @JsonKey()
  final double fatGrams;
  @override
  @JsonKey()
  final double fiberGrams;
  @override
  @JsonKey()
  final double sugarGrams;
  @override
  @JsonKey()
  final double servingSizeGrams;
  @override
  final String? servingSizeUnit;
// e.g., "cup", "tbsp", "piece", "ml"
  @override
  final String? brand;
  @override
  final String? barcode;
// For future barcode scanning feature
  @override
  @JsonKey()
  final bool isCustom;
// User-created custom food
  @override
  @JsonKey()
  final bool isVerified;
// Admin-verified food from database
  @override
  final FoodCategory? category;
  @override
  @NullableTimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'FoodItem(id: $id, name: $name, userId: $userId, calories: $calories, proteinGrams: $proteinGrams, carbsGrams: $carbsGrams, fatGrams: $fatGrams, fiberGrams: $fiberGrams, sugarGrams: $sugarGrams, servingSizeGrams: $servingSizeGrams, servingSizeUnit: $servingSizeUnit, brand: $brand, barcode: $barcode, isCustom: $isCustom, isVerified: $isVerified, category: $category, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinGrams, proteinGrams) ||
                other.proteinGrams == proteinGrams) &&
            (identical(other.carbsGrams, carbsGrams) ||
                other.carbsGrams == carbsGrams) &&
            (identical(other.fatGrams, fatGrams) ||
                other.fatGrams == fatGrams) &&
            (identical(other.fiberGrams, fiberGrams) ||
                other.fiberGrams == fiberGrams) &&
            (identical(other.sugarGrams, sugarGrams) ||
                other.sugarGrams == sugarGrams) &&
            (identical(other.servingSizeGrams, servingSizeGrams) ||
                other.servingSizeGrams == servingSizeGrams) &&
            (identical(other.servingSizeUnit, servingSizeUnit) ||
                other.servingSizeUnit == servingSizeUnit) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.barcode, barcode) || other.barcode == barcode) &&
            (identical(other.isCustom, isCustom) ||
                other.isCustom == isCustom) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      userId,
      calories,
      proteinGrams,
      carbsGrams,
      fatGrams,
      fiberGrams,
      sugarGrams,
      servingSizeGrams,
      servingSizeUnit,
      brand,
      barcode,
      isCustom,
      isVerified,
      category,
      createdAt);

  /// Create a copy of FoodItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodItemImplCopyWith<_$FoodItemImpl> get copyWith =>
      __$$FoodItemImplCopyWithImpl<_$FoodItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FoodItemImplToJson(
      this,
    );
  }
}

abstract class _FoodItem implements FoodItem {
  const factory _FoodItem(
          {required final String id,
          required final String name,
          required final String userId,
          final double calories,
          final double proteinGrams,
          final double carbsGrams,
          final double fatGrams,
          final double fiberGrams,
          final double sugarGrams,
          final double servingSizeGrams,
          final String? servingSizeUnit,
          final String? brand,
          final String? barcode,
          final bool isCustom,
          final bool isVerified,
          final FoodCategory? category,
          @NullableTimestampConverter() final DateTime? createdAt}) =
      _$FoodItemImpl;

  factory _FoodItem.fromJson(Map<String, dynamic> json) =
      _$FoodItemImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get userId;
  @override
  double get calories;
  @override
  double get proteinGrams;
  @override
  double get carbsGrams;
  @override
  double get fatGrams;
  @override
  double get fiberGrams;
  @override
  double get sugarGrams;
  @override
  double get servingSizeGrams;
  @override
  String? get servingSizeUnit; // e.g., "cup", "tbsp", "piece", "ml"
  @override
  String? get brand;
  @override
  String? get barcode; // For future barcode scanning feature
  @override
  bool get isCustom; // User-created custom food
  @override
  bool get isVerified; // Admin-verified food from database
  @override
  FoodCategory? get category;
  @override
  @NullableTimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of FoodItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FoodItemImplCopyWith<_$FoodItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
