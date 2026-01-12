import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_preference.dart';
import '../providers/notification_providers.dart';

class CreateReminderScreen extends ConsumerStatefulWidget {
  final NotificationPreference? editingPreference;

  const CreateReminderScreen({
    super.key,
    this.editingPreference,
  });

  @override
  ConsumerState<CreateReminderScreen> createState() =>
      _CreateReminderScreenState();
}

class _CreateReminderScreenState extends ConsumerState<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _messageController;

  ReminderType _selectedType = ReminderType.custom;
  Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // All days by default
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _enabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.editingPreference != null) {
      final pref = widget.editingPreference!;
      _titleController = TextEditingController(text: pref.title);
      _messageController = TextEditingController(text: pref.message);
      _selectedType = pref.type;
      _selectedDays = pref.daysOfWeek.toSet();
      _selectedTime = TimeOfDay(hour: pref.hour, minute: pref.minute);
      _enabled = pref.enabled;
    } else {
      _titleController = TextEditingController();
      _messageController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isEditing = widget.editingPreference != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Reminder' : 'Create Reminder'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Type selection
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Reminder Title',
                hintText: 'e.g., Morning Workout',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Message field
            TextFormField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message',
                hintText: 'What should the notification say?',
                prefixIcon: const Icon(Icons.message),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a message';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Time selection
            _buildTimeSelector(),
            const SizedBox(height: 24),

            // Days of week selection
            _buildDaysSelector(),
            const SizedBox(height: 24),

            // Enabled toggle
            _buildEnabledToggle(),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEditing ? 'Update Reminder' : 'Create Reminder',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Type',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ReminderType.values.map((type) {
            final isSelected = _selectedType == type;
            return ChoiceChip(
              label: Text(_getTypeLabel(type)),
              avatar: Icon(
                _getTypeIcon(type),
                size: 18,
                color: isSelected ? Colors.white : primary,
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedType = type;
                  _updateDefaultsForType(type);
                });
              },
              selectedColor: primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          child: Icon(
            Icons.schedule,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: const Text('Time'),
        subtitle: Text(_selectedTime.format(context)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final time = await showTimePicker(
            context: context,
            initialTime: _selectedTime,
          );
          if (time != null) {
            setState(() {
              _selectedTime = time;
            });
          }
        },
      ),
    );
  }

  Widget _buildDaysSelector() {
    final days = [
      (1, 'Mon'),
      (2, 'Tue'),
      (3, 'Wed'),
      (4, 'Thu'),
      (5, 'Fri'),
      (6, 'Sat'),
      (7, 'Sun'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat On',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((day) {
            final isSelected = _selectedDays.contains(day.$1);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDays.remove(day.$1);
                  } else {
                    _selectedDays.add(day.$1);
                  }
                });
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    day.$2,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedDays.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Please select at least one day',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEnabledToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Enable Reminder'),
        subtitle: Text(
          _enabled
              ? 'Reminder will be scheduled'
              : 'Reminder is disabled',
        ),
        value: _enabled,
        onChanged: (value) {
          setState(() {
            _enabled = value;
          });
        },
        activeThumbColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _updateDefaultsForType(ReminderType type) {
    switch (type) {
      case ReminderType.workout:
        _titleController.text = '💪 Time to Work Out!';
        _messageController.text =
            'Your scheduled workout is starting soon. Let\'s get moving!';
        _selectedTime = const TimeOfDay(hour: 18, minute: 0);
        _selectedDays = {1, 3, 5}; // Mon, Wed, Fri
        break;
      case ReminderType.habit:
        _titleController.text = '✅ Habit Reminder';
        _messageController.text = 'Don\'t forget to complete your daily habit!';
        _selectedTime = const TimeOfDay(hour: 20, minute: 0);
        _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // Every day
        break;
      case ReminderType.water:
        _titleController.text = '💧 Hydration Reminder';
        _messageController.text =
            'Time to drink some water! Stay hydrated throughout the day.';
        _selectedTime = const TimeOfDay(hour: 10, minute: 0);
        _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // Every day
        break;
      case ReminderType.meal:
        _titleController.text = '🍽️ Meal Time';
        _messageController.text = 'Time for a healthy meal! Fuel your body right.';
        _selectedTime = const TimeOfDay(hour: 12, minute: 30);
        _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // Every day
        break;
      case ReminderType.sleep:
        _titleController.text = '😴 Wind Down Time';
        _messageController.text =
            'Start preparing for bed. Aim for 7-9 hours of quality sleep.';
        _selectedTime = const TimeOfDay(hour: 22, minute: 0);
        _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // Every day
        break;
      case ReminderType.meditation:
        _titleController.text = '🧘 Meditation Time';
        _messageController.text =
            'Take a few minutes to center yourself and breathe.';
        _selectedTime = const TimeOfDay(hour: 7, minute: 0);
        _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // Every day
        break;
      case ReminderType.custom:
        // Keep user's input
        break;
    }
    setState(() {});
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final operations = ref.read(notificationOperationsProvider);
      final isEditing = widget.editingPreference != null;

      final preference = NotificationPreference(
        id: isEditing ? widget.editingPreference!.id : '',
        userId: '', // Will be set by repository
        type: _selectedType,
        enabled: _enabled,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        daysOfWeek: _selectedDays.toList()..sort(),
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        linkedEntityId: widget.editingPreference?.linkedEntityId,
        createdAt: widget.editingPreference?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (isEditing) {
        await operations.updatePreference(preference);
      } else {
        await operations.createPreference(preference);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Reminder updated successfully'
                  : 'Reminder created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getTypeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.workout:
        return 'Workout';
      case ReminderType.habit:
        return 'Habit';
      case ReminderType.water:
        return 'Water';
      case ReminderType.meal:
        return 'Meal';
      case ReminderType.sleep:
        return 'Sleep';
      case ReminderType.meditation:
        return 'Meditation';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.workout:
        return Icons.fitness_center;
      case ReminderType.habit:
        return Icons.check_circle_outline;
      case ReminderType.water:
        return Icons.water_drop;
      case ReminderType.meal:
        return Icons.restaurant;
      case ReminderType.sleep:
        return Icons.bedtime;
      case ReminderType.meditation:
        return Icons.self_improvement;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }
}
