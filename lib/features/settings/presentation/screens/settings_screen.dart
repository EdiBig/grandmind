import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme_presets.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../providers/app_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildThemeModeCard(context, ref, settings.themeMode),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildThemePresetCard(
                  context,
                  ref,
                  settings.themePresetId,
                ),
              ),
            ],
          ),
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
                'Offline Mode',
                'Work offline when possible',
                Icons.cloud_off_outlined,
                settings.offlineMode,
                (value) => ref
                    .read(appSettingsProvider.notifier)
                    .setOfflineMode(value),
              ),
            ],
          ),
          _buildSection(
            context,
            'AI Features',
            [
              _buildSettingsTile(
                context,
                'AI API Key Setup',
                'Configure your Claude API key',
                Icons.vpn_key_outlined,
                () => context.push(RouteConstants.apiKeySetup),
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
                'Export or delete your data',
                Icons.storage_outlined,
                () => context.push(RouteConstants.dataManagement),
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
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildThemeModeCard(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
  ) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Mode',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how Kinesa adapts to light and dark environments.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 16),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.auto_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setThemeMode(value.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemePresetCard(
    BuildContext context,
    WidgetRef ref,
    String selectedPresetId,
  ) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Preset',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a color story that fits your mood.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ThemePresets.all
                  .map((preset) => _ThemePresetTile(
                        preset: preset,
                        isSelected: preset.id == selectedPresetId,
                        onTap: () => ref
                            .read(appSettingsProvider.notifier)
                            .setThemePreset(preset),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primary),
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
    final primary = Theme.of(context).colorScheme.primary;
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: primary,
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

class _ThemePresetTile extends StatelessWidget {
  const _ThemePresetTile({
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  final ThemePreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final borderColor =
        isSelected ? preset.seedColor : outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ColorDot(color: preset.seedColor),
                const SizedBox(width: 6),
                _ColorDot(color: preset.accentColor),
                const Spacer(),
                if (isSelected)
                  Icon(Icons.check_circle, color: preset.seedColor, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              preset.name,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
