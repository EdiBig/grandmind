import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge_invitation_model.dart';
import '../models/challenge_model.dart';
import '../repositories/challenge_repository.dart';
import '../repositories/challenge_gdpr_repository.dart';
import 'challenge_notification_service.dart';

/// Service for managing challenge invitations
class ChallengeInvitationService {
  final FirebaseFirestore _firestore;
  final ChallengeRepository _challengeRepository;
  final ChallengeNotificationService _notificationService;

  ChallengeInvitationService({
    FirebaseFirestore? firestore,
    required ChallengeRepository challengeRepository,
    required ChallengeGDPRRepository gdprRepository, // Reserved for future consent checks
    required ChallengeNotificationService notificationService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _challengeRepository = challengeRepository,
        _notificationService = notificationService;

  static const String _invitationsCollection = 'challengeInvitations';
  static const String _inviteLinksCollection = 'challengeInviteLinks';

  // ============================================================
  // DIRECT INVITATIONS
  // ============================================================

  /// Send a direct invitation to a user
  Future<ChallengeInvitation> sendInvitation({
    required String challengeId,
    required String inviterId,
    required String inviterName,
    required String inviteeId,
    String? message,
    Duration? expiresIn,
  }) async {
    // Validate challenge exists and allows invites
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null) {
      throw Exception('Challenge not found');
    }

    if (!challenge.allowMemberInvites &&
        challenge.createdBy != inviterId) {
      throw Exception('This challenge does not allow member invites');
    }

    // Check if invitee is already a participant
    final existing = await _challengeRepository.getParticipant(
      challengeId: challengeId,
      userId: inviteeId,
    );
    if (existing != null && existing.leftAt == null) {
      throw Exception('User is already a participant');
    }

    // Check for existing pending invitation
    final pendingInvite = await _firestore
        .collection(_invitationsCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('inviteeId', isEqualTo: inviteeId)
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .limit(1)
        .get();

    if (pendingInvite.docs.isNotEmpty) {
      throw Exception('User already has a pending invitation');
    }

    // Create invitation
    final now = DateTime.now();
    final invitation = ChallengeInvitation(
      id: '',
      challengeId: challengeId,
      challengeName: challenge.name,
      inviteeId: inviteeId,
      inviterId: inviterId,
      inviterName: inviterName,
      type: InvitationType.direct,
      status: InvitationStatus.pending,
      createdAt: now,
      expiresAt: expiresIn != null ? now.add(expiresIn) : null,
      message: message,
    );

    final docRef = await _firestore
        .collection(_invitationsCollection)
        .add(invitation.toFirestore());

    // Send notification to invitee (if they have consent)
    await _notificationService.sendInvitationNotification(
      inviteeId: inviteeId,
      challengeId: challengeId,
      challengeName: challenge.name,
      inviterName: inviterName,
      invitationId: docRef.id,
    );

    return ChallengeInvitation(
      id: docRef.id,
      challengeId: invitation.challengeId,
      challengeName: invitation.challengeName,
      inviteeId: invitation.inviteeId,
      inviterId: invitation.inviterId,
      inviterName: invitation.inviterName,
      type: invitation.type,
      status: invitation.status,
      createdAt: invitation.createdAt,
      expiresAt: invitation.expiresAt,
      message: invitation.message,
    );
  }

  /// Accept an invitation
  Future<void> acceptInvitation({
    required String invitationId,
    required String userId,
    required String displayName,
    required bool optInRankings,
    required bool optInActivityFeed,
    required bool healthDisclaimerAccepted,
    required bool dataSharingConsent,
  }) async {
    final doc =
        await _firestore.collection(_invitationsCollection).doc(invitationId).get();

    if (!doc.exists) {
      throw Exception('Invitation not found');
    }

    final invitation = ChallengeInvitation.fromFirestore(doc.data()!, doc.id);

    if (invitation.inviteeId != userId) {
      throw Exception('This invitation is not for you');
    }

    if (!invitation.isValid) {
      throw Exception('This invitation is no longer valid');
    }

    // Join the challenge
    await _challengeRepository.joinChallenge(
      challengeId: invitation.challengeId,
      userId: userId,
      displayName: displayName,
      optInRankings: optInRankings,
      optInActivityFeed: optInActivityFeed,
      healthDisclaimerAccepted: healthDisclaimerAccepted,
      dataSharingConsent: dataSharingConsent,
    );

    // Update invitation status
    await _firestore.collection(_invitationsCollection).doc(invitationId).update({
      'status': InvitationStatus.accepted.name,
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // Notify inviter that their invitation was accepted
    await _notificationService.sendInvitationAcceptedNotification(
      userId: invitation.inviterId,
      challengeId: invitation.challengeId,
      challengeName: invitation.challengeName,
      acceptedByName: displayName,
    );
  }

  /// Decline an invitation
  Future<void> declineInvitation({
    required String invitationId,
    required String userId,
  }) async {
    final doc =
        await _firestore.collection(_invitationsCollection).doc(invitationId).get();

    if (!doc.exists) {
      throw Exception('Invitation not found');
    }

    final invitation = ChallengeInvitation.fromFirestore(doc.data()!, doc.id);

    if (invitation.inviteeId != userId) {
      throw Exception('This invitation is not for you');
    }

    await _firestore.collection(_invitationsCollection).doc(invitationId).update({
      'status': InvitationStatus.declined.name,
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get pending invitations for a user
  Stream<List<ChallengeInvitation>> getPendingInvitations(String userId) {
    return _firestore
        .collection(_invitationsCollection)
        .where('inviteeId', isEqualTo: userId)
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChallengeInvitation.fromFirestore(doc.data(), doc.id))
            .where((inv) => inv.isValid)
            .toList());
  }

  /// Get invitations sent by a user
  Future<List<ChallengeInvitation>> getSentInvitations(String userId) async {
    final snapshot = await _firestore
        .collection(_invitationsCollection)
        .where('inviterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => ChallengeInvitation.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // ============================================================
  // INVITE LINKS
  // ============================================================

  /// Create a shareable invite link
  Future<ChallengeInviteLink> createInviteLink({
    required String challengeId,
    required String creatorId,
    Duration? expiresIn,
    int? maxUses,
  }) async {
    // Validate challenge
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null) {
      throw Exception('Challenge not found');
    }

    if (!challenge.allowMemberInvites &&
        challenge.createdBy != creatorId) {
      throw Exception('This challenge does not allow member invites');
    }

    // Generate unique code
    final code = _generateInviteCode();

    final now = DateTime.now();
    final link = ChallengeInviteLink(
      id: '',
      challengeId: challengeId,
      creatorId: creatorId,
      code: code,
      createdAt: now,
      expiresAt: expiresIn != null ? now.add(expiresIn) : null,
      maxUses: maxUses,
    );

    final docRef =
        await _firestore.collection(_inviteLinksCollection).add(link.toFirestore());

    return ChallengeInviteLink(
      id: docRef.id,
      challengeId: link.challengeId,
      creatorId: link.creatorId,
      code: link.code,
      createdAt: link.createdAt,
      expiresAt: link.expiresAt,
      maxUses: link.maxUses,
    );
  }

  /// Join challenge via invite link
  Future<ChallengeModel> joinViaInviteLink({
    required String inviteCode,
    required String userId,
    required String displayName,
    required bool optInRankings,
    required bool optInActivityFeed,
    required bool healthDisclaimerAccepted,
    required bool dataSharingConsent,
  }) async {
    // Find invite link
    final snapshot = await _firestore
        .collection(_inviteLinksCollection)
        .where('code', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Invalid invite code');
    }

    final linkDoc = snapshot.docs.first;
    final link = ChallengeInviteLink.fromFirestore(linkDoc.data(), linkDoc.id);

    if (!link.isValid) {
      throw Exception('This invite link is no longer valid');
    }

    // Get challenge
    final challenge = await _challengeRepository.getChallenge(link.challengeId);
    if (challenge == null) {
      throw Exception('Challenge not found');
    }

    // Check if already a participant
    final existing = await _challengeRepository.getParticipant(
      challengeId: link.challengeId,
      userId: userId,
    );
    if (existing != null && existing.leftAt == null) {
      throw Exception('You are already a participant in this challenge');
    }

    // Join challenge
    await _challengeRepository.joinChallenge(
      challengeId: link.challengeId,
      userId: userId,
      displayName: displayName,
      optInRankings: optInRankings,
      optInActivityFeed: optInActivityFeed,
      healthDisclaimerAccepted: healthDisclaimerAccepted,
      dataSharingConsent: dataSharingConsent,
    );

    // Increment use count
    await _firestore.collection(_inviteLinksCollection).doc(linkDoc.id).update({
      'usedCount': FieldValue.increment(1),
    });

    // Record invitation for tracking
    final invitation = ChallengeInvitation(
      id: '',
      challengeId: link.challengeId,
      challengeName: challenge.name,
      inviteeId: userId,
      inviterId: link.creatorId,
      inviterName: 'Invite Link',
      type: InvitationType.link,
      status: InvitationStatus.accepted,
      createdAt: DateTime.now(),
      respondedAt: DateTime.now(),
      inviteCode: inviteCode,
    );

    await _firestore
        .collection(_invitationsCollection)
        .add(invitation.toFirestore());

    return challenge;
  }

  /// Get invite links for a challenge
  Future<List<ChallengeInviteLink>> getInviteLinks(String challengeId) async {
    final snapshot = await _firestore
        .collection(_inviteLinksCollection)
        .where('challengeId', isEqualTo: challengeId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChallengeInviteLink.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Deactivate an invite link
  Future<void> deactivateInviteLink(String linkId) async {
    await _firestore.collection(_inviteLinksCollection).doc(linkId).update({
      'isActive': false,
    });
  }

  /// Generate a unique invite code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  /// Expire old invitations (run periodically via Cloud Functions)
  Future<void> expireOldInvitations() async {
    final now = Timestamp.fromDate(DateTime.now());

    final expired = await _firestore
        .collection(_invitationsCollection)
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .where('expiresAt', isLessThan: now)
        .get();

    final batch = _firestore.batch();
    for (final doc in expired.docs) {
      batch.update(doc.reference, {
        'status': InvitationStatus.expired.name,
      });
    }
    await batch.commit();
  }
}

/// Provider for invitation service
final challengeInvitationServiceProvider =
    Provider<ChallengeInvitationService>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  final gdprRepository = ref.watch(challengeGDPRRepositoryProvider);
  final notificationService = ref.watch(challengeNotificationServiceProvider);

  return ChallengeInvitationService(
    challengeRepository: challengeRepository,
    gdprRepository: gdprRepository,
    notificationService: notificationService,
  );
});
