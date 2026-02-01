import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

/// Join challenge screen with 3-step flow:
/// Step 1: Choose tier (Gentle/Steady/Intense)
/// Step 2: Privacy settings (Whisper mode, rankings, feed)
/// Step 3: Health & Safety acknowledgment
class JoinChallengeScreen extends ConsumerStatefulWidget {
  const JoinChallengeScreen({
    super.key,
    required this.challengeId,
  });

  final String challengeId;

  @override
  ConsumerState<JoinChallengeScreen> createState() =>
      _JoinChallengeScreenState();
}

class _JoinChallengeScreenState extends ConsumerState<JoinChallengeScreen> {
  int _currentStep = 0;
  DifficultyTier _selectedTier = DifficultyTier.steady;
  bool _whisperMode = false;
  bool _showInRankings = true;
  bool _shareInFeed = true;
  bool _healthDisclaimerAccepted = false;
  bool _dataConsentGiven = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final challengeAsync = ref.watch(challengeByIdProvider(widget.challengeId));
    final joinState = ref.watch(joinChallengeProvider);

    // Listen for join success
    ref.listen<AsyncValue<String?>>(joinChallengeProvider, (previous, next) {
      next.whenData((participationId) {
        if (participationId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Successfully joined the challenge!')),
          );
          context.pop();
        }
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Challenge'),
      ),
      body: challengeAsync.when(
        data: (challenge) {
          if (challenge == null) {
            return const Center(child: Text('Challenge not found'));
          }
          return _buildContent(context, challenge);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: challengeAsync.maybeWhen(
        data: (challenge) {
          if (challenge == null) return null;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: joinState.isLoading
                          ? null
                          : () => _handleNext(challenge),
                      child: joinState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _currentStep == 2 ? 'Join Challenge' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _buildContent(BuildContext context, Challenge challenge) {
    return Column(
      children: [
        // Stepper indicator
        _buildStepIndicator(context),
        const SizedBox(height: 16),

        // Step content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStepContent(context, challenge),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final steps = ['Tier', 'Privacy', 'Consent'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: stepIndex < _currentStep
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.3),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= _currentStep;
          final isComplete = stepIndex < _currentStep;

          return Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
            ),
            child: Center(
              child: isComplete
                  ? Icon(Icons.check, size: 18, color: theme.colorScheme.onPrimary)
                  : Text(
                      '${stepIndex + 1}',
                      style: TextStyle(
                        color: isActive
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, Challenge challenge) {
    switch (_currentStep) {
      case 0:
        return _buildTierStep(context, challenge);
      case 1:
        return _buildPrivacyStep(context);
      case 2:
        return _buildConsentStep(context, challenge);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTierStep(BuildContext context, Challenge challenge) {
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('tier'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Your Tier',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Same achievement, your pace. All tiers complete the challenge equally.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 24),

        // Tier selection cards
        if (challenge.tiers != null) ...[
          TierSelectionCard(
            tier: DifficultyTier.gentle,
            tierConfig: challenge.tiers!.gentle,
            isSelected: _selectedTier == DifficultyTier.gentle,
            onTap: () => setState(() => _selectedTier = DifficultyTier.gentle),
          ),
          const SizedBox(height: 12),
          TierSelectionCard(
            tier: DifficultyTier.steady,
            tierConfig: challenge.tiers!.steady,
            isSelected: _selectedTier == DifficultyTier.steady,
            onTap: () => setState(() => _selectedTier = DifficultyTier.steady),
          ),
          const SizedBox(height: 12),
          TierSelectionCard(
            tier: DifficultyTier.intense,
            tierConfig: challenge.tiers!.intense,
            isSelected: _selectedTier == DifficultyTier.intense,
            onTap: () => setState(() => _selectedTier = DifficultyTier.intense),
          ),
        ] else ...[
          // Default tiers if not defined
          for (final tier in DifficultyTier.values) ...[
            TierSelectionCard(
              tier: tier,
              tierConfig: null,
              isSelected: _selectedTier == tier,
              onTap: () => setState(() => _selectedTier = tier),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }

  Widget _buildPrivacyStep(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('privacy'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Control how others see your participation.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 24),

        // Whisper mode
        Card(
          child: SwitchListTile(
            title: const Text('Whisper Mode'),
            subtitle: const Text(
              'Hide your identity from other participants. Your progress will be anonymous.',
            ),
            value: _whisperMode,
            onChanged: (value) => setState(() => _whisperMode = value),
            secondary: const Icon(Icons.visibility_off_outlined),
          ),
        ),
        const SizedBox(height: 12),

        // Show in rankings
        Card(
          child: SwitchListTile(
            title: const Text('Show in Rankings'),
            subtitle: const Text(
              'Allow your progress to appear in challenge leaderboards.',
            ),
            value: _showInRankings,
            onChanged: (value) => setState(() => _showInRankings = value),
            secondary: const Icon(Icons.leaderboard_outlined),
          ),
        ),
        const SizedBox(height: 12),

        // Share in feed
        Card(
          child: SwitchListTile(
            title: const Text('Share Activity in Feed'),
            subtitle: const Text(
              'Automatically share your workout activity in the challenge feed.',
            ),
            value: _shareInFeed,
            onChanged: (value) => setState(() => _shareInFeed = value),
            secondary: const Icon(Icons.dynamic_feed_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildConsentStep(BuildContext context, Challenge challenge) {
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('consent'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health & Safety',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please review and accept the following before joining.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: 24),

        // Health disclaimer
        Card(
          child: CheckboxListTile(
            title: const Text('Health Disclaimer'),
            subtitle: const Text(
              'I understand that this challenge is for fitness purposes only and is not medical advice. I will consult a healthcare provider if I have any health concerns.',
            ),
            value: _healthDisclaimerAccepted,
            onChanged: (value) =>
                setState(() => _healthDisclaimerAccepted = value ?? false),
          ),
        ),
        const SizedBox(height: 12),

        // Data consent
        Card(
          child: CheckboxListTile(
            title: const Text('Data Sharing Consent'),
            subtitle: const Text(
              'I consent to sharing my progress data with challenge participants according to my privacy settings.',
            ),
            value: _dataConsentGiven,
            onChanged: (value) =>
                setState(() => _dataConsentGiven = value ?? false),
          ),
        ),
        const SizedBox(height: 24),

        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Summary',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Challenge', challenge.name),
              _buildSummaryRow('Tier', _selectedTier.displayName),
              _buildSummaryRow('Whisper Mode', _whisperMode ? 'On' : 'Off'),
              _buildSummaryRow('Show in Rankings', _showInRankings ? 'Yes' : 'No'),
              _buildSummaryRow('Share in Feed', _shareInFeed ? 'Yes' : 'No'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _handleNext(Challenge challenge) {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Validate consents
      if (!_healthDisclaimerAccepted || !_dataConsentGiven) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept all required agreements to continue.'),
          ),
        );
        return;
      }

      // Join the challenge
      ref.read(joinChallengeProvider.notifier).joinChallenge(
            challengeId: widget.challengeId,
            tier: _selectedTier,
            whisperMode: _whisperMode,
            showInRankings: _showInRankings,
            shareInFeed: _shareInFeed,
          );
    }
  }
}
