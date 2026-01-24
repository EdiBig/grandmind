import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/pagination/pagination.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/challenge_participant_model.dart';
import '../../data/repositories/challenge_repository.dart';

// ========== Challenge Participants Pagination (Rankings) ==========

/// Parameters for paginated challenge participants query
class ParticipantsPaginationParams {
  final String challengeId;
  final bool sortByProgress;

  const ParticipantsPaginationParams({
    required this.challengeId,
    this.sortByProgress = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticipantsPaginationParams &&
          challengeId == other.challengeId &&
          sortByProgress == other.sortByProgress;

  @override
  int get hashCode => Object.hash(challengeId, sortByProgress);
}

/// Pagination notifier for challenge participants (rankings)
class ParticipantsPaginationNotifier extends PaginationNotifier<ChallengeParticipantModel> {
  final ChallengeRepository _repository;
  final ParticipantsPaginationParams _params;

  ParticipantsPaginationNotifier(this._repository, this._params) : super(pageSize: 50);

  @override
  Future<PaginatedResult<ChallengeParticipantModel>> fetchPage(int page, dynamic cursor) async {
    return _repository.getParticipantsPaginated(
      challengeId: _params.challengeId,
      pageSize: pageSize,
      startAfterDocument: cursor as DocumentSnapshot?,
      sortByProgress: _params.sortByProgress,
      page: page,
    );
  }

  /// Update a participant's progress (optimistic update)
  void updateParticipantProgress(String participantId, ChallengeParticipantModel updated) {
    updateWhere((p) => p.id == participantId, updated);
  }
}

/// Provider for paginated challenge participants (rankings)
final participantsPaginationProvider = StateNotifierProvider.family<
    ParticipantsPaginationNotifier,
    PaginationState<ChallengeParticipantModel>,
    ParticipantsPaginationParams>(
  (ref, params) {
    final repository = ref.watch(challengeRepositoryProvider);
    return ParticipantsPaginationNotifier(repository, params);
  },
);

/// Convenience provider for challenge rankings by challengeId
final challengeRankingsPaginatedProvider = StateNotifierProvider.family<
    ParticipantsPaginationNotifier, PaginationState<ChallengeParticipantModel>, String>(
  (ref, challengeId) {
    final repository = ref.watch(challengeRepositoryProvider);
    return ParticipantsPaginationNotifier(
      repository,
      ParticipantsPaginationParams(challengeId: challengeId),
    );
  },
);

/// Provider for real-time rankings (first page only)
final challengeRankingsStreamProvider =
    StreamProvider.family<PaginatedResult<ChallengeParticipantModel>, ParticipantsPaginationParams>(
        (ref, params) {
  final repository = ref.watch(challengeRepositoryProvider);
  return repository.streamParticipantsFirstPage(
    challengeId: params.challengeId,
    pageSize: 50,
    sortByProgress: params.sortByProgress,
  );
});

// ========== Challenges Pagination ==========

/// Parameters for paginated challenges query
class ChallengesPaginationParams {
  final bool activeOnly;

  const ChallengesPaginationParams({
    this.activeOnly = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengesPaginationParams && activeOnly == other.activeOnly;

  @override
  int get hashCode => activeOnly.hashCode;
}

/// Pagination notifier for challenges
class ChallengesPaginationNotifier extends PaginationNotifier<ChallengeModel> {
  final ChallengeRepository _repository;
  final ChallengesPaginationParams _params;

  ChallengesPaginationNotifier(this._repository, this._params) : super(pageSize: 20);

  @override
  Future<PaginatedResult<ChallengeModel>> fetchPage(int page, dynamic cursor) async {
    return _repository.getChallengesPaginated(
      activeOnly: _params.activeOnly,
      pageSize: pageSize,
      startAfterDocument: cursor as DocumentSnapshot?,
      page: page,
    );
  }
}

/// Provider for paginated challenges
final challengesPaginationProvider = StateNotifierProvider.family<
    ChallengesPaginationNotifier,
    PaginationState<ChallengeModel>,
    ChallengesPaginationParams>(
  (ref, params) {
    final repository = ref.watch(challengeRepositoryProvider);
    return ChallengesPaginationNotifier(repository, params);
  },
);

/// Convenience provider for active challenges
final activeChallengesPaginatedProvider = StateNotifierProvider<
    ChallengesPaginationNotifier, PaginationState<ChallengeModel>>(
  (ref) {
    final repository = ref.watch(challengeRepositoryProvider);
    return ChallengesPaginationNotifier(
      repository,
      const ChallengesPaginationParams(activeOnly: true),
    );
  },
);

// ========== User Challenges Pagination ==========

/// Pagination notifier for user's challenges
class UserChallengesPaginationNotifier extends PaginationNotifier<ChallengeParticipantModel> {
  final ChallengeRepository _repository;
  final String _userId;

  UserChallengesPaginationNotifier(this._repository, this._userId) : super(pageSize: 20);

  @override
  Future<PaginatedResult<ChallengeParticipantModel>> fetchPage(int page, dynamic cursor) async {
    return _repository.getUserChallengesPaginated(
      userId: _userId,
      pageSize: pageSize,
      startAfterDocument: cursor as DocumentSnapshot?,
      page: page,
    );
  }

  /// Add a new participation (optimistic update after joining)
  void addParticipation(ChallengeParticipantModel participation) {
    prependItem(participation);
  }

  /// Remove participation by challenge ID (optimistic update after leaving)
  void removeParticipationByChallengeId(String challengeId) {
    removeWhere((p) => p.challengeId == challengeId);
  }
}

/// Provider for paginated user challenges
final userChallengesPaginatedProvider = StateNotifierProvider.family<
    UserChallengesPaginationNotifier,
    PaginationState<ChallengeParticipantModel>,
    String>(
  (ref, userId) {
    final repository = ref.watch(challengeRepositoryProvider);
    return UserChallengesPaginationNotifier(repository, userId);
  },
);
