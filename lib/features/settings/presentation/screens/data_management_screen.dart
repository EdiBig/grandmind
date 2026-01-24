import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/screens/delete_account_screen.dart';
import '../../../profile/data/services/data_export_service.dart';
import '../../../health/data/services/health_data_deletion_service.dart';
import '../../../health/presentation/providers/health_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  bool _isExporting = false;
  bool _isDeletingHealth = false;
  DateTime? _healthDeleteStartDate;
  DateTime? _healthDeleteEndDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Data Export Section
          _buildSection(
            context,
            'Export Your Data',
            'Download a copy of your data in JSON or CSV format',
            [
              _buildActionCard(
                context,
                icon: Icons.file_download_outlined,
                title: 'Export as JSON',
                description: 'Download all your data in JSON format',
                color: Theme.of(context).colorScheme.primary,
                onTap: _isExporting ? null : () => _exportData('json'),
              ),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                icon: Icons.table_chart_outlined,
                title: 'Export as CSV',
                description: 'Download workouts and habits as CSV files',
                color: Theme.of(context).colorScheme.secondary,
                onTap: _isExporting ? null : () => _exportData('csv'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Health Data Section
          _buildSection(
            context,
            'Health Data',
            'Manage your synced health data from Apple Health or Google Fit',
            [
              _buildHealthDataInfoCard(context),
              const SizedBox(height: 12),
              _buildActionCard(
                context,
                icon: Icons.date_range_outlined,
                title: 'Delete Health Data by Date Range',
                description: 'Select a date range to delete specific health data',
                color: AppColors.warning,
                onTap: _isDeletingHealth ? null : () => _showHealthDeleteDialog(),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Danger Zone
          _buildSection(
            context,
            'Danger Zone',
            'Irreversible actions that affect your account',
            [
              _buildActionCard(
                context,
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                description:
                    'Permanently delete your account and all data',
                color: AppColors.error,
                onTap: () => _navigateToDeleteAccount(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent, // Use Material's transparent for proper tap rendering
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (_isExporting && onTap != null)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportData(String format) async {
    if (kIsWeb) {
      if (mounted) {
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Not supported on web'),
            content: const Text(
              'Data export is only available on mobile devices.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() => _isExporting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('No user logged in');
      }

      final exportService = DataExportService();
      final filePath = await exportService.exportUserData(userId, format);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data exported successfully to: $filePath'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: AppColors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _navigateToDeleteAccount() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DeleteAccountScreen(),
      ),
    );
  }

  Widget _buildHealthDataInfoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'What health data is stored',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your synced health data includes:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip('Steps'),
              _buildInfoChip('Distance'),
              _buildInfoChip('Calories'),
              _buildInfoChip('Heart Rate'),
              _buildInfoChip('Sleep'),
              _buildInfoChip('Weight'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.info,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _showHealthDeleteDialog() async {
    final now = DateTime.now();
    _healthDeleteStartDate = now.subtract(const Duration(days: 7));
    _healthDeleteEndDate = now;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Delete Health Data'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select the date range for health data you want to delete.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  // Start Date
                  Text(
                    'Start Date',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _healthDeleteStartDate ?? now,
                        firstDate: DateTime(2020),
                        lastDate: now,
                      );
                      if (date != null) {
                        setDialogState(() {
                          _healthDeleteStartDate = date;
                          if (_healthDeleteEndDate != null &&
                              _healthDeleteEndDate!.isBefore(date)) {
                            _healthDeleteEndDate = date;
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _healthDeleteStartDate != null
                                ? DateFormat('dd MMM yyyy')
                                    .format(_healthDeleteStartDate!)
                                : 'Select date',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // End Date
                  Text(
                    'End Date',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _healthDeleteEndDate ?? now,
                        firstDate: _healthDeleteStartDate ?? DateTime(2020),
                        lastDate: now,
                      );
                      if (date != null) {
                        setDialogState(() {
                          _healthDeleteEndDate = date;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _healthDeleteEndDate != null
                                ? DateFormat('dd MMM yyyy')
                                    .format(_healthDeleteEndDate!)
                                : 'Select date',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This action cannot be undone. The data will be permanently deleted.',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _healthDeleteStartDate != null &&
                        _healthDeleteEndDate != null
                    ? () {
                        Navigator.pop(context);
                        _confirmAndDeleteHealthData();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmAndDeleteHealthData() async {
    if (_healthDeleteStartDate == null || _healthDeleteEndDate == null) return;

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final deletionService = HealthDataDeletionService();

    // Get count first
    final count = await deletionService.getHealthDataCountInRange(
      userId,
      _healthDeleteStartDate!,
      _healthDeleteEndDate!,
    );

    if (!mounted) return;

    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No health data found in the selected date range.'),
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete $count health data record${count > 1 ? 's' : ''} from ${DateFormat('dd MMM yyyy').format(_healthDeleteStartDate!)} to ${DateFormat('dd MMM yyyy').format(_healthDeleteEndDate!)}?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingHealth = true);

    try {
      final deletedCount = await deletionService.deleteHealthDataInRange(
        userId,
        _healthDeleteStartDate!,
        _healthDeleteEndDate!,
      );

      // Invalidate health providers to refresh data
      ref.invalidate(healthSummaryProvider);
      ref.invalidate(last7DaysHealthDataProvider);
      ref.invalidate(last30DaysHealthDataProvider);
      ref.invalidate(weeklyHealthStatsProvider);
      ref.invalidate(syncedTodayHealthDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully deleted $deletedCount health data record${deletedCount > 1 ? 's' : ''}.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete health data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeletingHealth = false);
      }
    }
  }
}
