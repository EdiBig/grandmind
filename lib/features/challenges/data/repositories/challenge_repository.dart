import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../models/challenge_participant_model.dart';

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository();
});

class ChallengeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _challengesCollection = 'challenges';
  static const String _participantsCollection = 'challengeParticipants';

  Stream<List<ChallengeModel>> getChallengesStream({
    bool activeOnly = true,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(_challengesCollection);
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  Stream<List<ChallengeParticipantModel>> getUserChallengesStream(String userId) {
    return _firestore
        .collection(_participantsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChallengeParticipantModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<ChallengeParticipantModel>> getChallengeParticipantsStream(
    String challengeId,
  ) {
    return _firestore
        .collection(_participantsCollection)
        .where('challengeId', isEqualTo: challengeId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ChallengeParticipantModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<ChallengeModel?> getChallenge(String challengeId) async {
    final doc = await _firestore
        .collection(_challengesCollection)
        .doc(challengeId)
        .get();
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return ChallengeModel.fromFirestore(doc.data()!, doc.id);
  }

  Stream<ChallengeModel?> getChallengeStream(String challengeId) {
    return _firestore
        .collection(_challengesCollection)
        .doc(challengeId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }
      return ChallengeModel.fromFirestore(doc.data()!, doc.id);
    });
  }

  Future<String> createChallenge(ChallengeModel challenge) async {
    final docRef =
        await _firestore.collection(_challengesCollection).add(challenge.toFirestore());
    return docRef.id;
  }

  Future<ChallengeParticipantModel?> getParticipant({
    required String challengeId,
    required String userId,
  }) async {
    final snapshot = await _firestore
        .collection(_participantsCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      return null;
    }
    final doc = snapshot.docs.first;
    return ChallengeParticipantModel.fromFirestore(doc.data(), doc.id);
  }

  Future<void> joinChallenge({
    required String challengeId,
    required String userId,
    required String displayName,
    required bool optInRankings,
    required bool optInActivityFeed,
    required bool healthDisclaimerAccepted,
    required bool dataSharingConsent,
  }) async {
    final existing =
        await getParticipant(challengeId: challengeId, userId: userId);
    if (existing != null && existing.leftAt == null) {
      return;
    }

    final data = {
      'challengeId': challengeId,
      'userId': userId,
      'joinedAt': FieldValue.serverTimestamp(),
      'leftAt': null,
      'currentProgress': 0,
      'lastActivityAt': null,
      'optInRankings': optInRankings,
      'optInActivityFeed': optInActivityFeed,
      'displayName': displayName,
      'healthDisclaimerAccepted': healthDisclaimerAccepted,
      'dataSharingConsent': dataSharingConsent,
    };

    await _firestore.runTransaction((transaction) async {
      final challengeRef =
          _firestore.collection(_challengesCollection).doc(challengeId);
      final participantsRef =
          _firestore.collection(_participantsCollection).doc();
      transaction.set(participantsRef, data);
      transaction.update(challengeRef, {
        'participantCount': FieldValue.increment(1),
      });
    });
  }

  Future<void> leaveChallenge({
    required String challengeId,
    required String userId,
  }) async {
    final participant =
        await getParticipant(challengeId: challengeId, userId: userId);
    if (participant == null || participant.leftAt != null) {
      return;
    }

    await _firestore.runTransaction((transaction) async {
      final challengeRef =
          _firestore.collection(_challengesCollection).doc(challengeId);
      final participantRef =
          _firestore.collection(_participantsCollection).doc(participant.id);
      transaction.update(participantRef, {
        'leftAt': FieldValue.serverTimestamp(),
      });
      transaction.update(challengeRef, {
        'participantCount': FieldValue.increment(-1),
      });
    });
  }
}
