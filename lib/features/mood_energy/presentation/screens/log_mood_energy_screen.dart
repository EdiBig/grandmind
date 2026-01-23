import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/energy_log.dart';
import '../../data/repositories/mood_energy_repository.dart';

class LogMoodEnergyScreen extends ConsumerStatefulWidget {
  final EnergyLog? existingLog;

  const LogMoodEnergyScreen({super.key, this.existingLog});

  @override
  ConsumerState<LogMoodEnergyScreen> createState() =>
      _LogMoodEnergyScreenState();
}

class _LogMoodEnergyScreenState extends ConsumerState<LogMoodEnergyScreen> {
  int? _selectedMood;
  int? _selectedEnergy;
  final Set<String> _selectedTags = {};
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _contextTags = [
    'Stressed',
    'Calm',
    'Tired',
    'Energized',
    'Anxious',
    'Happy',
    'Focused',
    'Distracted',
    'Productive',
    'Unmotivated',
    'Grateful',
    'Frustrated',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingLog != null) {
      _selectedMood = widget.existingLog!.moodRating;
      _selectedEnergy = widget.existingLog!.energyLevel;
      _selectedTags.addAll(widget.existingLog!.contextTags);
      _notesController.text = widget.existingLog!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitLog() async {
    if (_selectedMood == null && _selectedEnergy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least mood or energy level'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final repository = ref.read(moodEnergyRepositoryProvider);

      final log = EnergyLog(
        id: widget.existingLog?.id ?? '',
        userId: userId,
        loggedAt: widget.existingLog?.loggedAt ?? DateTime.now(),
        moodRating: _selectedMood,
        energyLevel: _selectedEnergy,
        contextTags: _selectedTags.toList(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        source: 'manual',
      );

      if (widget.existingLog == null) {
        await repository.createLog(log);
      } else {
        await repository.updateLog(widget.existingLog!.id, log);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.existingLog == null ? 'Log saved!' : 'Log updated!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.existingLog != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Update Check-In' : 'Daily Check-In'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Section
            _buildSectionTitle('How are you feeling?', Icons.mood),
            const SizedBox(height: 12),
            _buildMoodSelector(),
            const SizedBox(height: 32),

            // Energy Section
            _buildSectionTitle('What\'s your energy level?', Icons.bolt),
            const SizedBox(height: 12),
            _buildEnergySlider(),
            const SizedBox(height: 32),

            // Context Tags Section
            _buildSectionTitle('What\'s going on?', Icons.label),
            const SizedBox(height: 12),
            _buildContextTags(),
            const SizedBox(height: 32),

            // Notes Section
            _buildSectionTitle('Any notes?', Icons.notes, isOptional: true),
            const SizedBox(height: 12),
            _buildNotesField(),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Check-In' : 'Save Check-In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon,
      {bool isOptional = false}) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isOptional) ...[
          const SizedBox(width: 8),
          Text(
            '(Optional)',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      {'emoji': '😢', 'label': 'Terrible', 'value': 1},
      {'emoji': '😕', 'label': 'Bad', 'value': 2},
      {'emoji': '😐', 'label': 'Okay', 'value': 3},
      {'emoji': '🙂', 'label': 'Good', 'value': 4},
      {'emoji': '😄', 'label': 'Excellent', 'value': 5},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moods.map((mood) {
        final value = mood['value'] as int;
        final isSelected = _selectedMood == value;

        return GestureDetector(
          onTap: () => setState(() => _selectedMood = value),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    mood['emoji'] as String,
                    style: TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mood['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnergySlider() {
    return Column(
      children: [
        Slider(
          value: (_selectedEnergy ?? 3).toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: _getEnergyLabel(_selectedEnergy ?? 3),
          onChanged: (value) => setState(() => _selectedEnergy = value.toInt()),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '😴 Exhausted',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              Text(
                '⚡ Energized',
                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getEnergyLabel(_selectedEnergy ?? 3),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  String _getEnergyLabel(int level) {
    switch (level) {
      case 1:
        return 'Exhausted';
      case 2:
        return 'Low';
      case 3:
        return 'Moderate';
      case 4:
        return 'High';
      case 5:
        return 'Energized';
      default:
        return 'Moderate';
    }
  }

  Widget _buildContextTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _contextTags.map((tag) {
        final isSelected = _selectedTags.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedTags.add(tag);
              } else {
                _selectedTags.remove(tag);
              }
            });
          },
          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          checkmarkColor: Theme.of(context).colorScheme.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Write about your day, thoughts, or anything on your mind...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
