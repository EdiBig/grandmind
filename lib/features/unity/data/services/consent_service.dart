import '../models/models.dart';
import '../repositories/repositories.dart';

/// Service for managing Unity consents
class ConsentService {
  ConsentService({
    required UnitySettingsRepository settingsRepository,
  }) : _settingsRepository = settingsRepository;

  final UnitySettingsRepository _settingsRepository;

  /// Get required consents for joining a challenge
  List<ConsentRequirement> getRequiredConsents({
    bool hasHealthMetrics = true,
    bool hasCompetitiveElements = false,
  }) {
    final requirements = <ConsentRequirement>[];

    // Always required
    requirements.add(const ConsentRequirement(
      type: ConsentType.dataSharing,
      title: 'Data Sharing',
      description: 'Share your progress with other challenge participants',
      isRequired: true,
    ));

    if (hasHealthMetrics) {
      requirements.add(const ConsentRequirement(
        type: ConsentType.healthDisclaimer,
        title: 'Health & Safety',
        description:
            'I understand the physical nature of this challenge and will listen to my body',
        isRequired: true,
      ));
    }

    return requirements;
  }

  /// Get optional consents for joining a challenge
  List<ConsentRequirement> getOptionalConsents({
    bool hasLeaderboard = false,
    bool hasActivityFeed = true,
  }) {
    final requirements = <ConsentRequirement>[];

    if (hasLeaderboard) {
      requirements.add(const ConsentRequirement(
        type: ConsentType.rankingsDisplay,
        title: 'Show in Rankings',
        description: 'Display my progress in the challenge leaderboard',
        isRequired: false,
        defaultValue: true,
      ));
    }

    if (hasActivityFeed) {
      requirements.add(const ConsentRequirement(
        type: ConsentType.activityFeed,
        title: 'Activity Feed',
        description: 'Share my activities in the challenge feed',
        isRequired: false,
        defaultValue: true,
      ));
    }

    return requirements;
  }

  /// Grant consent for a user
  Future<String> grantConsent({
    required String userId,
    required ConsentType type,
    String? challengeId,
  }) async {
    final consent = UnityConsent.grant(
      userId: userId,
      type: type,
      challengeId: challengeId,
    );

    return _settingsRepository.grantConsent(consent);
  }

  /// Revoke consent for a user
  Future<void> revokeConsent({
    required String userId,
    required ConsentType type,
    String? challengeId,
  }) async {
    await _settingsRepository.revokeConsentByType(
      userId,
      type,
      challengeId: challengeId,
    );
  }

  /// Check if user has required consents
  Future<bool> hasRequiredConsents(String userId) async {
    return _settingsRepository.hasAllRequiredConsents(userId);
  }

  /// Get missing required consents
  Future<List<ConsentType>> getMissingConsents(String userId) async {
    return _settingsRepository.getMissingRequiredConsents(userId);
  }

  /// Validate and grant multiple consents
  Future<ConsentValidationResult> validateAndGrantConsents({
    required String userId,
    required List<ConsentGrant> grants,
    String? challengeId,
  }) async {
    final errors = <String>[];
    final granted = <ConsentType>[];

    // Check required consents are included
    final requiredTypes =
        ConsentType.values.where((t) => t.isRequired).toList();
    for (final required in requiredTypes) {
      final grant = grants.firstWhere(
        (g) => g.type == required,
        orElse: () => ConsentGrant(type: required, granted: false),
      );

      if (!grant.granted) {
        errors.add('${required.displayName} is required');
      }
    }

    if (errors.isNotEmpty) {
      return ConsentValidationResult(
        success: false,
        errors: errors,
        grantedConsents: [],
      );
    }

    // Grant all consents
    for (final grant in grants) {
      if (grant.granted) {
        await grantConsent(
          userId: userId,
          type: grant.type,
          challengeId: challengeId,
        );
        granted.add(grant.type);
      }
    }

    return ConsentValidationResult(
      success: true,
      errors: [],
      grantedConsents: granted,
    );
  }

  /// Get all active consents for a user
  Future<ConsentCollection> getUserConsents(String userId) async {
    return _settingsRepository.getConsents(userId);
  }

  /// Get consent text for display
  ConsentText getConsentText(ConsentType type) {
    return ConsentText.currentVersions[type] ??
        ConsentText(
          type: type,
          version: 1,
          title: type.displayName,
          description: 'Consent for ${type.displayName}',
          fullText: '',
          effectiveDate: DateTime.now(),
        );
  }

  /// Check if a specific consent is granted
  Future<bool> hasConsent(
    String userId,
    ConsentType type, {
    String? challengeId,
  }) async {
    return _settingsRepository.hasConsent(
      userId,
      type,
      challengeId: challengeId,
    );
  }

  /// Generate consent summary for display
  Future<ConsentSummary> getConsentSummary(String userId) async {
    final consents = await getUserConsents(userId);

    return ConsentSummary(
      hasAllRequired: consents.hasAllRequired,
      missingRequired: consents.missingRequired,
      activeConsents: consents.activeConsents.map((c) => c.type).toList(),
    );
  }
}

/// Represents a consent requirement
class ConsentRequirement {
  const ConsentRequirement({
    required this.type,
    required this.title,
    required this.description,
    required this.isRequired,
    this.defaultValue = false,
  });

  final ConsentType type;
  final String title;
  final String description;
  final bool isRequired;
  final bool defaultValue;
}

/// Represents a consent grant request
class ConsentGrant {
  const ConsentGrant({
    required this.type,
    required this.granted,
  });

  final ConsentType type;
  final bool granted;
}

/// Result of consent validation
class ConsentValidationResult {
  const ConsentValidationResult({
    required this.success,
    required this.errors,
    required this.grantedConsents,
  });

  final bool success;
  final List<String> errors;
  final List<ConsentType> grantedConsents;
}

/// Summary of user's consent status
class ConsentSummary {
  const ConsentSummary({
    required this.hasAllRequired,
    required this.missingRequired,
    required this.activeConsents,
  });

  final bool hasAllRequired;
  final List<ConsentType> missingRequired;
  final List<ConsentType> activeConsents;
}
