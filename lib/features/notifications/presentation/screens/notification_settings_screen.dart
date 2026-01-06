import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/notification_preference.dart';
import '../providers/notification_providers.dart';
import 'create_reminder_screen.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(watchNotificationPreferencesProvider);
    final operations = ref.watch(notificationOperationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: preferencesAsync.when(
        data: (preferences) {
          if (preferences.isEmpty) {
            return _buildEmptyState(context, operations);
          }

          return _buildPreferencesList(context, ref, preferences, operations);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateReminderScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildPreferencesList(
    BuildContext context,
    WidgetRef ref,
    List<NotificationPreference> preferences,
    NotificationOperations operations,
  ) {
    // Group preferences by type
    final groupedPreferences = <ReminderType, List<NotificationPreference>>{};
    for (final pref in preferences) {
      groupedPreferences.putIfAbsent(pref.type, () => []).add(pref);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick actions card
        _buildQuickActionsCard(context, operations),
        const SizedBox(height: 24),

        // Grouped preferences
        ...groupedPreferences.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _getTypeLabel(entry.key),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                ),
              ),
              ...entry.value.map((pref) => _buildPreferenceCard(
                    context,
                    ref,
                    pref,
                    operations,
                  )),
              const SizedBox(height: 16),
            ],
          );
        }),

        const SizedBox(height: 80), // Space for FAB
      ],
    );
  }

  Widget _buildQuickActionsCard(
    BuildContext context,
    NotificationOperations operations,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bolt, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickActionChip(
                  context,
                  icon: Icons.fitness_center,
                  label: 'Workout',
                  onTap: () => operations.createDefaultWorkoutReminder(),
                ),
                _buildQuickActionChip(
                  context,
                  icon: Icons.water_drop,
                  label: 'Water',
                  onTap: () => operations.createDefaultWaterReminder(),
                ),
                _buildQuickActionChip(
                  context,
                  icon: Icons.bedtime,
                  label: 'Sleep',
                  onTap: () => operations.createDefaultSleepReminder(),
                ),
                _buildQuickActionChip(
                  context,
                  icon: Icons.self_improvement,
                  label: 'Meditation',
                  onTap: () => operations.createDefaultMeditationReminder(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => operations.sendTestNotification(),
              icon: const Icon(Icons.notifications_active),
              label: const Text('Send Test Notification'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: AppColors.primary),
    );
  }

  Widget _buildPreferenceCard(
    BuildContext context,
    WidgetRef ref,
    NotificationPreference preference,
    NotificationOperations operations,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: preference.enabled
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.grey.shade200,
          child: Icon(
            _getTypeIcon(preference.type),
            color: preference.enabled ? AppColors.primary : Colors.grey,
          ),
        ),
        title: Text(
          preference.title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: preference.enabled
                ? AppColors.textPrimaryLight
                : AppColors.textSecondaryLight,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${preference.timeString} • ${preference.daysString}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (preference.message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                preference.message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondaryLight,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: preference.enabled,
              onChanged: (value) async {
                await operations.togglePreference(preference.id, value);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        value
                            ? 'Reminder enabled'
                            : 'Reminder disabled',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              activeColor: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOptionsBottomSheet(
                context,
                preference,
                operations,
              ),
            ),
          ],
        ),
        isThreeLine: preference.message.isNotEmpty,
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    NotificationOperations operations,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'No Reminders Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Set up reminders to stay on track with your fitness goals. Never miss a workout, habit, or hydration break!',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateReminderScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => operations.sendTestNotification(),
              child: const Text('Send Test Notification'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error Loading Reminders',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(
    BuildContext context,
    NotificationPreference preference,
    NotificationOperations operations,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Reminder'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateReminderScreen(
                      editingPreference: preference,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Reminder', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Reminder'),
                    content: const Text(
                        'Are you sure you want to delete this reminder?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true && context.mounted) {
                  await operations.deletePreference(preference.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder deleted')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Notifications'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reminders help you stay consistent with your fitness goals.',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              Text('📱 Notification Types:'),
              SizedBox(height: 8),
              Text('• Workout Reminders - Never miss a training session'),
              Text('• Habit Reminders - Build consistent healthy habits'),
              Text('• Hydration Reminders - Stay hydrated throughout the day'),
              Text('• Meal Reminders - Maintain regular eating schedule'),
              Text('• Sleep Reminders - Get quality rest'),
              Text('• Meditation Reminders - Practice mindfulness'),
              SizedBox(height: 16),
              Text(
                '💡 Tips:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('• Set reminders for times when you\'re most likely to act'),
              Text('• Start with 1-2 reminders and add more gradually'),
              Text('• Adjust times to match your daily routine'),
              Text('• Use test notifications to check if they work'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.workout:
        return '💪 Workouts';
      case ReminderType.habit:
        return '✅ Habits';
      case ReminderType.water:
        return '💧 Hydration';
      case ReminderType.meal:
        return '🍽️ Meals';
      case ReminderType.sleep:
        return '😴 Sleep';
      case ReminderType.meditation:
        return '🧘 Meditation';
      case ReminderType.custom:
        return '🔔 Custom';
    }
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.workout:
        return Icons.fitness_center;
      case ReminderType.habit:
        return Icons.check_circle_outline;
      case ReminderType.water:
        return Icons.water_drop;
      case ReminderType.meal:
        return Icons.restaurant;
      case ReminderType.sleep:
        return Icons.bedtime;
      case ReminderType.meditation:
        return Icons.self_improvement;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }
}
