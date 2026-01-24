import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/theme_presets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/config/admin_config.dart';
import '../../../authentication/presentation/providers/auth_provider.dart';
import '../../../home/presentation/providers/dashboard_provider.dart';
import '../../../health/presentation/providers/health_providers.dart';
import '../../../notifications/domain/models/notification_preference.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../user/data/services/firestore_service.dart';
import '../../../user/data/models/user_model.dart';
import '../providers/app_settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String _privacyPolicyUrl =
      'https://grandmind-kinesa.web.app/privacy.html';
  static const String _deleteAccountUrl =
      'https://grandmind-kinesa.web.app/delete-account.html';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final userAsync = ref.watch(currentUserProvider);
    final healthPermissionsAsync = ref.watch(healthPermissionsProvider);
    final isAdmin = ref.watch(isAdminProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Profile',
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildProfileCard(context, userAsync),
              ),
              const SizedBox(height: 8),
              _buildSettingsTile(
                context,
                'Fitness Profile',
                'Goal, level, workout preferences',
                Icons.fitness_center,
                () => context.push(RouteConstants.fitnessProfile),
              ),
            ],
          ),
          _buildSection(
            context,
            'Active Modules',
            [
              _buildSwitchTile(
                context,
                'Workouts',
                'Enable workout tracking and plans',
                Icons.fitness_center,
                settings.workoutsEnabled,
                (value) => ref
                    .read(appSettingsProvider.notifier)
                    .setModuleEnabled(AppModule.workouts, value),
              ),
              _buildSwitchTile(
                context,
                'Habits',
                'Enable habit check-ins and streaks',
                Icons.check_circle_outline,
                settings.habitsEnabled,
                (value) => ref
                    .read(appSettingsProvider.notifier)
                    .setModuleEnabled(AppModule.habits, value),
              ),
              _buildSwitchTile(
                context,
                'Mood & Energy',
                'Enable energy check-ins and insights',
                Icons.bolt_outlined,
                settings.moodEnergyEnabled,
                (value) => ref
                    .read(appSettingsProvider.notifier)
                    .setModuleEnabled(AppModule.moodEnergy, value),
              ),
              _buildSwitchTile(
                context,
                'Nutrition',
                'Enable meal logging and insights',
                Icons.restaurant_menu_outlined,
                settings.nutritionEnabled,
                (value) => ref
                    .read(appSettingsProvider.notifier)
                    .setModuleEnabled(AppModule.nutrition, value),
              ),
              _buildSwitchTile(
                context,
                'Sleep',
                'Enable sleep metrics and reminders',
                Icons.bedtime_outlined,
                settings.sleepEnabled,
                (value) => ref
                    .read(appSettingsProvider.notifier)
                    .setModuleEnabled(AppModule.sleep, value),
              ),
            ],
          ),
          _buildSection(
            context,
            'Preferences',
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildToneAndUnits(context, ref, userAsync),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildLanguageCard(context, ref, settings.language),
              ),
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
            'Notifications',
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildNotificationPreferences(context, ref),
              ),
              _buildSettingsTile(
                context,
                'All Notification Settings',
                'Manage additional reminders',
                Icons.notifications_outlined,
                () => context.push(RouteConstants.notifications),
              ),
              _buildSettingsTile(
                context,
                'Weekly Summary',
                'View your week in review',
                Icons.insights_outlined,
                () => context.push(RouteConstants.weeklySummary),
              ),
            ],
          ),
          _buildSection(
            context,
            'Integrations',
            [
              _buildSettingsTile(
                context,
                'Health Sync',
                _integrationStatusText(healthPermissionsAsync),
                Icons.favorite_outline,
                () => context.push(RouteConstants.healthSync),
                trailing: _buildStatusPill(context, healthPermissionsAsync),
              ),
              _buildSettingsTile(
                context,
                'Apple Health',
                _integrationStatusText(healthPermissionsAsync),
                Icons.health_and_safety_outlined,
                () => context.push(RouteConstants.healthSync),
                trailing: _buildStatusPill(context, healthPermissionsAsync),
              ),
              _buildSettingsTile(
                context,
                'Google Fit',
                _integrationStatusText(healthPermissionsAsync),
                Icons.health_and_safety_outlined,
                () => context.push(RouteConstants.healthSync),
                trailing: _buildStatusPill(context, healthPermissionsAsync),
              ),
            ],
          ),
          _buildSection(
            context,
            'Subscription',
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildSubscriptionCard(context, userAsync),
              ),
            ],
          ),
          _buildSection(
            context,
            'Data & Privacy',
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
                'Delete Account',
                'Request account and data deletion',
                Icons.delete_outline,
                () => _launchDeleteAccount(context),
              ),
              _buildSettingsTile(
                context,
                'Data Management',
                'Export or delete your data',
                Icons.storage_outlined,
                () => context.push(RouteConstants.dataManagement),
              ),
              _buildSettingsTile(
                context,
                'Restart Setup Wizard',
                'Go through initial setup again',
                Icons.restart_alt,
                () => _showRestartOnboardingDialog(context, ref),
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
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
                'Contact Support',
                'support@grandpoint.uk',
                Icons.mail_outline,
                () => _launchSupportEmail(context),
              ),
              _buildSettingsTile(
                context,
                'Community Guidelines',
                'Rules for Unity challenges',
                Icons.rule_outlined,
                () => context.push(RouteConstants.communityGuidelines),
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
                'Read our privacy policy (web)',
                Icons.policy_outlined,
                () => _launchPrivacyPolicy(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildAppVersionCard(),
              ),
            ],
          ),
          // Admin Tools - only visible to admin users
          if (isAdmin)
            _buildSection(
              context,
              'Admin Tools',
              [
                _buildSettingsTile(
                  context,
                  'Exercise Library Sync',
                  'Manage wger sync and Algolia search',
                  Icons.admin_panel_settings,
                  () => context.push(RouteConstants.workoutAdmin),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: Icon(Icons.logout, color: AppColors.error),
              label: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppColors.error),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    AsyncValue<UserModel?> userAsync,
  ) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    return userAsync.when(
      loading: () => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(radius: 24, child: Icon(Icons.person_outline)),
              SizedBox(width: 12),
              Expanded(child: LinearProgressIndicator()),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: outline),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(radius: 24, child: Icon(Icons.person_outline)),
              SizedBox(width: 12),
              Expanded(child: Text('Unable to load profile')),
            ],
          ),
        ),
      ),
      data: (user) {
        final displayName =
            user?.displayName?.trim().isNotEmpty == true
                ? user!.displayName!
                : _fallbackNameFromEmail(user?.email);
        final email = user?.email ?? 'Sign in to personalize your profile';
        final initials = _initialsFromName(displayName);
        final photoUrl = user?.photoUrl;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? Text(
                          initials,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: user == null
                      ? null
                      : () => context.push(RouteConstants.editProfile),
                  icon: Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToneAndUnits(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UserModel?> userAsync,
  ) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final user = userAsync.asData?.value;
    final toneValue =
        (user?.onboarding?['coachTone'] as String?)?.toLowerCase();
    final selectedTone = toneValue == 'clinical' ? 'Clinical' : 'Coach';
    final units =
        (user?.preferences?['units'] as String?)?.trim().isNotEmpty == true
            ? user!.preferences!['units'] as String
            : 'Metric';

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
              'Tone',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Coach', label: Text('Coach')),
                ButtonSegment(value: 'Clinical', label: Text('Clinical')),
              ],
              selected: {selectedTone},
              onSelectionChanged: (value) => _updateUserPreference(
                context,
                ref,
                userAsync,
                {
                  'onboarding.coachTone':
                      value.first == 'Clinical' ? 'clinical' : 'friendly',
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Units',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Metric', label: Text('Metric')),
                ButtonSegment(value: 'Imperial', label: Text('Imperial')),
              ],
              selected: {units},
              onSelectionChanged: (value) => _updateUserPreference(
                context,
                ref,
                userAsync,
                {'preferences.units': value.first},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context,
    WidgetRef ref,
    String language,
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
              'Language',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: language,
              items: const [
                DropdownMenuItem(
                  value: 'English (UK)',
                  child: Text('English (UK)'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                ref.read(appSettingsProvider.notifier).setLanguage(value);
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationPreferences(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(watchNotificationPreferencesProvider);
    final configs = [
      const _NotificationToggleConfig(
        title: 'Daily Energy Check-in',
        subtitle: 'Quick mood & energy prompt',
        type: ReminderType.custom,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        daysLabel: 'Every day',
        hour: 8,
        minute: 0,
        message: 'How is your energy today?',
      ),
      const _NotificationToggleConfig(
        title: 'Weekly Summary',
        subtitle: 'Weekly progress and insights',
        type: ReminderType.custom,
        daysOfWeek: [7],
        daysLabel: 'Sun',
        hour: 19,
        minute: 0,
        message: 'Your weekly summary is ready.',
      ),
      const _NotificationToggleConfig(
        title: 'Workout Reminders',
        subtitle: 'Stay consistent with workouts',
        type: ReminderType.workout,
        daysOfWeek: [1, 3, 5],
        daysLabel: 'Mon, Wed, Fri',
        hour: 18,
        minute: 0,
        message: 'Your scheduled workout is starting soon.',
      ),
      const _NotificationToggleConfig(
        title: 'Habit Reminders',
        subtitle: 'Keep habit streaks alive',
        type: ReminderType.habit,
        daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
        daysLabel: 'Every day',
        hour: 20,
        minute: 0,
        message: 'Time to check in on your habits.',
      ),
    ];

    return preferencesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Text(
        'Unable to load notification preferences.',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
      ),
      data: (preferences) {
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
              children: [
                for (int index = 0; index < configs.length; index++) ...[
                  _buildNotificationRow(
                    context,
                    ref,
                    configs[index],
                    _findNotificationPreference(preferences, configs[index]),
                  ),
                  if (index != configs.length - 1)
                    Divider(height: 24),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationRow(
    BuildContext context,
    WidgetRef ref,
    _NotificationToggleConfig config,
    NotificationPreference? preference,
  ) {
    final operations = ref.read(notificationOperationsProvider);
    final enabled = preference?.enabled ?? false;
    final timeLabel = preference != null
        ? _formatTime(context, preference.hour, preference.minute)
        : _formatTime(context, config.hour, config.minute);
    final daysLabel = preference?.daysString ?? config.daysLabel;

    Future<void> ensurePreferenceEnabled() async {
      if (preference == null) {
        if (operations.userId == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please sign in to enable reminders.')),
            );
          }
          return;
        }
        final newPreference = NotificationPreference(
          id: '',
          userId: operations.userId!,
          type: config.type,
          enabled: true,
          title: config.title,
          message: config.message,
          daysOfWeek: config.daysOfWeek,
          hour: config.hour,
          minute: config.minute,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await operations.createPreference(newPreference);
      } else if (!preference.enabled) {
        await operations.togglePreference(preference.id, true);
      }
    }

    Future<void> updateTime(TimeOfDay time) async {
      if (preference == null) {
        await ensurePreferenceEnabled();
        return;
      }
      await operations.updatePreference(
        preference.copyWith(
          hour: time.hour,
          minute: time.minute,
          enabled: true,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: enabled,
              onChanged: (value) async {
                if (value) {
                  await ensurePreferenceEnabled();
                } else if (preference != null) {
                  await operations.togglePreference(preference.id, false);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              daysLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey,
                  ),
            ),
            const Spacer(),
            if (enabled)
              TextButton.icon(
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: preference?.hour ?? config.hour,
                      minute: preference?.minute ?? config.minute,
                    ),
                  );
                  if (selectedTime == null) return;
                  await updateTime(selectedTime);
                },
                icon: Icon(Icons.schedule, size: 18),
                label: Text(timeLabel),
              ),
          ],
        ),
      ],
    );
  }

  NotificationPreference? _findNotificationPreference(
    List<NotificationPreference> preferences,
    _NotificationToggleConfig config,
  ) {
    for (final preference in preferences) {
      if (preference.type == config.type && preference.title == config.title) {
        return preference;
      }
    }
    return null;
  }

  String _formatTime(BuildContext context, int hour, int minute) {
    return TimeOfDay(hour: hour, minute: minute).format(context);
  }

  Widget _buildSubscriptionCard(
    BuildContext context,
    AsyncValue<UserModel?> userAsync,
  ) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    final user = userAsync.asData?.value;
    final planValue = (user?.preferences?['plan'] ??
            user?.preferences?['subscription'] ??
            'Free')
        .toString();
    final isPremium = planValue.toLowerCase().contains('premium');
    final planTitle = isPremium ? 'Premium Plan' : 'Free Plan';
    final planSubtitle = isPremium
        ? 'Thanks for supporting Kinesa.'
        : 'Unlock personalized programs, insights, and more.';
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
              planTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              planSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey,
                  ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: _launchSubscription,
                child: Text(isPremium ? 'Manage Subscription' : 'Upgrade to Premium'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(
    BuildContext context,
    AsyncValue<bool> permissionsAsync,
  ) {
    final isConnected = permissionsAsync.asData?.value ?? false;
    final label = isConnected ? 'Connected' : 'Not Connected';
    final color = isConnected ? AppColors.success : AppColors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  String _integrationStatusText(AsyncValue<bool> permissionsAsync) {
    final isConnected = permissionsAsync.asData?.value ?? false;
    return isConnected ? 'Connected' : 'Not connected';
  }

  Widget _buildAppVersionCard() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final info = snapshot.data;
        final versionLabel = info == null
            ? 'Loading version...'
            : 'Version ${info.version} (${info.buildNumber})';
        return Card(
          elevation: 0,
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: const Text('App Version'),
            subtitle: Text(versionLabel),
          ),
        );
      },
    );
  }

  Future<void> _updateUserPreference(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<UserModel?> userAsync,
    Map<String, dynamic> updates,
  ) async {
    final userId = userAsync.asData?.value?.id;
    if (userId == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to update preferences.')),
      );
      return;
    }
    try {
      await ref.read(firestoreServiceProvider).updateUser(userId, updates);
      ref.invalidate(currentUserProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update preferences right now.')),
      );
    }
  }

  Future<void> _launchSupportEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@grandpoint.uk',
      queryParameters: {'subject': 'Kinesa Support'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open email client.')),
      );
    }
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    await _openExternalUrl(
      context,
      Uri.parse(_privacyPolicyUrl),
      fallback: () => context.push(RouteConstants.privacyPolicy),
    );
  }

  Future<void> _launchDeleteAccount(BuildContext context) async {
    await _openExternalUrl(
      context,
      Uri.parse(_deleteAccountUrl),
      fallbackMessage: 'Unable to open delete account page.',
    );
  }

  Future<void> _openExternalUrl(
    BuildContext context,
    Uri uri, {
    VoidCallback? fallback,
    String fallbackMessage = 'Unable to open link.',
  }) async {
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (launched) return;
      final inAppLaunched =
          await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (inAppLaunched) return;
      fallback?.call();
    } catch (_) {
      fallback?.call();
    }
    if (context.mounted && fallback == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fallbackMessage)),
      );
    }
  }

  Future<void> _launchSubscription() async {
    final uri = Uri.parse('https://kinesa.app/upgrade');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _fallbackNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'Guest';
    final parts = email.split('@');
    if (parts.isEmpty || parts.first.isEmpty) return 'Guest';
    return parts.first;
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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
                    color: AppColors.grey,
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
                    color: AppColors.grey,
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
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primary),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? Icon(Icons.chevron_right),
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
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestartOnboardingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Setup Wizard'),
        content: const Text(
          'This will take you through the initial setup again to update your fitness goals, level, and preferences. Your data will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final userAsync = ref.read(currentUserProvider);
              final userId = userAsync.asData?.value?.id;
              if (userId == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unable to restart setup. Please try again.')),
                  );
                }
                return;
              }
              try {
                await ref.read(firestoreServiceProvider).updateUser(userId, {
                  'hasCompletedOnboarding': false,
                });
                ref.invalidate(currentUserProvider);
                if (context.mounted) {
                  context.go(RouteConstants.onboarding);
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Unable to restart setup. Please try again.')),
                  );
                }
              }
            },
            child: Text(
              'Restart Setup',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
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
    final borderColor = isSelected ? preset.seedColor : outline;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 100,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with gradient background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [preset.seedColor, preset.accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                preset.icon,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              preset.name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (preset.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                preset.description,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.grey,
                      fontSize: 10,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle, color: preset.seedColor, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}


class _NotificationToggleConfig {
  final String title;
  final String subtitle;
  final ReminderType type;
  final List<int> daysOfWeek;
  final String daysLabel;
  final int hour;
  final int minute;
  final String message;

  const _NotificationToggleConfig({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.daysOfWeek,
    required this.daysLabel,
    required this.hour,
    required this.minute,
    required this.message,
  });
}
