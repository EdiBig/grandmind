/// Test fixtures for Kinesa tests
///
/// Provides reusable test data for models across all tests.
library;

import 'package:kinesa/features/habits/domain/models/habit.dart';
import 'package:kinesa/features/habits/domain/models/habit_log.dart';
import 'package:kinesa/features/nutrition/domain/models/meal.dart';
import 'package:kinesa/features/nutrition/domain/models/water_log.dart';
import 'package:kinesa/features/nutrition/domain/models/nutrition_goal.dart';
import 'package:kinesa/features/nutrition/domain/models/food_item.dart';
import 'package:kinesa/features/workouts/domain/models/workout.dart';
import 'package:kinesa/features/workouts/domain/models/workout_log.dart';
import 'package:kinesa/features/workouts/domain/models/exercise.dart';
import 'package:kinesa/features/user/data/models/user_model.dart';

// ========== User Fixtures ==========

const String testUserId = 'test-user-123';
const String testUserEmail = 'test@example.com';
const String testUserName = 'Test User';

UserModel createTestUser({
  String? id,
  String? email,
  String? displayName,
  DateTime? createdAt,
  DateTime? updatedAt,
}) =>
    UserModel(
      id: id ?? testUserId,
      email: email ?? testUserEmail,
      displayName: displayName ?? testUserName,
      createdAt: createdAt ?? DateTime(2024, 1, 1),
      updatedAt: updatedAt ?? DateTime(2024, 1, 1),
    );

// ========== Habit Fixtures ==========

Habit createTestHabit({
  String? id,
  String? userId,
  String? name,
  String? description,
  HabitFrequency? frequency,
  HabitIcon? icon,
  HabitColor? color,
  bool? isActive,
  int? currentStreak,
  int? longestStreak,
  DateTime? lastCompletedAt,
  DateTime? createdAt,
}) =>
    Habit(
      id: id ?? 'habit-123',
      userId: userId ?? testUserId,
      name: name ?? 'Test Habit',
      description: description ?? 'Test habit description',
      frequency: frequency ?? HabitFrequency.daily,
      icon: icon ?? HabitIcon.exercise,
      color: color ?? HabitColor.blue,
      isActive: isActive ?? true,
      currentStreak: currentStreak ?? 0,
      longestStreak: longestStreak ?? 0,
      lastCompletedAt: lastCompletedAt,
      createdAt: createdAt ?? DateTime(2024, 1, 1),
    );

HabitLog createTestHabitLog({
  String? id,
  String? habitId,
  String? userId,
  DateTime? date,
  DateTime? completedAt,
  String? notes,
}) =>
    HabitLog(
      id: id ?? 'habit-log-123',
      habitId: habitId ?? 'habit-123',
      userId: userId ?? testUserId,
      date: date ?? DateTime.now(),
      completedAt: completedAt ?? DateTime.now(),
      notes: notes,
    );

/// Creates a list of habit logs for consecutive days
List<HabitLog> createConsecutiveHabitLogs({
  required String habitId,
  required String userId,
  required int days,
  DateTime? startDate,
}) {
  final start = startDate ?? DateTime.now().subtract(Duration(days: days - 1));
  return List.generate(
    days,
    (i) => createTestHabitLog(
      id: 'log-$i',
      habitId: habitId,
      userId: userId,
      date: DateTime(start.year, start.month, start.day + i),
      completedAt: DateTime(start.year, start.month, start.day + i, 12, 0),
    ),
  );
}

// ========== Workout Fixtures ==========

Exercise createTestExercise({
  String? id,
  String? name,
  String? description,
  ExerciseType? type,
  List<String>? muscleGroups,
  ExerciseMetrics? metrics,
}) =>
    Exercise(
      id: id ?? 'exercise-123',
      name: name ?? 'Push Ups',
      description: description ?? 'A classic bodyweight exercise',
      type: type ?? ExerciseType.reps,
      muscleGroups: muscleGroups ?? ['Chest', 'Triceps'],
      metrics: metrics ?? ExerciseMetrics(sets: 3, reps: 12, restTime: 60),
    );

Workout createTestWorkout({
  String? id,
  String? name,
  String? description,
  WorkoutCategory? category,
  WorkoutDifficulty? difficulty,
  int? estimatedDuration,
  int? caloriesBurned,
  String? equipment,
  List<Exercise>? exercises,
  List<String>? tags,
  String? createdBy,
}) =>
    Workout(
      id: id ?? 'workout-123',
      name: name ?? 'Full Body Workout',
      description: description ?? 'A complete full body workout',
      category: category ?? WorkoutCategory.strength,
      difficulty: difficulty ?? WorkoutDifficulty.intermediate,
      estimatedDuration: estimatedDuration ?? 45,
      caloriesBurned: caloriesBurned ?? 350,
      equipment: equipment,
      exercises: exercises ?? [createTestExercise()],
      tags: tags ?? ['strength', 'full-body'],
      createdBy: createdBy,
    );

SetLog createTestSetLog({
  int? setNumber,
  int? reps,
  double? weight,
}) =>
    SetLog(
      setNumber: setNumber ?? 1,
      reps: reps ?? 12,
      weight: weight ?? 0,
    );

