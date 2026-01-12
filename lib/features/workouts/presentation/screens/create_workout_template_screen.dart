import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/exercise.dart';
import '../../data/repositories/workout_repository.dart';

class CreateWorkoutTemplateScreen extends ConsumerStatefulWidget {
  const CreateWorkoutTemplateScreen({super.key});

  @override
  ConsumerState<CreateWorkoutTemplateScreen> createState() =>
      _CreateWorkoutTemplateScreenState();
}

class _CreateWorkoutTemplateScreenState
    extends ConsumerState<CreateWorkoutTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _caloriesController = TextEditingController();

  WorkoutCategory _category = WorkoutCategory.strength;
  WorkoutDifficulty _difficulty = WorkoutDifficulty.beginner;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _saveTemplate() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to create a template.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final duration = int.tryParse(_durationController.text.trim()) ?? 0;
      final calories = _caloriesController.text.trim().isEmpty
          ? null
          : int.tryParse(_caloriesController.text.trim());

      final workout = Workout(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? 'Custom workout'
            : _descriptionController.text.trim(),
        difficulty: _difficulty,
        estimatedDuration: duration,
        exercises: const <Exercise>[],
        category: _category,
        caloriesBurned: calories,
      );

      final repository = ref.read(workoutRepositoryProvider);
      await repository.createWorkout(workout, userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout template created!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create template: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Template'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Build your own workout',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start simple — you can add exercises later.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout name',
                  hintText: 'e.g., Morning Strength',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'What is this workout about?',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = int.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Enter minutes';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _caloriesController,
                      decoration: const InputDecoration(
                        labelText: 'Calories (optional)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WorkoutCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: WorkoutCategory.values
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<WorkoutDifficulty>(
                value: _difficulty,
                decoration: const InputDecoration(labelText: 'Difficulty'),
                items: WorkoutDifficulty.values
                    .map(
                      (difficulty) => DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _difficulty = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveTemplate,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Template'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
