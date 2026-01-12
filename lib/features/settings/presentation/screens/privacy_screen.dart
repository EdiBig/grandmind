import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/privacy_settings_provider.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final privacyAsync = ref.watch(privacySettingsProvider);
    final operations = ref.read(privacySettingsOperationsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy'),
      ),
      body: privacyAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Control how your data is shared and used.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 16),
              _buildSection(
                context,
                'Visibility',
                [
                  _buildSwitchTile(
                    context,
                    'Profile visibility',
                    'Allow others to view your public profile',
                    Icons.visibility_outlined,
                    settings.profileVisible,
                    (value) => operations.updateSetting('profileVisible', value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Share progress',
                    'Show progress summaries on your profile',
                    Icons.insights_outlined,
                    settings.shareProgress,
                    (value) => operations.updateSetting('shareProgress', value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Share achievements',
                    'Display achievements to friends',
                    Icons.emoji_events_outlined,
                    settings.shareAchievements,
                    (value) => operations.updateSetting('shareAchievements', value),
                  ),
                ],
              ),
              _buildSection(
                context,
                'Personalization',
                [
                  _buildSwitchTile(
                    context,
                    'Personalized recommendations',
                    'Use your activity to tailor workouts and tips',
                    Icons.auto_awesome_outlined,
                    settings.allowPersonalization,
                    (value) =>
                        operations.updateSetting('allowPersonalization', value),
                  ),
                  _buildSwitchTile(
                    context,
                    'Usage data',
                    'Help improve Kinesa with anonymous usage insights',
                    Icons.bar_chart_outlined,
                    settings.allowUsageData,
                    (value) => operations.updateSetting('allowUsageData', value),
                  ),
                ],
              ),
              _buildSection(
                context,
                'Diagnostics',
                [
                  _buildSwitchTile(
                    context,
                    'Crash reports',
                    'Share crash logs to improve stability',
                    Icons.bug_report_outlined,
                    settings.allowCrashReports,
                    (value) =>
                        operations.updateSetting('allowCrashReports', value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Changes are saved automatically.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Unable to load privacy settings.'),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
          ),
        ),
        ...children,
        const SizedBox(height: 8),
      ],
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
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeThumbColor: primary,
    );
  }
}
