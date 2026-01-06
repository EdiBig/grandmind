import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/measurement_entry.dart';
import '../providers/progress_providers.dart';

/// Modal dialog for logging body measurements
class MeasurementInputDialog extends ConsumerStatefulWidget {
  final MeasurementEntry? existingEntry; // For editing existing entry

  const MeasurementInputDialog({super.key, this.existingEntry});

  /// Show the dialog as a modal bottom sheet
  static Future<void> show(BuildContext context,
      {MeasurementEntry? existingEntry}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          MeasurementInputDialog(existingEntry: existingEntry),
    );
  }

  @override
  ConsumerState<MeasurementInputDialog> createState() =>
      _MeasurementInputDialogState();
}

class _MeasurementInputDialogState
    extends ConsumerState<MeasurementInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  // Controllers for each measurement type
  final Map<MeasurementType, TextEditingController> _controllers = {};

  bool _useCm = true; // Unit preference
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Initialize controllers for all measurement types
    for (var type in MeasurementType.values) {
      _controllers[type] = TextEditingController();

      // If editing existing entry, populate fields
      if (widget.existingEntry != null) {
        final value = widget.existingEntry!.getMeasurement(type);
        if (value != null) {
          _controllers[type]!.text = value.toStringAsFixed(1);
        }
      }
    }

    // Set other fields from existing entry
    if (widget.existingEntry != null) {
      _selectedDate = widget.existingEntry!.date;
      _notesController.text = widget.existingEntry!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Get measurements in cm
  Map<String, double> _getMeasurementsInCm() {
    final measurements = <String, double>{};

    for (var entry in _controllers.entries) {
      final text = entry.value.text.trim();
      if (text.isEmpty) continue;

      final value = double.tryParse(text);
      if (value == null || value <= 0) continue;

      // Convert to cm if needed
      final valueInCm = _useCm ? value : value * 2.54;
      measurements[entry.key.name] = valueInCm;
    }

    return measurements;
  }

  /// Save the measurement entry
  Future<void> _saveMeasurements() async {
    if (!_formKey.currentState!.validate()) return;

    final measurements = _getMeasurementsInCm();

    if (measurements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter at least one measurement'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to log measurements')),
        );
      }
      return;
    }

    final entry = MeasurementEntry(
      id: widget.existingEntry?.id ?? '',
      userId: userId,
      measurements: measurements,
      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
      createdAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final operations = ref.read(progressOperationsProvider.notifier);

    if (widget.existingEntry == null) {
      // Create new entry
      final success = await operations.logMeasurements(entry);

      if (!mounted) return;

      if (success != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Measurements logged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to log measurements. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Update existing entry
      final success = await operations.updateMeasurements(
        widget.existingEntry!.id,
        {
          'measurements': measurements,
          'date': entry.date,
          'notes': entry.notes,
        },
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Measurements updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update measurements. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Pick a date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
        child: SingleChildScrollView(
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingEntry == null
                        ? 'Log Measurements'
                        : 'Update Measurements',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  // Unit toggle
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('cm')),
                      ButtonSegment(value: false, label: Text('in')),
                    ],
                    selected: {_useCm},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _useCm = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Instruction text
              Text(
                'Enter only the measurements you want to track. All fields are optional.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
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

              // Measurement inputs grouped by body area
              _buildMeasurementSection(
                'Core',
                [
                  MeasurementType.waist,
                  MeasurementType.chest,
                  MeasurementType.hips,
                ],
              ),
              const SizedBox(height: 16),

              _buildMeasurementSection(
                'Upper Body',
                [
                  MeasurementType.shoulders,
                  MeasurementType.neck,
                  MeasurementType.leftArm,
                  MeasurementType.rightArm,
                ],
              ),
              const SizedBox(height: 16),

              _buildMeasurementSection(
                'Lower Body',
                [
                  MeasurementType.leftThigh,
                  MeasurementType.rightThigh,
                  MeasurementType.calves,
                ],
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
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: operationsState.isLoading ? null : _saveMeasurements,
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
                        widget.existingEntry == null
                            ? 'Log Measurements'
                            : 'Update Measurements',
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementSection(
      String title, List<MeasurementType> types) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
        ),
        const SizedBox(height: 8),
        ...types.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: _controllers[type],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: type.displayName,
                  hintText: 'Optional',
                  border: const OutlineInputBorder(),
                  suffixText: _useCm ? 'cm' : 'in',
                  prefixIcon: Icon(type.icon),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;

                  final number = double.tryParse(value);
                  if (number == null || number <= 0) {
                    return 'Please enter a valid measurement';
                  }
                  return null;
                },
              ),
            )),
      ],
    );
  }
}
