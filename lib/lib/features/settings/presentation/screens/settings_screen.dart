import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Account',
            [
              _buildSettingsTile(
                context,
                'Edit Profile',
                'Update your personal information',
                Icons.person_outline,
                () => context.push(RouteConstants.editProfile),
              ),
              _buildSettingsTile(
                context,
                'Notifications',
                'Manage notification preferences',
                Icons.notifications_outlined,
                () => context.push(RouteConstants.notifications),
              ),
              _buildSettingsTile(
                context,
                'Health Sync',
                'Connect health apps and devices',
                Icons.favorite_outline,
                () => context.push(RouteConstants.healthSync),
              ),
            ],
          ),
          _buildSection(
            context,
            'App Settings',
            [
              _buildSwitchTile(
                context,
                'Dark Mode',
                'Enable dark theme',
                Icons.dark_mode_outlined,
                false,
                (value) {},
              ),
              _buildSwitchTile(
                context,
                'Offline Mode',
                'Work offline when possible',
                Icons.cloud_off_outlined,
                false,
                (value) {},
              ),
            ],
          ),
          _buildSection(
            context,
            'Privacy & Security',
            [
              _buildSettingsTile(
                context,
                'Privacy',
                'Manage your privacy settings',
                Icons.lock_outline,
                () => context.push(RouteConstants.privacy),
              ),
              _buildSettingsTile(
                context,
                'Data Management',
                'Download or delete your data',
                Icons.storage_outlined,
                () {},
              ),
            ],
          ),
          _buildSection(
            context,
            'Support',
            [
              _buildSettingsTile(
                context,
                'Help Center',
                'Get help and support',
                Icons.help_outline,
                () => context.push(RouteConstants.help),
              ),
              _buildSettingsTile(
                context,
                'About',
                'App version and information',
                Icons.info_outline,
                () => context.push(RouteConstants.about),
              ),
              _buildSettingsTile(
                context,
                'Terms of Service',
                'Read our terms',
                Icons.description_outlined,
                () => context.push(RouteConstants.termsOfService),
              ),
              _buildSettingsTile(
                context,
                'Privacy Policy',
                'Read our privacy policy',
                Icons.policy_outlined,
                () => context.push(RouteConstants.privacyPolicy),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authControllerProvider.notifier).signOut();
              if (context.mounted) {
                context.go(RouteConstants.login);
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
