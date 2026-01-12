import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/challenge_participant_model.dart';
import '../../data/repositories/challenge_repository.dart';

final challengesProvider = StreamProvider<List<ChallengeModel>>((ref) {
  final repo = ref.watch(challengeRepositoryProvider);
  return repo.getChallengesStream(activeOnly: true);
});

final userChallengeParticipantsProvider =
    StreamProvider<List<ChallengeParticipantModel>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }
  final repo = ref.watch(challengeRepositoryProvider);
  return repo.getUserChallengesStream(userId);
});

final challengeParticipantsProvider =
    StreamProvider.family<List<ChallengeParticipantModel>, String>(
  (ref, challengeId) {
    final repo = ref.watch(challengeRepositoryProvider);
    return repo.getChallengeParticipantsStream(challengeId);
  },
);
