import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/challenge_consent_model.dart';
import '../models/challenge_activity_model.dart';
import '../models/challenge_participant_model.dart' show ChallengeParticipantModel;

/// Repository for GDPR-compliant operations on challenge data
class ChallengeGDPRRepository {
  final FirebaseFirestore _firestore;

  ChallengeGDPRRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _consentsCollection =>
      _firestore.collection('challengeConsents');

  CollectionReference<Map<String, dynamic>> get _participantsCollection =>
      _firestore.collection('challengeParticipants');

  CollectionReference<Map<String, dynamic>> get _activitiesCollection =>
      _firestore.collection('challengeActivities');

  CollectionReference<Map<String, dynamic>> get _challengesCollection =>
      _firestore.collection('challenges');

  CollectionReference<Map<String, dynamic>> get _withdrawalRequestsCollection =>
      _firestore.collection('consentWithdrawalRequests');

  // ============================================================
  // CONSENT MANAGEMENT (GDPR Art. 6, 7)
  // ============================================================

  /// Get user's current consent status
  Future<ChallengeConsent?> getUserConsent(String userId) async {
    final doc = await _consentsCollection.doc(userId).get();
    if (!doc.exists) return null;
    return ChallengeConsent.fromFirestore(doc);
  }

  /// Stream user's consent status for reactive updates
  Stream<ChallengeConsent?> watchUserConsent(String userId) {
    return _consentsCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ChallengeConsent.fromFirestore(doc);
    });
  }

  /// Record user consent (initial or update)
  /// GDPR Art. 7(1) requires demonstrable consent
  Future<void> recordConsent({
    required String userId,
    required Map<String, ConsentRecord> consents,
    bool isInitialConsent = false,
  }) async {
    final now = DateTime.now();
    final existingConsent = await getUserConsent(userId);

    if (existingConsent == null) {
      // Create new consent document
      final newConsent = ChallengeConsent(
        id: userId,
        odataType: 'challenge_consent',
        userId: userId,
        consents: consents,
        createdAt: now,
        updatedAt: now,
        hasCompletedInitialConsent: isInitialConsent,
      );
      await _consentsCollection.doc(userId).set(newConsent.toFirestore());
    } else {
      // Merge with existing consents
      final mergedConsents = Map<String, ConsentRecord>.from(existingConsent.consents)
        ..addAll(consents);

      await _consentsCollection.doc(userId).update({
        'consents': mergedConsents.map((key, value) => MapEntry(key, {
              'type': value.type.name,
              'granted': value.granted,
              'timestamp': Timestamp.fromDate(value.timestamp),
              'policyVersion': value.policyVersion,
              if (value.ipAddress != null) 'ipAddress': value.ipAddress,
              if (value.userAgent != null) 'userAgent': value.userAgent,
            })),
        'updatedAt': Timestamp.fromDate(now),
        if (isInitialConsent) 'hasCompletedInitialConsent': true,
      });
    }

    // Log consent change for audit trail
    await _logConsentChange(userId, consents);
  }

  /// Withdraw specific consents
  /// GDPR Art. 7(3) - right to withdraw consent
  Future<void> withdrawConsent({
    required String userId,
    required List<ConsentType> consentsToWithdraw,
    String? reason,
    bool deleteAssociatedData = false,
  }) async {
    final now = DateTime.now();
    final consent = await getUserConsent(userId);
    if (consent == null) return;

    // Build updated consents map
    final updatedConsents = Map<String, ConsentRecord>.from(consent.consents);
    for (final type in consentsToWithdraw) {
      updatedConsents[type.name] = ConsentRecord(
        type: type,
        granted: false,
        timestamp: now,
        policyVersion: consent.consents[type.name]?.policyVersion ?? '1.0',
      );
    }

    // Update consent document
    await _consentsCollection.doc(userId).update({
      'consents': updatedConsents.map((key, value) => MapEntry(key, {
            'type': value.type.name,
            'granted': value.granted,
            'timestamp': Timestamp.fromDate(value.timestamp),
            'policyVersion': value.policyVersion,
          })),
      'updatedAt': Timestamp.fromDate(now),
      'lastWithdrawalAt': Timestamp.fromDate(now),
      if (reason != null) 'withdrawalReason': reason,
    });

    // Log withdrawal request
    await _withdrawalRequestsCollection.add({
      'userId': userId,
      'consentsToWithdraw': consentsToWithdraw.map((c) => c.name).toList(),
      'reason': reason,
      'requestedAt': Timestamp.fromDate(now),
      'deleteAssociatedData': deleteAssociatedData,
      'processed': false,
    });

    // If user withdrew activity sharing consent, redact their activities
    if (consentsToWithdraw.contains(ConsentType.activityDataSharing)) {
      await _redactUserActivities(userId);
    }

    // If user withdrew participation consent, leave all challenges
    if (consentsToWithdraw.contains(ConsentType.challengeParticipation)) {
      await _leaveAllChallenges(userId);
    }

    // If requested, delete associated data
    if (deleteAssociatedData) {
      await deleteUserChallengeData(userId);
    }
  }

  /// Log consent changes for GDPR audit trail
  Future<void> _logConsentChange(
      String userId, Map<String, ConsentRecord> changes) async {
    await _firestore.collection('consentAuditLog').add({
      'userId': userId,
      'changes': changes.map((key, value) => MapEntry(key, {
            'type': value.type.name,
            'granted': value.granted,
            'timestamp': Timestamp.fromDate(value.timestamp),
          })),
      'loggedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DATA ACCESS (GDPR Art. 15)
  // ============================================================

  /// Export all user's challenge-related data
  /// GDPR Art. 20 - Right to data portability
  Future<Map<String, dynamic>> exportUserChallengeData(String userId) async {
    final data = <String, dynamic>{
      'exportedAt': DateTime.now().toIso8601String(),
      'userId': userId,
      'dataCategories': [],
    };

    // 1. Export consent records
    final consent = await getUserConsent(userId);
    if (consent != null) {
      data['consents'] = consent.toJson();
      (data['dataCategories'] as List).add('consents');
    }

    // 2. Export challenge participations
    final participations = await _participantsCollection
        .where('userId', isEqualTo: userId)
        .get();

    data['participations'] = participations.docs.map((doc) {
      final participant = ChallengeParticipantModel.fromFirestore(
        doc.data(),
        doc.id,
      );
      return {
        'challengeId': participant.challengeId,
        'joinedAt': participant.joinedAt.toIso8601String(),
        'progress': participant.currentProgress,
        'privacySettings': {
          'optInRankings': participant.optInRankings,
          'optInActivityFeed': participant.optInActivityFeed,
        },
        'leftAt': participant.leftAt?.toIso8601String(),
      };
    }).toList();
    (data['dataCategories'] as List).add('participations');

    // 3. Export activity feed items created by user
    final activities = await _activitiesCollection
        .where('userId', isEqualTo: userId)
        .get();

    data['activities'] = activities.docs.map((doc) {
      final activity = ChallengeActivity.fromFirestore(doc);
      return {
        'challengeId': activity.challengeId,
        'activityType': activity.activityType.name,
        'createdAt': activity.createdAt.toIso8601String(),
        'data': activity.data,
      };
    }).toList();
    (data['dataCategories'] as List).add('activities');

    // 4. Export challenges created by user
    final createdChallenges = await _challengesCollection
        .where('creatorId', isEqualTo: userId)
        .get();

    data['createdChallenges'] = createdChallenges.docs.map((doc) {
      final docData = doc.data();
      return {
        'id': doc.id,
        'title': docData['title'],
        'createdAt': (docData['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
      };
    }).toList();
    (data['dataCategories'] as List).add('createdChallenges');

    // 5. Export encouragements given
    final encouragements = await _activitiesCollection
        .where('encouragedBy', arrayContains: userId)
        .get();

    data['encouragementsGiven'] = encouragements.docs.map((doc) {
      return {
        'activityId': doc.id,
        'challengeId': doc.data()['challengeId'],
      };
    }).toList();
    (data['dataCategories'] as List).add('encouragementsGiven');

    return data;
  }

  /// Export data as JSON string
  Future<String> exportUserChallengeDataAsJson(String userId) async {
    final data = await exportUserChallengeData(userId);
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Export data as CSV format
  Future<String> exportUserChallengeDataAsCsv(String userId) async {
    final data = await exportUserChallengeData(userId);
    final buffer = StringBuffer();

    // Participations CSV
    buffer.writeln('=== Challenge Participations ===');
    buffer.writeln('Challenge ID,Joined At,Progress,Opt In Rankings,Opt In Activity Feed,Left At');
    final participations = data['participations'] as List? ?? [];
    for (final p in participations) {
      final map = p as Map<String, dynamic>;
      buffer.writeln([
        map['challengeId'],
        map['joinedAt'],
        map['progress'],
        (map['privacySettings'] as Map?)?['optInRankings'],
        (map['privacySettings'] as Map?)?['optInActivityFeed'],
        map['leftAt'] ?? '',
      ].join(','));
    }

    buffer.writeln();
    buffer.writeln('=== Activities ===');
    buffer.writeln('Challenge ID,Activity Type,Created At');
    final activities = data['activities'] as List? ?? [];
    for (final a in activities) {
      final map = a as Map<String, dynamic>;
      buffer.writeln([
        map['challengeId'],
        map['activityType'],
        map['createdAt'],
      ].join(','));
    }

    return buffer.toString();
  }

  // ============================================================
  // DATA DELETION (GDPR Art. 17)
  // ============================================================

  /// Delete all user's challenge data
  /// GDPR Art. 17 - Right to erasure
  Future<void> deleteUserChallengeData(String userId) async {
    final batch = _firestore.batch();

    // 1. Delete consent record
    batch.delete(_consentsCollection.doc(userId));

    // 2. Delete all participations
    final participations = await _participantsCollection
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in participations.docs) {
      batch.delete(doc.reference);
    }

    // 3. Delete or anonymize activities
    final activities = await _activitiesCollection
        .where('userId', isEqualTo: userId)
        .get();
    for (final doc in activities.docs) {
      // Anonymize rather than delete to preserve challenge statistics
      batch.update(doc.reference, {
        'userId': 'deleted_user',
        'displayName': null,
        'avatarUrl': null,
        'isRedacted': true,
        'description': 'Activity from deleted user',
      });
    }

    // 4. Remove user from encouragedBy arrays
    final encouragedActivities = await _activitiesCollection
        .where('encouragedBy', arrayContains: userId)
        .get();
    for (final doc in encouragedActivities.docs) {
      batch.update(doc.reference, {
        'encouragedBy': FieldValue.arrayRemove([userId]),
      });
    }

    await batch.commit();

    // 5. Handle challenges created by user (transfer ownership or delete)
    await _handleCreatedChallenges(userId);

    // 6. Log deletion for audit
    await _firestore.collection('dataDeletionLog').add({
      'userId': userId,
      'dataType': 'challenges',
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete specific challenge participation data
  Future<void> deleteParticipationData({
    required String userId,
    required String challengeId,
  }) async {
    // Delete participation
    final participations = await _participantsCollection
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .get();

    for (final doc in participations.docs) {
      await doc.reference.delete();
    }

    // Anonymize activities for this challenge
    final activities = await _activitiesCollection
        .where('userId', isEqualTo: userId)
        .where('challengeId', isEqualTo: challengeId)
        .get();

    for (final doc in activities.docs) {
      await doc.reference.update({
        'displayName': null,
        'avatarUrl': null,
        'isRedacted': true,
      });
    }
  }

  /// Handle challenges created by user being deleted
  Future<void> _handleCreatedChallenges(String userId) async {
    final challenges = await _challengesCollection
        .where('creatorId', isEqualTo: userId)
        .get();

    for (final doc in challenges.docs) {
      final participants = await _participantsCollection
          .where('challengeId', isEqualTo: doc.id)
          .where('leftAt', isNull: true)
          .limit(1)
          .get();

      if (participants.docs.isEmpty) {
        // No active participants - delete the challenge
        await doc.reference.delete();
      } else {
        // Transfer ownership to first active participant
        final newOwner = participants.docs.first.data()['userId'] as String;
        await doc.reference.update({
          'creatorId': newOwner,
          'ownershipTransferredAt': FieldValue.serverTimestamp(),
          'originalCreatorDeleted': true,
        });
      }
    }
  }

  // ============================================================
  // PRIVACY HELPERS
  // ============================================================

  /// Redact all user's activities (when they withdraw activity sharing consent)
  Future<void> _redactUserActivities(String userId) async {
    final activities = await _activitiesCollection
        .where('userId', isEqualTo: userId)
        .get();

    final batch = _firestore.batch();
    for (final doc in activities.docs) {
      batch.update(doc.reference, {
        'displayName': null,
        'avatarUrl': null,
        'isRedacted': true,
      });
    }
    await batch.commit();
  }

  /// Leave all challenges (when user withdraws participation consent)
  Future<void> _leaveAllChallenges(String userId) async {
    final participations = await _participantsCollection
        .where('userId', isEqualTo: userId)
        .where('leftAt', isNull: true)
        .get();

    final batch = _firestore.batch();
    final now = Timestamp.fromDate(DateTime.now());

    for (final doc in participations.docs) {
      batch.update(doc.reference, {
        'leftAt': now,
        'leftReason': 'consent_withdrawn',
      });

      // Decrement participant count on challenge
      final challengeId = doc.data()['challengeId'] as String;
      batch.update(_challengesCollection.doc(challengeId), {
        'participantCount': FieldValue.increment(-1),
      });
    }

    await batch.commit();
  }

  /// Check if user has required consents for a specific action
  Future<bool> hasRequiredConsents(
      String userId, List<ConsentType> requiredConsents) async {
    final consent = await getUserConsent(userId);
    if (consent == null) return false;

    return requiredConsents.every((type) => consent.hasConsent(type));
  }

  /// Get activities with privacy filtering applied
  Future<List<ChallengeActivity>> getActivitiesWithPrivacy({
    required String challengeId,
    required String viewerUserId,
    int limit = 50,
  }) async {
    // Get viewer's consent to determine what they can see
    final viewerConsent = await getUserConsent(viewerUserId);

    // If viewer hasn't consented to activity sharing, they can only see public activities
    final canSeeParticipantActivities =
        viewerConsent?.hasConsent(ConsentType.activityDataSharing) ?? false;

    final query = _activitiesCollection
        .where('challengeId', isEqualTo: challengeId)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final activity = ChallengeActivity.fromFirestore(doc);

      // Check if this activity's creator consented to sharing
      // If not, or if viewer can't see participant activities, redact it
      if (activity.isRedacted ||
          (!canSeeParticipantActivities &&
              activity.visibility == ActivityVisibility.participants)) {
        return activity.redacted();
      }

      return activity;
    }).toList();
  }
}

/// Provider for GDPR repository
final challengeGDPRRepositoryProvider = Provider<ChallengeGDPRRepository>((ref) {
  return ChallengeGDPRRepository();
});

/// Provider for watching user's consent status
final userChallengeConsentProvider =
    StreamProvider.family<ChallengeConsent?, String>((ref, userId) {
  final repository = ref.watch(challengeGDPRRepositoryProvider);
  return repository.watchUserConsent(userId);
});
