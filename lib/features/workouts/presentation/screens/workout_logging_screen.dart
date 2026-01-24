import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/workout_repository.dart';
import '../../domain/models/exercise.dart';
import '../../domain/models/workout.dart';
import '../../domain/models/workout_log.dart';
import '../providers/workout_providers.dart';
import '../../../mood_energy/data/repositories/mood_energy_repository.dart';
import '../../../mood_energy/domain/models/energy_log.dart';
import '../../../health/presentation/providers/health_providers.dart';
import '../../../../core/utils/validators.dart';

class WorkoutLoggingScreen extends ConsumerStatefulWidget {
  final Workout? workout;

  const WorkoutLoggingScreen({
    super.key,
    this.workout,
  });

  @override
  ConsumerState<WorkoutLoggingScreen> createState() =>
      _WorkoutLoggingScreenState();
}

class _WorkoutLoggingScreenState extends ConsumerState<WorkoutLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  TextEditingController? _exerciseSearchController;
  FocusNode? _exerciseSearchFocus;
  final List<_ExerciseEntry> _exerciseEntries = [];
  final Set<String> _contextTags = {};
  DateTime _selectedDate = DateTime.now();
  _WorkoutLogTypeOption? _selectedType;
  int? _energyBefore;
  int? _energyAfter;
  bool _showDetails = false;
  bool _isLogging = false;

  @override
  void initState() {
    super.initState();
    if (widget.workout != null) {
      _durationController.text = widget.workout!.estimatedDuration.toString();
      _selectedType = _typeOptions.firstWhere(
        (option) => option.category == widget.workout!.category,
        orElse: () => _typeOptions.last,
      );
      _showDetails = true;
      for (final exercise in widget.workout!.exercises) {
        _exerciseEntries.add(_ExerciseEntry(name: exercise.name));
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _durationController.dispose();
    for (final entry in _exerciseEntries) {
      entry.dispose();
    }
    super.dispose();
  }

  Future<void> _logWorkout({required bool isQuick}) async {
    // Validate form for detailed workouts
    if (!isQuick && !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final userId = ref.read(workoutLogUserIdProvider);
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to track workouts')),
      );
      return;
    }

    setState(() => _isLogging = true);

    try {
      final repository = ref.read(workoutRepositoryProvider);
      final durationMinutes = _resolveDuration();
      final startedAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        DateTime.now().hour,
        DateTime.now().minute,
      );
      final completedAt = startedAt.add(Duration(minutes: durationMinutes));
      final notes = _buildNotesPayload();

      final workoutLog = WorkoutLog(
        id: '',
        userId: userId,
        workoutId: widget.workout?.id ?? '',
        workoutName: widget.workout?.name ??
            _selectedType?.label ??
            (isQuick ? 'Quick Workout' : 'Workout'),
        startedAt: startedAt,
        completedAt: completedAt,
        duration: durationMinutes,
        exercises: isQuick ? [] : _buildExerciseLogs(),
        caloriesBurned: widget.workout?.caloriesBurned,
        notes: notes,
        difficulty: widget.workout?.difficulty,
        category: widget.workout?.category ?? _selectedType?.category,
      );

      await repository.logWorkout(workoutLog);
      await _logEnergyEntry(userId, startedAt);
      await _syncWorkoutToHealth(workoutLog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout logged successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging workout: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLogging = false);
      }
    }
  }

  Future<void> _logEnergyEntry(String userId, DateTime loggedAt) async {
    final hasEnergy = _energyBefore != null || _energyAfter != null;
    final hasTags = _contextTags.isNotEmpty;
    if (!hasEnergy && !hasTags) {
      return;
    }

    final notes = _notesController.text.trim();
    final repository = ref.read(moodEnergyRepositoryProvider);

    // Log energy level after workout (more relevant for mood/energy tracking)
    final energyLevel = _energyAfter ?? _energyBefore;

    final log = EnergyLog(
      id: '',
      userId: userId,
      loggedAt: loggedAt,
      energyLevel: energyLevel,
      contextTags: _contextTags.toList(),
      notes: notes.isEmpty ? null : notes,
      source: 'workout',
    );
    try {
      await repository.createLog(log);
    } catch (_) {
      // Ignore energy logging failures to avoid blocking workout saves.
    }
  }

  Future<void> _syncWorkoutToHealth(WorkoutLog log) async {
    if (!ref.read(workoutHealthSyncEnabledProvider)) {
      return;
    }
    try {
      final healthService = ref.read(healthServiceProvider);
      final hasPermissions = await healthService.hasPermissions();
      if (!hasPermissions) return;

      final operations = ref.read(healthOperationsProvider.notifier);
      await operations.writeWorkout(
        workoutType: log.category?.displayName ?? log.workoutName,
        startTime: log.startedAt,
        endTime: log.completedAt ?? log.startedAt,
        caloriesBurned: log.caloriesBurned,
        distanceMeters: null,
      );
    } catch (_) {
      // Ignore health sync failures to avoid blocking workout saves.
    }
  }

  @override
  Widget build(BuildContext context) {
    final headlineStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Log Workout', style: headlineStyle),
            const SizedBox(height: 8),
            _buildDateSelector(),
            const SizedBox(height: 20),
            _buildQuickLogCard(),
            const SizedBox(height: 24),
            _buildDetailsIntro(),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 12),
            _buildDetailsAction(),
            if (_showDetails)
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    _buildDetailHeader(),
                    const SizedBox(height: 16),
                    _buildExerciseBuilder(),
                    const SizedBox(height: 20),
                    _buildDurationField(),
                    const SizedBox(height: 20),
                    _buildEnergySection(),
                    const SizedBox(height: 20),
                    _buildNotesField(),
                    const SizedBox(height: 20),
                    _buildContextTags(),
                    const SizedBox(height: 28),
                    _buildSaveButton(),
                    const SizedBox(height: 8),
                    _buildCancelLink(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: _pickDate,
          icon: Icon(Icons.calendar_today, size: 18),
          label: Text(_formatDate(_selectedDate)),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.3,
          children: _typeOptions.map((option) {
            final isSelected = _selectedType == option;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedType = option;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: 1.3,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        option.icon,
                        color: isSelected
                            ? AppColors.white
                            : Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option.label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickLogCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLogging ? null : () => _logWorkout(isQuick: true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'I worked out today',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save details later or keep it simple',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsIntro() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Add details (optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        if (_showDetails)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'In progress',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsAction() {
    if (_showDetails) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          if (_selectedType == null && widget.workout == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Select a workout type to continue')),
            );
            return;
          }
          setState(() => _showDetails = true);
        },
        child: const Text('Continue to details'),
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Row(
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (widget.workout != null) ...[
          const SizedBox(width: 8),
          Chip(
            label: Text(widget.workout!.name),
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ],
      ],
    );
  }

  Widget _buildExerciseBuilder() {
    final recentLogs = ref.watch(recentWorkoutLogsProvider).maybeWhen(
          data: (logs) => logs,
          orElse: () => const <WorkoutLog>[],
        );
    final suggestions = _buildExerciseSuggestions(recentLogs);
    final recentExercises = suggestions.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise builder',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Autocomplete<String>(
          optionsBuilder: (value) {
            if (value.text.trim().isEmpty) {
              return const Iterable<String>.empty();
            }
            return suggestions.where(
              (option) => option
                  .toLowerCase()
                  .contains(value.text.trim().toLowerCase()),
            );
          },
          onSelected: (selection) {
            _addExercise(selection);
          },
          fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
            _exerciseSearchController = controller;
            _exerciseSearchFocus = focusNode;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onSubmitted: (_) => _addExercise(controller.text),
              decoration: InputDecoration(
                hintText: 'Add exercise',
                prefixIcon: Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: () => _addExercise(controller.text),
                ),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recentExercises.map((exercise) {
            return ActionChip(
              label: Text(exercise),
              onPressed: () => _addExercise(exercise),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        ..._exerciseEntries.map(_buildExerciseCard),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _exerciseSearchFocus?.requestFocus(),
          icon: Icon(Icons.add),
          label: const Text('Add another exercise'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.primary),
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(_ExerciseEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                onPressed: () => _removeExercise(entry),
                tooltip: 'Remove',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sets  Reps @ Weight',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMiniField(
                controller: entry.setsController,
                label: 'Sets',
                validator: Validators.validateSets,
              ),
              const SizedBox(width: 8),
              _buildMiniField(
                controller: entry.repsController,
                label: 'Reps',
                validator: Validators.validateReps,
              ),
              const SizedBox(width: 8),
              _buildMiniField(
                controller: entry.weightController,
                label: 'Weight',
                validator: Validators.validateExerciseWeight,
                allowDecimal: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    bool allowDecimal = false,
  }) {
    return SizedBox(
      width: 80,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
        inputFormatters: [
          if (allowDecimal)
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}'))
          else
            FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDurationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration (optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: 'How long? (minutes)',
            suffixText: 'min',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
          ),
          validator: (value) => Validators.validateDuration(value, required: false),
        ),
      ],
    );
  }

  Widget _buildEnergySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Energy',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        _buildEnergyScale(
          label: 'Before',
          value: _energyBefore,
          onSelected: (value) => setState(() => _energyBefore = value),
        ),
        const SizedBox(height: 8),
        _buildEnergyScale(
          label: 'After',
          value: _energyAfter,
          onSelected: (value) => setState(() => _energyAfter = value),
        ),
      ],
    );
  }

  Widget _buildEnergyScale({
    required String label,
    required int? value,
    required ValueChanged<int> onSelected,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 6,
            children: List.generate(5, (index) {
              final level = index + 1;
              final isSelected = value == level;
              return ChoiceChip(
                label: Text('$level'),
                selected: isSelected,
                onSelected: (_) => onSelected(level),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                selectedColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.18),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'How did it feel?',
            hintStyle:
                TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            contentPadding: const EdgeInsets.all(16),
          ),
          minLines: 3,
          maxLines: 6,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildContextTags() {
    const tags = ['Stressed', 'Tired', 'Great', 'Sick'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Context tags (optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: tags.map((tag) {
            final selected = _contextTags.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _contextTags.add(tag);
                  } else {
                    _contextTags.remove(tag);
                  }
                });
              },
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.18),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              shape: StadiumBorder(
                side: BorderSide(
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLogging ? null : () => _logWorkout(isQuick: false),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLogging
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : const Text(
                'Save Workout',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildCancelLink() {
    return Center(
      child: TextButton(
        onPressed: _isLogging ? null : () => Navigator.of(context).pop(),
        child: Text(
          'Cancel',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)), // Max 1 year ago
      lastDate: now, // Cannot log future workouts
    );
    if (selected != null) {
      setState(() => _selectedDate = selected);
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day/${date.year}';
  }

  int _resolveDuration() {
    final parsed = int.tryParse(_durationController.text.trim());
    if (parsed != null && parsed > 0) {
      return parsed;
    }
    if (widget.workout != null) {
      return widget.workout!.estimatedDuration;
    }
    return 30;
  }

  void _addExercise(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    if (_exerciseEntries.any((entry) => entry.name == trimmed)) {
      _exerciseSearchController?.clear();
      return;
    }
    setState(() {
      _exerciseEntries.add(_ExerciseEntry(name: trimmed));
      _exerciseSearchController?.clear();
    });
  }

  void _removeExercise(_ExerciseEntry entry) {
    setState(() {
      entry.dispose();
      _exerciseEntries.remove(entry);
    });
  }

  List<ExerciseLog> _buildExerciseLogs() {
    return _exerciseEntries.map((entry) {
      final sets = entry.sets;
      final reps = entry.reps;
      final weight = entry.weight;
      final setLogs = <SetLog>[];
      for (var i = 0; i < sets; i++) {
        setLogs.add(SetLog(
          setNumber: i + 1,
          reps: reps > 0 ? reps : null,
          weight: weight > 0 ? weight : null,
        ));
      }
      return ExerciseLog(
        exerciseId: entry.name.toLowerCase().replaceAll(' ', '_'),
        exerciseName: entry.name,
        type: _detectExerciseType(entry.name),
        sets: setLogs,
      );
    }).toList();
  }

  ExerciseType _detectExerciseType(String exerciseName) {
    final nameLower = exerciseName.toLowerCase();

    // Duration-based exercises
    const durationExercises = [
      'plank', 'hold', 'stretch', 'yoga', 'pose', 'meditation',
      'wall sit', 'dead hang', 'isometric', 'static',
    ];
    for (final keyword in durationExercises) {
      if (nameLower.contains(keyword)) {
        return ExerciseType.duration;
      }
    }

    // Distance-based exercises
    const distanceExercises = [
      'running', 'run', 'cycling', 'bike', 'swimming', 'swim',
      'rowing', 'row', 'walking', 'walk', 'sprint', 'jog',
      'hiking', 'hike', 'marathon', 'lap',
    ];
    for (final keyword in distanceExercises) {
      if (nameLower.contains(keyword)) {
        return ExerciseType.distance;
      }
    }

    // Default to reps for strength/other exercises
    return ExerciseType.reps;
  }

  String? _buildNotesPayload() {
    return buildWorkoutNotes(
      notes: _notesController.text.trim(),
      energyBefore: _energyBefore,
      energyAfter: _energyAfter,
      contextTags: _contextTags,
    );
  }

  List<String> _buildExerciseSuggestions(List<WorkoutLog> logs) {
    final suggestions = <String>[];
    final seen = <String>{};

    // Add exercises from recent logs first (user's history)
    for (final log in logs) {
      for (final exercise in log.exercises) {
        final name = exercise.exerciseName.trim();
        if (name.isEmpty) continue;
        final key = name.toLowerCase();
        if (seen.add(key)) {
          suggestions.add(name);
        }
      }
    }

    // Add exercises from current workout template
    if (widget.workout != null) {
      for (final exercise in widget.workout!.exercises) {
        final name = exercise.name.trim();
        if (name.isEmpty) continue;
        final key = name.toLowerCase();
        if (seen.add(key)) {
          suggestions.add(name);
        }
      }
    }

    // Add common exercises that aren't already in the list
    for (final exercise in _commonExercises) {
      final key = exercise.toLowerCase();
      if (seen.add(key)) {
        suggestions.add(exercise);
      }
    }

    return suggestions;
  }
}

/// Common exercises for suggestions when user has no history
const List<String> _commonExercises = [
  // Strength - Upper Body
  'Push-ups',
  'Pull-ups',
  'Bench Press',
  'Dumbbell Rows',
  'Shoulder Press',
  'Bicep Curls',
  'Tricep Dips',
  'Lat Pulldown',
  'Chest Fly',
  'Face Pulls',

  // Strength - Lower Body
  'Squats',
  'Lunges',
  'Deadlifts',
  'Leg Press',
  'Leg Curls',
  'Leg Extensions',
  'Calf Raises',
  'Hip Thrusts',
  'Romanian Deadlifts',
  'Bulgarian Split Squats',

  // Strength - Core
  'Plank',
  'Crunches',
  'Russian Twists',
  'Leg Raises',
  'Mountain Climbers',
  'Dead Bug',
  'Bird Dog',
  'Ab Wheel Rollout',

  // Cardio
  'Running',
  'Cycling',
  'Rowing',
  'Jump Rope',
  'Jumping Jacks',
  'Burpees',
  'High Knees',
  'Box Jumps',
  'Stair Climbing',
  'Swimming',

  // Flexibility/Yoga
  'Downward Dog',
  'Warrior Pose',
  'Child\'s Pose',
  'Cat-Cow Stretch',
  'Pigeon Pose',
  'Cobra Stretch',
  'Hamstring Stretch',
  'Quad Stretch',
  'Hip Flexor Stretch',
  'Shoulder Stretch',

  // Full Body
  'Kettlebell Swings',
  'Clean and Press',
  'Thrusters',
  'Turkish Get-ups',
  'Battle Ropes',
  'Sled Push',
  'Farmer\'s Walk',
];

@visibleForTesting
String? buildWorkoutNotes({
  required String notes,
  required int? energyBefore,
  required int? energyAfter,
  required Set<String> contextTags,
}) {
  final extras = <String>[];
  if (energyBefore != null || energyAfter != null) {
    final before = energyBefore?.toString() ?? '-';
    final after = energyAfter?.toString() ?? '-';
    extras.add('Energy before: $before, after: $after');
  }
  if (contextTags.isNotEmpty) {
    extras.add('Context: ${contextTags.join(', ')}');
  }
  if (notes.isEmpty && extras.isEmpty) {
    return null;
  }
  if (notes.isNotEmpty) {
    extras.insert(0, notes);
  }
  return extras.join('\n');
}

class _WorkoutLogTypeOption {
  const _WorkoutLogTypeOption({
    required this.label,
    required this.icon,
    required this.category,
  });

  final String label;
  final IconData icon;
  final WorkoutCategory? category;
}

const List<_WorkoutLogTypeOption> _typeOptions = [
  _WorkoutLogTypeOption(
    label: 'Strength',
    icon: Icons.fitness_center,
    category: WorkoutCategory.strength,
  ),
  _WorkoutLogTypeOption(
    label: 'Cardio',
    icon: Icons.directions_run,
    category: WorkoutCategory.cardio,
  ),
  _WorkoutLogTypeOption(
    label: 'Yoga',
    icon: Icons.self_improvement,
    category: WorkoutCategory.yoga,
  ),
  _WorkoutLogTypeOption(
    label: 'Walk',
    icon: Icons.directions_walk,
    category: WorkoutCategory.cardio,
  ),
  _WorkoutLogTypeOption(
    label: 'Sport',
    icon: Icons.sports_soccer,
    category: WorkoutCategory.sports,
  ),
  _WorkoutLogTypeOption(
    label: 'Other',
    icon: Icons.more_horiz,
    category: WorkoutCategory.other,
  ),
];

class _ExerciseEntry {
  _ExerciseEntry({
    required this.name,
  })  : setsController = TextEditingController(text: '3'),
        repsController = TextEditingController(text: '10'),
        weightController = TextEditingController();

  final String name;
  final TextEditingController setsController;
  final TextEditingController repsController;
  final TextEditingController weightController;

  int get sets => int.tryParse(setsController.text) ?? 0;
  int get reps => int.tryParse(repsController.text) ?? 0;
  double get weight => double.tryParse(weightController.text) ?? 0;

  void dispose() {
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
  }
}
