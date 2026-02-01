import '../models/models.dart';
import '../repositories/repositories.dart';

/// Service for age verification and parental consent
class AgeVerificationService {
  AgeVerificationService({
    required UnitySettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  final UnitySettingsRepository _settingsRepository;

  /// Minimum age requirement
  static const int minimumAge = 13;

  /// Age for full features (without parental consent)
  static const int fullFeaturesAge = 16;

  /// Verify if a user meets age requirements
  AgeVerificationResult verifyAge(DateTime birthDate) {
    final now = DateTime.now();
    final age = _calculateAge(birthDate, now);

    if (age < minimumAge) {
      return AgeVerificationResult(
        isEligible: false,
        age: age,
        ageGroup: AgeGroup.child,
        requiresParentalConsent: false,
        restrictions: const [
          'You must be at least $minimumAge years old to use Unity',
        ],
        message: 'Sorry, Unity is for users $minimumAge and older.',
      );
    }

    if (age < fullFeaturesAge) {
      return AgeVerificationResult(
        isEligible: true,
        age: age,
        ageGroup: AgeGroup.teen,
        requiresParentalConsent: true,
        restrictions: const [
          'Parent or guardian consent is required',
          'Some social features may be limited',
          'Cannot participate in public challenges',
        ],
        message:
            'Welcome! A parent or guardian will need to approve your account.',
      );
    }

    return AgeVerificationResult(
      isEligible: true,
      age: age,
      ageGroup: AgeGroup.adult,
      requiresParentalConsent: false,
      restrictions: const [],
      message: "You're all set! Full access to Unity features.",
    );
  }

  int _calculateAge(DateTime birthDate, DateTime now) {
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Check if user has verified their age
  Future<bool> isAgeVerified(String userId) async {
    return _settingsRepository.hasConsent(userId, ConsentType.ageVerification);
  }

  /// Record age verification consent
  Future<void> recordAgeVerification({
    required String userId,
    required DateTime birthDate,
  }) async {
    final result = verifyAge(birthDate);

    if (!result.isEligible) {
      throw AgeVerificationException(
        'User does not meet minimum age requirement',
      );
    }

    await _settingsRepository.grantConsent(
      UnityConsent.grant(
        userId: userId,
        type: ConsentType.ageVerification,
      ),
    );
  }

  /// Check if parental consent is needed
  Future<bool> needsParentalConsent(String userId) async {
    final hasAgeConsent =
        await _settingsRepository.hasConsent(userId, ConsentType.ageVerification);

    if (!hasAgeConsent) {
      // Can't determine without age verification
      return false;
    }

    // Check if parental consent is already granted
    return !await _settingsRepository.hasConsent(
      userId,
      ConsentType.parentalConsent,
    );
  }

  /// Request parental consent
  Future<ParentalConsentRequest> requestParentalConsent({
    required String userId,
    required String parentEmail,
    required String childName,
  }) async {
    // In a real implementation, this would send an email to the parent
    // and create a verification token

    final token = _generateConsentToken();
    final expiresAt = DateTime.now().add(const Duration(days: 7));

    return ParentalConsentRequest(
      token: token,
      userId: userId,
      parentEmail: parentEmail,
      childName: childName,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      status: ParentalConsentStatus.pending,
    );
  }

  String _generateConsentToken() {
    // Simple token generation - use proper crypto in production
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'pct_$timestamp';
  }

  /// Verify parental consent token
  Future<bool> verifyParentalConsent({
    required String userId,
    required String token,
  }) async {
    // In a real implementation, verify the token and mark consent as granted
    // For now, just grant the consent

    await _settingsRepository.grantConsent(
      UnityConsent.grant(
        userId: userId,
        type: ConsentType.parentalConsent,
      ),
    );

    return true;
  }

  /// Get feature restrictions for a user's age group
  List<FeatureRestriction> getFeatureRestrictions(AgeGroup ageGroup) {
    switch (ageGroup) {
      case AgeGroup.child:
        return const [
          FeatureRestriction(
            feature: 'all',
            isBlocked: true,
            reason: 'Account not eligible',
          ),
        ];
      case AgeGroup.teen:
        return const [
          FeatureRestriction(
            feature: 'public_challenges',
            isBlocked: true,
            reason: 'Only circle challenges available',
          ),
          FeatureRestriction(
            feature: 'public_circles',
            isBlocked: true,
            reason: 'Only private circles with invited members',
          ),
          FeatureRestriction(
            feature: 'direct_messages',
            isBlocked: true,
            reason: 'Messaging not available',
          ),
        ];
      case AgeGroup.adult:
        return const [];
    }
  }

  /// Check if a specific feature is available for user
  Future<bool> isFeatureAvailable({
    required String userId,
    required String feature,
    required AgeGroup ageGroup,
  }) async {
    final restrictions = getFeatureRestrictions(ageGroup);
    final featureRestriction = restrictions.firstWhere(
      (r) => r.feature == feature || r.feature == 'all',
      orElse: () => const FeatureRestriction(
        feature: '',
        isBlocked: false,
        reason: '',
      ),
    );

    if (featureRestriction.isBlocked) {
      return false;
    }

    // For teens, check parental consent
    if (ageGroup == AgeGroup.teen) {
      return await _settingsRepository.hasConsent(
        userId,
        ConsentType.parentalConsent,
      );
    }

    return true;
  }
}

/// Result of age verification
class AgeVerificationResult {
  const AgeVerificationResult({
    required this.isEligible,
    required this.age,
    required this.ageGroup,
    required this.requiresParentalConsent,
    required this.restrictions,
    required this.message,
  });

  final bool isEligible;
  final int age;
  final AgeGroup ageGroup;
  final bool requiresParentalConsent;
  final List<String> restrictions;
  final String message;
}

/// Age groups for feature access
enum AgeGroup {
  child, // Under 13
  teen, // 13-15
  adult, // 16+
}

extension AgeGroupExtension on AgeGroup {
  String get displayName {
    switch (this) {
      case AgeGroup.child:
        return 'Child';
      case AgeGroup.teen:
        return 'Teen';
      case AgeGroup.adult:
        return 'Adult';
    }
  }
}

/// Parental consent request
class ParentalConsentRequest {
  const ParentalConsentRequest({
    required this.token,
    required this.userId,
    required this.parentEmail,
    required this.childName,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
  });

  final String token;
  final String userId;
  final String parentEmail;
  final String childName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final ParentalConsentStatus status;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Status of parental consent request
enum ParentalConsentStatus {
  pending,
  approved,
  denied,
  expired,
}

/// Feature restriction based on age
class FeatureRestriction {
  const FeatureRestriction({
    required this.feature,
    required this.isBlocked,
    required this.reason,
  });

  final String feature;
  final bool isBlocked;
  final String reason;
}

/// Exception for age verification failures
class AgeVerificationException implements Exception {
  const AgeVerificationException(this.message);
  final String message;

  @override
  String toString() => 'AgeVerificationException: $message';
}
