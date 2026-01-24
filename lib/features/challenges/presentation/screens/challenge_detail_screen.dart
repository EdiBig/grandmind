import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../../../home/presentation/providers/dashboard_provider.dart';
import '../../../../core/providers/shared_preferences_provider.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/challenge_participant_model.dart';
import '../../data/repositories/challenge_repository.dart';
import '../providers/challenge_providers.dart';
import '../../../../core/constants/route_constants.dart';

class ChallengeDetailScreen extends ConsumerStatefulWidget {
  const ChallengeDetailScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  ConsumerState<ChallengeDetailScreen> createState() =>
      _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends ConsumerState<ChallengeDetailScreen> {
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(challengeRepositoryProvider);
    final challengeStream = repo.getChallengeStream(widget.challengeId);
    final participantsAsync =
        ref.watch(challengeParticipantsProvider(widget.challengeId));
    final userParticipantsAsync = ref.watch(userChallengeParticipantsProvider);

    return StreamBuilder<ChallengeModel?>(
      stream: challengeStream,
      builder: (context, snapshot) {
        final challenge = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (challenge == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Challenge')),
            body: const Center(child: Text('Challenge not found.')),
          );
        }

        final participant = _currentParticipant(
          userParticipantsAsync.asData?.value ?? [],
          challenge.id,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(challenge.name),
            actions: [
              IconButton(
                onPressed: () => _shareChallenge(challenge),
                icon: Icon(Icons.share_outlined),
                tooltip: 'Share',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _buildHeader(context, challenge),
              const SizedBox(height: 16),
              _buildProgressMap(context, challenge, participant),
              const SizedBox(height: 16),
              _buildStats(context, challenge, participantsAsync, participant),
              const SizedBox(height: 16),
              _buildOverview(context, challenge, participant),
              const SizedBox(height: 16),
              _buildGuidanceLinks(context),
              const SizedBox(height: 24),
              _buildJoinSection(context, challenge, participant),
            ],
          ),
        );
      },
    );
  }

  ChallengeParticipantModel? _currentParticipant(
    List<ChallengeParticipantModel> participants,
    String challengeId,
  ) {
    for (final participant in participants) {
      if (participant.challengeId == challengeId && participant.leftAt == null) {
        return participant;
      }
    }
    return null;
  }

  Widget _buildHeader(BuildContext context, ChallengeModel challenge) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              challenge.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(context, challenge.type.name),
                _buildTag(
                  context,
                  '${challenge.goalTarget} ${challenge.goalUnit}',
                ),
                _buildTag(context, _daysRemainingLabel(challenge)),
                _buildTag(
                  context,
                  challenge.visibility == ChallengeVisibility.inviteOnly
                      ? 'Invite Only'
                      : challenge.visibility.name,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressMap(
    BuildContext context,
    ChallengeModel challenge,
    ChallengeParticipantModel? participant,
  ) {
    final progress = participant?.currentProgress ?? 0;
    final progressValue = challenge.goalTarget == 0
        ? 0.0
        : progress / challenge.goalTarget;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress map',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Milestones unlock as you move toward the goal.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressValue.clamp(0.0, 1.0),
            minHeight: 10,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 8),
          Text(
            '$progress / ${challenge.goalTarget} ${challenge.goalUnit}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    ChallengeModel challenge,
    AsyncValue<List<ChallengeParticipantModel>> participantsAsync,
    ChallengeParticipantModel? participant,
  ) {
    final participantCount = participantsAsync.asData?.value.length ??
        challenge.participantCount;
    final progress = participant?.currentProgress ?? 0;
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Participants',
            participantCount.toString(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Your progress',
            '$progress ${challenge.goalUnit}',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(
    BuildContext context,
    ChallengeModel challenge,
    ChallengeParticipantModel? participant,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          participant == null
              ? 'Join to track your progress with the community.'
              : 'You are in this challenge. Keep the momentum going.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTag(context, challenge.goalType.name),
            if (challenge.hasRankings) _buildTag(context, 'Rankings available'),
            if (challenge.hasActivityFeed) _buildTag(context, 'Activity feed'),
          ],
        ),
        const SizedBox(height: 12),
        _buildFeatureLinks(context, challenge),
      ],
    );
  }

  Widget _buildFeatureLinks(BuildContext context, ChallengeModel challenge) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (challenge.hasRankings)
          OutlinedButton.icon(
            onPressed: () => context.push(
              RouteConstants.challengeRankings
                  .replaceFirst(':id', challenge.id),
            ),
            icon: Icon(Icons.leaderboard_outlined),
            label: const Text('View Rankings'),
          ),
        if (challenge.hasActivityFeed)
          OutlinedButton.icon(
            onPressed: () => context.push(
              RouteConstants.challengeFeed.replaceFirst(':id', challenge.id),
            ),
            icon: const Icon(Icons.forum_outlined),
            label: const Text('Open Feed'),
          ),
      ],
    );
  }

  Widget _buildGuidanceLinks(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.push(RouteConstants.communityGuidelines),
          icon: const Icon(Icons.rule_outlined),
          label: const Text('Community Guidelines'),
        ),
        OutlinedButton.icon(
          onPressed: () => context.push(RouteConstants.privacy),
          icon: const Icon(Icons.privacy_tip_outlined),
          label: const Text('Privacy Policy'),
        ),
      ],
    );
  }

  Widget _buildJoinSection(
    BuildContext context,
    ChallengeModel challenge,
    ChallengeParticipantModel? participant,
  ) {
    if (participant != null) {
      return OutlinedButton.icon(
        onPressed: _isJoining ? null : () => _leaveChallenge(context, challenge),
        icon: const Icon(Icons.exit_to_app),
        label: Text(_isJoining ? 'Leaving...' : 'Leave Challenge'),
      );
    }

    return ElevatedButton.icon(
      onPressed: _isJoining ? null : () => _joinChallenge(context, challenge),
      icon: _isJoining
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.check_circle_outline),
      label: Text(_isJoining ? 'Joining...' : 'Join Challenge'),
    );
  }

  Future<void> _joinChallenge(
    BuildContext context,
    ChallengeModel challenge,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showMessage('Sign in to join challenges.');
      return;
    }

    final isEligible = await _confirmAgeEligibility();
    if (!context.mounted) return;
    if (!isEligible) {
      _showMessage('Age verification required before joining.');
      return;
    }

    final disclaimerAccepted = await _showHealthDisclaimer(context);
    if (!context.mounted) return;
    if (!disclaimerAccepted) {
      return;
    }

    final consent = await _showDataConsent(context);
    if (!context.mounted) return;
    if (consent == null) {
      return;
    }

    setState(() => _isJoining = true);
    try {
      final user = ref.read(currentUserProvider).asData?.value;
      await ref.read(challengeRepositoryProvider).joinChallenge(
            challengeId: challenge.id,
            userId: userId,
            displayName: user?.displayName ?? 'Anonymous',
            optInRankings: consent.optInRankings,
            optInActivityFeed: consent.optInActivityFeed,
            healthDisclaimerAccepted: true,
            dataSharingConsent: consent.dataSharingConsent,
          );
      if (!context.mounted) return;
      _showMessage('You have joined the challenge.');
    } catch (error) {
      if (!context.mounted) return;
      _showMessage('Unable to join. ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _leaveChallenge(
    BuildContext context,
    ChallengeModel challenge,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showMessage('Sign in to manage challenges.');
      return;
    }
    setState(() => _isJoining = true);
    try {
      await ref.read(challengeRepositoryProvider).leaveChallenge(
            challengeId: challenge.id,
            userId: userId,
          );
      if (!context.mounted) return;
      _showMessage('You have left the challenge.');
    } catch (error) {
      if (!context.mounted) return;
      _showMessage('Unable to leave. ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<bool> _confirmAgeEligibility() async {
    final user = ref.read(currentUserProvider).asData?.value;
    final preferences = ref.read(sharedPreferencesProvider);
    final stored = preferences.getBool('unity_age_verified') ?? false;
    if (stored) {
      return true;
    }

    if (user?.dateOfBirth != null) {
      final age = _calculateAge(user!.dateOfBirth!);
      if (age < 16) {
        await _showAgeRestrictionDialog();
        return false;
      }
      preferences.setBool('unity_age_verified', true);
      return true;
    }

    final confirmed = await _showAgeConfirmDialog();
    if (confirmed) {
      preferences.setBool('unity_age_verified', true);
    }
    return confirmed;
  }

  Future<void> _showAgeRestrictionDialog() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Age verification required'),
        content: const Text(
          'You must be 16 or older to join challenges without parental consent.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showAgeConfirmDialog() async {
    bool confirmed = false;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Confirm your age'),
            content: Row(
              children: [
                Checkbox(
                  value: confirmed,
                  onChanged: (value) =>
                      setState(() => confirmed = value ?? false),
                ),
                const Expanded(
                  child: Text('I confirm that I am 16 or older.'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: confirmed ? () => Navigator.pop(context, true) : null,
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _showHealthDisclaimer(BuildContext context) async {
    bool agreeRisks = false;
    bool agreeConsult = false;
    bool agreeSafe = false;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Before you join'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consult your doctor before starting new exercise, '
                  'especially if you have medical conditions.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Stop if you experience pain, dizziness, or shortness of breath.',
                ),
                const SizedBox(height: 8),
                const Text(
                  'Challenges are for motivation, not medical advice.',
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: agreeRisks,
                  onChanged: (value) =>
                      setState(() => agreeRisks = value ?? false),
                  title: const Text('I understand the risks.'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: agreeConsult,
                  onChanged: (value) =>
                      setState(() => agreeConsult = value ?? false),
                  title: const Text(
                      'I have consulted or will consult a professional.'),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: agreeSafe,
                  onChanged: (value) =>
                      setState(() => agreeSafe = value ?? false),
                  title: const Text('I agree to exercise safely.'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: agreeRisks && agreeConsult && agreeSafe
                  ? () => Navigator.pop(context, true)
                  : null,
              child: const Text('I Agree'),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  Future<_ConsentSelection?> _showDataConsent(BuildContext context) async {
    bool optInRankings = true;
    bool optInFeed = true;
    bool consent = false;
    final result = await showDialog<_ConsentSelection>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Sharing preferences'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: optInRankings,
                onChanged: (value) => setState(() => optInRankings = value),
                title: const Text('Show my progress in rankings'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: optInFeed,
                onChanged: (value) => setState(() => optInFeed = value),
                title: const Text('Enable activity feed'),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: consent,
                onChanged: (value) => setState(() => consent = value ?? false),
                title: const Text('I consent to share my challenge data.'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: consent
                  ? () => Navigator.pop(
                        context,
                        _ConsentSelection(
                          optInRankings: optInRankings,
                          optInActivityFeed: optInFeed,
                          dataSharingConsent: consent,
                        ),
                      )
                  : null,
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
    return result;
  }

  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _shareChallenge(ChallengeModel challenge) async {
    final url = 'https://kinesa.app/challenge/${challenge.id}';
    final message = StringBuffer()
      ..writeln('Join this challenge on Kinesa: ${challenge.name}')
      ..writeln()
      ..writeln(url);
    await Share.share(
      message.toString(),
      subject: challenge.name,
    );
  }

  Widget _buildTag(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  String _daysRemainingLabel(ChallengeModel challenge) {
    final now = DateTime.now();
    final difference = challenge.endDate.difference(now);
    if (difference.inDays <= 0) {
      return 'Ends today';
    }
    return '${difference.inDays} days left';
  }
}

class _ConsentSelection {
  const _ConsentSelection({
    required this.optInRankings,
    required this.optInActivityFeed,
    required this.dataSharingConsent,
  });

  final bool optInRankings;
  final bool optInActivityFeed;
  final bool dataSharingConsent;
}
