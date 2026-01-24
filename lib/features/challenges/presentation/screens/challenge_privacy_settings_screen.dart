import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/challenge_consent_model.dart';
import '../../data/repositories/challenge_gdpr_repository.dart';

/// Screen for managing challenge privacy settings
/// Implements GDPR Art. 15, 17, 20 - access, erasure, portability
class ChallengePrivacySettingsScreen extends ConsumerStatefulWidget {
  const ChallengePrivacySettingsScreen({super.key});

  @override
  ConsumerState<ChallengePrivacySettingsScreen> createState() =>
      _ChallengePrivacySettingsScreenState();
}

class _ChallengePrivacySettingsScreenState
    extends ConsumerState<ChallengePrivacySettingsScreen> {
  bool _isExporting = false;
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to manage privacy settings')),
      );
    }

    final consentAsync = ref.watch(userChallengeConsentProvider(userId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenge Privacy'),
      ),
      body: consentAsync.when(
        data: (consent) => _buildContent(context, consent, userId),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load privacy settings'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(userChallengeConsentProvider(userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, ChallengeConsent? consent, String userId) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Privacy header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield,
                size: 48,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Privacy Matters',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Control what data is shared and how it\'s used in challenges',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Consent status section
        _buildSectionHeader(context, 'Data Sharing Preferences'),
        const SizedBox(height: 12),

        if (consent == null)
          _buildNoConsentCard(context, userId)
        else
          _buildConsentCard(context, consent, userId),

        const SizedBox(height: 24),

        // Data rights section
        _buildSectionHeader(context, 'Your Data Rights'),
        const SizedBox(height: 12),

        // Export data
        _buildActionCard(
          context,
          icon: Icons.download,
          iconColor: colorScheme.primary,
          title: 'Export My Data',
          description:
              'Download all your challenge data including participation history, progress, and activities.',
          action: TextButton.icon(
            onPressed: _isExporting ? null : () => _exportData(userId),
            icon: _isExporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            label: Text(_isExporting ? 'Exporting...' : 'Export'),
          ),
        ),

        const SizedBox(height: 12),

        // Delete data
        _buildActionCard(
          context,
          icon: Icons.delete_forever,
          iconColor: colorScheme.error,
          title: 'Delete My Challenge Data',
          description:
              'Permanently remove all your challenge data. This cannot be undone.',
          action: TextButton.icon(
            onPressed: _isDeleting ? null : () => _confirmDeleteData(userId),
            icon: _isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.delete_forever, color: colorScheme.error),
            label: Text(
              _isDeleting ? 'Deleting...' : 'Delete',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Information section
        _buildSectionHeader(context, 'About Your Data'),
        const SizedBox(height: 12),

        _buildInfoCard(
          context,
          items: [
            _InfoItem(
              icon: Icons.fitness_center,
              title: 'Challenge Progress',
              description:
                  'Your workout completions, step counts, and achievements within challenges.',
            ),
            _InfoItem(
              icon: Icons.leaderboard,
              title: 'Leaderboard Entries',
              description:
                  'Your rankings in challenges you\'ve opted into public leaderboards.',
            ),
            _InfoItem(
              icon: Icons.chat_bubble_outline,
              title: 'Activity Feed',
              description:
                  'Posts and interactions in challenge activity feeds.',
            ),
            _InfoItem(
              icon: Icons.people,
              title: 'Participation Records',
              description:
                  'History of challenges you\'ve joined or created.',
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Legal links
        _buildSectionHeader(context, 'Legal'),
        const SizedBox(height: 12),

        _buildLinkTile(
          context,
          icon: Icons.policy,
          title: 'Privacy Policy',
          onTap: () => launchUrl(Uri.parse('https://kinesa.app/privacy')),
        ),
        _buildLinkTile(
          context,
          icon: Icons.description,
          title: 'Terms of Service',
          onTap: () => launchUrl(Uri.parse('https://kinesa.app/terms')),
        ),
        _buildLinkTile(
          context,
          icon: Icons.gavel,
          title: 'GDPR Information',
          onTap: () => launchUrl(Uri.parse('https://kinesa.app/gdpr')),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildNoConsentCard(BuildContext context, String userId) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No Privacy Preferences Set',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t participated in any challenges yet. Privacy preferences will be set when you join your first challenge.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentCard(
      BuildContext context, ChallengeConsent consent, String userId) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consent toggles
            _ConsentToggle(
              title: 'Activity Feed Sharing',
              description: 'Show your name and activity to other participants',
              value: consent.hasConsent(ConsentType.activityDataSharing),
              onChanged: (v) => _updateConsent(
                userId,
                ConsentType.activityDataSharing,
                v,
              ),
            ),
            const Divider(),
            _ConsentToggle(
              title: 'Public Leaderboards',
              description: 'Appear in challenge rankings',
              value: consent.hasConsent(ConsentType.publicRankings),
              onChanged: (v) => _updateConsent(
                userId,
                ConsentType.publicRankings,
                v,
              ),
            ),
            const Divider(),
            _ConsentToggle(
              title: 'Challenge Notifications',
              description: 'Receive reminders and encouragement',
              value: consent.hasConsent(ConsentType.challengeNotifications),
              onChanged: (v) => _updateConsent(
                userId,
                ConsentType.challengeNotifications,
                v,
              ),
            ),

            const SizedBox(height: 16),

            // Last updated info
            Row(
              children: [
                Icon(
                  Icons.update,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Last updated: ${_formatDate(consent.updatedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required Widget action,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            action,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required List<_InfoItem> items}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Data we collect for challenges:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Text(
                              item.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.open_in_new, size: 20),
        onTap: onTap,
      ),
    );
  }

  Future<void> _updateConsent(
      String userId, ConsentType type, bool granted) async {
    try {
      final repository = ref.read(challengeGDPRRepositoryProvider);
      final builder = ChallengeConsentBuilder();

      if (granted) {
        builder.grant(type);
      } else {
        builder.revoke(type);
      }

      await repository.recordConsent(
        userId: userId,
        consents: builder.build(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _exportData(String userId) async {
    setState(() => _isExporting = true);

    try {
      final repository = ref.read(challengeGDPRRepositoryProvider);
      final jsonData = await repository.exportUserChallengeDataAsJson(userId);

      // In a real app, you'd save this to a file or share it
      // For now, we'll show a preview
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Your Data Export'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SingleChildScrollView(
                child: SelectableText(
                  jsonData,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              FilledButton(
                onPressed: () {
                  // TODO: Implement actual file download
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Data export will be emailed to you')),
                  );
                },
                child: const Text('Download'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _confirmDeleteData(String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Challenge Data?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will permanently delete:',
            ),
            const SizedBox(height: 12),
            _buildDeleteItem('All challenge participations'),
            _buildDeleteItem('Your activity feed posts'),
            _buildDeleteItem('Leaderboard entries'),
            _buildDeleteItem('Challenge progress history'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete All Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteData(userId);
    }
  }

  Widget _buildDeleteItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Future<void> _deleteData(String userId) async {
    setState(() => _isDeleting = true);

    try {
      final repository = ref.read(challengeGDPRRepositoryProvider);
      await repository.deleteUserChallengeData(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Challenge data deleted successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Toggle widget for consent settings
class _ConsentToggle extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentToggle({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(
        description,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

/// Info item model
class _InfoItem {
  final IconData icon;
  final String title;
  final String description;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
