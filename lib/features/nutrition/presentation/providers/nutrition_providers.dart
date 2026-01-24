import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../data/services/usda_service.dart';
import '../../data/services/openfoodfacts_service.dart';
import '../../domain/models/daily_nutrition_summary.dart';
import '../../domain/models/food_item.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/nutrition_goal.dart';
import '../../domain/models/water_log.dart';

// ========== REPOSITORY PROVIDER ==========

/// Nutrition repository provider
final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepository();
});

// ========== GOAL PROVIDERS ==========

/// User's nutrition goal (real-time stream)
final userNutritionGoalProvider = StreamProvider<NutritionGoal?>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(null);

  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getUserNutritionGoalStream(userId);
});

// ========== MEAL PROVIDERS ==========

/// Today's meals (real-time stream)
final todayMealsProvider = StreamProvider<List<Meal>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(nutritionRepositoryProvider);
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return repository.getUserMealsStream(userId).map((meals) {
    return meals.where((meal) {
      final mealDate =
          DateTime(meal.mealDate.year, meal.mealDate.month, meal.mealDate.day);
      return !mealDate.isBefore(startOfDay) && mealDate.isBefore(endOfDay);
    }).toList();
  });
});

/// Meals for a specific date range (parameterized)
final mealsForDateRangeProvider =
    StreamProvider.family<List<Meal>, DateRange>((ref, dateRange) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(nutritionRepositoryProvider);
  final start =
      DateTime(dateRange.start.year, dateRange.start.month, dateRange.start.day);
  final endExclusive = DateTime(
    dateRange.end.year,
    dateRange.end.month,
    dateRange.end.day,
  ).add(const Duration(days: 1));

  return repository.getUserMealsStream(userId).map((meals) {
    return meals.where((meal) {
      final mealDate =
          DateTime(meal.mealDate.year, meal.mealDate.month, meal.mealDate.day);
      return !mealDate.isBefore(start) && mealDate.isBefore(endExclusive);
    }).toList();
  });
});

/// Single meal by ID
final mealByIdProvider = FutureProvider.family<Meal?, String>((ref, mealId) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getMeal(mealId);
});

// ========== WATER PROVIDERS ==========

/// Today's water log (real-time stream)
final todayWaterLogProvider = StreamProvider<WaterLog?>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(null);

  final repository = ref.watch(nutritionRepositoryProvider);
  final today = DateTime.now();
  return repository.getWaterLogStreamForDate(userId, today);
});

/// Water log for a specific date
final waterLogForDateProvider =
    StreamProvider.family<WaterLog?, DateTime>((ref, date) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(null);

  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getWaterLogStreamForDate(userId, date);
});

// ========== FOOD ITEM PROVIDERS ==========

/// Search food items by query
final foodSearchProvider =
    FutureProvider.family<List<FoodItem>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.searchFoodItems(query);
});

/// User's custom foods
final userCustomFoodsProvider = FutureProvider<List<FoodItem>>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getUserCustomFoods(userId);
});

/// Search food items by category
final foodsByCategoryProvider = FutureProvider.family<List<FoodItem>,
    FoodSearchParams>((ref, params) async {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.searchFoodItems(
    params.query,
    category: params.category,
  );
});

// ========== EXTERNAL API PROVIDERS ==========

/// USDA Service provider
final usdaServiceProvider = Provider<USDAService>((ref) {
  return USDAService();
});

/// OpenFoodFacts Service provider
final openFoodFactsServiceProvider = Provider<OpenFoodFactsService>((ref) {
  return OpenFoodFactsService();
});

/// USDA food search provider
/// Returns foods from USDA FoodData Central database
final usdaFoodSearchProvider =
    FutureProvider.family<List<FoodItem>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final service = ref.watch(usdaServiceProvider);
  return service.searchFoods(query, userId);
});

/// OpenFoodFacts search provider
/// Returns foods from OpenFoodFacts database (branded products)
final openFoodFactsSearchProvider =
    FutureProvider.family<List<FoodItem>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final service = ref.watch(openFoodFactsServiceProvider);
  return service.searchProducts(query, userId);
});

/// Unified food search provider
/// Searches USDA (primary) + OpenFoodFacts (secondary) + user custom foods
/// Returns combined results with duplicates removed
final unifiedFoodSearchProvider =
    FutureProvider.family<List<FoodItem>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return [];

  // Search all sources in parallel
  final usdaResults = await ref.watch(usdaFoodSearchProvider(query).future);
  final offResults = await ref.watch(openFoodFactsSearchProvider(query).future);
  final customResults = await ref.watch(foodSearchProvider(query).future);

  // Combine results: custom foods first, then USDA, then OpenFoodFacts
  final allResults = <FoodItem>[];
  final seenNames = <String>{};

  // Add custom foods first (highest priority)
  for (final food in customResults) {
    final normalizedName = food.name.toLowerCase().trim();
    if (!seenNames.contains(normalizedName)) {
      allResults.add(food);
      seenNames.add(normalizedName);
    }
  }

  // Add USDA results (verified government data)
  for (final food in usdaResults) {
    final normalizedName = food.name.toLowerCase().trim();
    if (!seenNames.contains(normalizedName)) {
      allResults.add(food);
      seenNames.add(normalizedName);
    }
  }

  // Add OpenFoodFacts results (branded products)
  for (final food in offResults) {
    final normalizedName = food.name.toLowerCase().trim();
    if (!seenNames.contains(normalizedName)) {
      allResults.add(food);
      seenNames.add(normalizedName);
    }
  }

  return allResults;
});

