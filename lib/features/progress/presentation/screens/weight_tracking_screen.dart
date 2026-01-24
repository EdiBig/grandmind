import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../domain/models/weight_entry.dart';
import '../providers/progress_providers.dart';
import '../widgets/weight_input_dialog.dart';
import '../widgets/weight_chart_widget.dart';

class WeightTrackingScreen extends ConsumerStatefulWidget {
  const WeightTrackingScreen({super.key});

  @override
  ConsumerState<WeightTrackingScreen> createState() =>
      _WeightTrackingScreenState();
}

class _WeightTrackingScreenState extends ConsumerState<WeightTrackingScreen> {
  DateRange _selectedRange = DateRange.last90Days();
  bool _useKg = true; // Unit preference

  @override
  Widget build(BuildContext context) {
    final weightEntriesAsync = ref.watch(weightEntriesProvider);
    final latestWeightAsync = ref.watch(latestWeightProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracking'),
        actions: [
          // Unit toggle
          IconButton(
            icon: Text(
              _useKg ? 'kg' : 'lbs',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              setState(() {
                _useKg = !_useKg;
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weightEntriesProvider);
          ref.invalidate(latestWeightProvider);
        },
        child: weightEntriesAsync.when(
          data: (entries) {
            if (entries.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Latest weight card
                latestWeightAsync.when(
                  data: (latest) => latest != null
                      ? _buildLatestWeightCard(context, latest)
                      : const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 16),

                // Weight change summary
                if (entries.length > 1) ...[
                  _buildWeightChangeSummary(context, entries),
                  const SizedBox(height: 24),
                ],

                // Chart section
                WeightChartWidget(
                  entries: entries.reversed.toList(), // Oldest to newest for chart
                  useKg: _useKg,
                ),
                const SizedBox(height: 24),

                // Date range selector
                _buildDateRangeSelector(context),
                const SizedBox(height: 16),

                // Weight history list
                _buildWeightHistoryList(context, entries),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error loading weight data'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    ref.invalidate(weightEntriesProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => WeightInputDialog.show(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Weight'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_weight_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 24),
          Text(
            'No Weight Entries',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your weight progress!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => WeightInputDialog.show(context),
            icon: Icon(Icons.add),
            label: const Text('Log First Weight'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestWeightCard(BuildContext context, WeightEntry latest) {
    final displayWeight = _useKg ? latest.weight : latest.weight * 2.20462;

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
            'Current Weight',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                displayWeight.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                _useKg ? 'kg' : 'lbs',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: ${DateFormat('MMM d, yyyy').format(latest.date)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChangeSummary(
      BuildContext context, List<WeightEntry> entries) {
    final latest = entries.first;
    final oldest = entries.last;
    final change = latest.weight - oldest.weight;
    final changeDisplay = _useKg ? change : change * 2.20462;
    final isLoss = change < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLoss ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoss ? AppColors.success.withValues(alpha: 0.4) : AppColors.warning.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLoss ? AppColors.success : AppColors.warning,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLoss ? Icons.trending_down : Icons.trending_up,
              color: AppColors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isLoss ? 'Lost' : 'Gained'} ${changeDisplay.abs().toStringAsFixed(1)} ${_useKg ? 'kg' : 'lbs'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isLoss ? AppColors.success : AppColors.warning,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Since ${DateFormat('MMM d').format(oldest.date)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildRangeChip('7 Days', DateRange.last7Days()),
          const SizedBox(width: 8),
          _buildRangeChip('30 Days', DateRange.last30Days()),
          const SizedBox(width: 8),
          _buildRangeChip('90 Days', DateRange.last90Days()),
          const SizedBox(width: 8),
          _buildRangeChip('All Time', DateRange.allTime()),
        ],
      ),
    );
  }

  Widget _buildRangeChip(String label, DateRange range) {
    final isSelected = _selectedRange.label == range.label;
    final colorScheme = Theme.of(context).colorScheme;
    final labelColor = isSelected
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;
    final borderColor =
        isSelected ? colorScheme.primary : colorScheme.outlineVariant;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedRange = range;
          });
        }
      },
      selectedColor: colorScheme.primaryContainer,
      backgroundColor: colorScheme.surface,
      showCheckmark: false,
      side: BorderSide(color: borderColor),
    );
  }

  Widget _buildWeightHistoryList(
      BuildContext context, List<WeightEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Weight History',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...entries.map((entry) => _buildWeightHistoryItem(context, entry)),
      ],
    );
  }

  Widget _buildWeightHistoryItem(BuildContext context, WeightEntry entry) {
    final displayWeight = _useKg ? entry.weight : entry.weight * 2.20462;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.monitor_weight,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          '${displayWeight.toStringAsFixed(1)} ${_useKg ? 'kg' : 'lbs'}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(DateFormat('EEEE, MMM d, yyyy').format(entry.date)),
            if (entry.notes != null) ...[
              const SizedBox(height: 4),
              Text(
                entry.notes!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          itemBuilder: (context) => [
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(value, entry),
        ),
      ),
    );
  }

  void _handleMenuAction(String action, WeightEntry entry) {
    switch (action) {
      case 'edit':
        WeightInputDialog.show(context, existingEntry: entry);
        break;
      case 'delete':
        _showDeleteConfirmation(entry);
        break;
    }
  }

  void _showDeleteConfirmation(WeightEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Weight Entry'),
        content: const Text(
          'Are you sure you want to delete this weight entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final operations = ref.read(progressOperationsProvider.notifier);
              final success = await operations.deleteWeight(entry.id);

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success ? 'Weight entry deleted' : 'Failed to delete entry',
                  ),
                  backgroundColor: success ? AppColors.success : AppColors.error,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
