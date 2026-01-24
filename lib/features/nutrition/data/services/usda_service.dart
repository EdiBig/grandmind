import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/usda_config.dart';
import '../../domain/models/food_item.dart';

/// Service for interacting with the USDA FoodData Central API
/// https://fdc.nal.usda.gov/api-guide.html
class USDAService {
  final Dio _dio;
  static const String _userAgent = 'Kinesa - Fitness App - Version 1.0';

  USDAService() : _dio = Dio() {
    _dio.options.headers['User-Agent'] = _userAgent;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
  }

  /// Search foods by query
  /// Returns list of FoodItems matching the search terms
  Future<List<FoodItem>> searchFoods(String query, String userId) async {
    if (query.isEmpty) return [];

    try {
      final response = await _dio.get(
        '${USDAConfig.baseUrl}/foods/search',
        queryParameters: {
          'query': query,
          'pageSize': USDAConfig.defaultPageSize,
          'dataType': 'Foundation,SR Legacy,Survey (FNDDS),Branded',
          'api_key': USDAConfig.apiKey,
        },
      );

      if (response.statusCode == 200 && response.data['foods'] != null) {
        final foods = response.data['foods'] as List;
        return foods
            .map((food) => _parseFoodItem(food, userId))
            .where((item) => item != null)
            .cast<FoodItem>()
            .toList();
      }

      return [];
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('USDA search error: ${e.message}');
        if (e.response != null) {
          debugPrint('Response: ${e.response?.data}');
        }
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        debugPrint('USDA search error: $e');
      }
      return [];
    }
  }

  /// Get detailed food information by FDC ID
  Future<FoodItem?> getFoodById(int fdcId, String userId) async {
    try {
      final response = await _dio.get(
        '${USDAConfig.baseUrl}/food/$fdcId',
        queryParameters: {
          'api_key': USDAConfig.apiKey,
        },
      );

      if (response.statusCode == 200) {
        return _parseFoodItemDetail(response.data, userId);
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('USDA food lookup error: $e');
      }
      return null;
    }
  }

  /// Parse USDA search result into FoodItem
  FoodItem? _parseFoodItem(Map<String, dynamic> food, String userId) {
    try {
      final fdcId = food['fdcId'];
      final description = food['description']?.toString();

      if (fdcId == null || description == null) return null;

      // Get brand for branded foods
      final brandOwner = food['brandOwner']?.toString();
      final brandName = food['brandName']?.toString();
      final brand = brandName ?? brandOwner;

      // Get serving size if available
      double servingSize = 100.0;
      String servingUnit = 'g';

      final servingSizeValue = food['servingSize'];
      if (servingSizeValue != null) {
        servingSize = _parseDouble(servingSizeValue) ?? 100.0;
        servingUnit = food['servingSizeUnit']?.toString() ?? 'g';
      }

      // Extract nutrients from foodNutrients array
      final foodNutrients = food['foodNutrients'] as List? ?? [];

      double calories = 0;
      double protein = 0;
      double carbs = 0;
      double fat = 0;
      double fiber = 0;
      double sugar = 0;

      for (var nutrient in foodNutrients) {
        final value = _parseDouble(nutrient['value']) ?? 0;
        final nutrientId = nutrient['nutrientId'] ?? nutrient['nutrientNumber'];
        final nutrientName = nutrient['nutrientName']?.toString() ?? '';

        // Map nutrient IDs or names to our fields
        // USDA Nutrient IDs: 1008=Energy(kcal), 1003=Protein, 1005=Carbs, 1004=Fat, 1079=Fiber, 2000=Sugar
        if (nutrientId == 1008 || nutrientName.contains('Energy')) {
          // Check if it's kcal (not kJ)
          final unitName = nutrient['unitName']?.toString() ?? '';
          if (unitName.toLowerCase() == 'kcal' || !unitName.toLowerCase().contains('kj')) {
            calories = value;
          }
        } else if (nutrientId == 1003 || nutrientName.contains('Protein')) {
          protein = value;
        } else if (nutrientId == 1005 || nutrientName.contains('Carbohydrate')) {
          carbs = value;
        } else if (nutrientId == 1004 || nutrientName.contains('Total lipid') || nutrientName.contains('Fat')) {
          fat = value;
        } else if (nutrientId == 1079 || nutrientName.contains('Fiber')) {
          fiber = value;
        } else if (nutrientId == 2000 || (nutrientName.contains('Sugar') && !nutrientName.contains('Added'))) {
          sugar = value;
        }
      }

      // Format display name
      String displayName = _formatFoodName(description);
      if (brand != null && brand.isNotEmpty) {
        displayName = '$displayName ($brand)';
      }

      return FoodItem(
        id: const Uuid().v4(),
        name: displayName,
        userId: userId,
        calories: calories,
        proteinGrams: protein,
        carbsGrams: carbs,
        fatGrams: fat,
        fiberGrams: fiber,
        sugarGrams: sugar,
        servingSizeGrams: servingSize,
        servingSizeUnit: servingUnit,
        brand: brand,
        barcode: fdcId.toString(), // Store FDC ID for reference
        isCustom: false,
        isVerified: true, // USDA is official government source
        category: _guessCategory(description),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing USDA food: $e');
      }
      return null;
    }
  }

  /// Parse detailed food response
  FoodItem? _parseFoodItemDetail(Map<String, dynamic> data, String userId) {
    try {
      final fdcId = data['fdcId'];
      final description = data['description']?.toString();

      if (fdcId == null || description == null) return null;

      final brandOwner = data['brandOwner']?.toString();
      final brandName = data['brandName']?.toString();
      final brand = brandName ?? brandOwner;

      // Get serving size
      double servingSize = 100.0;
      String servingUnit = 'g';

      // Check food portions for serving info
      final foodPortions = data['foodPortions'] as List?;
      if (foodPortions != null && foodPortions.isNotEmpty) {
        final portion = foodPortions.first;
        servingSize = _parseDouble(portion['gramWeight']) ?? 100.0;
        final portionDesc = portion['portionDescription']?.toString();
        if (portionDesc != null && portionDesc.isNotEmpty) {
          servingUnit = portionDesc;
        }
      }

      // Extract nutrients
      final foodNutrients = data['foodNutrients'] as List? ?? [];

      double calories = 0;
      double protein = 0;
      double carbs = 0;
      double fat = 0;
      double fiber = 0;
      double sugar = 0;

      for (var item in foodNutrients) {
        final nutrient = item['nutrient'] as Map<String, dynamic>? ?? item;
        final value = _parseDouble(item['amount'] ?? item['value']) ?? 0;
        final nutrientId = nutrient['id'] ?? nutrient['nutrientId'];
        final nutrientName = nutrient['name']?.toString() ?? '';
        final unitName = nutrient['unitName']?.toString() ?? '';

        if (nutrientId == 1008 || nutrientName.contains('Energy')) {
          if (unitName.toLowerCase() == 'kcal') {
            calories = value;
          }
        } else if (nutrientId == 1003 || nutrientName.contains('Protein')) {
          protein = value;
        } else if (nutrientId == 1005 || nutrientName.contains('Carbohydrate')) {
          carbs = value;
        } else if (nutrientId == 1004 || nutrientName.contains('Total lipid')) {
          fat = value;
        } else if (nutrientId == 1079 || nutrientName.contains('Fiber')) {
          fiber = value;
        } else if (nutrientId == 2000 || (nutrientName.contains('Sugar') && !nutrientName.contains('Added'))) {
          sugar = value;
        }
      }

      String displayName = _formatFoodName(description);
      if (brand != null && brand.isNotEmpty) {
        displayName = '$displayName ($brand)';
      }

      return FoodItem(
        id: const Uuid().v4(),
        name: displayName,
        userId: userId,
        calories: calories,
        proteinGrams: protein,
        carbsGrams: carbs,
        fatGrams: fat,
        fiberGrams: fiber,
        sugarGrams: sugar,
        servingSizeGrams: servingSize,
        servingSizeUnit: servingUnit,
        brand: brand,
        barcode: fdcId.toString(),
        isCustom: false,
        isVerified: true,
        category: _guessCategory(description),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error parsing USDA food detail: $e');
      }
      return null;
    }
  }

  /// Format food name to be more user-friendly
  String _formatFoodName(String description) {
    // USDA names are often in ALL CAPS or have technical descriptions
    String name = description;

    // Convert from ALL CAPS to Title Case if needed
    if (name == name.toUpperCase() && name.length > 3) {
      name = name.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    // Remove common technical suffixes
    name = name
        .replaceAll(RegExp(r',\s*raw$', caseSensitive: false), '')
        .replaceAll(RegExp(r',\s*cooked$', caseSensitive: false), ' (cooked)')
        .replaceAll(RegExp(r',\s*NFS$', caseSensitive: false), '') // Not Further Specified
        .trim();

    return name;
  }

  /// Helper to parse double from dynamic value
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Guess food category from description
  FoodCategory? _guessCategory(String description) {
    final lower = description.toLowerCase();

    // Protein
    if (lower.contains('chicken') ||
        lower.contains('beef') ||
        lower.contains('pork') ||
        lower.contains('fish') ||
        lower.contains('salmon') ||
        lower.contains('tuna') ||
        lower.contains('shrimp') ||
        lower.contains('turkey') ||
        lower.contains('lamb') ||
        lower.contains('protein') ||
        lower.contains('meat') ||
        lower.contains('egg') ||
        lower.contains('tofu') ||
        lower.contains('tempeh') ||
        lower.contains('seitan')) {
      return FoodCategory.protein;
    }

    // Dairy
    if (lower.contains('milk') ||
        lower.contains('cheese') ||
        lower.contains('yogurt') ||
        lower.contains('yoghurt') ||
        lower.contains('cream') ||
        lower.contains('butter') ||
        lower.contains('dairy')) {
      return FoodCategory.dairy;
    }

    // Grains
    if (lower.contains('bread') ||
        lower.contains('pasta') ||
        lower.contains('rice') ||
        lower.contains('cereal') ||
        lower.contains('oat') ||
        lower.contains('wheat') ||
        lower.contains('grain') ||
        lower.contains('quinoa') ||
        lower.contains('barley') ||
        lower.contains('flour') ||
        lower.contains('tortilla') ||
        lower.contains('bagel') ||
        lower.contains('muffin')) {
      return FoodCategory.grains;
    }

    // Vegetables
    if (lower.contains('vegetable') ||
        lower.contains('salad') ||
        lower.contains('carrot') ||
        lower.contains('broccoli') ||
        lower.contains('spinach') ||
        lower.contains('tomato') ||
        lower.contains('lettuce') ||
        lower.contains('kale') ||
        lower.contains('pepper') ||
        lower.contains('onion') ||
        lower.contains('potato') ||
        lower.contains('sweet potato') ||
        lower.contains('squash') ||
        lower.contains('zucchini') ||
        lower.contains('cucumber') ||
        lower.contains('celery') ||
        lower.contains('asparagus') ||
        lower.contains('cauliflower') ||
        lower.contains('cabbage') ||
        lower.contains('mushroom') ||
        lower.contains('bean') ||
        lower.contains('pea') ||
        lower.contains('corn') ||
        lower.contains('lentil')) {
      return FoodCategory.vegetables;
    }

    // Fruits
    if (lower.contains('fruit') ||
        lower.contains('apple') ||
        lower.contains('banana') ||
        lower.contains('orange') ||
        lower.contains('berry') ||
        lower.contains('strawberry') ||
        lower.contains('blueberry') ||
        lower.contains('raspberry') ||
        lower.contains('grape') ||
        lower.contains('melon') ||
        lower.contains('watermelon') ||
        lower.contains('mango') ||
        lower.contains('pineapple') ||
        lower.contains('peach') ||
        lower.contains('pear') ||
        lower.contains('plum') ||
        lower.contains('cherry') ||
        lower.contains('kiwi') ||
        lower.contains('lemon') ||
        lower.contains('lime') ||
        lower.contains('grapefruit') ||
        lower.contains('avocado')) {
      return FoodCategory.fruits;
    }

    // Fats
    if (lower.contains('oil') ||
        lower.contains('olive') ||
        lower.contains('coconut oil') ||
        lower.contains('nut') ||
        lower.contains('almond') ||
        lower.contains('walnut') ||
        lower.contains('peanut') ||
        lower.contains('cashew') ||
        lower.contains('seed') ||
        lower.contains('flax') ||
        lower.contains('chia')) {
      return FoodCategory.fats;
    }

    // Beverages
    if (lower.contains('drink') ||
        lower.contains('juice') ||
        lower.contains('soda') ||
        lower.contains('water') ||
        lower.contains('coffee') ||
        lower.contains('tea') ||
        lower.contains('smoothie') ||
        lower.contains('shake') ||
        lower.contains('beverage')) {
      return FoodCategory.beverages;
    }

    // Snacks
    if (lower.contains('chip') ||
        lower.contains('cookie') ||
        lower.contains('candy') ||
        lower.contains('chocolate') ||
        lower.contains('snack') ||
        lower.contains('bar') ||
        lower.contains('cracker') ||
        lower.contains('pretzel') ||
        lower.contains('popcorn')) {
      return FoodCategory.snacks;
    }

    return FoodCategory.other;
  }
}
