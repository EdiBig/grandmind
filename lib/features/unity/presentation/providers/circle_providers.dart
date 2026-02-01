import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

/// Circle repository provider
final circleRepositoryProvider = Provider<CircleRepository>((ref) {
  return CircleRepository();
});

/// User's circles
final userCirclesProvider = StreamProvider<List<Circle>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repo = ref.watch(circleRepositoryProvider);
  return repo.getUserCirclesStream(userId);
});

/// Circle by ID
final circleByIdProvider =
    StreamProvider.family<Circle?, String>((ref, circleId) {
  final repo = ref.watch(circleRepositoryProvider);
  return repo.getCircleStream(circleId);
});

/// Circle members
final circleMembersProvider =
    StreamProvider.family<List<CircleMember>, String>((ref, circleId) {
  final repo = ref.watch(circleRepositoryProvider);
  return repo.getMembersStream(circleId);
});

/// Check if user is circle member
final isCircleMemberProvider =
    FutureProvider.family<bool, String>((ref, circleId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return false;

  final repo = ref.watch(circleRepositoryProvider);
  return repo.isMember(circleId, userId);
});

/// Get current user's membership in a circle
final userCircleMembershipProvider =
    FutureProvider.family<CircleMember?, String>((ref, circleId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return null;

  final repo = ref.watch(circleRepositoryProvider);
  return repo.getMember(circleId, userId);
});

/// Discover public circles
final discoverCirclesProvider = StreamProvider<List<Circle>>((ref) {
  final repo = ref.watch(circleRepositoryProvider);
  return repo.discoverCirclesStream();
});

/// Circle by invite code
final circleByInviteCodeProvider =
    FutureProvider.family<Circle?, String>((ref, inviteCode) async {
  final repo = ref.watch(circleRepositoryProvider);
  return repo.getCircleByInviteCode(inviteCode);
});

/// Pending circle invites for user
final pendingCircleInvitesProvider = StreamProvider<List<CircleInvite>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repo = ref.watch(circleRepositoryProvider);
  return repo.getPendingInvitesStream(userId);
});

/// Create circle notifier
class CreateCircleNotifier extends StateNotifier<AsyncValue<String?>> {
  CreateCircleNotifier(this._circleRepo) : super(const AsyncValue.data(null));

  final CircleRepository _circleRepo;

