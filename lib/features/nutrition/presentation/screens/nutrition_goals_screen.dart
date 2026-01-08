import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/nutrition_goal.dart';
import '../providers/nutrition_providers.dart';

class NutritionGoalsScreen extends ConsumerStatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  ConsumerState<NutritionGoalsScreen> createState() =>
      _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends ConsumerState<NutritionGoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _waterController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialized = false;
  NutritionGoal? _existingGoal;

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _initializeFromGoal(NutritionGoal? goal) {
    if (_isInitialized) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isInitialized) return;
      setState(() {
        _existingGoal = goal;
        _caloriesController.text =
            (goal?.dailyCalories ?? 2000).toStringAsFixed(0);
        _proteinController.text =
            (goal?.dailyProteinGrams ?? 150).toStringAsFixed(0);
        _carbsController.text =
            (goal?.dailyCarbsGrams ?? 250).toStringAsFixed(0);
        _fatController.text =
            (goal?.dailyFatGrams ?? 65).toStringAsFixed(0);
        _waterController.text = (goal?.dailyWaterGlasses ?? 8).toString();
        _isInitialized = true;
      });
    });
  }

  double _parseDouble(String value, double fallback) {
    return double.tryParse(value.trim()) ?? fallback;
  }

  int _parseInt(String value, int fallback) {
    return int.tryParse(value.trim()) ?? fallback;
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to update goals')),
          );
        }
        return;
      }

      final goal = NutritionGoal(
        id: _existingGoal?.id ?? '',
        userId: userId,
        dailyCalories: _parseDouble(_caloriesController.text, 2000),
        dailyProteinGrams: _parseDouble(_proteinController.text, 150),
        dailyCarbsGrams: _parseDouble(_carbsController.text, 250),
        dailyFatGrams: _parseDouble(_fatController.text, 65),
        dailyWaterGlasses: _parseInt(_waterController.text, 8),
        createdAt: _existingGoal?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isActive: true,
      );

      final operations = ref.read(nutritionOperationsProvider.notifier);
      final success = await operations.saveNutritionGoal(goal) != null;

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nutrition goals saved')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save goals')),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = ref.watch(userNutritionGoalProvider);

    return goalAsync.when(
      data: (goal) {
        _initializeFromGoal(goal);
        return Scaffold(
          appBar: AppBar(title: const Text('Nutrition Goals')),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildNumberField(
                  controller: _caloriesController,
                  label: 'Daily Calories',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildNumberField(
                        controller: _proteinController,
                        label: 'Protein (g)',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNumberField(
                        controller: _carbsController,
                        label: 'Carbs (g)',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildNumberField(
                  controller: _fatController,
                  label: 'Fat (g)',
                ),
                const SizedBox(height: 16),
                _buildNumberField(
                  controller: _waterController,
                  label: 'Water (glasses)',
                  isInteger: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveGoals,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Goals'),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Nutrition Goals')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Nutrition Goals')),
        body: Center(child: Text('Failed to load goals: $error')),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    bool isInteger = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: !isInteger),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        if (isInteger) {
          if (int.tryParse(value) == null) {
            return 'Invalid number';
          }
        } else if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }
}
