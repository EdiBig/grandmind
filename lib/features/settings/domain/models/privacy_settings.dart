class PrivacySettings {
  final bool profileVisible;
  final bool shareProgress;
  final bool shareAchievements;
  final bool allowPersonalization;
  final bool allowUsageData;
  final bool allowCrashReports;

  const PrivacySettings({
    required this.profileVisible,
    required this.shareProgress,
    required this.shareAchievements,
    required this.allowPersonalization,
    required this.allowUsageData,
    required this.allowCrashReports,
  });

  factory PrivacySettings.defaults() {
    return const PrivacySettings(
      profileVisible: false,
      shareProgress: false,
      shareAchievements: true,
      allowPersonalization: true,
      allowUsageData: true,
      allowCrashReports: true,
    );
  }

  factory PrivacySettings.fromPreferences(Map<String, dynamic>? preferences) {
    final privacy = preferences?['privacy'];
    if (privacy is! Map) {
      return PrivacySettings.defaults();
    }

    bool readBool(String key, bool fallback) {
      final value = privacy[key];
      return value is bool ? value : fallback;
    }

    final defaults = PrivacySettings.defaults();
    return PrivacySettings(
      profileVisible: readBool('profileVisible', defaults.profileVisible),
      shareProgress: readBool('shareProgress', defaults.shareProgress),
      shareAchievements: readBool('shareAchievements', defaults.shareAchievements),
      allowPersonalization:
          readBool('allowPersonalization', defaults.allowPersonalization),
      allowUsageData: readBool('allowUsageData', defaults.allowUsageData),
      allowCrashReports: readBool('allowCrashReports', defaults.allowCrashReports),
    );
  }
}
