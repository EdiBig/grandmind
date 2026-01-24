import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge_report_model.dart';
import '../models/challenge_activity_model.dart';
import '../repositories/challenge_repository.dart';

/// Service for challenge moderation features
class ChallengeModerationService {
  final FirebaseFirestore _firestore;
  final ChallengeRepository _challengeRepository;

  ChallengeModerationService({
    FirebaseFirestore? firestore,
    required ChallengeRepository challengeRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _challengeRepository = challengeRepository;

  static const String _reportsCollection = 'challengeReports';
  static const String _blockedUsersCollection = 'blockedUsers';
  static const String _moderationSettingsCollection = 'challengeModerationSettings';
  static const String _activitiesCollection = 'challengeActivities';

  // ============================================================
  // REPORTING
  // ============================================================

  /// Submit a report
  Future<ChallengeReport> submitReport({
    required String reporterId,
    required ReportableContentType contentType,
    required String contentId,
    required ReportReason reason,
    String? challengeId,
    String? reportedUserId,
    String? description,
  }) async {
    // Check if user has already reported this content
    final existingReport = await _firestore
        .collection(_reportsCollection)
        .where('reporterId', isEqualTo: reporterId)
        .where('contentId', isEqualTo: contentId)
        .where('status', isEqualTo: ReportStatus.pending.name)
        .limit(1)
        .get();

    if (existingReport.docs.isNotEmpty) {
      throw Exception('You have already reported this content');
    }

    final report = ChallengeReport(
      id: '',
      reporterId: reporterId,
      contentType: contentType,
      contentId: contentId,
      reason: reason,
      status: ReportStatus.pending,
      createdAt: DateTime.now(),
      challengeId: challengeId,
      reportedUserId: reportedUserId,
      description: description,
    );

    final docRef =
        await _firestore.collection(_reportsCollection).add(report.toFirestore());

    // If multiple reports on same content, escalate priority
    await _checkForEscalation(contentId, contentType);

    return ChallengeReport(
      id: docRef.id,
      reporterId: report.reporterId,
      contentType: report.contentType,
      contentId: report.contentId,
      reason: report.reason,
      status: report.status,
      createdAt: report.createdAt,
      challengeId: report.challengeId,
      reportedUserId: report.reportedUserId,
      description: report.description,
    );
  }

  /// Check if content should be auto-hidden due to multiple reports
  Future<void> _checkForEscalation(
      String contentId, ReportableContentType contentType) async {
    final reportCount = await _firestore
        .collection(_reportsCollection)
        .where('contentId', isEqualTo: contentId)
        .where('status', isEqualTo: ReportStatus.pending.name)
        .count()
        .get();

    // Auto-hide content after 3 reports
    if ((reportCount.count ?? 0) >= 3) {
      if (contentType == ReportableContentType.activity) {
        await _firestore.collection(_activitiesCollection).doc(contentId).update({
          'isHidden': true,
          'hiddenReason': 'Multiple reports received',
        });
      }
    }
  }

  /// Get reports for a challenge (for challenge creator)
  Future<List<ChallengeReport>> getChallengeReports(String challengeId) async {
    final snapshot = await _firestore
        .collection(_reportsCollection)
        .where('challengeId', isEqualTo: challengeId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChallengeReport.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Get user's submitted reports
  Future<List<ChallengeReport>> getUserReports(String userId) async {
    final snapshot = await _firestore
        .collection(_reportsCollection)
        .where('reporterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((doc) => ChallengeReport.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  // ============================================================
  // BLOCKING
  // ============================================================

  /// Block a user
  Future<void> blockUser({
    required String blockerId,
    required String blockedUserId,
    String? reason,
  }) async {
    // Check if already blocked
    final existing = await _firestore
        .collection(_blockedUsersCollection)
        .where('blockerId', isEqualTo: blockerId)
        .where('blockedUserId', isEqualTo: blockedUserId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return; // Already blocked
    }

    final block = BlockedUser(
      id: '',
      blockerId: blockerId,
      blockedUserId: blockedUserId,
      createdAt: DateTime.now(),
      reason: reason,
    );

    await _firestore.collection(_blockedUsersCollection).add(block.toFirestore());
  }

  /// Unblock a user
  Future<void> unblockUser({
    required String blockerId,
    required String blockedUserId,
  }) async {
    final snapshot = await _firestore
        .collection(_blockedUsersCollection)
        .where('blockerId', isEqualTo: blockerId)
        .where('blockedUserId', isEqualTo: blockedUserId)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// Get list of blocked users
  Future<List<BlockedUser>> getBlockedUsers(String userId) async {
    final snapshot = await _firestore
        .collection(_blockedUsersCollection)
        .where('blockerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BlockedUser.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked({
    required String blockerId,
    required String blockedUserId,
  }) async {
    final snapshot = await _firestore
        .collection(_blockedUsersCollection)
        .where('blockerId', isEqualTo: blockerId)
        .where('blockedUserId', isEqualTo: blockedUserId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  /// Get list of users who blocked a specific user
  Future<List<String>> getBlockedByUsers(String userId) async {
    final snapshot = await _firestore
        .collection(_blockedUsersCollection)
        .where('blockedUserId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['blockerId'] as String)
        .toList();
  }

  // ============================================================
  // CHALLENGE MODERATION (for creators)
  // ============================================================

  /// Get moderation settings for a challenge
  Future<ChallengeModerationSettings> getModerationSettings(
      String challengeId) async {
    final doc = await _firestore
        .collection(_moderationSettingsCollection)
        .doc(challengeId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return const ChallengeModerationSettings();
    }

    return ChallengeModerationSettings.fromMap(doc.data()!);
  }

  /// Update moderation settings
  Future<void> updateModerationSettings({
    required String challengeId,
    required String userId,
    required ChallengeModerationSettings settings,
  }) async {
    // Verify user is challenge creator
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null || challenge.createdBy != userId) {
      throw Exception('Only challenge creator can modify moderation settings');
    }

    await _firestore
        .collection(_moderationSettingsCollection)
        .doc(challengeId)
        .set(settings.toMap());
  }

  /// Remove a participant from a challenge (kick)
  Future<void> removeParticipant({
    required String challengeId,
    required String moderatorId,
    required String participantUserId,
    String? reason,
  }) async {
    // Verify moderator is challenge creator
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null || challenge.createdBy != moderatorId) {
      throw Exception('Only challenge creator can remove participants');
    }

    // Can't remove yourself
    if (moderatorId == participantUserId) {
      throw Exception('You cannot remove yourself from the challenge');
    }

    // Leave the challenge for the participant
    await _challengeRepository.leaveChallenge(
      challengeId: challengeId,
      userId: participantUserId,
    );

    // Log the removal
    await _firestore.collection('moderationLogs').add({
      'action': 'participant_removed',
      'challengeId': challengeId,
      'moderatorId': moderatorId,
      'targetUserId': participantUserId,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Hide an activity post
  Future<void> hideActivity({
    required String activityId,
    required String moderatorId,
    required String challengeId,
    String? reason,
  }) async {
    // Verify moderator is challenge creator
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null || challenge.createdBy != moderatorId) {
      throw Exception('Only challenge creator can hide activities');
    }

    await _firestore.collection(_activitiesCollection).doc(activityId).update({
      'isHidden': true,
      'hiddenBy': moderatorId,
      'hiddenReason': reason ?? 'Hidden by moderator',
      'hiddenAt': FieldValue.serverTimestamp(),
    });

    // Log the action
    await _firestore.collection('moderationLogs').add({
      'action': 'activity_hidden',
      'challengeId': challengeId,
      'activityId': activityId,
      'moderatorId': moderatorId,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Unhide an activity post
  Future<void> unhideActivity({
    required String activityId,
    required String moderatorId,
    required String challengeId,
  }) async {
    // Verify moderator is challenge creator
    final challenge = await _challengeRepository.getChallenge(challengeId);
    if (challenge == null || challenge.createdBy != moderatorId) {
      throw Exception('Only challenge creator can unhide activities');
    }

    await _firestore.collection(_activitiesCollection).doc(activityId).update({
      'isHidden': false,
      'hiddenBy': FieldValue.delete(),
      'hiddenReason': FieldValue.delete(),
      'hiddenAt': FieldValue.delete(),
    });
  }

  // ============================================================
  // CONTENT FILTERING
  // ============================================================

  /// Filter activities based on blocks and moderation
  Future<List<ChallengeActivity>> filterActivities({
    required String userId,
    required List<ChallengeActivity> activities,
  }) async {
    // Get blocked users
    final blockedUsers = await getBlockedUsers(userId);
    final blockedIds = blockedUsers.map((b) => b.blockedUserId).toSet();

    // Get users who blocked this user
    final blockedByIds = (await getBlockedByUsers(userId)).toSet();

    // Filter out:
    // 1. Activities from blocked users
    // 2. Activities from users who blocked the viewer
    // 3. Hidden activities (unless viewer is the author)
    return activities.where((activity) {
      // Skip if from blocked user
      if (blockedIds.contains(activity.userId)) return false;

      // Skip if from user who blocked viewer
      if (blockedByIds.contains(activity.userId)) return false;

      // Skip hidden activities (unless viewer is author)
      final isHidden = activity.data?['isHidden'] as bool? ?? false;
      if (isHidden && activity.userId != userId) return false;

      return true;
    }).toList();
  }

  /// Check content against banned words
  bool containsBannedWords(String content, List<String> bannedWords) {
    if (bannedWords.isEmpty) return false;

    final lowerContent = content.toLowerCase();
    for (final word in bannedWords) {
      if (lowerContent.contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}

/// Provider for moderation service
final challengeModerationServiceProvider =
    Provider<ChallengeModerationService>((ref) {
  final challengeRepository = ref.watch(challengeRepositoryProvider);
  return ChallengeModerationService(challengeRepository: challengeRepository);
});

/// Provider for blocked users
final blockedUsersProvider =
    FutureProvider.family<List<BlockedUser>, String>((ref, userId) async {
  final service = ref.watch(challengeModerationServiceProvider);
  return service.getBlockedUsers(userId);
});

/// Provider for moderation settings
final challengeModerationSettingsProvider =
    FutureProvider.family<ChallengeModerationSettings, String>(
  (ref, challengeId) async {
    final service = ref.watch(challengeModerationServiceProvider);
    return service.getModerationSettings(challengeId);
  },
);
