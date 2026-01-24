// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_consent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsentRecordImpl _$$ConsentRecordImplFromJson(Map<String, dynamic> json) =>
    _$ConsentRecordImpl(
      type: $enumDecode(_$ConsentTypeEnumMap, json['type']),
      granted: json['granted'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      policyVersion: json['policyVersion'] as String? ?? '1.0',
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
    );

Map<String, dynamic> _$$ConsentRecordImplToJson(_$ConsentRecordImpl instance) =>
    <String, dynamic>{
      'type': _$ConsentTypeEnumMap[instance.type]!,
      'granted': instance.granted,
      'timestamp': instance.timestamp.toIso8601String(),
      'policyVersion': instance.policyVersion,
      'ipAddress': instance.ipAddress,
      'userAgent': instance.userAgent,
    };

const _$ConsentTypeEnumMap = {
  ConsentType.challengeParticipation: 'challengeParticipation',
  ConsentType.activityDataSharing: 'activityDataSharing',
  ConsentType.publicRankings: 'publicRankings',
  ConsentType.challengeNotifications: 'challengeNotifications',
  ConsentType.progressSharing: 'progressSharing',
  ConsentType.healthDisclaimer: 'healthDisclaimer',
};

_$ChallengeConsentImpl _$$ChallengeConsentImplFromJson(
        Map<String, dynamic> json) =>
    _$ChallengeConsentImpl(
      id: json['id'] as String,
      odataType: json['odataType'] as String,
      userId: json['userId'] as String,
      consents: (json['consents'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, ConsentRecord.fromJson(e as Map<String, dynamic>)),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      hasCompletedInitialConsent:
          json['hasCompletedInitialConsent'] as bool? ?? false,
      withdrawalReason: json['withdrawalReason'] as String?,
      lastWithdrawalAt: json['lastWithdrawalAt'] == null
          ? null
          : DateTime.parse(json['lastWithdrawalAt'] as String),
    );

Map<String, dynamic> _$$ChallengeConsentImplToJson(
        _$ChallengeConsentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'odataType': instance.odataType,
      'userId': instance.userId,
      'consents': instance.consents.map((k, e) => MapEntry(k, e.toJson())),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'hasCompletedInitialConsent': instance.hasCompletedInitialConsent,
      'withdrawalReason': instance.withdrawalReason,
      'lastWithdrawalAt': instance.lastWithdrawalAt?.toIso8601String(),
    };

_$ConsentWithdrawalRequestImpl _$$ConsentWithdrawalRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$ConsentWithdrawalRequestImpl(
      userId: json['userId'] as String,
      consentsToWithdraw: (json['consentsToWithdraw'] as List<dynamic>)
          .map((e) => $enumDecode(_$ConsentTypeEnumMap, e))
          .toList(),
      reason: json['reason'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      deleteAssociatedData: json['deleteAssociatedData'] as bool? ?? false,
      processed: json['processed'] as bool? ?? false,
      processedAt: json['processedAt'] == null
          ? null
          : DateTime.parse(json['processedAt'] as String),
    );

Map<String, dynamic> _$$ConsentWithdrawalRequestImplToJson(
        _$ConsentWithdrawalRequestImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'consentsToWithdraw': instance.consentsToWithdraw
          .map((e) => _$ConsentTypeEnumMap[e]!)
          .toList(),
      'reason': instance.reason,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'deleteAssociatedData': instance.deleteAssociatedData,
      'processed': instance.processed,
      'processedAt': instance.processedAt?.toIso8601String(),
    };
