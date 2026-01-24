import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/challenge_consent_model.dart';
import '../../data/repositories/challenge_gdpr_repository.dart';

/// GDPR-compliant consent dialog for challenge participation
/// Implements Art. 7 requirements for freely given, specific, informed consent
class ChallengeConsentDialog extends ConsumerStatefulWidget {
  final String userId;
  final ChallengeConsent? existingConsent;
  final VoidCallback? onConsentGranted;
  final VoidCallback? onConsentDenied;

  const ChallengeConsentDialog({
    super.key,
    required this.userId,
    this.existingConsent,
    this.onConsentGranted,
    this.onConsentDenied,
  });

  /// Show the consent dialog
  static Future<bool> show({
    required BuildContext context,
    required String userId,
    ChallengeConsent? existingConsent,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChallengeConsentDialog(
        userId: userId,
        existingConsent: existingConsent,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<ChallengeConsentDialog> createState() =>
      _ChallengeConsentDialogState();
}

class _ChallengeConsentDialogState
    extends ConsumerState<ChallengeConsentDialog> {
  bool _participationConsent = false;
  bool _activitySharingConsent = false;
  bool _rankingsConsent = false;
  bool _notificationsConsent = false;
  bool _healthDisclaimerAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate with existing consents if available
    if (widget.existingConsent != null) {
      final consent = widget.existingConsent!;
      _participationConsent =
          consent.hasConsent(ConsentType.challengeParticipation);
      _activitySharingConsent =
          consent.hasConsent(ConsentType.activityDataSharing);
      _rankingsConsent = consent.hasConsent(ConsentType.publicRankings);
      _notificationsConsent =
          consent.hasConsent(ConsentType.challengeNotifications);
      _healthDisclaimerAccepted =
          consent.hasConsent(ConsentType.healthDisclaimer);
    }
  }

  bool get _canProceed =>
      _participationConsent && _healthDisclaimerAccepted && !_isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Challenge Privacy Settings',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Your data, your choice',
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
              const SizedBox(height: 24),

              // Scrollable consent options
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info text
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'You can change these settings anytime from your profile. We only collect data necessary for the features you enable.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Required consents
                      Text(
                        'Required',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),

                      _ConsentTile(
                        title: 'Challenge Participation',
                        description:
                            'Allow the app to store your challenge progress, including workout completions, steps, and achievements within challenges.',
                        isRequired: true,
                        value: _participationConsent,
                        onChanged: (v) =>
                            setState(() => _participationConsent = v ?? false),
                      ),

                      _ConsentTile(
                        title: 'Health & Fitness Disclaimer',
                        description:
                            'I understand that challenges involve physical activity and I will consult a healthcare provider if I have concerns. Kinesa does not provide medical advice.',
                        isRequired: true,
                        value: _healthDisclaimerAccepted,
                        onChanged: (v) =>
                            setState(() => _healthDisclaimerAccepted = v ?? false),
                      ),

                      const SizedBox(height: 20),

                      // Optional consents
                      Text(
                        'Optional',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),

                      _ConsentTile(
                        title: 'Activity Sharing',
                        description:
                            'Share your activity with other challenge participants. Your name and progress will appear in the activity feed.',
                        value: _activitySharingConsent,
                        onChanged: (v) =>
                            setState(() => _activitySharingConsent = v ?? false),
                      ),

                      _ConsentTile(
                        title: 'Public Leaderboards',
                        description:
                            'Appear in challenge rankings visible to other participants. You can still participate privately without this.',
                        value: _rankingsConsent,
                        onChanged: (v) =>
                            setState(() => _rankingsConsent = v ?? false),
                      ),

                      _ConsentTile(
                        title: 'Challenge Notifications',
                        description:
                            'Receive reminders, milestone alerts, and encouragement from other participants.',
                        value: _notificationsConsent,
                        onChanged: (v) =>
                            setState(() => _notificationsConsent = v ?? false),
                      ),

                      const SizedBox(height: 16),

                      // Privacy policy link
                      RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                          children: [
                            const TextSpan(text: 'By continuing, you agree to our '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _openPrivacyPolicy,
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _openTerms,
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            widget.onConsentDenied?.call();
                            Navigator.of(context).pop(false);
                          },
                    child: const Text('Not Now'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _canProceed ? _saveConsent : null,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveConsent() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(challengeGDPRRepositoryProvider);
      final builder = ChallengeConsentBuilder();

      // Required consents
      if (_participationConsent) {
        builder.grant(ConsentType.challengeParticipation);
      }
      if (_healthDisclaimerAccepted) {
        builder.grant(ConsentType.healthDisclaimer);
      }

      // Optional consents
      if (_activitySharingConsent) {
        builder.grant(ConsentType.activityDataSharing);
      } else {
        builder.revoke(ConsentType.activityDataSharing);
      }

      if (_rankingsConsent) {
        builder.grant(ConsentType.publicRankings);
      } else {
        builder.revoke(ConsentType.publicRankings);
      }

      if (_notificationsConsent) {
        builder.grant(ConsentType.challengeNotifications);
      } else {
        builder.revoke(ConsentType.challengeNotifications);
      }

      await repository.recordConsent(
        userId: widget.userId,
        consents: builder.build(),
        isInitialConsent: widget.existingConsent == null,
      );

      widget.onConsentGranted?.call();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save preferences: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openPrivacyPolicy() {
    launchUrl(Uri.parse('https://kinesa.app/privacy'));
  }

  void _openTerms() {
    launchUrl(Uri.parse('https://kinesa.app/terms'));
  }
}

/// Individual consent toggle tile
class _ConsentTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isRequired;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _ConsentTile({
    required this.title,
    required this.description,
    this.isRequired = false,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: value
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
            color: value
                ? colorScheme.primaryContainer.withValues(alpha: 0.1)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: onChanged,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (isRequired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Required',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: colorScheme.onErrorContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
