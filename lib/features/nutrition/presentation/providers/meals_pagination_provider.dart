import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/pagination.dart';
import '../../data/repositories/nutrition_repository.dart';
import '../../domain/models/meal.dart';
import 'nutrition_providers.dart';

/// Parameters for paginated meals query
class MealsPaginationParams {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const MealsPaginationParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealsPaginationParams &&
          userId == other.userId &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => Object.hash(userId, startDate, endDate);
}

/// Pagination notifier for meals
class MealsPaginationNotifier extends PaginationNotifier<Meal> {
  final NutritionRepository _repository;
  final MealsPaginationParams _params;

  MealsPaginationNotifier(this._repository, this._params) : super(pageSize: 20);

  @override
  Future<PaginatedResult<Meal>> fetchPage(int page, dynamic cursor) async {
    return _repository.getMealsPaginated(
      userId: _params.userId,
      pageSize: pageSize,
      startAfterDocument: cursor as DocumentSnapshot?,
      startDate: _params.startDate,
      endDate: _params.endDate,
      page: page,
    );
  }

  /// Add a new meal (optimistic update)
  void addMeal(Meal meal) {
    prependItem(meal);
  }

  /// Remove a meal by ID (optimistic update)
  void removeMealById(String mealId) {
    removeWhere((meal) => meal.id == mealId);
  }

  /// Update a meal (optimistic update)
  void updateMealById(String mealId, Meal updatedMeal) {
    updateWhere((meal) => meal.id == mealId, updatedMeal);
  }
}

/// Provider for paginated meals
final mealsPaginationProvider = StateNotifierProvider.family<
    MealsPaginationNotifier, PaginationState<Meal>, MealsPaginationParams>(
  (ref, params) {
    final repository = ref.watch(nutritionRepositoryProvider);
    return MealsPaginationNotifier(repository, params);
  },
);

/// Convenience provider for paginated meals with just userId
/// Loads all meals without date filter
final userMealsPaginatedProvider = StateNotifierProvider.family<
    MealsPaginationNotifier, PaginationState<Meal>, String>(
  (ref, userId) {
    final repository = ref.watch(nutritionRepositoryProvider);
    return MealsPaginationNotifier(
      repository,
      MealsPaginationParams(userId: userId),
    );
  },
);

/// Provider for recent meals (first page only, real-time)
final recentMealsStreamProvider =
    StreamProvider.family<PaginatedResult<Meal>, String>((ref, userId) {
  final repository = ref.watch(nutritionRepositoryProvider);
  return repository.streamMealsFirstPage(
    userId: userId,
    pageSize: 10,
  );
});
