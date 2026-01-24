import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/weight_entry.dart';
import '../providers/progress_providers.dart';

/// Modal dialog for logging weight
class WeightInputDialog extends ConsumerStatefulWidget {
  final WeightEntry? existingEntry; // For editing existing entry

  const WeightInputDialog({super.key, this.existingEntry});

  /// Show the dialog as a modal bottom sheet
  static Future<void> show(BuildContext context, {WeightEntry? existingEntry}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WeightInputDialog(existingEntry: existingEntry),
    );
  }

  @override
  ConsumerState<WeightInputDialog> createState() => _WeightInputDialogState();
}

class _WeightInputDialogState extends ConsumerState<WeightInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  bool _useKg = true; // Unit preference
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // If editing existing entry, populate fields
    if (widget.existingEntry != null) {
      _weightController.text = widget.existingEntry!.weight.toStringAsFixed(1);
      _selectedDate = widget.existingEntry!.date;
      _notesController.text = widget.existingEntry!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Convert weight to kg if needed
  double _getWeightInKg() {
    final inputWeight = double.tryParse(_weightController.text) ?? 0.0;
    if (_useKg) {
      return inputWeight;
    } else {
      // Convert lbs to kg
      return inputWeight * 0.453592;
    }
  }

  /// Save the weight entry
  Future<void> _saveWeight() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to log weight')),
        );
      }
      return;
    }

    final weightInKg = _getWeightInKg();

    final entry = WeightEntry(
      id: widget.existingEntry?.id ?? '',
      userId: userId,
      weight: weightInKg,
      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
      createdAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final operations = ref.read(progressOperationsProvider.notifier);

    if (widget.existingEntry == null) {
      // Create new entry
      final success = await operations.logWeight(entry);

      if (!mounted) return;

      if (success != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Weight logged successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to log weight. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      // Update existing entry
      final success = await operations.updateWeight(
        widget.existingEntry!.id,
        {
          'weight': weightInKg,
          'date': Timestamp.fromDate(entry.date),
          'notes': entry.notes,
        },
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Weight updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update weight. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Pick a date
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365)), // Max 1 year ago
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final operationsState = ref.watch(progressOperationsProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Text(
              widget.existingEntry == null ? 'Log Weight' : 'Update Weight',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Weight input with unit toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,1}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      hintText: _useKg ? '30-300' : '66-660',
                      border: const OutlineInputBorder(),
                      suffixText: _useKg ? 'kg' : 'lbs',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your weight';
                      }
                      final weight = double.tryParse(value);
                      if (weight == null) {
                        return 'Please enter a valid number';
                      }
                      // Validate based on unit
                      if (_useKg) {
                        if (weight < 30) return 'Weight must be at least 30 kg';
                        if (weight > 300) return 'Weight cannot exceed 300 kg';
                      } else {
                        if (weight < 66) return 'Weight must be at least 66 lbs';
                        if (weight > 660) return 'Weight cannot exceed 660 lbs';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Unit toggle
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('kg')),
                    ButtonSegment(value: false, label: Text('lbs')),
                  ],
                  selected: {_useKg},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _useKg = newSelection.first;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),

            // Notes (optional)
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Add any notes...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: operationsState.isLoading ? null : _saveWeight,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: operationsState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.existingEntry == null ? 'Log Weight' : 'Update Weight',
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