ExerciseLog createTestExerciseLog({
  String? exerciseId,
  String? exerciseName,
  ExerciseType? type,
  List<SetLog>? sets,
}) =>
    ExerciseLog(
      exerciseId: exerciseId ?? 'exercise-123',
      exerciseName: exerciseName ?? 'Push Ups',
      type: type ?? ExerciseType.reps,
      sets: sets ?? [createTestSetLog()],
    );

WorkoutLog createTestWorkoutLog({
  String? id,
  String? userId,
  String? workoutId,
  String? workoutName,
  WorkoutCategory? category,
  DateTime? startedAt,
  int? duration,
  List<ExerciseLog>? exercises,
  int? caloriesBurned,
  String? notes,
}) =>
    WorkoutLog(
      id: id ?? 'workout-log-123',
      userId: userId ?? testUserId,
      workoutId: workoutId ?? 'workout-123',
      workoutName: workoutName ?? 'Full Body Workout',
      category: category ?? WorkoutCategory.strength,
      startedAt: startedAt ?? DateTime.now(),
      duration: duration ?? 45,
      exercises: exercises ?? [createTestExerciseLog()],
      caloriesBurned: caloriesBurned ?? 350,
      notes: notes,
    );

// ========== Nutrition Fixtures ==========

FoodItem createTestFoodItem({
  String? id,
  String? name,
  String? userId,
  String? brand,
  double? calories,
  double? proteinGrams,
  double? carbsGrams,
  double? fatGrams,
  double? servingSizeGrams,
  String? servingSizeUnit,
  FoodCategory? category,
  bool? isCustom,
}) =>
    FoodItem(
      id: id ?? 'food-123',
      name: name ?? 'Test Food',
      userId: userId ?? testUserId,
      brand: brand,
      calories: calories ?? 200,
      proteinGrams: proteinGrams ?? 15,
      carbsGrams: carbsGrams ?? 20,
      fatGrams: fatGrams ?? 10,
      servingSizeGrams: servingSizeGrams ?? 100,
      servingSizeUnit: servingSizeUnit,
      category: category ?? FoodCategory.protein,
      isCustom: isCustom ?? false,
    );

MealEntry createTestMealEntry({
  FoodItem? foodItem,
  double? servings,
}) =>
    MealEntry(
      foodItem: foodItem ?? createTestFoodItem(),
      servings: servings ?? 1.0,
    );

Meal createTestMeal({
  String? id,
  String? userId,
  MealType? mealType,
  DateTime? mealDate,
  DateTime? loggedAt,
  List<MealEntry>? entries,
  double? totalCalories,
  double? totalProtein,
  double? totalCarbs,
  double? totalFat,
  String? notes,
}) {
  final meal = Meal(
    id: id ?? 'meal-123',
    userId: userId ?? testUserId,
    mealType: mealType ?? MealType.breakfast,
    mealDate: mealDate ?? DateTime.now(),
    loggedAt: loggedAt ?? DateTime.now(),
    entries: entries ?? [createTestMealEntry()],
    totalCalories: totalCalories ?? 0,
    totalProtein: totalProtein ?? 0,
    totalCarbs: totalCarbs ?? 0,
    totalFat: totalFat ?? 0,
    notes: notes,
  );
  return meal.calculateTotals();
}

WaterLog createTestWaterLog({
  String? id,
  String? userId,
  DateTime? date,
  DateTime? loggedAt,
  int? glassesConsumed,
  int? targetGlasses,
}) =>
    WaterLog(
      id: id ?? 'water-log-123',
      userId: userId ?? testUserId,
      date: date ?? DateTime.now(),
      loggedAt: loggedAt ?? DateTime.now(),
      glassesConsumed: glassesConsumed ?? 4,
      targetGlasses: targetGlasses ?? 8,
    );

NutritionGoal createTestNutritionGoal({
  String? id,
  String? userId,
  double? dailyCalories,
  double? dailyProteinGrams,
  double? dailyCarbsGrams,
  double? dailyFatGrams,
  int? dailyWaterGlasses,
  bool? isActive,
  DateTime? createdAt,
}) =>
    NutritionGoal(
      id: id ?? 'goal-123',
      userId: userId ?? testUserId,
      dailyCalories: dailyCalories ?? 2000,
      dailyProteinGrams: dailyProteinGrams ?? 150,
      dailyCarbsGrams: dailyCarbsGrams ?? 200,
      dailyFatGrams: dailyFatGrams ?? 65,
      dailyWaterGlasses: dailyWaterGlasses ?? 8,
      isActive: isActive ?? true,
      createdAt: createdAt ?? DateTime(2024, 1, 1),
    );

// ========== Date Fixtures ==========

/// Start of today
DateTime get todayStart => DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

/// End of today (23:59:59)
DateTime get todayEnd => todayStart.add(const Duration(days: 1)).subtract(
      const Duration(seconds: 1),
    );

/// Start of yesterday
DateTime get yesterdayStart => todayStart.subtract(const Duration(days: 1));

/// Start of this week (Monday)
DateTime get weekStart {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - (now.weekday - 1));
}

/// Start of this month
DateTime get monthStart {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
}
