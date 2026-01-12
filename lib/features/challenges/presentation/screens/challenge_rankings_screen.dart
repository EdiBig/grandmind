import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/challenge_participant_model.dart';
import '../providers/challenge_providers.dart';

class ChallengeRankingsScreen extends ConsumerWidget {
  const ChallengeRankingsScreen({super.key, required this.challengeId});

  final String challengeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participantsAsync =
        ref.watch(challengeParticipantsProvider(challengeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
      ),
      body: participantsAsync.when(
        data: (participants) => _buildList(context, participants),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Unable to load rankings: $error'),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<ChallengeParticipantModel> participants,
  ) {
    final ranked = participants.toList()
      ..sort((a, b) => b.currentProgress.compareTo(a.currentProgress));

    if (ranked.isEmpty) {
      return const Center(
        child: Text('No rankings yet.'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: ranked.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final participant = ranked[index];
        final rank = index + 1;
        return ListTile(
          leading: CircleAvatar(
            child: Text(rank.toString()),
          ),
          title: Text(participant.displayName.isEmpty
              ? 'Anonymous'
              : participant.displayName),
          subtitle: Text('${participant.currentProgress} progress'),
        );
      },
    );
  }
}