/// Food search source enum for filtering
enum FoodSearchSource {
  all,
  usda,
  openFoodFacts,
  custom,
}

/// Food search with source filter
final foodSearchBySourceProvider = FutureProvider.family<List<FoodItem>,
    FoodSearchBySourceParams>((ref, params) async {
  if (params.query.isEmpty) return [];

  switch (params.source) {
    case FoodSearchSource.usda:
      return ref.watch(usdaFoodSearchProvider(params.query).future);
    case FoodSearchSource.openFoodFacts:
      return ref.watch(openFoodFactsSearchProvider(params.query).future);
    case FoodSearchSource.custom:
      return ref.watch(foodSearchProvider(params.query).future);
    case FoodSearchSource.all:
      return ref.watch(unifiedFoodSearchProvider(params.query).future);
  }
});

// ========== DAILY SUMMARY PROVIDERS ==========

/// Today's nutrition summary
final todayNutritionSummaryProvider =
    FutureProvider<DailyNutritionSummary>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  final repository = ref.watch(nutritionRepositoryProvider);
  final today = DateTime.now();
  return repository.getDailySummary(userId, today);
});

/// Daily summary for a specific date
final dailyNutritionSummaryProvider =
    FutureProvider.family<DailyNutritionSummary, DateTime>((ref, date) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getDailySummary(userId, date);
});

/// Weekly stats provider
final weeklyNutritionStatsProvider =
    FutureProvider.family<Map<String, dynamic>, DateTime>((ref, weekStart) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return {};

  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.getWeeklyStats(userId, weekStart);
});

// ========== OPERATIONS STATE NOTIFIER ==========

/// State notifier for nutrition operations (mutations)
class NutritionOperations extends StateNotifier<AsyncValue<void>> {
  final NutritionRepository _repository;

  NutritionOperations(this._repository) : super(const AsyncValue.data(null));

  /// Log a meal
  Future<String?> logMeal(Meal meal) async {
    state = const AsyncValue.loading();
    try {
      final mealId = await _repository.logMeal(meal);
      state = const AsyncValue.data(null);
      return mealId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update a meal
  Future<bool> updateMeal(String mealId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateMeal(mealId, data);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Delete a meal
  Future<bool> deleteMeal(String mealId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteMeal(mealId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Increment water intake
  Future<bool> incrementWater(String userId, int glasses) async {
    state = const AsyncValue.loading();
    try {
      final today = DateTime.now();
      await _repository.incrementWater(userId, today, glasses);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Set water intake to a specific count
  Future<bool> setWaterCount(String userId, int glasses) async {
    state = const AsyncValue.loading();
    try {
      final today = DateTime.now();
      await _repository.setWaterCount(userId, today, glasses);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Reset water intake for today
  Future<bool> resetWater(String userId) async {
    return setWaterCount(userId, 0);
  }

  /// Create a custom food item
  Future<String?> createFoodItem(FoodItem foodItem) async {
    state = const AsyncValue.loading();
    try {
      final foodId = await _repository.createFoodItem(foodItem);
      state = const AsyncValue.data(null);
      return foodId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Update a food item
  Future<bool> updateFoodItem(
      String foodItemId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateFoodItem(foodItemId, data);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Delete a food item
  Future<bool> deleteFoodItem(String foodItemId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteFoodItem(foodItemId);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Create or update nutrition goal
  Future<String?> saveNutritionGoal(NutritionGoal goal) async {
    state = const AsyncValue.loading();
    try {
      final goalId = await _repository.createOrUpdateNutritionGoal(goal);
      state = const AsyncValue.data(null);
      return goalId;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}

/// Nutrition operations provider
final nutritionOperationsProvider =
    StateNotifierProvider<NutritionOperations, AsyncValue<void>>((ref) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return NutritionOperations(repository);
});

// ========== HELPER CLASSES ==========

/// Date range for querying meals
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({required this.start, required this.end});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

/// Food search parameters
class FoodSearchParams {
  final String query;
  final FoodCategory? category;

  const FoodSearchParams({
    required this.query,
    this.category,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodSearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          category == other.category;

  @override
  int get hashCode => query.hashCode ^ category.hashCode;
}

/// Food search by source parameters
class FoodSearchBySourceParams {
  final String query;
  final FoodSearchSource source;

  const FoodSearchBySourceParams({
    required this.query,
    this.source = FoodSearchSource.all,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodSearchBySourceParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          source == other.source;

  @override
  int get hashCode => query.hashCode ^ source.hashCode;
}
