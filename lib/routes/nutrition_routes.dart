import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../features/nutrition/presentation/screens/log_meal_screen.dart';
import '../features/nutrition/presentation/screens/food_search_screen.dart';
import '../features/nutrition/presentation/screens/create_custom_food_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_goals_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_history_screen.dart';
import '../features/nutrition/presentation/screens/meal_details_screen.dart';
import '../features/nutrition/presentation/screens/nutrition_insights_screen.dart';
import '../features/nutrition/presentation/screens/barcode_scanner_screen.dart';

/// Nutrition feature routes
List<GoRoute> nutritionRoutes = [
  GoRoute(
    path: RouteConstants.logMeal,
    name: 'logMeal',
    builder: (context, state) {
      final args = state.extra as LogMealArgs?;
      return LogMealScreen(
        mealId: args?.mealId,
        initialMealType: args?.initialMealType,
      );
    },
  ),
  GoRoute(
    path: RouteConstants.foodSearch,
    name: 'foodSearch',
    builder: (context, state) {
      final isSelection = state.extra as bool? ?? false;
      return FoodSearchScreen(isSelection: isSelection);
    },
  ),
  GoRoute(
    path: RouteConstants.createCustomFood,
    name: 'createCustomFood',
    builder: (context, state) => const CreateCustomFoodScreen(),
  ),
  GoRoute(
    path: RouteConstants.nutritionGoals,
    name: 'nutritionGoals',
    builder: (context, state) => const NutritionGoalsScreen(),
  ),
  GoRoute(
    path: RouteConstants.nutritionHistory,
    name: 'nutritionHistory',
    builder: (context, state) => const NutritionHistoryScreen(),
  ),
  GoRoute(
    path: RouteConstants.mealDetails,
    name: 'mealDetails',
    builder: (context, state) {
      final mealId = state.pathParameters['id'] ?? '';
      return MealDetailsScreen(mealId: mealId);
    },
  ),
  GoRoute(
    path: RouteConstants.aiInsights,
    name: 'aiInsights',
    builder: (context, state) => const NutritionInsightsScreen(),
  ),
  GoRoute(
    path: RouteConstants.barcodeScanner,
    name: 'barcodeScanner',
    builder: (context, state) => const BarcodeScannerScreen(),
  ),
];
