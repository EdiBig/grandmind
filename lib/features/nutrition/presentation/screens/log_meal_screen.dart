import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/models/food_item.dart';
import '../../domain/models/meal.dart';
import '../providers/nutrition_providers.dart';
import '../../data/services/nutrition_photo_service.dart';

class LogMealArgs {
  final String? mealId;
  final MealType? initialMealType;

  const LogMealArgs({this.mealId, this.initialMealType});
}

class LogMealScreen extends ConsumerStatefulWidget {
  final String? mealId;
  final MealType? initialMealType;

  const LogMealScreen({super.key, this.mealId, this.initialMealType});

  @override
  ConsumerState<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends ConsumerState<LogMealScreen> {
  final _notesController = TextEditingController();
  final _photoService = NutritionPhotoService();

  MealType _mealType = MealType.breakfast;
  DateTime _mealDate = DateTime.now();
  List<MealEntry> _entries = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  DateTime? _existingLoggedAt;
  String? _existingPhotoUrl;
  File? _newPhotoFile;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _mealType = widget.initialMealType ?? MealType.breakfast;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _initializeFromMeal(Meal meal) {
    if (_isInitialized) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isInitialized) return;
      setState(() {
        _mealType = meal.mealType;
        _mealDate = meal.mealDate;
        _entries = List<MealEntry>.from(meal.entries);
        _notesController.text = meal.notes ?? '';
        _existingLoggedAt = meal.loggedAt;
        _existingPhotoUrl = meal.photoUrl;
        _isInitialized = true;
      });
    });
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _mealDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selected != null && mounted) {
      setState(() => _mealDate = selected);
    }
  }

  Future<double?> _promptServings({double initial = 1}) async {
    final controller = TextEditingController(text: initial.toStringAsFixed(1));
    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Servings'),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Number of servings',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                Navigator.of(context).pop(value);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    return result;
  }

  Future<void> _addFood() async {
    final selected = await context.push<FoodItem>(
      RouteConstants.foodSearch,
      extra: true,
    );
    if (selected == null || !mounted) return;

    final servings = await _promptServings();
    if (servings == null || servings <= 0) return;

    setState(() {
      _entries = [
        ..._entries,
        MealEntry(foodItem: selected, servings: servings),
      ];
    });
  }

  Future<void> _editEntryServings(int index) async {
    final entry = _entries[index];
    final updated = await _promptServings(initial: entry.servings);
    if (updated == null || updated <= 0 || !mounted) return;
    setState(() {
      final updatedEntry = entry.copyWith(servings: updated);
      _entries = [
        ..._entries.sublist(0, index),
        updatedEntry,
        ..._entries.sublist(index + 1),
      ];
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entries = [
        ..._entries.sublist(0, index),
        ..._entries.sublist(index + 1),
      ];
    });
  }

  Future<void> _showPhotoSourcePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              if (_newPhotoFile != null || _existingPhotoUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () => Navigator.pop(context, null),
                ),
            ],
          ),
        );
      },
    );

    if (source == ImageSource.camera) {
      await _takePhoto();
    } else if (source == ImageSource.gallery) {
      await _pickPhotoFromGallery();
    } else if (source == null &&
        (_newPhotoFile != null || _existingPhotoUrl != null)) {
      // Remove photo
      setState(() {
        _newPhotoFile = null;
        _existingPhotoUrl = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    final file = await _photoService.getImage(source: ImageSource.camera);
    if (file != null && mounted) {
      setState(() {
        _newPhotoFile = file;
        _existingPhotoUrl = null; // Clear existing photo URL if uploading new
      });
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    final file = await _photoService.getImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      setState(() {
        _newPhotoFile = file;
        _existingPhotoUrl = null; // Clear existing photo URL if uploading new
      });
    }
  }

  Future<void> _saveMeal() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one food item')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to log meals')),
          );
        }
        return;
      }

      // Upload new photo if selected
      String? photoUrl = _existingPhotoUrl;
      if (_newPhotoFile != null) {
        setState(() => _isUploadingPhoto = true);
        photoUrl = await _photoService.uploadMealPhoto(_newPhotoFile!, userId);
        setState(() => _isUploadingPhoto = false);

        if (photoUrl == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload photo')),
          );
          // Continue anyway, don't block meal creation
        }
      }

      final normalizedDate = DateTime(
        _mealDate.year,
        _mealDate.month,
        _mealDate.day,
      );

      final meal = Meal(
        id: widget.mealId ?? '',
        userId: userId,
        mealType: _mealType,
        mealDate: normalizedDate,
        loggedAt: _existingLoggedAt ?? DateTime.now(),
        entries: _entries,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        photoUrl: photoUrl,
      ).calculateTotals();

      final operations = ref.read(nutritionOperationsProvider.notifier);
      final isCreate = widget.mealId == null;
      final mealId = isCreate
          ? await operations.logMeal(meal)
          : (await operations.updateMeal(widget.mealId!, meal.toJson())
              ? widget.mealId
              : null);
      final success = mealId != null;

      if (mounted) {
        if (success) {
          ref.invalidate(todayMealsProvider);
          ref.invalidate(todayNutritionSummaryProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isCreate
                    ? 'Meal logged successfully!'
                    : 'Meal updated successfully!',
              ),
            ),
          );
          context.pop();
        } else {
          final opState = ref.read(nutritionOperationsProvider);
          final errorText = opState.hasError
              ? opState.error.toString()
              : 'Failed to save meal';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorText)),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPhotoSection() {
    final hasPhoto = _newPhotoFile != null || _existingPhotoUrl != null;

    if (!hasPhoto) {
      return InkWell(
        onTap: _showPhotoSourcePicker,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 2),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_a_photo, size: 40, color: Colors.grey.shade600),
                const SizedBox(height: 8),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _newPhotoFile != null
              ? Image.file(
                  _newPhotoFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  _existingPhotoUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.error, size: 48),
                    );
                  },
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              IconButton(
                onPressed: _showPhotoSourcePicker,
                icon: const Icon(Icons.edit),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  setState(() {
                    _newPhotoFile = null;
                    _existingPhotoUrl = null;
                  });
                },
                icon: const Icon(Icons.delete),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
        if (_isUploadingPhoto)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 8),
                    Text(
                      'Uploading photo...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEntriesList() {
    if (_entries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.restaurant, color: Colors.grey.shade500),
            const SizedBox(width: 12),
            Text(
              'No foods added yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final entry = _entries[index];
        final item = entry.foodItem;
        final calories =
            (item.calories * entry.servings).toStringAsFixed(0);
        return InkWell(
          onTap: () => _editEntryServings(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${entry.servings.toStringAsFixed(1)} servings • $calories cal',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _removeEntry(index),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<MealType>(
          initialValue: _mealType,
          decoration: const InputDecoration(
            labelText: 'Meal Type',
            border: OutlineInputBorder(),
          ),
          items: MealType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _mealType = value);
            }
          },
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Meal Date'),
          subtitle: Text(Formatters.formatDate(_mealDate)),
          trailing: const Icon(Icons.calendar_today),
          onTap: _selectDate,
        ),
        const SizedBox(height: 16),
        Text(
          'Food Items',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildEntriesList(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addFood,
                icon: const Icon(Icons.search),
                label: const Text('Search Foods'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.push(RouteConstants.createCustomFood),
                icon: const Icon(Icons.add),
                label: const Text('Custom Food'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Meal Photo',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildPhotoSection(),
        const SizedBox(height: 24),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveMeal,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  widget.mealId == null ? 'Log Meal' : 'Update Meal',
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mealId != null) {
      final mealAsync = ref.watch(mealByIdProvider(widget.mealId!));
      return mealAsync.when(
        data: (meal) {
          if (meal == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Meal Not Found')),
              body: const Center(child: Text('Meal not found')),
            );
          }
          _initializeFromMeal(meal);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Meal'),
            ),
            body: _buildContent(),
          );
        },
        loading: () => Scaffold(
          appBar: AppBar(title: const Text('Edit Meal')),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Edit Meal')),
          body: Center(child: Text('Failed to load meal: $error')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Log Meal')),
      body: _buildContent(),
    );
  }
}
