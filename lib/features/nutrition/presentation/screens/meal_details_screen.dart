import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/models/meal.dart';
import '../providers/nutrition_providers.dart';
import 'log_meal_screen.dart';

class MealDetailsScreen extends ConsumerWidget {
  final String mealId;

  const MealDetailsScreen({super.key, required this.mealId});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('This will permanently delete the meal.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final operations = ref.read(nutritionOperationsProvider.notifier);
    final success = await operations.deleteMeal(id);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal deleted')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete meal')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealAsync = ref.watch(mealByIdProvider(mealId));

    return mealAsync.when(
      data: (meal) {
        if (meal == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Meal Details')),
            body: const Center(child: Text('Meal not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Meal Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  context.push(
                    RouteConstants.logMeal,
                    extra: LogMealArgs(mealId: meal.id),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, ref, meal.id),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(meal),
              const SizedBox(height: 16),
              _buildTotalsCard(meal),
              const SizedBox(height: 16),
              Text(
                'Foods',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...meal.entries.map((entry) => _buildEntryTile(entry)),
              if (meal.notes != null && meal.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(meal.notes!),
              ],
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Meal Details')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Meal Details')),
        body: Center(child: Text('Failed to load meal: $error')),
      ),
    );
  }

  Widget _buildHeader(Meal meal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.restaurant_menu, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.mealType.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatDateTime(meal.loggedAt),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsCard(Meal meal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTotalItem('Calories', meal.totalCalories, 'cal'),
          _buildTotalItem('Protein', meal.totalProtein, 'g'),
          _buildTotalItem('Carbs', meal.totalCarbs, 'g'),
          _buildTotalItem('Fat', meal.totalFat, 'g'),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, double value, String unit) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(0),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '$label ($unit)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEntryTile(MealEntry entry) {
    final calories =
        (entry.foodItem.calories * entry.servings).toStringAsFixed(0);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.foodItem.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.servings.toStringAsFixed(1)} servings',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Text('$calories cal'),
        ],
      ),
    );
  }
}
