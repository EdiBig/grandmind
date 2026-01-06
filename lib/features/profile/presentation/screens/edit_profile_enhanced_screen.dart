import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/providers/dashboard_provider.dart';
import '../../../user/data/services/firestore_service.dart';
import '../../data/services/profile_photo_service.dart';

class EditProfileEnhancedScreen extends ConsumerStatefulWidget {
  const EditProfileEnhancedScreen({super.key});

  @override
  ConsumerState<EditProfileEnhancedScreen> createState() =>
      _EditProfileEnhancedScreenState();
}

class _EditProfileEnhancedScreenState
    extends ConsumerState<EditProfileEnhancedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _imagePicker = ImagePicker();
  final _profilePhotoService = ProfilePhotoService();

  DateTime? _dateOfBirth;
  String? _gender;
  String? _fitnessLevel;
  String? _goal;
  String? _coachTone;
  String? _unitPreference;
  File? _selectedImage;
  String? _currentPhotoUrl;
  bool _initialized = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;

  static const _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say'
  ];
  static const _fitnessOptions = ['Beginner', 'Intermediate', 'Advanced'];
  static const _goalOptions = [
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'Stay Healthy'
  ];
  static const _coachToneOptions = ['Friendly', 'Strict', 'Clinical'];
  static const _unitOptions = ['Metric', 'Imperial'];

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => _saveProfile(context),
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
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
            _gender = user.gender;
            _fitnessLevel = user.fitnessLevel;
            _goal = user.goal;
            _currentPhotoUrl = user.photoUrl;
            _coachTone = user.onboarding?['coachTone'] as String? ?? 'Friendly';
            _unitPreference = user.preferences?['units'] as String? ?? 'Metric';
            _initialized = true;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Photo Section
                _buildProfilePhotoSection(context),
                const SizedBox(height: 32),

                // Basic Information
                _buildSectionTitle(context, 'Basic Information'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _displayNameController,
                  label: 'Display Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
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
                const SizedBox(height: 24),

                // Personal Information
                _buildSectionTitle(context, 'Personal Information'),
                const SizedBox(height: 12),
                _buildDateField(context),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Gender',
                  icon: Icons.person_outline,
                  value: _gender,
                  options: _genderOptions,
                  onChanged: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 24),

                // Fitness Information
                _buildSectionTitle(context, 'Fitness Information'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _heightController,
                  label: 'Height (${_unitPreference == 'Imperial' ? 'inches' : 'cm'})',
                  icon: Icons.height,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _weightController,
                  label: 'Weight (${_unitPreference == 'Imperial' ? 'lbs' : 'kg'})',
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
                  label: 'Primary Goal',
                  icon: Icons.flag_outlined,
                  value: _goal,
                  options: _goalOptions,
                  onChanged: (value) => setState(() => _goal = value),
                ),
                const SizedBox(height: 24),

                // Preferences
                _buildSectionTitle(context, 'Preferences'),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Coach Tone',
                  icon: Icons.psychology_outlined,
                  value: _coachTone,
                  options: _coachToneOptions,
                  onChanged: (value) => setState(() => _coachTone = value),
                  hint: 'How should your AI coach communicate?',
                ),
                const SizedBox(height: 12),
                _buildDropdownField(
                  label: 'Units',
                  icon: Icons.straighten,
                  value: _unitPreference,
                  options: _unitOptions,
                  onChanged: (value) => setState(() => _unitPreference = value),
                  hint: 'Metric (kg, cm) or Imperial (lbs, inches)',
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : () => _saveProfile(context),
                  icon: const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
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

  Widget _buildProfilePhotoSection(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : _currentPhotoUrl != null
                      ? Image.network(_currentPhotoUrl!, fit: BoxFit.cover)
                      : Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: _isUploadingPhoto ? null : _showPhotoOptions,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isUploadingPhoto
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_currentPhotoUrl != null || _selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _currentPhotoUrl = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
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
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        helperMaxLines: 2,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
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
        decoration: InputDecoration(
          labelText: 'Date of Birth',
          prefixIcon: const Icon(Icons.cake_outlined, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(value),
      ),
    );
  }

  Future<void> _saveProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      String? photoUrl = _currentPhotoUrl;

      // Upload new photo if selected
      if (_selectedImage != null) {
        setState(() => _isUploadingPhoto = true);
        photoUrl = await _profilePhotoService.uploadProfilePhoto(
          userId: userId,
          imageFile: _selectedImage!,
        );
        setState(() => _isUploadingPhoto = false);

        // Delete old photo if exists
        if (_currentPhotoUrl != null && _currentPhotoUrl != photoUrl) {
          await _profilePhotoService.deleteProfilePhoto(_currentPhotoUrl!);
        }
      }

      final data = <String, dynamic>{
        'displayName': _displayNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'dateOfBirth': _dateOfBirth,
        'gender': _gender,
        'height': _parseDoubleOrNull(_heightController.text),
        'weight': _parseDoubleOrNull(_weightController.text),
        'fitnessLevel': _fitnessLevel,
        'goal': _goal,
        'photoUrl': photoUrl,
        'onboarding': {
          'coachTone': _coachTone,
        },
        'preferences': {
          'units': _unitPreference,
        },
      };

      final firestoreService = ref.read(firestoreServiceProvider);
      await firestoreService.updateUser(userId, data);

      // Update Firebase Auth display name
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser != null) {
        await authUser.updateDisplayName(data['displayName']);
        if (photoUrl != null) {
          await authUser.updatePhotoURL(photoUrl);
        }
      }

      // Invalidate provider to refresh
      ref.invalidate(currentUserProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isUploadingPhoto = false;
        });
      }
    }
  }

  double? _parseDoubleOrNull(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
