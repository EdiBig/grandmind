import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';
import 'feed_providers.dart';

/// Cheer repository provider
final cheerRepositoryProvider = Provider<CheerRepository>((ref) {
  return CheerRepository();
});

/// Received cheers stream
final receivedCheersProvider = StreamProvider<List<Cheer>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repo = ref.watch(cheerRepositoryProvider);
  return repo.getReceivedCheersStream(userId);
});

/// Sent cheers stream
final sentCheersProvider = StreamProvider<List<Cheer>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repo = ref.watch(cheerRepositoryProvider);
  return repo.getSentCheersStream(userId);
});

/// Unread cheers count
final unreadCheersCountProvider = StreamProvider<int>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value(0);

  final repo = ref.watch(cheerRepositoryProvider);
  return repo.getUnreadCheersCountStream(userId);
});

/// Unread cheers
final unreadCheersProvider = StreamProvider<List<Cheer>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repo = ref.watch(cheerRepositoryProvider);
  return repo.getUnreadCheersStream(userId);
});

/// Cheers for a specific post
final cheersForPostProvider =
    StreamProvider.family<List<Cheer>, String>((ref, postId) {
  final repo = ref.watch(cheerRepositoryProvider);
  return repo.getCheersForPostStream(postId);
});

/// Cheers for a specific activity
final cheersForActivityProvider =
    StreamProvider.family<List<Cheer>, String>((ref, activityId) {
  final repo = ref.watch(cheerRepositoryProvider);
  return repo.getCheersForActivityStream(activityId);
});

/// Cheers in a challenge
final challengeCheersProvider =
    StreamProvider.family<List<Cheer>, String>((ref, challengeId) {
  final repo = ref.watch(cheerRepositoryProvider);
  return repo.getChallengeCheersStream(challengeId);
});

/// Cheers in a circle
final circleCheersProvider =
    StreamProvider.family<List<Cheer>, String>((ref, circleId) {
  final repo = ref.watch(cheerRepositoryProvider);
  return repo.getCircleCheersStream(circleId);
});

/// User's cheer stats
final cheerStatsProvider = FutureProvider<CheerStats>((ref) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return const CheerStats();
  }

  final repo = ref.watch(cheerRepositoryProvider);
  return repo.getCheerStats(userId);
});

/// Check if user has cheered a post
final hasUserCheeredPostProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return false;

  final repo = ref.watch(cheerRepositoryProvider);
  return repo.hasUserCheeredPost(userId, postId);
});

/// Send cheer notifier
class SendCheerNotifier extends StateNotifier<AsyncValue<void>> {
  SendCheerNotifier(this._cheerRepo, this._feedRepo)
      : super(const AsyncValue.data(null));

  final CheerRepository _cheerRepo;
  final FeedRepository _feedRepo;

  Future<void> cheerPost({
    required String postId,
    required String receiverId,
    required CheerType type,
    String? circleId,
    String? challengeId,
    String? message,
    bool isAnonymous = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      // Check if already cheered
      final existing = await _cheerRepo.getUserCheerForPost(userId, postId);
      if (existing != null) {
        state = AsyncValue.error(
            'You have already cheered this post', StackTrace.current);
        return;
      }

      // Send the cheer
      await _cheerRepo.sendPostCheer(
        senderId: userId,
        receiverId: receiverId,
        type: type,
        postId: postId,
        circleId: circleId,
        challengeId: challengeId,
        message: message,
        isAnonymous: isAnonymous,
      );

      // Update post cheer count
      await _feedRepo.addCheerToPost(postId, type);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> cheerActivity({
    required String activityId,
    required String receiverId,
    required CheerType type,
    String? challengeId,
    String? message,
    bool isAnonymous = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _cheerRepo.sendActivityCheer(
        senderId: userId,
        receiverId: receiverId,
        type: type,
        activityId: activityId,
        challengeId: challengeId,
        message: message,
        isAnonymous: isAnonymous,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendEncouragement({
    required String receiverId,
    required CheerType type,
    String? circleId,
    String? challengeId,
    String? message,
    bool isAnonymous = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _cheerRepo.sendEncouragementCheer(
        senderId: userId,
        receiverId: receiverId,
        type: type,
        circleId: circleId,
        challengeId: challengeId,
        message: message,
        isAnonymous: isAnonymous,
      );

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final sendCheerProvider =
    StateNotifierProvider<SendCheerNotifier, AsyncValue<void>>((ref) {
  final cheerRepo = ref.watch(cheerRepositoryProvider);
  final feedRepo = ref.watch(feedRepositoryProvider);
  return SendCheerNotifier(cheerRepo, feedRepo);
});

/// Mark cheers as read notifier
class MarkCheersReadNotifier extends StateNotifier<AsyncValue<void>> {
  MarkCheersReadNotifier(this._cheerRepo) : super(const AsyncValue.data(null));

  final CheerRepository _cheerRepo;

  Future<void> markAsRead(String cheerId) async {
    state = const AsyncValue.loading();

    try {
      await _cheerRepo.markAsRead(cheerId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      await _cheerRepo.markAllAsRead(userId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final markCheersReadProvider =
    StateNotifierProvider<MarkCheersReadNotifier, AsyncValue<void>>((ref) {
  final cheerRepo = ref.watch(cheerRepositoryProvider);
  return MarkCheersReadNotifier(cheerRepo);
});
