import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/challenge_invitation_model.dart';
import '../../data/services/challenge_invitation_service.dart';

/// Provider for pending invitations for the current user
final pendingInvitationsProvider =
    StreamProvider<List<ChallengeInvitation>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  final service = ref.watch(challengeInvitationServiceProvider);
  return service.getPendingInvitations(userId);
});

/// Provider for pending invitation count
final pendingInvitationCountProvider = Provider<int>((ref) {
  final invitations = ref.watch(pendingInvitationsProvider);
  return invitations.maybeWhen(
    data: (list) => list.length,
    orElse: () => 0,
  );
});

/// Provider for invite links for a specific challenge
final challengeInviteLinksProvider =
    FutureProvider.family<List<ChallengeInviteLink>, String>(
  (ref, challengeId) async {
    final service = ref.watch(challengeInvitationServiceProvider);
    return service.getInviteLinks(challengeId);
  },
);

/// Notifier for managing invitations
class InvitationNotifier extends StateNotifier<AsyncValue<void>> {
  final ChallengeInvitationService _service;

  InvitationNotifier(this._service) : super(const AsyncValue.data(null));

  /// Send an invitation
  Future<ChallengeInvitation?> sendInvitation({
    required String challengeId,
    required String inviterId,
    required String inviterName,
    required String inviteeId,
    String? message,
  }) async {
    state = const AsyncValue.loading();
    try {
      final invitation = await _service.sendInvitation(
        challengeId: challengeId,
        inviterId: inviterId,
        inviterName: inviterName,
        inviteeId: inviteeId,
        message: message,
        expiresIn: const Duration(days: 7),
      );
      state = const AsyncValue.data(null);
      return invitation;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Accept an invitation
  Future<bool> acceptInvitation({
    required String invitationId,
    required String userId,
    required String displayName,
    required bool optInRankings,
    required bool optInActivityFeed,
    required bool healthDisclaimerAccepted,
    required bool dataSharingConsent,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.acceptInvitation(
        invitationId: invitationId,
        userId: userId,
        displayName: displayName,
        optInRankings: optInRankings,
        optInActivityFeed: optInActivityFeed,
        healthDisclaimerAccepted: healthDisclaimerAccepted,
        dataSharingConsent: dataSharingConsent,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Decline an invitation
  Future<bool> declineInvitation({
    required String invitationId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.declineInvitation(
        invitationId: invitationId,
        userId: userId,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Create an invite link
  Future<ChallengeInviteLink?> createInviteLink({
    required String challengeId,
    required String creatorId,
    int? maxUses,
  }) async {
    state = const AsyncValue.loading();
    try {
      final link = await _service.createInviteLink(
        challengeId: challengeId,
        creatorId: creatorId,
        expiresIn: const Duration(days: 7),
        maxUses: maxUses,
      );
      state = const AsyncValue.data(null);
      return link;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Join via invite code
  Future<bool> joinViaInviteCode({
    required String inviteCode,
    required String userId,
    required String displayName,
    required bool optInRankings,
    required bool optInActivityFeed,
    required bool healthDisclaimerAccepted,
    required bool dataSharingConsent,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _service.joinViaInviteLink(
        inviteCode: inviteCode,
        userId: userId,
        displayName: displayName,
        optInRankings: optInRankings,
        optInActivityFeed: optInActivityFeed,
        healthDisclaimerAccepted: healthDisclaimerAccepted,
        dataSharingConsent: dataSharingConsent,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  /// Deactivate an invite link
  Future<void> deactivateLink(String linkId) async {
    try {
      await _service.deactivateInviteLink(linkId);
    } catch (e) {
      // Handle silently or log
    }
  }
}

final invitationNotifierProvider =
    StateNotifierProvider<InvitationNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(challengeInvitationServiceProvider);
  return InvitationNotifier(service);
});
