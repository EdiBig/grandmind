import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/models.dart';

/// Repository for Unity Settings and Consent operations
class UnitySettingsRepository {
  UnitySettingsRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _settings =>
      _firestore.collection('unity_settings');

  CollectionReference<Map<String, dynamic>> get _consents =>
      _firestore.collection('unity_consents');

  // Settings methods

  /// Get user settings
  Future<UnitySettings> getSettings(String userId) async {
    final doc = await _settings.doc(userId).get();
    if (!doc.exists) {
      // Return default settings if not found
      return UnitySettings.defaults(userId);
    }
    return UnitySettings.fromFirestore(doc.data()!, userId);
  }

  /// Stream user settings
  Stream<UnitySettings> getSettingsStream(String userId) {
    return _settings.doc(userId).snapshots().map((doc) {
      if (!doc.exists) {
        return UnitySettings.defaults(userId);
      }
      return UnitySettings.fromFirestore(doc.data()!, userId);
    });
  }

  /// Save user settings
  Future<void> saveSettings(UnitySettings settings) async {
    await _settings.doc(settings.userId).set(
          settings.toFirestore(),
          SetOptions(merge: true),
        );
  }

  /// Update a single setting
  Future<void> updateSetting(
    String userId,
    String key,
    dynamic value,
  ) async {
    await _settings.doc(userId).set(
      {
        key: value,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Update multiple settings
  Future<void> updateSettings(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    updates['updatedAt'] = FieldValue.serverTimestamp();
    await _settings.doc(userId).set(
          updates,
          SetOptions(merge: true),
        );
  }

  /// Mute a circle
  Future<void> muteCircle(String userId, String circleId) async {
    await _settings.doc(userId).set(
      {
        'mutedCircles': FieldValue.arrayUnion([circleId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Unmute a circle
  Future<void> unmuteCircle(String userId, String circleId) async {
    await _settings.doc(userId).set(
      {
        'mutedCircles': FieldValue.arrayRemove([circleId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Mute a challenge
  Future<void> muteChallenge(String userId, String challengeId) async {
    await _settings.doc(userId).set(
      {
        'mutedChallenges': FieldValue.arrayUnion([challengeId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Unmute a challenge
  Future<void> unmuteChallenge(String userId, String challengeId) async {
    await _settings.doc(userId).set(
      {
        'mutedChallenges': FieldValue.arrayRemove([challengeId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Block a user
  Future<void> blockUser(String userId, String blockedUserId) async {
    await _settings.doc(userId).set(
      {
        'blockedUsers': FieldValue.arrayUnion([blockedUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Unblock a user
  Future<void> unblockUser(String userId, String blockedUserId) async {
    await _settings.doc(userId).set(
      {
        'blockedUsers': FieldValue.arrayRemove([blockedUserId]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Check if a user is blocked
  Future<bool> isUserBlocked(String userId, String targetUserId) async {
    final settings = await getSettings(userId);
    return settings.blockedUsers.contains(targetUserId);
  }

  // Consent methods

  /// Get user consents
  Future<ConsentCollection> getConsents(String userId) async {
    final snapshot = await _consents
        .where('userId', isEqualTo: userId)
        .get();

    final consents = snapshot.docs
        .map((doc) => UnityConsent.fromFirestore(doc.data(), doc.id))
        .toList();

    return ConsentCollection(consents: consents);
  }

  /// Stream user consents
  Stream<ConsentCollection> getConsentsStream(String userId) {
    return _consents
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final consents = snapshot.docs
          .map((doc) => UnityConsent.fromFirestore(doc.data(), doc.id))
          .toList();
      return ConsentCollection(consents: consents);
    });
  }

  /// Grant a consent
  Future<String> grantConsent(UnityConsent consent) async {
    // Check if consent already exists
    final existing = await _consents
        .where('userId', isEqualTo: consent.userId)
        .where('type', isEqualTo: consent.type.name)
        .where('challengeId', isEqualTo: consent.challengeId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      // Update existing consent
      await _consents.doc(existing.docs.first.id).update({
        'granted': true,
        'grantedAt': FieldValue.serverTimestamp(),
        'revokedAt': null,
        'version': consent.version,
      });
      return existing.docs.first.id;
    }

    // Create new consent
    final docRef = await _consents.add(consent.toFirestore());
    return docRef.id;
  }

  /// Revoke a consent
  Future<void> revokeConsent(String consentId) async {
    await _consents.doc(consentId).update({
      'revokedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Revoke consent by type
  Future<void> revokeConsentByType(
    String userId,
    ConsentType type, {
    String? challengeId,
  }) async {
    Query<Map<String, dynamic>> query = _consents
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.name);

    if (challengeId != null) {
      query = query.where('challengeId', isEqualTo: challengeId);
    }

    final snapshot = await query.get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'revokedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Check if user has a specific consent
  Future<bool> hasConsent(
    String userId,
    ConsentType type, {
    String? challengeId,
  }) async {
    Query<Map<String, dynamic>> query = _consents
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.name)
        .where('granted', isEqualTo: true);

    if (challengeId != null) {
      query = query.where('challengeId', isEqualTo: challengeId);
    }

    final snapshot = await query.limit(1).get();
    if (snapshot.docs.isEmpty) return false;

    // Check if not revoked
    final data = snapshot.docs.first.data();
    return data['revokedAt'] == null;
  }

  /// Check if user has all required consents
  Future<bool> hasAllRequiredConsents(String userId) async {
    for (final type in ConsentType.values) {
      if (type.isRequired && !await hasConsent(userId, type)) {
        return false;
      }
    }
    return true;
  }

  /// Get missing required consents
  Future<List<ConsentType>> getMissingRequiredConsents(String userId) async {
    final missing = <ConsentType>[];
    for (final type in ConsentType.values) {
      if (type.isRequired && !await hasConsent(userId, type)) {
        missing.add(type);
      }
    }
    return missing;
  }

  /// Grant multiple consents at once
  Future<void> grantConsents(List<UnityConsent> consents) async {
    final batch = _firestore.batch();

    for (final consent in consents) {
      final docRef = _consents.doc();
      batch.set(docRef, consent.toFirestore());
    }

    await batch.commit();
  }

  /// Get consent history for audit
  Future<List<UnityConsent>> getConsentHistory(String userId) async {
    final snapshot = await _consents
        .where('userId', isEqualTo: userId)
        .orderBy('grantedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => UnityConsent.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Delete all user data (GDPR)
  Future<void> deleteUserData(String userId) async {
    final batch = _firestore.batch();

    // Delete settings
    batch.delete(_settings.doc(userId));

    // Delete consents
    final consents = await _consents.where('userId', isEqualTo: userId).get();
    for (final doc in consents.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Export user data (GDPR)
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    final settings = await getSettings(userId);
    final consents = await getConsentHistory(userId);

    return {
      'settings': settings.toFirestore(),
      'consents': consents.map((c) => c.toFirestore()).toList(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }
}