  Future<void> createCircle({
    required String name,
    String? description,
    String? avatarUrl,
    required CircleType type,
    CircleVisibility visibility = CircleVisibility.private,
    String? theme,
    List<String> tags = const [],
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      final userName = FirebaseAuth.instance.currentUser?.displayName;
      final userAvatar = FirebaseAuth.instance.currentUser?.photoURL;

      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final circle = Circle(
        id: '',
        name: name,
        description: description,
        avatarUrl: avatarUrl,
        type: type,
        visibility: visibility,
        memberCount: 1,
        createdBy: userId,
        admins: [userId],
        theme: theme,
        tags: tags,
      );

      final creator = CircleMember(
        userId: userId,
        circleId: '',
        displayName: userName ?? userEmail?.split('@').first ?? 'User',
        avatarUrl: userAvatar,
        role: CircleMemberRole.owner,
        joinedAt: DateTime.now(),
      );

      final circleId = await _circleRepo.createCircle(circle, creator);
      state = AsyncValue.data(circleId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final createCircleProvider =
    StateNotifierProvider<CreateCircleNotifier, AsyncValue<String?>>((ref) {
  final circleRepo = ref.watch(circleRepositoryProvider);
  return CreateCircleNotifier(circleRepo);
});

/// Join circle notifier
class JoinCircleNotifier extends StateNotifier<AsyncValue<void>> {
  JoinCircleNotifier(this._circleRepo) : super(const AsyncValue.data(null));

  final CircleRepository _circleRepo;

  Future<void> joinCircle({
    required String circleId,
    String? invitedBy,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.displayName;
      final userAvatar = FirebaseAuth.instance.currentUser?.photoURL;
      final userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      // Check if already a member
      final isMember = await _circleRepo.isMember(circleId, userId);
      if (isMember) {
        state = AsyncValue.error(
            'Already a member of this circle', StackTrace.current);
        return;
      }

      final member = CircleMember(
        userId: userId,
        circleId: circleId,
        displayName: userName ?? userEmail?.split('@').first ?? 'User',
        avatarUrl: userAvatar,
        role: CircleMemberRole.member,
        joinedAt: DateTime.now(),
        invitedBy: invitedBy,
      );

      await _circleRepo.addMember(circleId, member);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> joinByInviteCode(String inviteCode) async {
    state = const AsyncValue.loading();

    try {
      final circle = await _circleRepo.getCircleByInviteCode(inviteCode);
      if (circle == null) {
        state =
            AsyncValue.error('Invalid invite code', StackTrace.current);
        return;
      }

      await joinCircle(circleId: circle.id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final joinCircleProvider =
    StateNotifierProvider<JoinCircleNotifier, AsyncValue<void>>((ref) {
  final circleRepo = ref.watch(circleRepositoryProvider);
  return JoinCircleNotifier(circleRepo);
});

/// Leave circle notifier
class LeaveCircleNotifier extends StateNotifier<AsyncValue<void>> {
  LeaveCircleNotifier(this._circleRepo) : super(const AsyncValue.data(null));

  final CircleRepository _circleRepo;

  Future<void> leaveCircle(String circleId) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      // Check if user is the owner
      final circle = await _circleRepo.getCircle(circleId);
      if (circle != null && circle.createdBy == userId) {
        state = AsyncValue.error(
          'Circle owner cannot leave. Transfer ownership or delete the circle.',
          StackTrace.current,
        );
        return;
      }

      await _circleRepo.removeMember(circleId, userId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final leaveCircleProvider =
    StateNotifierProvider<LeaveCircleNotifier, AsyncValue<void>>((ref) {
  final circleRepo = ref.watch(circleRepositoryProvider);
  return LeaveCircleNotifier(circleRepo);
});

/// Invite to circle notifier
class InviteToCircleNotifier extends StateNotifier<AsyncValue<void>> {
  InviteToCircleNotifier(this._circleRepo) : super(const AsyncValue.data(null));

  final CircleRepository _circleRepo;

  Future<void> inviteMember({
    required String circleId,
    required String invitedUserId,
    String? message,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final invite = CircleInvite(
        id: '',
        circleId: circleId,
        invitedUserId: invitedUserId,
        invitedBy: userId,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        message: message,
      );

      await _circleRepo.createInvite(invite);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final inviteToCircleProvider =
    StateNotifierProvider<InviteToCircleNotifier, AsyncValue<void>>((ref) {
  final circleRepo = ref.watch(circleRepositoryProvider);
  return InviteToCircleNotifier(circleRepo);
});

/// Respond to invite notifier
class RespondToInviteNotifier extends StateNotifier<AsyncValue<void>> {
  RespondToInviteNotifier(this._circleRepo) : super(const AsyncValue.data(null));

  final CircleRepository _circleRepo;

  Future<void> acceptInvite(CircleInvite invite) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.displayName;
      final userAvatar = FirebaseAuth.instance.currentUser?.photoURL;
      final userEmail = FirebaseAuth.instance.currentUser?.email;

      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final member = CircleMember(
        userId: userId,
        circleId: invite.circleId,
        displayName: userName ?? userEmail?.split('@').first ?? 'User',
        avatarUrl: userAvatar,
        role: CircleMemberRole.member,
        joinedAt: DateTime.now(),
        invitedBy: invite.invitedBy,
      );

      await _circleRepo.acceptInvite(invite.id, member);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> declineInvite(String inviteId) async {
    state = const AsyncValue.loading();

    try {
      await _circleRepo.declineInvite(inviteId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final respondToInviteProvider =
    StateNotifierProvider<RespondToInviteNotifier, AsyncValue<void>>((ref) {
  final circleRepo = ref.watch(circleRepositoryProvider);
  return RespondToInviteNotifier(circleRepo);
});

/// Generate invite code notifier
class GenerateInviteCodeNotifier extends StateNotifier<AsyncValue<String?>> {
  GenerateInviteCodeNotifier(this._circleRepo)
      : super(const AsyncValue.data(null));

  final CircleRepository _circleRepo;

  Future<void> generateCode(String circleId) async {
    state = const AsyncValue.loading();

    try {
      final code = await _circleRepo.generateInviteCode(circleId);
      state = AsyncValue.data(code);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final generateInviteCodeProvider =
    StateNotifierProvider<GenerateInviteCodeNotifier, AsyncValue<String?>>(
        (ref) {
  final circleRepo = ref.watch(circleRepositoryProvider);
  return GenerateInviteCodeNotifier(circleRepo);
});
