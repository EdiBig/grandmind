import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/food_item.dart';
import '../../domain/models/meal.dart';
import '../../domain/models/water_log.dart';
import '../../domain/models/nutrition_goal.dart';
import '../../domain/models/daily_nutrition_summary.dart';

/// Repository for nutrition-related data operations
/// Handles CRUD operations for meals, water logs, food items, and nutrition goals
class NutritionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection names
  static const String _mealsCollection = 'meals';
  static const String _waterLogsCollection = 'water_logs';
  static const String _nutritionGoalsCollection = 'nutrition_goals';
  static const String _foodItemsCollection = 'food_items';

  // ========== MEALS CRUD ==========

  /// Log a new meal
  Future<String> logMeal(Meal meal) async {
    try {
      // Calculate totals before saving
      final mealWithTotals = meal.calculateTotals();

      final mealData = mealWithTotals.toJson();
      mealData['loggedAt'] = FieldValue.serverTimestamp();

      final docRef =
          await _firestore.collection(_mealsCollection).add(mealData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to log meal: $e');
    }
  }

  /// Update an existing meal
  Future<void> updateMeal(String mealId, Map<String, dynamic> data) async {
    try {
      final updateData = Map<String, dynamic>.from(data);

      if (updateData.containsKey('entries')) {
        final doc =
            await _firestore.collection(_mealsCollection).doc(mealId).get();
        if (!doc.exists) {
          throw Exception('Meal not found');
        }

        final mergedData = <String, dynamic>{
          ...doc.data() as Map<String, dynamic>,
          ...updateData,
          'id': doc.id,
        };
        final updatedMeal = Meal.fromJson(mergedData).calculateTotals();
        updateData
          ..['totalCalories'] = updatedMeal.totalCalories
          ..['totalProtein'] = updatedMeal.totalProtein
          ..['totalCarbs'] = updatedMeal.totalCarbs
          ..['totalFat'] = updatedMeal.totalFat;
      }

      await _firestore
          .collection(_mealsCollection)
          .doc(mealId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update meal: $e');
    }
  }

  /// Delete a meal
  Future<void> deleteMeal(String mealId) async {
    try {
      await _firestore.collection(_mealsCollection).doc(mealId).delete();
    } catch (e) {
      throw Exception('Failed to delete meal: $e');
    }
  }

  /// Get a single meal by ID
  Future<Meal?> getMeal(String mealId) async {
    try {
      final doc =
          await _firestore.collection(_mealsCollection).doc(mealId).get();

      if (!doc.exists) return null;

      return Meal.fromJson({
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id,
      });
    } catch (e) {
      throw Exception('Failed to get meal: $e');
    }
  }

  /// Get all meals for a specific date
  Future<List<Meal>> getUserMealsForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_mealsCollection)
          .where('userId', isEqualTo: userId)
          .where('mealDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('mealDate', isLessThan: Timestamp.fromDate(endOfDay))
          .orderBy('mealDate')
          .orderBy('loggedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Meal.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user meals for date: $e');
    }
  }

  /// Get user meals as a stream (real-time updates)
  Stream<List<Meal>> getUserMealsStream(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    try {
      Query query = _firestore
          .collection(_mealsCollection)
          .where('userId', isEqualTo: userId);

      if (startDate != null) {
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        query = query.where('mealDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start));
      }

      if (endDate != null) {
        final end = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        query = query.where('mealDate', isLessThanOrEqualTo: Timestamp.fromDate(end));
      }

      return query.orderBy('mealDate', descending: true).snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => Meal.fromJson({
                      ...doc.data() as Map<String, dynamic>,
                      'id': doc.id,
                    }))
                .toList(),
          );
    } catch (e) {
      throw Exception('Failed to stream user meals: $e');
    }
  }

  // ========== WATER LOGS CRUD ==========

  /// Log water intake
  Future<String> logWater(WaterLog waterLog) async {
    try {
      final waterData = waterLog.toJson();
      waterData['loggedAt'] = FieldValue.serverTimestamp();

      final docRef =
          await _firestore.collection(_waterLogsCollection).add(waterData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to log water: $e');
    }
  }

  /// Update water log
  Future<void> updateWaterLog(String logId, int glassesConsumed) async {
    try {
      await _firestore.collection(_waterLogsCollection).doc(logId).update({
        'glassesConsumed': glassesConsumed,
        'loggedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update water log: $e');
    }
  }

  /// Get water log for a specific date
  Future<WaterLog?> getWaterLogForDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection(_waterLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = Map<String, dynamic>.from(snapshot.docs.first.data());
      data['date'] ??= Timestamp.fromDate(startOfDay);
      data['loggedAt'] ??= Timestamp.fromDate(DateTime.now());

      try {
        return WaterLog.fromJson({
          ...data,
          'id': snapshot.docs.first.id,
        });
      } catch (_) {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to get water log for date: $e');
    }
  }

  /// Get water log for a specific date as a stream
  Stream<WaterLog?> getWaterLogStreamForDate(
      String userId, DateTime date) {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return _firestore
          .collection(_waterLogsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;

        final data = Map<String, dynamic>.from(snapshot.docs.first.data());
        data['date'] ??= Timestamp.fromDate(startOfDay);
        data['loggedAt'] ??= Timestamp.fromDate(DateTime.now());

        try {
          return WaterLog.fromJson({
            ...data,
            'id': snapshot.docs.first.id,
          });
        } catch (_) {
          return null;
        }
      });
    } catch (e) {
      throw Exception('Failed to stream water log for date: $e');
    }
  }

  /// Increment water intake for a specific date
  Future<void> incrementWater(
    String userId, DateTime date, int glasses) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);

      // Check if water log exists for today
      final existingLog = await getWaterLogForDate(userId, date);

      if (existingLog != null) {
        // Update existing log
        await updateWaterLog(
          existingLog.id,
          existingLog.glassesConsumed + glasses,
        );
      } else {
        // Create new log
        final goal = await getUserNutritionGoal(userId);
        final waterLog = WaterLog(
          id: '',
          userId: userId,
          date: startOfDay,
          loggedAt: DateTime.now(),
          glassesConsumed: glasses,
          targetGlasses: goal?.dailyWaterGlasses ?? 8,
        );
        await logWater(waterLog);
      }
    } catch (e) {
      throw Exception('Failed to increment water: $e');
    }
  }

  /// Set water intake for a specific date
  Future<void> setWaterCount(
    String userId,
    DateTime date,
    int glassesConsumed,
  ) async {
    try {
      final existingLog = await getWaterLogForDate(userId, date);
      final sanitized = glassesConsumed < 0 ? 0 : glassesConsumed;

      if (existingLog != null) {
        await updateWaterLog(existingLog.id, sanitized);
        return;
      }

      final goal = await getUserNutritionGoal(userId);
      final startOfDay = DateTime(date.year, date.month, date.day);
      final waterLog = WaterLog(
        id: '',
        userId: userId,
        date: startOfDay,
        loggedAt: DateTime.now(),
        glassesConsumed: sanitized,
        targetGlasses: goal?.dailyWaterGlasses ?? 8,
      );
      await logWater(waterLog);
    } catch (e) {
      throw Exception('Failed to set water count: $e');
    }
  }

  // ========== FOOD ITEMS CRUD ==========

  /// Create a custom food item
  Future<String> createFoodItem(FoodItem foodItem) async {
    try {
      final foodData = foodItem.toJson();
      foodData['createdAt'] = FieldValue.serverTimestamp();

      final docRef =
          await _firestore.collection(_foodItemsCollection).add(foodData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create food item: $e');
    }
  }

  /// Update a food item
  Future<void> updateFoodItem(
      String foodItemId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(_foodItemsCollection)
          .doc(foodItemId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update food item: $e');
    }
  }

  /// Delete a food item
  Future<void> deleteFoodItem(String foodItemId) async {
    try {
      await _firestore.collection(_foodItemsCollection).doc(foodItemId).delete();
    } catch (e) {
      throw Exception('Failed to delete food item: $e');
    }
  }

  /// Search food items by name
  Future<List<FoodItem>> searchFoodItems(String query,
      {FoodCategory? category}) async {
    try {
      Query queryRef = _firestore.collection(_foodItemsCollection);

      if (category != null) {
        queryRef = queryRef.where('category', isEqualTo: category.name);
      }

      // Note: Firestore doesn't support case-insensitive search natively
      // This is a basic implementation. For production, consider using Algolia or similar
      final snapshot = await queryRef.limit(50).get();

      final results = snapshot.docs
          .map((doc) => FoodItem.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .where((food) =>
              food.name.toLowerCase().contains(query.toLowerCase()) ||
              (food.brand?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();

      return results;
    } catch (e) {
      throw Exception('Failed to search food items: $e');
    }
  }

  /// Get user's custom foods
  Future<List<FoodItem>> getUserCustomFoods(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_foodItemsCollection)
          .where('userId', isEqualTo: userId)
          .where('isCustom', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FoodItem.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user custom foods: $e');
    }
  }

  /// Get food item by barcode (future feature)
  Future<FoodItem?> getFoodItemByBarcode(String barcode) async {
    try {
      final snapshot = await _firestore
          .collection(_foodItemsCollection)
          .where('barcode', isEqualTo: barcode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return FoodItem.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      throw Exception('Failed to get food item by barcode: $e');
    }
  }

  // ========== NUTRITION GOALS CRUD ==========

  /// Create or update nutrition goal
  Future<String> createOrUpdateNutritionGoal(NutritionGoal goal) async {
    try {
      final goalData = goal.toJson();
      goalData['updatedAt'] = FieldValue.serverTimestamp();

      if (goal.id.isEmpty) {
        // Create new goal
        goalData['createdAt'] = FieldValue.serverTimestamp();
        final docRef = await _firestore
            .collection(_nutritionGoalsCollection)
            .add(goalData);
        return docRef.id;
      } else {
        // Update existing goal
        await _firestore
            .collection(_nutritionGoalsCollection)
            .doc(goal.id)
            .set(goalData, SetOptions(merge: true));
        return goal.id;
      }
    } catch (e) {
      throw Exception('Failed to create/update nutrition goal: $e');
    }
  }

  /// Get user's nutrition goal
  Future<NutritionGoal?> getUserNutritionGoal(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_nutritionGoalsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return NutritionGoal.fromJson({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      throw Exception('Failed to get user nutrition goal: $e');
    }
  }

  /// Get user's nutrition goal as a stream
  Stream<NutritionGoal?> getUserNutritionGoalStream(String userId) {
    try {
      return _firestore
          .collection(_nutritionGoalsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;

        return NutritionGoal.fromJson({
          ...snapshot.docs.first.data(),
          'id': snapshot.docs.first.id,
        });
      });
    } catch (e) {
      throw Exception('Failed to stream user nutrition goal: $e');
    }
  }

  // ========== AGGREGATIONS & SUMMARIES ==========

  /// Get daily nutrition summary for a specific date
  Future<DailyNutritionSummary> getDailySummary(
      String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);

      // Get all meals for the day
      final meals = await getUserMealsForDate(userId, date);

      // Get water log
      final waterLog = await getWaterLogForDate(userId, date);

      // Get user's goal
      final goal = await getUserNutritionGoal(userId);

      // Calculate totals
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      Map<MealType, double> caloriesByMeal = {};

      for (var meal in meals) {
        totalCalories += meal.totalCalories;
        totalProtein += meal.totalProtein;
        totalCarbs += meal.totalCarbs;
        totalFat += meal.totalFat;

        caloriesByMeal[meal.mealType] =
            (caloriesByMeal[meal.mealType] ?? 0) + meal.totalCalories;
      }

      return DailyNutritionSummary(
        userId: userId,
        date: startOfDay,
        totalCalories: totalCalories,
        totalProtein: totalProtein,
        totalCarbs: totalCarbs,
        totalFat: totalFat,
        waterGlasses: waterLog?.glassesConsumed ?? 0,
        mealsLogged: meals.length,
        caloriesByMeal: caloriesByMeal,
        goal: goal,
      );
    } catch (e) {
      throw Exception('Failed to get daily summary: $e');
    }
  }

  /// Get weekly nutrition statistics
  Future<Map<String, dynamic>> getWeeklyStats(
      String userId, DateTime weekStart) async {
    try {
      final weekEnd = weekStart.add(const Duration(days: 7));

      // Get all meals in the week
      Query query = _firestore
          .collection(_mealsCollection)
          .where('userId', isEqualTo: userId)
          .where('mealDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(weekStart))
          .where('mealDate', isLessThan: Timestamp.fromDate(weekEnd));

      final snapshot = await query.get();

      final meals = snapshot.docs
          .map((doc) => Meal.fromJson({
                ...doc.data() as Map<String, dynamic>,
                'id': doc.id,
              }))
          .toList();

      if (meals.isEmpty) {
        return {
          'averageDailyCalories': 0,
          'averageDailyProtein': 0.0,
          'averageDailyCarbs': 0.0,
          'averageDailyFat': 0.0,
          'daysLogged': 0,
          'totalMeals': 0,
        };
      }

      // Group meals by day
      final mealsByDay = <String, List<Meal>>{};
      for (var meal in meals) {
        final dateKey =
            '${meal.mealDate.year}-${meal.mealDate.month}-${meal.mealDate.day}';
        mealsByDay.putIfAbsent(dateKey, () => []);
        mealsByDay[dateKey]!.add(meal);
      }

      final daysLogged = mealsByDay.length;
      final totalCalories =
          meals.fold<double>(0, (total, meal) => total + meal.totalCalories);
      final totalProtein =
          meals.fold<double>(0, (total, meal) => total + meal.totalProtein);
      final totalCarbs =
          meals.fold<double>(0, (total, meal) => total + meal.totalCarbs);
      final totalFat =
          meals.fold<double>(0, (total, meal) => total + meal.totalFat);

      return {
        'averageDailyCalories': (totalCalories / daysLogged).round(),
        'averageDailyProtein': totalProtein / daysLogged,
        'averageDailyCarbs': totalCarbs / daysLogged,
        'averageDailyFat': totalFat / daysLogged,
        'daysLogged': daysLogged,
        'totalMeals': meals.length,
        'totalWeekCalories': totalCalories.round(),
        'totalWeekProtein': totalProtein,
        'totalWeekCarbs': totalCarbs,
        'totalWeekFat': totalFat,
      };
    } catch (e) {
      throw Exception('Failed to get weekly stats: $e');
    }
  }
}
