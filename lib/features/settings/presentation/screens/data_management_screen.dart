import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../profile/presentation/screens/delete_account_screen.dart';
import '../../../profile/data/services/data_export_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  bool _isExporting = false;

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
                color: Colors.red,
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
                color: Colors.grey[600],
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
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
                            color: Colors.grey[700],
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
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
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
            backgroundColor: Colors.red,
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
}
