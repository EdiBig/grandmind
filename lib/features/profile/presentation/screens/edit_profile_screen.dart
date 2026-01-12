import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../home/presentation/providers/dashboard_provider.dart';
import '../../../user/data/services/firestore_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _fitnessLevel;
  String? _goal;
  bool _initialized = false;
  bool _isSaving = false;

  static const _genderOptions = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
  static const _fitnessOptions = ['Beginner', 'Intermediate', 'Advanced'];
  static const _goalOptions = ['Lose Weight', 'Build Muscle', 'Improve Endurance', 'Stay Healthy'];

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => _saveProfile(context),
            child: Text(
              _isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (!_initialized && user != null) {
            _displayNameController.text = user.displayName ?? '';
            _phoneController.text = user.phoneNumber ?? '';
            _heightController.text =
                user.height != null ? user.height!.toStringAsFixed(0) : '';
            _weightController.text =
                user.weight != null ? user.weight!.toStringAsFixed(1) : '';
            _dateOfBirth = user.dateOfBirth;
            _gender = _normalizeDropdownValue(user.gender, _genderOptions);
            _fitnessLevel = _normalizeDropdownValue(user.fitnessLevel, _fitnessOptions);
            _goal = _normalizeDropdownValue(user.goal, _goalOptions);
            _initialized = true;
            _runProfileMigration(user.id);
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionTitle(context, 'Basic'),
                _buildTextField(
                  controller: _displayNameController,
                  label: 'Display Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildReadOnlyField(
                  label: 'Email',
                  value: user?.email ?? 'Not set',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'Personal'),
                _buildDateField(context),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Gender',
                  icon: Icons.person_outline,
                  value: _gender,
                  options: _genderOptions,
                  onChanged: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle(context, 'Fitness'),
                _buildTextField(
                  controller: _heightController,
                  label: 'Height (cm)',
                  icon: Icons.height,
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _weightController,
                  label: 'Weight (kg)',
                  icon: Icons.monitor_weight_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Fitness Level',
                  icon: Icons.fitness_center,
                  value: _fitnessLevel,
                  options: _fitnessOptions,
                  onChanged: (value) => setState(() => _fitnessLevel = value),
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Goal',
                  icon: Icons.flag_outlined,
                  value: _goal,
                  options: _goalOptions,
                  onChanged: (value) => setState(() => _goal = value),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load profile')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextFormField(
      initialValue: value,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: _normalizeDropdownValue(value, options),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(BuildContext context) {
    final value = _dateOfBirth == null ? 'Not set' : _formatDate(_dateOfBirth!);

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: _dateOfBirth ?? DateTime(now.year - 25, 1, 1),
          firstDate: DateTime(1900),
          lastDate: DateTime(now.year, now.month, now.day),
        );

        if (picked != null) {
          setState(() => _dateOfBirth = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: Icon(Icons.cake_outlined),
          border: OutlineInputBorder(),
        ),
        child: Text(value),
      ),
    );
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (_isSaving) return;
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final data = <String, dynamic>{
        'displayName': _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
        'phoneNumber':
            _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'dateOfBirth': _dateOfBirth,
        'gender': _gender,
        'height': _parseDoubleOrNull(_heightController.text),
        'weight': _parseDoubleOrNull(_weightController.text),
        'fitnessLevel': _fitnessLevel,
        'goal': _goal,
      };

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateUser(userId, data);

      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser != null && data['displayName'] != null) {
        await authUser.updateDisplayName(data['displayName']);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  double? _parseDoubleOrNull(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value);
  }

  String? _normalizeDropdownValue(String? value, List<String> options) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return options.contains(trimmed) ? trimmed : null;
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> _runProfileMigration(String userId) async {
    try {
      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.sanitizeUserProfile(userId);
    } catch (_) {
      // Best-effort cleanup; ignore failures.
    }
  }
}
