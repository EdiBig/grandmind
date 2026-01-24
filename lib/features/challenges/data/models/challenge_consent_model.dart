import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'challenge_consent_model.freezed.dart';
part 'challenge_consent_model.g.dart';

/// Granular consent types for GDPR compliance
enum ConsentType {
  /// Consent to participate in challenges (Art. 6(1)(a))
  challengeParticipation,

  /// Consent to share activity data with challenge participants
  activityDataSharing,

  /// Consent to appear in public rankings/leaderboards
  publicRankings,

  /// Consent to receive challenge notifications
  challengeNotifications,

  /// Consent to share progress with friends
  progressSharing,

  /// Consent to health-related data processing disclaimer
  healthDisclaimer,
}

/// Individual consent record with timestamp and version tracking
@freezed
class ConsentRecord with _$ConsentRecord {
  const factory ConsentRecord({
    required ConsentType type,
    required bool granted,
    required DateTime timestamp,
    @Default('1.0') String policyVersion,
    String? ipAddress,
    String? userAgent,
  }) = _ConsentRecord;

  factory ConsentRecord.fromJson(Map<String, dynamic> json) =>
      _$ConsentRecordFromJson(json);
}

/// Complete consent profile for a user in the challenges feature
@freezed
class ChallengeConsent with _$ChallengeConsent {
  const ChallengeConsent._();

  const factory ChallengeConsent({
    required String id,
    required String odataType,
    required String userId,
    required Map<String, ConsentRecord> consents,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool hasCompletedInitialConsent,
    String? withdrawalReason,
    DateTime? lastWithdrawalAt,
  }) = _ChallengeConsent;

  factory ChallengeConsent.fromJson(Map<String, dynamic> json) =>
      _$ChallengeConsentFromJson(json);

  factory ChallengeConsent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChallengeConsent(
      id: doc.id,
      odataType: 'challenge_consent',
      userId: data['userId'] as String? ?? '',
      consents: _parseConsents(data['consents'] as Map<String, dynamic>?),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      hasCompletedInitialConsent:
          data['hasCompletedInitialConsent'] as bool? ?? false,
      withdrawalReason: data['withdrawalReason'] as String?,
      lastWithdrawalAt:
          (data['lastWithdrawalAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'consents': consents.map((key, value) => MapEntry(key, {
            'type': value.type.name,
            'granted': value.granted,
            'timestamp': Timestamp.fromDate(value.timestamp),
            'policyVersion': value.policyVersion,
            if (value.ipAddress != null) 'ipAddress': value.ipAddress,
            if (value.userAgent != null) 'userAgent': value.userAgent,
          })),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'hasCompletedInitialConsent': hasCompletedInitialConsent,
      if (withdrawalReason != null) 'withdrawalReason': withdrawalReason,
      if (lastWithdrawalAt != null)
        'lastWithdrawalAt': Timestamp.fromDate(lastWithdrawalAt!),
    };
  }

  /// Check if a specific consent is granted
  bool hasConsent(ConsentType type) {
    final record = consents[type.name];
    return record?.granted ?? false;
  }

  /// Check if user can participate in challenges (minimum required consents)
  bool get canParticipate =>
      hasConsent(ConsentType.challengeParticipation) &&
      hasConsent(ConsentType.healthDisclaimer);

  /// Check if user has opted into public features
  bool get isPubliclyVisible =>
      hasConsent(ConsentType.publicRankings) &&
      hasConsent(ConsentType.activityDataSharing);

  /// Get list of all granted consents
  List<ConsentType> get grantedConsents => consents.entries
      .where((e) => e.value.granted)
      .map((e) => ConsentType.values.firstWhere(
            (t) => t.name == e.key,
            orElse: () => ConsentType.challengeParticipation,
          ))
      .toList();

  static Map<String, ConsentRecord> _parseConsents(
      Map<String, dynamic>? data) {
    if (data == null) return {};

    return data.map((key, value) {
      final map = value as Map<String, dynamic>;
      return MapEntry(
        key,
        ConsentRecord(
          type: ConsentType.values.firstWhere(
            (t) => t.name == (map['type'] as String? ?? key),
            orElse: () => ConsentType.challengeParticipation,
          ),
          granted: map['granted'] as bool? ?? false,
          timestamp:
              (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          policyVersion: map['policyVersion'] as String? ?? '1.0',
          ipAddress: map['ipAddress'] as String?,
          userAgent: map['userAgent'] as String?,
        ),
      );
    });
  }
}

/// Builder for creating consent updates
class ChallengeConsentBuilder {
  final Map<String, ConsentRecord> _consents = {};
  final String _policyVersion;

  ChallengeConsentBuilder({String policyVersion = '1.0'})
      : _policyVersion = policyVersion;

  /// Grant a consent
  ChallengeConsentBuilder grant(ConsentType type) {
    _consents[type.name] = ConsentRecord(
      type: type,
      granted: true,
      timestamp: DateTime.now(),
      policyVersion: _policyVersion,
    );
    return this;
  }

  /// Revoke a consent
  ChallengeConsentBuilder revoke(ConsentType type) {
    _consents[type.name] = ConsentRecord(
      type: type,
      granted: false,
      timestamp: DateTime.now(),
      policyVersion: _policyVersion,
    );
    return this;
  }

  /// Build the consents map
  Map<String, ConsentRecord> build() => Map.unmodifiable(_consents);
}

/// Consent withdrawal request for audit trail
@freezed
class ConsentWithdrawalRequest with _$ConsentWithdrawalRequest {
  const factory ConsentWithdrawalRequest({
    required String userId,
    required List<ConsentType> consentsToWithdraw,
    required String reason,
    required DateTime requestedAt,
    @Default(false) bool deleteAssociatedData,
    @Default(false) bool processed,
    DateTime? processedAt,
  }) = _ConsentWithdrawalRequest;

  factory ConsentWithdrawalRequest.fromJson(Map<String, dynamic> json) =>
      _$ConsentWithdrawalRequestFromJson(json);
}
