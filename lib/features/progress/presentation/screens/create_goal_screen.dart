import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../domain/models/progress_goal.dart';
import '../../domain/models/measurement_entry.dart';
import '../providers/progress_providers.dart';

class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _startValueController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _notesController = TextEditingController();

  GoalType _selectedType = GoalType.weight;
  MeasurementType? _selectedMeasurementType;
  DateTime? _targetDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _startValueController.dispose();
    _targetValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentValues() async {
    // Auto-fill start value based on goal type
    if (_selectedType == GoalType.weight) {
      final latestWeight = await ref.read(latestWeightProvider.future);
      if (latestWeight != null && mounted) {
        _startValueController.text = latestWeight.weight.toStringAsFixed(1);
      }
    } else if (_selectedType == GoalType.measurement && _selectedMeasurementType != null) {
      final latestMeasurements = await ref.read(latestMeasurementsProvider.future);
      if (latestMeasurements != null && mounted) {
        final value = latestMeasurements.measurements[_selectedMeasurementType!.name];
        if (value != null) {
          _startValueController.text = value.toStringAsFixed(1);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Goal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal Type Selection
              Text(
                'Goal Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: GoalType.values.map((type) {
                  final isSelected = _selectedType == type;
                  final labelColor = isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant;
                  final borderColor =
                      isSelected ? colorScheme.primary : colorScheme.outlineVariant;
                  return ChoiceChip(
                    label: Text(
                      type.displayName,
                      style: TextStyle(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type;
                          _startValueController.clear();
                        });
                        _loadCurrentValues();
                      }
                    },
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: colorScheme.surface,
                    showCheckmark: false,
                    side: BorderSide(color: borderColor),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Measurement Type (if measurement goal)
              if (_selectedType == GoalType.measurement) ...[
                Text(
                  'Measurement Type',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<MeasurementType>(
                  value: _selectedMeasurementType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select measurement',
                  ),
                  items: MeasurementType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Row(
                        children: [
                          Icon(type.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(type.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMeasurementType = value;
                      _startValueController.clear();
                    });
                    _loadCurrentValues();
                  },
                  validator: (value) {
                    if (_selectedType == GoalType.measurement && value == null) {
                      return 'Please select a measurement type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Goal Title
              Text(
                'Goal Title',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: _getDefaultTitle(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a goal title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Start Value
              Text(
                'Starting Value',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _startValueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Current value',
                  suffixText: _getUnit(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter starting value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Target Value
              Text(
                'Target Value',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _targetValueController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText: 'Goal value',
                  suffixText: _getUnit(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter target value';
                  }
                  final target = double.tryParse(value);
                  if (target == null) {
                    return 'Please enter a valid number';
                  }
                  final start = double.tryParse(_startValueController.text);
                  if (start != null && target == start) {
                    return 'Target must be different from start';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Target Date (Optional)
              Text(
                'Target Date (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _targetDate == null
                      ? 'No target date (open-ended)'
                      : DateFormat('EEEE, MMM d, yyyy').format(_targetDate!),
                ),
                trailing: _targetDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _targetDate = null;
                          });
                        },
                      )
                    : const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (picked != null) {
                    setState(() {
                      _targetDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),

              // Notes (Optional)
              Text(
                'Notes (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Add notes about this goal...',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createGoal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Goal', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDefaultTitle() {
    switch (_selectedType) {
      case GoalType.weight:
        return 'e.g., Lose 5kg in 8 weeks';
      case GoalType.measurement:
        return _selectedMeasurementType != null
            ? 'e.g., Reduce ${_selectedMeasurementType!.displayName} by 5cm'
            : 'e.g., Reduce waist by 5cm';
      case GoalType.custom:
        return 'e.g., Drink 8 glasses of water daily';
    }
  }

  String _getUnit() {
    switch (_selectedType) {
      case GoalType.weight:
        return 'kg';
      case GoalType.measurement:
        return 'cm';
      case GoalType.custom:
        return '';
    }
  }

  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to create goals')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final startValue = double.parse(_startValueController.text);
    final targetValue = double.parse(_targetValueController.text);

    final goal = ProgressGoal(
      id: '',
      userId: userId,
      title: _titleController.text.trim(),
      type: _selectedType,
      startValue: startValue,
      targetValue: targetValue,
      currentValue: startValue,
      startDate: DateTime.now(),
      targetDate: _targetDate,
      completedDate: null,
      status: GoalStatus.active,
      measurementType: _selectedMeasurementType,
      unit: _getUnit(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    final operations = ref.read(progressOperationsProvider.notifier);
    final goalId = await operations.createGoal(goal);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (goalId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create goal. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
