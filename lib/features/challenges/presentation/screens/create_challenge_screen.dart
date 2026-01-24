import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/dashboard_provider.dart';
import '../../../user/data/models/user_model.dart';
import '../../data/models/challenge_model.dart';
import '../../data/repositories/challenge_repository.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  ConsumerState<CreateChallengeScreen> createState() =>
      _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ChallengeType _type = ChallengeType.community;
  ChallengeGoalType _goalType = ChallengeGoalType.workouts;
  final ChallengeVisibility _visibility = ChallengeVisibility.inviteOnly;
  ChallengeTheme _theme = ChallengeTheme.custom;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _hasRankings = true;
  bool _hasActivityFeed = false;
  bool _allowInvites = true;
  int _goalTarget = 10;
  String _goalUnit = 'workouts';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final units = _resolveUnits(userAsync.asData?.value?.preferences?['units']);
    ref.listen<AsyncValue<UserModel?>>(currentUserProvider, (previous, next) {
      final nextUnits = _resolveUnits(next.asData?.value?.preferences?['units']);
      final nextUnit = _goalUnitForType(_goalType, nextUnits);
      if (_goalUnit != nextUnit && mounted) {
        setState(() => _goalUnit = nextUnit);
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Challenge'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Challenge name',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Challenge type',
            value: _type,
            values: ChallengeType.values,
            onChanged: (value) => setState(() => _type = value),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Goal type',
            value: _goalType,
            values: ChallengeGoalType.values,
            onChanged: (value) {
              setState(() {
                _goalType = value;
                _goalUnit = _goalUnitForType(value, units);
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Goal target',
                  ),
                  onChanged: (value) => setState(() {
                    _goalTarget = int.tryParse(value) ?? _goalTarget;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Goal unit',
                  ),
                  child: Text(_goalUnit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDatePicker(
            context,
            label: 'Start date',
            date: _startDate,
            onChanged: (date) => setState(() => _startDate = date),
          ),
          const SizedBox(height: 12),
          _buildDatePicker(
            context,
            label: 'End date',
            date: _endDate,
            onChanged: (date) => setState(() => _endDate = date),
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Visibility',
            ),
            child: Text(
              _visibility.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          _buildDropdown(
            label: 'Theme',
            value: _theme,
            values: ChallengeTheme.values,
            onChanged: (value) => setState(() => _theme = value),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Enable rankings'),
            value: _hasRankings,
            onChanged: (value) => setState(() => _hasRankings = value),
          ),
          SwitchListTile(
            title: const Text('Enable activity feed'),
            value: _hasActivityFeed,
            onChanged: (value) => setState(() => _hasActivityFeed = value),
          ),
          SwitchListTile(
            title: const Text('Allow member invites'),
            value: _allowInvites,
            onChanged: (value) => setState(() => _allowInvites = value),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isSaving ? null : () => _handleCreate(context),
            child: Text(_isSaving ? 'Creating...' : 'Create Challenge'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> values,
    required ValueChanged<T> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: values
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text((item as Enum).name),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    BuildContext context, {
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onChanged,
  }) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (!context.mounted) return;
        if (picked != null) {
          onChanged(picked);
        }
      },
      icon: const Icon(Icons.calendar_today),
      label: Text('$label: ${_formatDate(date)}'),
    );
  }

  Future<void> _handleCreate(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showMessage(context, 'Sign in to create challenges.');
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage(context, 'Please provide a challenge name.');
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      _showMessage(context, 'End date must be after start date.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final challenge = ChallengeModel(
        id: '',
        name: name,
        description: _descriptionController.text.trim(),
        type: _type,
        goalType: _goalType,
        goalTarget: _goalTarget,
        goalUnit: _goalUnit,
        startDate: _startDate,
        endDate: _endDate,
        visibility: _visibility,
        hasRankings: _hasRankings,
        hasActivityFeed: _hasActivityFeed,
        allowMemberInvites: _allowInvites,
        theme: _theme,
        coverImageUrl: null,
        createdBy: userId,
        createdAt: DateTime.now(),
        participantCount: 0,
        isActive: true,
      );
      await ref.read(challengeRepositoryProvider).createChallenge(challenge);
      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!context.mounted) return;
      _showMessage(context, 'Unable to create challenge. $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _goalUnitForType(ChallengeGoalType type, String units) {
    switch (type) {
      case ChallengeGoalType.steps:
        return 'steps';
      case ChallengeGoalType.workouts:
        return 'workouts';
      case ChallengeGoalType.habit:
        return 'days';
      case ChallengeGoalType.distance:
        return units == 'imperial' ? 'mi' : 'km';
    }
  }

  String _resolveUnits(dynamic value) {
    final resolved = value is String ? value.trim().toLowerCase() : '';
    if (resolved == 'imperial') return 'imperial';
    return 'metric';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
