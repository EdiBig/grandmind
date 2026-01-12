import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../domain/models/measurement_entry.dart';
import '../providers/progress_providers.dart';
import '../widgets/measurement_input_dialog.dart';

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() =>
      _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  bool _useCm = true; // Unit preference

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(measurementEntriesProvider);
    final latestAsync = ref.watch(latestMeasurementsProvider);
    final baselineAsync = ref.watch(baselineMeasurementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurements'),
        actions: [
          // Unit toggle
          IconButton(
            icon: Text(
              _useCm ? 'cm' : 'in',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setState(() {
                _useCm = !_useCm;
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(measurementEntriesProvider);
          ref.invalidate(latestMeasurementsProvider);
          ref.invalidate(baselineMeasurementsProvider);
        },
        child: measurementsAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Latest measurements card
                latestAsync.when(
                  data: (latest) => latest != null
                      ? _buildLatestMeasurementsCard(context, latest)
                      : const SizedBox.shrink(),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Comparison card (if we have baseline)
                if (entries.length > 1) ...[
                  baselineAsync.when(
                    data: (baseline) => baseline != null && latestAsync.value != null
                        ? _buildComparisonCard(
                            context,
                            baseline,
                            latestAsync.value!,
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Measurement history
                Text(
                  'Measurement History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...entries.map((entry) => _buildMeasurementHistoryItem(context, entry)),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error loading measurements'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(measurementEntriesProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => MeasurementInputDialog.show(context),
        icon: const Icon(Icons.straighten),
        label: const Text('Log Measurements'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.straighten,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No Measurements Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your body measurements',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => MeasurementInputDialog.show(context),
            icon: const Icon(Icons.add),
            label: const Text('Log First Measurement'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestMeasurementsCard(
      BuildContext context, MeasurementEntry latest) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: Theme.of(context).extension<AppGradients>()!.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Latest Measurements',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM d, yyyy').format(latest.date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: latest.measurements.entries.map((entry) {
              final type = MeasurementType.values.firstWhere(
                (t) => t.name == entry.key,
                orElse: () => MeasurementType.waist,
              );
              final displayValue = _useCm ? entry.value : entry.value / 2.54;

              return _buildMeasurementChip(
                context,
                type.displayName,
                displayValue,
                _useCm ? 'cm' : 'in',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementChip(
    BuildContext context,
    String label,
    double value,
    String unit,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context,
    MeasurementEntry baseline,
    MeasurementEntry latest,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Since ${DateFormat('MMM d').format(baseline.date)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...baseline.measurements.entries.map((entry) {
            final type = MeasurementType.values.firstWhere(
              (t) => t.name == entry.key,
              orElse: () => MeasurementType.waist,
            );
            final baselineValue = entry.value;
            final latestValue = latest.measurements[entry.key] ?? baselineValue;
            final change = latestValue - baselineValue;

            return _buildComparisonRow(
              context,
              type.displayName,
              baselineValue,
              latestValue,
              change,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context,
    String label,
    double baseline,
    double current,
    double change,
  ) {
    final displayBaseline = _useCm ? baseline : baseline / 2.54;
    final displayCurrent = _useCm ? current : current / 2.54;
    final displayChange = _useCm ? change : change / 2.54;
    final unit = _useCm ? 'cm' : 'in';

    final isDecrease = change < 0;
    final changeColor = isDecrease ? Colors.green : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              '${displayBaseline.toStringAsFixed(1)} $unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
          Expanded(
            child: Text(
              '${displayCurrent.toStringAsFixed(1)} $unit',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: changeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${isDecrease ? '' : '+'}${displayChange.toStringAsFixed(1)}',
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementHistoryItem(
      BuildContext context, MeasurementEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.straighten,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          DateFormat('EEEE, MMM d, yyyy').format(entry.date),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '${entry.measurements.length} measurements',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: entry.measurements.entries.map((measurement) {
                final type = MeasurementType.values.firstWhere(
                  (t) => t.name == measurement.key,
                  orElse: () => MeasurementType.waist,
                );
                final displayValue =
                    _useCm ? measurement.value : measurement.value / 2.54;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(type.icon, size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(type.displayName),
                        ],
                      ),
                      Text(
                        '${displayValue.toStringAsFixed(1)} ${_useCm ? 'cm' : 'in'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
