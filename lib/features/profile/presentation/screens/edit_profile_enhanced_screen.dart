import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_gradients.dart';
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
  static const int _maxPhotoBytes = 10 * 1024 * 1024;
  static const double _cmPerInch = 2.54;
  static const double _lbsPerKg = 2.2046226218;
  static const double _minHeightCm = 50;
  static const double _maxHeightCm = 250;
  static const double _minHeightIn = 20;
  static const double _maxHeightIn = 100;
  static const double _minWeightKg = 20;
  static const double _maxWeightKg = 300;
  static const double _minWeightLbs = 44;
  static const double _maxWeightLbs = 660;

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
  Uint8List? _selectedImageBytes;
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
    final colorScheme = Theme.of(context).colorScheme;

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
        _dateOfBirth = user.dateOfBirth;
        _gender = _normalizeDropdownValue(user.gender, _genderOptions);
        _fitnessLevel =
            _normalizeDropdownValue(user.fitnessLevel, _fitnessOptions);
        _goal = _normalizeDropdownValue(user.goal, _goalOptions);
        _currentPhotoUrl = user.photoUrl;
        _coachTone = _normalizeDropdownValue(
          user.onboarding?['coachTone'] as String?,
          _coachToneOptions,
        ) ??
            'Friendly';
        _unitPreference = _normalizeDropdownValue(
              user.preferences?['units'] as String?,
              _unitOptions,
            ) ??
            'Metric';
        _setMeasurementControllers(
          heightCm: user.height,
          weightKg: user.weight,
          unitPreference: _unitPreference!,
        );
        _initialized = true;
        _runProfileMigration(user.id);
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
                  validator: _validateHeight,
                  helperText: _heightHelperText(),
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
                  validator: _validateWeight,
                  helperText: _weightHelperText(),
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
                  onChanged: _onUnitPreferenceChanged,
                  hint: 'Metric (kg, cm) or Imperial (lbs, inches)',
                ),
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton.icon(
                  onPressed: _isSaving ? null : () => _saveProfile(context),
                  icon: const Icon(Icons.save),
                  label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
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
    final gradients = Theme.of(context).extension<AppGradients>()!;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Stack(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.primary, width: 3),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _selectedImageBytes != null
                  ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                  : _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : _currentPhotoUrl != null
                          ? Image.network(
                              _currentPhotoUrl!,
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                              webHtmlElementStrategy: kIsWeb
                                  ? WebHtmlElementStrategy.prefer
                                  : WebHtmlElementStrategy.never,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                decoration: BoxDecoration(
                                  gradient: gradients.primary,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 70,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: gradients.primary,
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
              color: colorScheme.primary,
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
            if (_currentPhotoUrl != null ||
                _selectedImage != null ||
                _selectedImageBytes != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _selectedImageBytes = null;
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
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          if (bytes.length > _maxPhotoBytes) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Photo is too large. Please choose a smaller image.'),
                ),
              );
            }
            return;
          }
          setState(() {
            _selectedImageBytes = bytes;
            _selectedImage = null;
          });
        } else {
          final file = File(pickedFile.path);
          final fileSize = await file.length();
          if (fileSize > _maxPhotoBytes) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Photo is too large. Please choose a smaller image.'),
                ),
              );
            }
            return;
          }
          setState(() {
            _selectedImage = file;
          });
        }
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
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
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
    String? helperText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperMaxLines: 2,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
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
    final colorScheme = Theme.of(context).colorScheme;
    return DropdownButtonFormField<String>(
      initialValue: _normalizeDropdownValue(value, options),
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      decoration: InputDecoration(
        labelText: label,
        helperText: hint,
        helperMaxLines: 2,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
          prefixIcon: Icon(Icons.cake_outlined, color: colorScheme.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(value),
      ),
    );
  }

  void _setMeasurementControllers({
    required double? heightCm,
    required double? weightKg,
    required String unitPreference,
  }) {
    if (heightCm != null) {
      final heightValue =
          unitPreference == 'Imperial' ? _cmToInches(heightCm) : heightCm;
      _heightController.text =
          _formatHeight(heightValue, unitPreference: unitPreference);
    } else {
      _heightController.text = '';
    }

    if (weightKg != null) {
      final weightValue =
          unitPreference == 'Imperial' ? _kgToLbs(weightKg) : weightKg;
      _weightController.text =
          _formatWeight(weightValue, unitPreference: unitPreference);
    } else {
      _weightController.text = '';
    }
  }

  void _onUnitPreferenceChanged(String? value) {
    if (value == null) return;
    final previous = _unitPreference ?? 'Metric';
    if (previous == value) return;

    final height = _parseDoubleOrNull(_heightController.text);
    final weight = _parseDoubleOrNull(_weightController.text);

    setState(() {
      _unitPreference = value;
      if (height != null) {
        final converted = previous == 'Metric'
            ? _cmToInches(height)
            : _inchesToCm(height);
        _heightController.text =
            _formatHeight(converted, unitPreference: value);
      }
      if (weight != null) {
        final converted =
            previous == 'Metric' ? _kgToLbs(weight) : _lbsToKg(weight);
        _weightController.text =
            _formatWeight(converted, unitPreference: value);
      }
    });
  }

  String? _validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Enter a valid height';
    if ((_unitPreference ?? 'Metric') == 'Imperial') {
      if (parsed < _minHeightIn || parsed > _maxHeightIn) {
        return 'Height should be ${_minHeightIn.toStringAsFixed(0)}-${_maxHeightIn.toStringAsFixed(0)} in';
      }
      return null;
    }
    if (parsed < _minHeightCm || parsed > _maxHeightCm) {
      return 'Height should be ${_minHeightCm.toStringAsFixed(0)}-${_maxHeightCm.toStringAsFixed(0)} cm';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Enter a valid weight';
    if ((_unitPreference ?? 'Metric') == 'Imperial') {
      if (parsed < _minWeightLbs || parsed > _maxWeightLbs) {
        return 'Weight should be ${_minWeightLbs.toStringAsFixed(0)}-${_maxWeightLbs.toStringAsFixed(0)} lbs';
      }
      return null;
    }
    if (parsed < _minWeightKg || parsed > _maxWeightKg) {
      return 'Weight should be ${_minWeightKg.toStringAsFixed(0)}-${_maxWeightKg.toStringAsFixed(0)} kg';
    }
    return null;
  }

  String _heightHelperText() {
    if ((_unitPreference ?? 'Metric') == 'Imperial') {
      return 'Typical range: ${_minHeightIn.toStringAsFixed(0)}-${_maxHeightIn.toStringAsFixed(0)} in';
    }
    return 'Typical range: ${_minHeightCm.toStringAsFixed(0)}-${_maxHeightCm.toStringAsFixed(0)} cm';
  }

  String _weightHelperText() {
    if ((_unitPreference ?? 'Metric') == 'Imperial') {
      return 'Typical range: ${_minWeightLbs.toStringAsFixed(0)}-${_maxWeightLbs.toStringAsFixed(0)} lbs';
    }
    return 'Typical range: ${_minWeightKg.toStringAsFixed(0)}-${_maxWeightKg.toStringAsFixed(0)} kg';
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
      if (_selectedImageBytes != null || _selectedImage != null) {
        setState(() => _isUploadingPhoto = true);
        if (_selectedImageBytes != null) {
          photoUrl = await _profilePhotoService.uploadProfilePhotoBytes(
            userId: userId,
            bytes: _selectedImageBytes!,
          );
        } else {
          photoUrl = await _profilePhotoService.uploadProfilePhoto(
            userId: userId,
            imageFile: _selectedImage!,
          );
        }
        setState(() => _isUploadingPhoto = false);

        // Delete old photo if exists
        if (_currentPhotoUrl != null && _currentPhotoUrl != photoUrl) {
          await _profilePhotoService.deleteProfilePhoto(_currentPhotoUrl!);
        }
      }

      final unitPreference = _unitPreference ?? 'Metric';
      final heightInput = _parseDoubleOrNull(_heightController.text);
      final weightInput = _parseDoubleOrNull(_weightController.text);
      final heightCm = heightInput == null
          ? null
          : (unitPreference == 'Imperial'
              ? _inchesToCm(heightInput)
              : heightInput);
      final weightKg = weightInput == null
          ? null
          : (unitPreference == 'Imperial'
              ? _lbsToKg(weightInput)
              : weightInput);

      final data = <String, dynamic>{
        'displayName': _displayNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'dateOfBirth': _dateOfBirth,
        'gender': _gender,
        'height': heightCm,
        'weight': weightKg,
        'fitnessLevel': _fitnessLevel,
        'goal': _goal,
        'photoUrl': photoUrl,
        'photoURL': photoUrl,
        'onboarding': {
          'coachTone': _coachTone,
        },
        'preferences': {
          'units': unitPreference,
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
        await authUser.reload();
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

  String _formatHeight(double value, {required String unitPreference}) {
    final decimals = unitPreference == 'Imperial' ? 1 : 0;
    return value.toStringAsFixed(decimals);
  }

  String _formatWeight(double value, {required String unitPreference}) {
    final decimals = unitPreference == 'Imperial' ? 1 : 1;
    return value.toStringAsFixed(decimals);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  double _cmToInches(double cm) => cm / _cmPerInch;

  double _inchesToCm(double inches) => inches * _cmPerInch;

  double _kgToLbs(double kg) => kg * _lbsPerKg;

  double _lbsToKg(double lbs) => lbs / _lbsPerKg;

  String? _normalizeDropdownValue(String? value, List<String> options) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return options.contains(trimmed) ? trimmed : null;
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
