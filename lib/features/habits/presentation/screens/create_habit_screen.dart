import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/habit.dart';
import '../providers/habit_providers.dart';
import '../widgets/habit_icon_helper.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  final String? habitId; // null for create, non-null for edit

  const CreateHabitScreen({super.key, this.habitId});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetCountController = TextEditingController();
  final _unitController = TextEditingController();

  HabitIcon _selectedIcon = HabitIcon.other;
  HabitColor _selectedColor = HabitColor.blue;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  bool _hasTargetCount = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetCountController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not authenticated')),
          );
        }
        return;
      }

      final habit = Habit(
        id: widget.habitId ?? '',
        userId: userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        frequency: _selectedFrequency,
        icon: _selectedIcon,
        color: _selectedColor,
        createdAt: DateTime.now(),
        targetCount: _hasTargetCount
            ? int.tryParse(_targetCountController.text) ?? 0
            : 0,
        unit: _hasTargetCount ? _unitController.text.trim() : null,
      );

      final habitOps = ref.read(habitOperationsProvider.notifier);
      final success = widget.habitId == null
          ? await habitOps.createHabit(habit) != null
          : await habitOps.updateHabit(widget.habitId!, habit.toJson());

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.habitId == null
                    ? 'Habit created successfully!'
                    : 'Habit updated successfully!',
              ),
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save habit')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habitId == null ? 'Create Habit' : 'Edit Habit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Habit Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit Name',
                hintText: 'e.g., Drink 8 glasses of water',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Why is this habit important to you?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Icon Selection
            Text(
              'Choose an icon',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildIconSelector(),
            const SizedBox(height: 24),

            // Color Selection
            Text(
              'Choose a color',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildColorSelector(),
            const SizedBox(height: 24),

            // Frequency
            Text(
              'Frequency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildFrequencySelector(),
            const SizedBox(height: 24),

            // Target Count
            SwitchListTile(
              title: const Text('Track specific count?'),
              subtitle: const Text('e.g., 8 glasses of water, 10,000 steps'),
              value: _hasTargetCount,
              onChanged: (value) {
                setState(() => _hasTargetCount = value);
              },
            ),
            if (_hasTargetCount) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _targetCountController,
                      decoration: const InputDecoration(
                        labelText: 'Target Count',
                        hintText: '8',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: _hasTargetCount
                          ? (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Invalid number';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        hintText: 'glasses',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveHabit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.habitId == null ? 'Create Habit' : 'Update Habit',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: HabitIcon.values.map((icon) {
        final isSelected = icon == _selectedIcon;
        final iconData = HabitIconHelper.getIconData(icon);

        return InkWell(
          onTap: () => setState(() => _selectedIcon = icon),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey[200],
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: isSelected ? AppColors.primary : Colors.grey[700],
              size: 28,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: HabitColor.values.map((habitColor) {
        final isSelected = habitColor == _selectedColor;
        final color = HabitIconHelper.getColor(habitColor);

        return InkWell(
          onTap: () => setState(() => _selectedColor = habitColor),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.transparent,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 24)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySelector() {
    return SegmentedButton<HabitFrequency>(
      segments: HabitFrequency.values.map((freq) {
        return ButtonSegment<HabitFrequency>(
          value: freq,
          label: Text(freq.displayName),
        );
      }).toList(),
      selected: {_selectedFrequency},
      onSelectionChanged: (Set<HabitFrequency> selected) {
        setState(() => _selectedFrequency = selected.first);
      },
    );
  }
}
