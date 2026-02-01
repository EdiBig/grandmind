import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

/// Feed repository provider
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository();
});

/// Circle feed stream
final circleFeedProvider =
    StreamProvider.family<List<FeedPost>, String>((ref, circleId) {
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getCircleFeedStream(circleId);
});

/// Challenge feed stream
final challengeFeedProvider =
    StreamProvider.family<List<FeedPost>, String>((ref, challengeId) {
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getChallengeFeedStream(challengeId);
});

/// Single post stream
final postByIdProvider =
    StreamProvider.family<FeedPost?, String>((ref, postId) {
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getPostStream(postId);
});

/// Post comments stream
final postCommentsProvider =
    StreamProvider.family<List<FeedComment>, String>((ref, postId) {
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getCommentsStream(postId);
});

/// Pinned posts for a circle
final pinnedPostsProvider =
    StreamProvider.family<List<FeedPost>, String>((ref, circleId) {
  final repo = ref.watch(feedRepositoryProvider);
  return repo.getPinnedPostsStream(circleId);
});

/// User's posts
final userPostsProvider = StreamProvider<List<FeedPost>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return Stream.value([]);

  final repo = ref.watch(feedRepositoryProvider);
  return repo.getUserPostsStream(userId);
});

/// Create post notifier
class CreatePostNotifier extends StateNotifier<AsyncValue<String?>> {
  CreatePostNotifier(this._feedRepo) : super(const AsyncValue.data(null));

  final FeedRepository _feedRepo;

  Future<void> createTextPost({
    required String text,
    String? circleId,
    String? challengeId,
    List<String>? imageUrls,
    bool isAnonymous = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.displayName;
      final userAvatar = FirebaseAuth.instance.currentUser?.photoURL;

      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final postId = await _feedRepo.createTextPost(
        authorId: userId,
        authorName: userName ?? 'User',
        authorAvatarUrl: userAvatar,
        circleId: circleId,
        challengeId: challengeId,
        text: text,
        imageUrls: imageUrls,
        isAnonymous: isAnonymous,
      );

      state = AsyncValue.data(postId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createActivityPost({
    required String activityType,
    required double value,
    required String unit,
    String? circleId,
    String? challengeId,
    String? caption,
    String? workoutId,
    bool isAnonymous = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.displayName;
      final userAvatar = FirebaseAuth.instance.currentUser?.photoURL;

      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final postId = await _feedRepo.createActivityPost(
        authorId: userId,
        authorName: userName ?? 'User',
        authorAvatarUrl: userAvatar,
        circleId: circleId,
        challengeId: challengeId,
        activityType: activityType,
        value: value,
        unit: unit,
        caption: caption,
        workoutId: workoutId,
        isAnonymous: isAnonymous,
      );

      state = AsyncValue.data(postId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createMilestonePost({
    required String milestoneId,
    required String milestoneName,
    String? circleId,
    String? challengeId,
    double? progress,
    String? caption,
    bool isAnonymous = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.displayName;
      final userAvatar = FirebaseAuth.instance.currentUser?.photoURL;

      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final postId = await _feedRepo.createMilestonePost(
        authorId: userId,
        authorName: userName ?? 'User',
        authorAvatarUrl: userAvatar,
        circleId: circleId,
        challengeId: challengeId,
        milestoneId: milestoneId,
        milestoneName: milestoneName,
        progress: progress,
        caption: caption,
        isAnonymous: isAnonymous,
      );

      state = AsyncValue.data(postId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final createPostProvider =
    StateNotifierProvider<CreatePostNotifier, AsyncValue<String?>>((ref) {
  final feedRepo = ref.watch(feedRepositoryProvider);
  return CreatePostNotifier(feedRepo);
});

/// Delete post notifier
class DeletePostNotifier extends StateNotifier<AsyncValue<void>> {
  DeletePostNotifier(this._feedRepo) : super(const AsyncValue.data(null));

  final FeedRepository _feedRepo;

  Future<void> deletePost(String postId) async {
    state = const AsyncValue.loading();

    try {
      await _feedRepo.deletePost(postId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final deletePostProvider =
    StateNotifierProvider<DeletePostNotifier, AsyncValue<void>>((ref) {
  final feedRepo = ref.watch(feedRepositoryProvider);
  return DeletePostNotifier(feedRepo);
});

/// Add comment notifier
class AddCommentNotifier extends StateNotifier<AsyncValue<String?>> {
  AddCommentNotifier(this._feedRepo) : super(const AsyncValue.data(null));

  final FeedRepository _feedRepo;

  Future<void> addComment({
    required String postId,
    required String text,
    bool isAnonymous = false,
  }) async {
    state = const AsyncValue.loading();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      final userName = FirebaseAuth.instance.currentUser?.displayName;
      final userAvatar = FirebaseAuth.instance.currentUser?.photoURL;

      if (userId == null) {
        state = AsyncValue.error('Not authenticated', StackTrace.current);
        return;
      }

      final comment = FeedComment(
        id: '',
        postId: postId,
        authorId: userId,
        authorName: userName,
        authorAvatarUrl: userAvatar,
        isAnonymous: isAnonymous,
        text: text,
      );

      final commentId = await _feedRepo.addComment(comment);
      state = AsyncValue.data(commentId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final addCommentProvider =
    StateNotifierProvider<AddCommentNotifier, AsyncValue<String?>>((ref) {
  final feedRepo = ref.watch(feedRepositoryProvider);
  return AddCommentNotifier(feedRepo);
});

/// Pin post notifier
class PinPostNotifier extends StateNotifier<AsyncValue<void>> {
  PinPostNotifier(this._feedRepo) : super(const AsyncValue.data(null));

  final FeedRepository _feedRepo;

  Future<void> pinPost(String postId) async {
    state = const AsyncValue.loading();

    try {
      await _feedRepo.pinPost(postId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unpinPost(String postId) async {
    state = const AsyncValue.loading();

    try {
      await _feedRepo.unpinPost(postId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final pinPostProvider =
    StateNotifierProvider<PinPostNotifier, AsyncValue<void>>((ref) {
  final feedRepo = ref.watch(feedRepositoryProvider);
  return PinPostNotifier(feedRepo);
});

/// Flag post notifier
class FlagPostNotifier extends StateNotifier<AsyncValue<void>> {
  FlagPostNotifier(this._feedRepo) : super(const AsyncValue.data(null));

  final FeedRepository _feedRepo;

  Future<void> flagPost(String postId, String reason) async {
    state = const AsyncValue.loading();

    try {
      await _feedRepo.flagPost(postId, reason);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final flagPostProvider =
    StateNotifierProvider<FlagPostNotifier, AsyncValue<void>>((ref) {
  final feedRepo = ref.watch(feedRepositoryProvider);
  return FlagPostNotifier(feedRepo);
});
