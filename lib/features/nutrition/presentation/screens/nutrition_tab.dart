import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../providers/nutrition_providers.dart';
import '../../domain/models/meal.dart';
import 'log_meal_screen.dart';

/// Main nutrition tab screen
/// Displays water intake, daily summary, today's meals, and quick actions
class NutritionTab extends ConsumerWidget {
  const NutritionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              context.push(RouteConstants.nutritionHistory);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(RouteConstants.nutritionGoals);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh all providers
          ref.invalidate(todayWaterLogProvider);
          ref.invalidate(todayMealsProvider);
          ref.invalidate(todayNutritionSummaryProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Water Intake Widget
              _buildWaterIntakeSection(context, ref),
              const SizedBox(height: 24),

              // 2. Daily Summary Card
              _buildDailySummarySection(context, ref),
              const SizedBox(height: 24),

              // 3. Today's Meals List
              _buildTodaysMealsSection(context, ref),
              const SizedBox(height: 24),

              // 4. Quick Actions
              _buildQuickActionsSection(context, ref),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(RouteConstants.logMeal);
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Meal'),
      ),
    );
  }

  // ========== WATER INTAKE SECTION ==========

  Widget _buildWaterIntakeSection(BuildContext context, WidgetRef ref) {
    final waterLogAsync = ref.watch(todayWaterLogProvider);

    return waterLogAsync.when(
      data: (waterLog) {
        final glassesConsumed = waterLog?.glassesConsumed ?? 0;
        final targetGlasses = waterLog?.targetGlasses ?? 8;
        final progress = waterLog?.progressPercentage ?? 0;
        final goalAchieved = waterLog?.goalAchieved ?? false;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_drink,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Water Intake',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (goalAchieved)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Visual glasses representation
              _buildWaterGlasses(glassesConsumed, targetGlasses),

              const SizedBox(height: 16),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),

              const SizedBox(height: 12),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$glassesConsumed / $targetGlasses glasses',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Add glass button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _addWaterGlass(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Glass (250ml)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorCard(
        context,
        'Failed to load water intake',
        error.toString(),
        () => ref.refresh(todayWaterLogProvider),
      ),
    );
  }

  Widget _buildWaterGlasses(int consumed, int target) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(target, (index) {
        final isFilled = index < consumed;
        return Icon(
          isFilled ? Icons.local_drink : Icons.local_drink_outlined,
          color: Colors.white.withValues(alpha: isFilled ? 1.0 : 0.3),
          size: 32,
        );
      }),
    );
  }

  Future<void> _addWaterGlass(BuildContext context, WidgetRef ref) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to track water')),
        );
      }
      return;
    }

    final operations = ref.read(nutritionOperationsProvider.notifier);
    final success = await operations.incrementWater(userId, 1);

    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added 1 glass of water!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // ========== DAILY SUMMARY SECTION ==========

  Widget _buildDailySummarySection(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todayNutritionSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orange.shade50,
                Colors.orange.shade100,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orange.shade200,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Nutrition',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                summary.progressSummary,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),

              // Macros grid
              Row(
                children: [
                  Expanded(
                    child: _buildMacroCard(
                      'Calories',
                      summary.totalCalories.toStringAsFixed(0),
                      summary.goal?.dailyCalories.toStringAsFixed(0) ?? '0',
                      summary.caloriesProgress,
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMacroCard(
                      'Protein',
                      '${summary.totalProtein.toStringAsFixed(0)}g',
                      '${summary.goal?.dailyProteinGrams.toStringAsFixed(0) ?? '0'}g',
                      summary.proteinProgress,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMacroCard(
                      'Carbs',
                      '${summary.totalCarbs.toStringAsFixed(0)}g',
                      '${summary.goal?.dailyCarbsGrams.toStringAsFixed(0) ?? '0'}g',
                      summary.carbsProgress,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMacroCard(
                      'Fat',
                      '${summary.totalFat.toStringAsFixed(0)}g',
                      '${summary.goal?.dailyFatGrams.toStringAsFixed(0) ?? '0'}g',
                      summary.fatProgress,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorCard(
        context,
        'Failed to load nutrition summary',
        error.toString(),
        () => ref.refresh(todayNutritionSummaryProvider),
      ),
    );
  }

  Widget _buildMacroCard(
    String label,
    String current,
    String target,
    double progress,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            current,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'of $target',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (progress / 100).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  // ========== TODAY'S MEALS SECTION ==========

  Widget _buildTodaysMealsSection(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(todayMealsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Meals',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        mealsAsync.when(
          data: (meals) {
            if (meals.isEmpty) {
              return _buildEmptyMealsState(context);
            }

            // Group meals by type
            final mealsByType = <MealType, List<Meal>>{};
            for (var meal in meals) {
              mealsByType.putIfAbsent(meal.mealType, () => []);
              mealsByType[meal.mealType]!.add(meal);
            }

            return Column(
              children: MealType.values.map((type) {
                final typeMeals = mealsByType[type] ?? [];
                if (typeMeals.isEmpty) return const SizedBox.shrink();

                return Column(
                  children: [
                    _buildMealTypeSection(context, type, typeMeals),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorCard(
            context,
            'Failed to load meals',
            error.toString(),
            () => ref.refresh(todayMealsProvider),
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSection(
      BuildContext context, MealType type, List<Meal> meals) {
    final totalCalories =
        meals.fold<double>(0, (sum, meal) => sum + meal.totalCalories);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                type.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                type.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${totalCalories.toStringAsFixed(0)} cal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...meals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildMealItem(context, meal),
              )),
        ],
      ),
    );
  }

  Widget _buildMealItem(BuildContext context, Meal meal) {
    return InkWell(
      onTap: () {
        final route = RouteConstants.mealDetails.replaceFirst(':id', meal.id);
        context.push(route);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            if (meal.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  meal.photoUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.restaurant, size: 50),
                ),
              )
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.restaurant, color: Colors.grey),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${meal.entries.length} items',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (meal.notes != null && meal.notes!.isNotEmpty)
                    Text(
                      meal.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${meal.totalCalories.toStringAsFixed(0)} cal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'P: ${meal.totalProtein.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMealsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No meals logged today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to log your first meal',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========== QUICK ACTIONS SECTION ==========

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionChip(
              context,
              icon: Icons.restaurant,
              label: 'Log Meal',
              color: Colors.orange,
              onTap: () {
                context.push(RouteConstants.logMeal);
              },
            ),
            _buildQuickActionChip(
              context,
              icon: Icons.fastfood,
              label: 'Quick Snack',
              color: Colors.purple,
              onTap: () {
                context.push(
                  RouteConstants.logMeal,
                  extra: const LogMealArgs(initialMealType: MealType.snack),
                );
              },
            ),
            _buildQuickActionChip(
              context,
              icon: Icons.search,
              label: 'Search Foods',
              color: Colors.green,
              onTap: () {
                context.push(RouteConstants.foodSearch);
              },
            ),
            _buildQuickActionChip(
              context,
              icon: Icons.analytics,
              label: 'View Insights',
              color: Colors.blue,
              onTap: () {
                context.push(RouteConstants.aiInsights);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== ERROR STATE ==========

  Widget _buildErrorCard(
    BuildContext context,
    String title,
    String error,
    VoidCallback onRetry,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
