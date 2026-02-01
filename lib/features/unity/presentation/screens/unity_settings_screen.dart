import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';

/// Unity settings screen for privacy, notifications, and data management
class UnitySettingsScreen extends ConsumerWidget {
  const UnitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(unitySettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity Settings'),
      ),
      body: settingsAsync.when(
        data: (settings) => _buildContent(context, ref, settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UnitySettings settings,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy settings section
          _buildSectionHeader(context, 'Privacy', Icons.lock_outline),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Profile Visible to Circles'),
                  subtitle: const Text(
                    'Allow circle members to see your profile',
                  ),
                  value: settings.profileVisibleToCircles,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'profileVisibleToCircles',
                          value,
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Share Workouts in Feed'),
                  subtitle: const Text(
                    'Automatically share workout activity',
                  ),
                  value: settings.shareWorkoutsInFeed,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'shareWorkoutsInFeed',
                          value,
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Show Progress in Rankings'),
                  subtitle: const Text(
                    'Display your progress on leaderboards',
                  ),
                  value: settings.shareProgressInRankings,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'shareProgressInRankings',
                          value,
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Allow Cheers from Non-Friends'),
                  subtitle: const Text(
                    'Receive encouragement from anyone',
                  ),
                  value: settings.allowCheersFromNonFriends,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'allowCheersFromNonFriends',
                          value,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notification settings section
          _buildSectionHeader(context, 'Notifications', Icons.notifications_outlined),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Challenge Notifications'),
                  subtitle: const Text(
                    'Updates about your challenges',
                  ),
                  value: settings.receiveChallengeNotifications,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'receiveChallengeNotifications',
                          value,
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Cheer Notifications'),
                  subtitle: const Text(
                    'When someone sends you encouragement',
                  ),
                  value: settings.receiveCheerNotifications,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'receiveCheerNotifications',
                          value,
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Milestone Notifications'),
                  subtitle: const Text(
                    'When you reach milestones',
                  ),
                  value: settings.receiveMilestoneNotifications,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'receiveMilestoneNotifications',
                          value,
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Circle Activity Notifications'),
                  subtitle: const Text(
                    'Updates from your circles',
                  ),
                  value: settings.receiveCircleActivityNotifications,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'receiveCircleActivityNotifications',
                          value,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Invites section
          _buildSectionHeader(context, 'Invites', Icons.mail_outline),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Allow Circle Invites'),
                  subtitle: const Text(
                    'Receive invitations to join circles',
                  ),
                  value: settings.allowCircleInvites,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'allowCircleInvites',
                          value,
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Allow Challenge Invites'),
                  subtitle: const Text(
                    'Receive invitations to join challenges',
                  ),
                  value: settings.allowChallengeInvites,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'allowChallengeInvites',
                          value,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Default participation settings
          _buildSectionHeader(context, 'Default Participation', Icons.tune),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Default Whisper Mode'),
                  subtitle: const Text(
                    'Start new challenges anonymously',
                  ),
                  value: settings.defaultWhisperMode,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'defaultWhisperMode',
                          value,
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Default Show in Rankings'),
                  subtitle: const Text(
                    'Show progress on leaderboards by default',
                  ),
                  value: settings.defaultShowInRankings,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'defaultShowInRankings',
                          value,
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Default Share in Feed'),
                  subtitle: const Text(
                    'Share activity in feed by default',
                  ),
                  value: settings.defaultShareInFeed,
                  onChanged: (value) {
                    ref.read(updateSettingsProvider.notifier).updateSetting(
                          'defaultShareInFeed',
                          value,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Blocked users section
          _buildSectionHeader(context, 'Blocked Users', Icons.block),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text('${settings.blockedUsers.length} blocked users'),
              subtitle: const Text('Manage blocked users'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showBlockedUsersSheet(context, ref, settings),
            ),
          ),
          const SizedBox(height: 24),

          // Data management section
          _buildSectionHeader(context, 'Data Management', Icons.storage_outlined),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Export My Data'),
                  subtitle: const Text('Download your Unity data'),
                  onTap: () => _showExportDataDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.delete_forever_outlined,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Delete Unity Data',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: const Text(
                    'Permanently delete all Unity data',
                  ),
                  onTap: () => _showDeleteDataDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showBlockedUsersSheet(
    BuildContext context,
    WidgetRef ref,
    UnitySettings settings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.25,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Blocked Users',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: settings.blockedUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.block,
                                size: 48,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No blocked users',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: settings.blockedUsers.length,
                          itemBuilder: (context, index) {
                            final userId = settings.blockedUsers[index];
                            return ListTile(
                              title: Text('User $userId'),
                              trailing: TextButton(
                                onPressed: () {
                                  ref
                                      .read(updateSettingsProvider.notifier)
                                      .unblockUser(userId);
                                },
                                child: const Text('Unblock'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExportDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Data'),
          content: const Text(
            'Your Unity data will be exported as a JSON file. This includes your challenges, circles, and activity history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data export started. You will receive an email when ready.'),
                  ),
                );
              },
              child: const Text('Export'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Unity Data'),
          content: const Text(
            'Are you sure you want to permanently delete all your Unity data? This action cannot be undone.\n\nThis will delete:\n- All challenge participations\n- All circle memberships\n- All posts and comments\n- Your Unity settings',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Implement data deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your Unity data will be deleted within 24 hours.'),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
