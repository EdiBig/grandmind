import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/fitness_profile.dart';
import '../../domain/models/workout_library_entry.dart';
import '../providers/fitness_profile_provider.dart';

class FitnessProfileScreen extends ConsumerStatefulWidget {
  const FitnessProfileScreen({
    super.key,
    this.title = 'Fitness Profile',
  });

  final String title;

  @override
  ConsumerState<FitnessProfileScreen> createState() =>
      _FitnessProfileScreenState();
}

class _FitnessProfileScreenState extends ConsumerState<FitnessProfileScreen> {
  FitnessLevel? _fitnessLevel;
  final Set<FitnessInjury> _injuries = {};
  final Set<FitnessMedicalCondition> _medicalConditions = {};
  final Set<WorkoutEquipment> _equipment = {};
  final Set<WorkoutGoal> _goals = {};
  WorkoutLocation? _location;
  WorkoutDurationRange? _duration;
  int? _energyLevel;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(fitnessProfileProvider);
    _fitnessLevel = profile.fitnessLevel;
    _injuries.addAll(profile.injuries);
    _medicalConditions.addAll(profile.medicalConditions);
    _equipment.addAll(profile.availableEquipment);
    _goals.addAll(profile.goals);
    _location = profile.workoutLocation;
    _duration = profile.preferredDuration;
    _energyLevel = profile.energyLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Current Fitness Level'),
          _buildChoiceChips<FitnessLevel>(
            FitnessLevel.values,
            _fitnessLevel == null ? {} : {_fitnessLevel!},
            (level) => level.displayName,
            (value, selected) {
              setState(() {
                _fitnessLevel = selected ? value : null;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Injuries or Pain'),
          _buildNoneChip(
            label: 'No injuries or pain',
            isSelected: _injuries.isEmpty,
            onSelected: () => setState(_injuries.clear),
          ),
          const SizedBox(height: 8),
          _buildFilterChips<FitnessInjury>(
            FitnessInjury.values,
            _injuries,
            (injury) => injury.displayName,
            (value, selected) => _toggleSet(_injuries, value, selected),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Medical Conditions'),
          _buildNoneChip(
            label: 'None',
            isSelected: _medicalConditions.isEmpty,
            onSelected: () => setState(_medicalConditions.clear),
          ),
          const SizedBox(height: 8),
          _buildFilterChips<FitnessMedicalCondition>(
            FitnessMedicalCondition.values,
            _medicalConditions,
            (condition) => condition.displayName,
            (value, selected) => _toggleSet(_medicalConditions, value, selected),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Equipment Available'),
          _buildFilterChips<WorkoutEquipment>(
            WorkoutEquipment.values,
            _equipment,
            (equipment) => equipment.displayName,
            (value, selected) => _toggleSet(_equipment, value, selected),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Workout Location'),
          _buildChoiceChips<WorkoutLocation>(
            WorkoutLocation.values,
            _location == null ? {} : {_location!},
            (location) => location.displayName,
            (value, selected) {
              setState(() {
                _location = selected ? value : null;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Typical Duration'),
          _buildChoiceChips<WorkoutDurationRange>(
            WorkoutDurationRange.values,
            _duration == null ? {} : {_duration!},
            (range) => range.displayName,
            (value, selected) {
              setState(() {
                _duration = selected ? value : null;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Goals'),
          _buildFilterChips<WorkoutGoal>(
            WorkoutGoal.values,
            _goals,
            (goal) => goal.displayName,
            (value, selected) => _toggleSet(_goals, value, selected),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Energy Today'),
          Wrap(
            spacing: 8,
            children: List.generate(5, (index) {
              final level = index + 1;
              return ChoiceChip(
                label: Text('$level'),
                selected: _energyLevel == level,
                onSelected: (selected) {
                  setState(() {
                    _energyLevel = selected ? level : null;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              child: const Text('Save Profile'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You can update this anytime in Settings.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  void _toggleSet<T>(Set<T> set, T value, bool selected) {
    setState(() {
      if (selected) {
        set.add(value);
      } else {
        set.remove(value);
      }
    });
  }

  void _saveProfile() {
    final profile = FitnessProfile(
      fitnessLevel: _fitnessLevel,
      injuries: _injuries,
      medicalConditions: _medicalConditions,
      availableEquipment: _equipment,
      workoutLocation: _location,
      preferredDuration: _duration,
      goals: _goals,
      energyLevel: _energyLevel,
      updatedAt: DateTime.now(),
    );
    ref.read(fitnessProfileProvider.notifier).update(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitness profile updated')),
    );
    Navigator.of(context).pop();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildChoiceChips<T>(
    List<T> options,
    Set<T> selected,
    String Function(T) labelBuilder,
    void Function(T, bool) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return ChoiceChip(
          label: Text(labelBuilder(option)),
          selected: isSelected,
          onSelected: (value) => onToggle(option, value),
        );
      }).toList(),
    );
  }

  Widget _buildFilterChips<T>(
    List<T> options,
    Set<T> selected,
    String Function(T) labelBuilder,
    void Function(T, bool) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(labelBuilder(option)),
          selected: isSelected,
          onSelected: (value) => onToggle(option, value),
        );
      }).toList(),
    );
  }

  Widget _buildNoneChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }
}
