import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/services/account_deletion_service.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isDeleting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final providerIds = user?.providerData.map((info) => info.providerId).toSet() ?? {};
    final hasPasswordProvider = providerIds.contains('password');
    final hasGoogleProvider = providerIds.contains('google.com');
    final hasAppleProvider = providerIds.contains('apple.com');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.error, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          'Warning',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This action is permanent and cannot be undone!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Deleting your account will:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // What Will Be Deleted
              _buildDeletedDataSection(context),
              const SizedBox(height: 32),

              // Password Confirmation
              if (hasPasswordProvider) ...[
                Text(
                  'Confirm Your Password',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'For security, please enter your password to confirm account deletion.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (!hasPasswordProvider) return null;
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isDeleting
                        ? null
                        : () => _confirmDeletion(
                              reauth: () async {
                                final deletionService = AccountDeletionService();
                                await deletionService.reauthenticateUser(
                                  user?.email ?? '',
                                  _passwordController.text,
                                );
                              },
                            ),
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Icon(Icons.delete_forever),
                    label:
                        Text(_isDeleting ? 'Deleting...' : 'Delete My Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (!hasPasswordProvider && (hasGoogleProvider || hasAppleProvider)) ...[
                Text(
                  'Re-authenticate to continue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Confirm your identity with your sign-in provider to delete your account.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
                if (hasGoogleProvider)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _confirmDeletion(
                                reauth: () async {
                                  final deletionService =
                                      AccountDeletionService();
                                  await deletionService.reauthenticateWithGoogle();
                                },
                              ),
                      icon: const Icon(Icons.account_circle),
                      label: const Text('Continue with Google'),
                    ),
                  ),
                if (hasAppleProvider) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isDeleting
                          ? null
                          : () => _confirmDeletion(
                                reauth: () async {
                                  final deletionService =
                                      AccountDeletionService();
                                  await deletionService.reauthenticateWithApple();
                                },
                              ),
                      icon: const Icon(Icons.apple),
                      label: const Text('Continue with Apple'),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeletedDataSection(BuildContext context) {
    final dataItems = [
      _DataItem(
        icon: Icons.fitness_center,
        title: 'Workout History',
        description: 'All logged workouts and exercises',
      ),
      _DataItem(
        icon: Icons.check_circle_outline,
        title: 'Habits & Streaks',
        description: 'All habits, logs, and streak data',
      ),
      _DataItem(
        icon: Icons.monitor_weight_outlined,
        title: 'Progress Data',
        description: 'Weight, measurements, photos, and goals',
      ),
      _DataItem(
        icon: Icons.favorite_outline,
        title: 'Health Data',
        description: 'Synced health and fitness data',
      ),
      _DataItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        description: 'All reminders and notification settings',
      ),
      _DataItem(
        icon: Icons.photo_library_outlined,
        title: 'Photos',
        description: 'Profile photo and progress photos',
      ),
      _DataItem(
        icon: Icons.person_outline,
        title: 'Account',
        description: 'Your account and authentication data',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What Will Be Deleted',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...dataItems.map((item) => _buildDataItem(context, item)),
      ],
    );
  }

  Widget _buildDataItem(BuildContext context, _DataItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
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

  Future<void> _confirmDeletion({
    required Future<void> Function() reauth,
  }) async {
    if (_formKey.currentState != null &&
        !_formKey.currentState!.validate()) {
      return;
    }

    // Show final confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 12),
            Text('Final Confirmation'),
          ],
        ),
        content: const Text(
          'Are you absolutely sure you want to delete your account?\n\n'
          'This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Yes, Delete My Account'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user
      await reauth();

      // Delete account
      final deletionService = AccountDeletionService();
      await deletionService.deleteAccount();

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account successfully deleted'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to login
        context.go(RouteConstants.login);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String message = 'Failed to delete account';
        if (e.code == 'wrong-password') {
          message = 'Incorrect password';
        } else if (e.code == 'requires-recent-login') {
          message = 'Please sign out and sign in again before deleting your account';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }
}

class _DataItem {
  final IconData icon;
  final String title;
  final String description;

  _DataItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
