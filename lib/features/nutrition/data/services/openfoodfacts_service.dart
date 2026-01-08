import 'package:dio/dio.dart';
import '../../domain/models/food_item.dart';
import 'package:uuid/uuid.dart';

/// Service for interacting with the OpenFoodFacts API
/// https://world.openfoodfacts.org/data
class OpenFoodFactsService {
  final Dio _dio;
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String _userAgent = 'Kinesa - Fitness App - Version 1.0';

  OpenFoodFactsService() : _dio = Dio() {
    _dio.options.headers['User-Agent'] = _userAgent;
  }

  /// Search products by barcode
  /// Returns FoodItem if found, null otherwise
  Future<FoodItem?> getProductByBarcode(String barcode, String userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/product/$barcode',
        queryParameters: {
          'fields': 'product_name,brands,nutriments,serving_size,image_url',
        },
      );

      if (response.statusCode == 200 &&
          response.data['status'] == 1 &&
          response.data['product'] != null) {
        final product = response.data['product'];
        return _parseFoodItem(product, barcode, userId);
      }

      return null;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  /// Search products by name
  /// Returns list of FoodItems matching the query
  Future<List<FoodItem>> searchProducts(String query, String userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'search_terms': query,
          'page_size': 20,
          'fields':
              'code,product_name,brands,nutriments,serving_size,image_url',
        },
      );

      if (response.statusCode == 200 && response.data['products'] != null) {
        final products = response.data['products'] as List;
        return products
            .map((product) =>
                _parseFoodItem(product, product['code'] ?? '', userId))
            .where((item) => item != null)
            .cast<FoodItem>()
            .toList();
      }

      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Parse OpenFoodFacts product data into FoodItem
  FoodItem? _parseFoodItem(
      Map<String, dynamic> product, String barcode, String userId) {
    try {
      final nutriments = product['nutriments'] ?? {};

      // Extract name and brand
      final name = product['product_name']?.toString() ?? 'Unknown Product';
      final brand = product['brands']?.toString();

      // Extract serving size (in grams)
      double servingSize = 100.0; // Default to 100g
      final servingSizeStr = product['serving_size']?.toString();
      if (servingSizeStr != null) {
        // Try to extract number from serving size string
        final match = RegExp(r'(\d+\.?\d*)').firstMatch(servingSizeStr);
        if (match != null) {
          servingSize = double.tryParse(match.group(1)!) ?? 100.0;
        }
      }

      // Extract nutrients (per 100g)
      final caloriesPer100g = _parseDouble(nutriments['energy-kcal_100g']) ??
          _parseDouble(nutriments['energy_100g']) ??
          0.0;
      final proteinPer100g = _parseDouble(nutriments['proteins_100g']) ?? 0.0;
      final carbsPer100g =
          _parseDouble(nutriments['carbohydrates_100g']) ?? 0.0;
      final fatPer100g = _parseDouble(nutriments['fat_100g']) ?? 0.0;
      final fiberPer100g = _parseDouble(nutriments['fiber_100g']) ?? 0.0;
      final sugarPer100g = _parseDouble(nutriments['sugars_100g']) ?? 0.0;

      // Convert to per serving
      final servingMultiplier = servingSize / 100.0;
      final calories = caloriesPer100g * servingMultiplier;
      final protein = proteinPer100g * servingMultiplier;
      final carbs = carbsPer100g * servingMultiplier;
      final fat = fatPer100g * servingMultiplier;
      final fiber = fiberPer100g * servingMultiplier;
      final sugar = sugarPer100g * servingMultiplier;

      return FoodItem(
        id: const Uuid().v4(),
        name: name,
        userId: userId,
        calories: calories,
        proteinGrams: protein,
        carbsGrams: carbs,
        fatGrams: fat,
        fiberGrams: fiber,
        sugarGrams: sugar,
        servingSizeGrams: servingSize,
        servingSizeUnit: 'g',
        brand: brand,
        barcode: barcode.isNotEmpty ? barcode : null,
        isCustom: false,
        isVerified: true, // Products from OpenFoodFacts are verified
        category: _guessCategory(name, brand),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      print('Error parsing food item: $e');
      return null;
    }
  }

  /// Helper to parse double from dynamic value
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Guess food category from name and brand
  FoodCategory? _guessCategory(String name, String? brand) {
    final lowerName = name.toLowerCase();
    final lowerBrand = brand?.toLowerCase() ?? '';

    // Protein
    if (lowerName.contains('chicken') ||
        lowerName.contains('beef') ||
        lowerName.contains('pork') ||
        lowerName.contains('fish') ||
        lowerName.contains('protein') ||
        lowerName.contains('meat') ||
        lowerName.contains('egg') ||
        lowerName.contains('tofu')) {
      return FoodCategory.protein;
    }

    // Dairy
    if (lowerName.contains('milk') ||
        lowerName.contains('cheese') ||
        lowerName.contains('yogurt') ||
        lowerName.contains('cream') ||
        lowerName.contains('butter')) {
      return FoodCategory.dairy;
    }

    // Grains
    if (lowerName.contains('bread') ||
        lowerName.contains('pasta') ||
        lowerName.contains('rice') ||
        lowerName.contains('cereal') ||
        lowerName.contains('oat') ||
        lowerName.contains('grain')) {
      return FoodCategory.grains;
    }

    // Vegetables
    if (lowerName.contains('vegetable') ||
        lowerName.contains('salad') ||
        lowerName.contains('carrot') ||
        lowerName.contains('broccoli') ||
        lowerName.contains('spinach') ||
        lowerName.contains('tomato') ||
        lowerName.contains('lettuce')) {
      return FoodCategory.vegetables;
    }

    // Fruits
    if (lowerName.contains('fruit') ||
        lowerName.contains('apple') ||
        lowerName.contains('banana') ||
        lowerName.contains('orange') ||
        lowerName.contains('berry') ||
        lowerName.contains('grape') ||
        lowerName.contains('melon')) {
      return FoodCategory.fruits;
    }

    // Fats
    if (lowerName.contains('oil') ||
        lowerName.contains('fat') ||
        lowerName.contains('avocado') ||
        lowerName.contains('nut') ||
        lowerName.contains('seed')) {
      return FoodCategory.fats;
    }

    // Beverages
    if (lowerName.contains('drink') ||
        lowerName.contains('juice') ||
        lowerName.contains('soda') ||
        lowerName.contains('water') ||
        lowerName.contains('coffee') ||
        lowerName.contains('tea')) {
      return FoodCategory.beverages;
    }

    // Snacks
    if (lowerName.contains('chip') ||
        lowerName.contains('cookie') ||
        lowerName.contains('candy') ||
        lowerName.contains('chocolate') ||
        lowerName.contains('snack') ||
        lowerName.contains('bar')) {
      return FoodCategory.snacks;
    }

    return FoodCategory.other;
  }
}
