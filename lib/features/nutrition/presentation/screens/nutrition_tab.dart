import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/providers/app_settings_provider.dart';
import '../providers/nutrition_providers.dart';
import '../../domain/models/meal.dart';
import 'log_meal_screen.dart';

/// Main nutrition tab screen
/// Displays water intake, daily summary, today's meals, and quick actions
class NutritionTab extends ConsumerWidget {
  const NutritionTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    if (!settings.nutritionEnabled) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition'),
        ),
        body: _buildModuleDisabled(
          context,
          title: 'Nutrition is turned off',
          subtitle: 'Enable nutrition in Settings to use this tab.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
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

  Widget _buildModuleDisabled(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push(RouteConstants.settings),
              child: const Text('Open Settings'),
            ),
          ],
        ),
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
                AppColors.info,
                AppColors.info,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.info.withValues(alpha: 0.3),
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
                    color: AppColors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Water Intake',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (goalAchieved)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.white,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Visual glasses representation
              _buildWaterGlasses(
                context,
                ref,
                glassesConsumed,
                targetGlasses,
              ),

              const SizedBox(height: 16),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),

              const SizedBox(height: 12),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$glassesConsumed / $targetGlasses glasses',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Add / Reset actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _addWaterGlass(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Glass (250ml)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.info,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => _resetWater(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: BorderSide(color: AppColors.white),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    child: const Text('Reset'),
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
        'Failed to load water intake',
        error.toString(),
        () => ref.refresh(todayWaterLogProvider),
      ),
    );
  }

  Widget _buildWaterGlasses(
    BuildContext context,
    WidgetRef ref,
    int consumed,
    int target,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(target, (index) {
        final isFilled = index < consumed;
        return InkWell(
          onTap: () => _setWaterGlasses(context, ref, consumed, index, target),
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            isFilled ? Icons.local_drink : Icons.local_drink_outlined,
            color: AppColors.white.withValues(alpha: isFilled ? 1.0 : 0.3),
            size: 32,
          ),
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

  Future<void> _setWaterGlasses(
    BuildContext context,
    WidgetRef ref,
    int current,
    int index,
    int target,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to track water')),
        );
      }
      return;
    }

    final nextCount = index < current ? index : index + 1;
    final clamped = nextCount.clamp(0, target);
    final operations = ref.read(nutritionOperationsProvider.notifier);
    final success = await operations.setWaterCount(userId, clamped);

    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Water updated to $clamped glass${clamped == 1 ? '' : 'es'}'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _resetWater(BuildContext context, WidgetRef ref) async {
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
    final success = await operations.resetWater(userId);

    if (context.mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Water intake reset for today'),
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
                AppColors.warning.withValues(alpha: 0.1),
                AppColors.warning.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
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
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                summary.progressSummary,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // Macros grid
              Row(
                children: [
                  Expanded(
                    child: _buildMacroCard(
                      context,
                      'Calories',
                      summary.totalCalories.toStringAsFixed(0),
                      summary.goal?.dailyCalories.toStringAsFixed(0) ?? '0',
                      summary.caloriesProgress,
                      AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMacroCard(
                      context,
                      'Protein',
                      '${summary.totalProtein.toStringAsFixed(0)}g',
                      '${summary.goal?.dailyProteinGrams.toStringAsFixed(0) ?? '0'}g',
                      summary.proteinProgress,
                      AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMacroCard(
                      context,
                      'Carbs',
                      '${summary.totalCarbs.toStringAsFixed(0)}g',
                      '${summary.goal?.dailyCarbsGrams.toStringAsFixed(0) ?? '0'}g',
                      summary.carbsProgress,
                      AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMacroCard(
                      context,
                      'Fat',
                      '${summary.totalFat.toStringAsFixed(0)}g',
                      '${summary.goal?.dailyFatGrams.toStringAsFixed(0) ?? '0'}g',
                      summary.fatProgress,
                      AppColors.workoutFlexibility,
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
    BuildContext context,
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                type.emoji,
                style: TextStyle(fontSize: 24),
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                      Icon(Icons.restaurant, size: 50),
                ),
              )
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.restaurant, color: AppColors.grey),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${meal.entries.length} items',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (meal.notes != null && meal.notes!.isNotEmpty)
                    Text(
                      meal.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'P: ${meal.totalProtein.toStringAsFixed(0)}g',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No meals logged today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to log your first meal',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              color: AppColors.warning,
              onTap: () {
                context.push(RouteConstants.logMeal);
              },
            ),
            _buildQuickActionChip(
              context,
              icon: Icons.fastfood,
              label: 'Quick Snack',
              color: AppColors.workoutFlexibility,
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
              color: AppColors.success,
              onTap: () {
                context.push(RouteConstants.foodSearch);
              },
            ),
            _buildQuickActionChip(
              context,
              icon: Icons.analytics,
              label: 'View Insights',
              color: AppColors.info,
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
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Content-only version of NutritionTab for embedding in TrackTab.
/// Does not include Scaffold, AppBar, or FloatingActionButton.
class NutritionTabContent extends ConsumerWidget {
  const NutritionTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);

    if (!settings.nutritionEnabled) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                'Nutrition is turned off',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enable nutrition in Settings to use this tab.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push(RouteConstants.settings),
                child: const Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
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
                _buildWaterIntakeSection(context, ref),
                const SizedBox(height: 24),
                _buildDailySummarySection(context, ref),
                const SizedBox(height: 24),
                _buildTodaysMealsSection(context, ref),
                const SizedBox(height: 24),
                _buildQuickActionsSection(context, ref),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'nutrition_fab',
            onPressed: () => context.push(RouteConstants.logMeal),
            icon: const Icon(Icons.add),
            label: const Text('Log Meal'),
          ),
        ),
      ],
    );
  }

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
            gradient: const LinearGradient(colors: [AppColors.info, AppColors.info]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.info.withValues(alpha: 0.3),
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
                  const Icon(Icons.local_drink, color: AppColors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Water Intake',
                    style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  if (goalAchieved) const Icon(Icons.check_circle, color: AppColors.white, size: 28),
                ],
              ),
              const SizedBox(height: 16),
              _buildWaterGlasses(context, ref, glassesConsumed, targetGlasses),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$glassesConsumed / $targetGlasses glasses',
                    style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: const TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _addWaterGlass(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Glass'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.info,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () => _resetWater(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorCard(context, 'Failed to load water intake', error.toString(), () => ref.refresh(todayWaterLogProvider)),
    );
  }

  Widget _buildWaterGlasses(BuildContext context, WidgetRef ref, int consumed, int target) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(target, (index) {
        final isFilled = index < consumed;
        return InkWell(
          onTap: () => _setWaterGlasses(context, ref, consumed, index, target),
          borderRadius: BorderRadius.circular(20),
          child: Icon(
            isFilled ? Icons.local_drink : Icons.local_drink_outlined,
            color: AppColors.white.withValues(alpha: isFilled ? 1.0 : 0.3),
            size: 32,
          ),
        );
      }),
    );
  }

  Future<void> _addWaterGlass(BuildContext context, WidgetRef ref) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final operations = ref.read(nutritionOperationsProvider.notifier);
    await operations.incrementWater(userId, 1);
  }

  Future<void> _setWaterGlasses(BuildContext context, WidgetRef ref, int current, int index, int target) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final nextCount = index < current ? index : index + 1;
    final clamped = nextCount.clamp(0, target);
    final operations = ref.read(nutritionOperationsProvider.notifier);
    await operations.setWaterCount(userId, clamped);
  }

  Future<void> _resetWater(BuildContext context, WidgetRef ref) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    final operations = ref.read(nutritionOperationsProvider.notifier);
    await operations.resetWater(userId);
  }

  Widget _buildDailySummarySection(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(todayNutritionSummaryProvider);

    return summaryAsync.when(
      data: (summary) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.warning.withValues(alpha: 0.1), AppColors.warning.withValues(alpha: 0.2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Nutrition',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
              ),
              const SizedBox(height: 4),
              Text(
                summary.progressSummary,
                style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildMacroCard(context, 'Calories', summary.totalCalories.toStringAsFixed(0), summary.goal?.dailyCalories.toStringAsFixed(0) ?? '0', summary.caloriesProgress, AppColors.warning)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMacroCard(context, 'Protein', '${summary.totalProtein.toStringAsFixed(0)}g', '${summary.goal?.dailyProteinGrams.toStringAsFixed(0) ?? '0'}g', summary.proteinProgress, AppColors.info)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildMacroCard(context, 'Carbs', '${summary.totalCarbs.toStringAsFixed(0)}g', '${summary.goal?.dailyCarbsGrams.toStringAsFixed(0) ?? '0'}g', summary.carbsProgress, AppColors.success)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMacroCard(context, 'Fat', '${summary.totalFat.toStringAsFixed(0)}g', '${summary.goal?.dailyFatGrams.toStringAsFixed(0) ?? '0'}g', summary.fatProgress, AppColors.workoutFlexibility)),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorCard(context, 'Failed to load nutrition', error.toString(), () => ref.refresh(todayNutritionSummaryProvider)),
    );
  }

  Widget _buildMacroCard(BuildContext context, String label, String current, String target, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(current, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text('of $target', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

  Widget _buildTodaysMealsSection(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(todayMealsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today\'s Meals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        mealsAsync.when(
          data: (meals) {
            if (meals.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu, size: 64, color: Theme.of(context).colorScheme.outline),
                    const SizedBox(height: 16),
                    Text('No meals logged today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text('Tap the button below to log your first meal', style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                  ],
                ),
              );
            }

            final mealsByType = <MealType, List<Meal>>{};
            for (var meal in meals) {
              mealsByType.putIfAbsent(meal.mealType, () => []);
              mealsByType[meal.mealType]!.add(meal);
            }

            return Column(
              children: MealType.values.map((type) {
                final typeMeals = mealsByType[type] ?? [];
                if (typeMeals.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildMealTypeSection(context, type, typeMeals),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorCard(context, 'Failed to load meals', error.toString(), () => ref.refresh(todayMealsProvider)),
        ),
      ],
    );
  }

  Widget _buildMealTypeSection(BuildContext context, MealType type, List<Meal> meals) {
    final totalCalories = meals.fold<double>(0, (sum, meal) => sum + meal.totalCalories);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(type.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(type.displayName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${totalCalories.toStringAsFixed(0)} cal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
      onTap: () => context.push(RouteConstants.mealDetails.replaceFirst(':id', meal.id)),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            if (meal.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(meal.photoUrl!, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.restaurant, size: 50)),
              )
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.restaurant, color: AppColors.grey),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${meal.entries.length} items', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  if (meal.notes != null && meal.notes!.isNotEmpty)
                    Text(meal.notes!, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${meal.totalCalories.toStringAsFixed(0)} cal', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text('P: ${meal.totalProtein.toStringAsFixed(0)}g', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildQuickActionChip(context, icon: Icons.restaurant, label: 'Log Meal', color: AppColors.warning, onTap: () => context.push(RouteConstants.logMeal)),
            _buildQuickActionChip(context, icon: Icons.fastfood, label: 'Quick Snack', color: AppColors.workoutFlexibility, onTap: () => context.push(RouteConstants.logMeal, extra: const LogMealArgs(initialMealType: MealType.snack))),
            _buildQuickActionChip(context, icon: Icons.search, label: 'Search Foods', color: AppColors.success, onTap: () => context.push(RouteConstants.foodSearch)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionChip(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String title, String error, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(error, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: AppColors.white),
          ),
        ],
      ),
    );
  }
}
