// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FoodItemImpl _$$FoodItemImplFromJson(Map<String, dynamic> json) =>
    _$FoodItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['userId'] as String,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0.0,
      fiberGrams: (json['fiberGrams'] as num?)?.toDouble() ?? 0.0,
      sugarGrams: (json['sugarGrams'] as num?)?.toDouble() ?? 0.0,
      servingSizeGrams: (json['servingSizeGrams'] as num?)?.toDouble() ?? 100.0,
      servingSizeUnit: json['servingSizeUnit'] as String?,
      brand: json['brand'] as String?,
      barcode: json['barcode'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      category: $enumDecodeNullable(_$FoodCategoryEnumMap, json['category']),
      createdAt: const NullableTimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$$FoodItemImplToJson(_$FoodItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'userId': instance.userId,
      'calories': instance.calories,
      'proteinGrams': instance.proteinGrams,
      'carbsGrams': instance.carbsGrams,
      'fatGrams': instance.fatGrams,
      'fiberGrams': instance.fiberGrams,
      'sugarGrams': instance.sugarGrams,
      'servingSizeGrams': instance.servingSizeGrams,
      'servingSizeUnit': instance.servingSizeUnit,
      'brand': instance.brand,
      'barcode': instance.barcode,
      'isCustom': instance.isCustom,
      'isVerified': instance.isVerified,
      'category': _$FoodCategoryEnumMap[instance.category],
      'createdAt':
          const NullableTimestampConverter().toJson(instance.createdAt),
    };

const _$FoodCategoryEnumMap = {
  FoodCategory.protein: 'protein',
  FoodCategory.grains: 'grains',
  FoodCategory.vegetables: 'vegetables',
  FoodCategory.fruits: 'fruits',
  FoodCategory.dairy: 'dairy',
  FoodCategory.fats: 'fats',
  FoodCategory.snacks: 'snacks',
  FoodCategory.beverages: 'beverages',
  FoodCategory.other: 'other',
};
