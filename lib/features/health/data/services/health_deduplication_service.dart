import '../../domain/models/health_data.dart';

/// Service for handling health data deduplication and smart merging
class HealthDeduplicationService {
  /// Priority order for data sources (higher index = higher priority)
  static const Map<HealthDataSource, int> _sourcePriority = {
    HealthDataSource.unknown: 0,
    HealthDataSource.googleFit: 1,
    HealthDataSource.appleHealth: 2,
    HealthDataSource.manual: 3, // Manual entries have highest priority
  };

  /// Get the priority value for a source
  int getSourcePriority(HealthDataSource source) {
    return _sourcePriority[source] ?? 0;
  }

  /// Compare two sources and return the higher priority one
  HealthDataSource getHigherPrioritySource(
    HealthDataSource source1,
    HealthDataSource source2,
  ) {
    final priority1 = getSourcePriority(source1);
    final priority2 = getSourcePriority(source2);
    return priority1 >= priority2 ? source1 : source2;
  }

  /// Smart merge two HealthData records
  ///
  /// Priority rules:
  /// 1. Manual entries override user-editable fields (weight, sleep)
  /// 2. Activity metrics (steps, calories, distance) prefer synced data
  /// 3. Same source → prefer newer data
  /// 4. Different sources → field-level priority merge
  HealthData smartMerge(HealthData existing, HealthData incoming) {
    final existingPriority = getSourcePriority(existing.source);
    final incomingPriority = getSourcePriority(incoming.source);

    // If same source, prefer newer data
    if (existing.source == incoming.source) {
      return _mergePreferNewest(existing, incoming);
    }

    // Different sources - do field-level merge
    return _fieldLevelMerge(existing, incoming, existingPriority, incomingPriority);
  }

  /// Merge preferring the newest data
  HealthData _mergePreferNewest(HealthData existing, HealthData incoming) {
    final existingTime = existing.syncedAt;
    final incomingTime = incoming.syncedAt;

    // If incoming is newer, use it but preserve any manual overrides
    if (incomingTime.isAfter(existingTime)) {
      return incoming.copyWith(
        // Preserve weight if existing has it and incoming doesn't
        weight: incoming.weight ?? existing.weight,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    // Existing is newer, but update with any new data
    return existing.copyWith(
      // Update steps/distance/calories if incoming has higher values (more activity)
      steps: incoming.steps > existing.steps ? incoming.steps : existing.steps,
      distanceMeters: incoming.distanceMeters > existing.distanceMeters
          ? incoming.distanceMeters
          : existing.distanceMeters,
      caloriesBurned: incoming.caloriesBurned > existing.caloriesBurned
          ? incoming.caloriesBurned
          : existing.caloriesBurned,
      updatedAt: DateTime.now(),
    );
  }

  /// Field-level merge based on source priorities
  HealthData _fieldLevelMerge(
    HealthData existing,
    HealthData incoming,
    int existingPriority,
    int incomingPriority,
  ) {
    final isIncomingHigherPriority = incomingPriority > existingPriority;
    final isManualIncoming = incoming.source == HealthDataSource.manual;
    final isManualExisting = existing.source == HealthDataSource.manual;

    // Determine which source to use for different field types
    final HealthData activitySource;
    final HealthData userEditableSource;

    // For user-editable fields (weight, sleep), manual entries take precedence
    if (isManualIncoming) {
      userEditableSource = incoming;
    } else if (isManualExisting) {
      userEditableSource = existing;
    } else {
      userEditableSource = isIncomingHigherPriority ? incoming : existing;
    }

    // For activity metrics, prefer synced data (not manual)
    // because they come directly from health platforms
    if (isManualIncoming && !isManualExisting) {
      activitySource = existing;
    } else if (!isManualIncoming && isManualExisting) {
      activitySource = incoming;
    } else {
      // Both manual or both synced - prefer higher priority or newer
      activitySource = isIncomingHigherPriority
          ? incoming
          : (incoming.syncedAt.isAfter(existing.syncedAt) ? incoming : existing);
    }

    // Determine final source to record
    final finalSource = getHigherPrioritySource(existing.source, incoming.source);

    return HealthData(
      id: existing.id,
      userId: existing.userId,
      date: existing.date,
      // Activity metrics - prefer synced/platform data
      steps: _selectBestValue(
        activitySource.steps,
        isManualIncoming ? existing.steps : incoming.steps,
        preferHigher: true,
      ),
      distanceMeters: _selectBestDoubleValue(
        activitySource.distanceMeters,
        isManualIncoming ? existing.distanceMeters : incoming.distanceMeters,
        preferHigher: true,
      ),
      caloriesBurned: _selectBestDoubleValue(
        activitySource.caloriesBurned,
        isManualIncoming ? existing.caloriesBurned : incoming.caloriesBurned,
        preferHigher: true,
      ),
      // Heart rate - prefer platform data when available
      averageHeartRate: activitySource.averageHeartRate ??
          userEditableSource.averageHeartRate,
      // User-editable fields - manual entries take precedence
      sleepHours: userEditableSource.sleepHours > 0
          ? userEditableSource.sleepHours
          : activitySource.sleepHours,
      weight: userEditableSource.weight ?? activitySource.weight,
      // Track the highest priority source
      source: finalSource,
      sourceDetails: isIncomingHigherPriority
          ? incoming.sourceDetails
          : existing.sourceDetails,
      syncedAt: DateTime.now(),
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Select the best integer value based on preference
  int _selectBestValue(int primary, int secondary, {bool preferHigher = false}) {
    if (preferHigher) {
      return primary > secondary ? primary : secondary;
    }
    return primary > 0 ? primary : secondary;
  }

  /// Select the best double value based on preference
  double _selectBestDoubleValue(double primary, double secondary, {bool preferHigher = false}) {
    if (preferHigher) {
      return primary > secondary ? primary : secondary;
    }
    return primary > 0 ? primary : secondary;
  }

  /// Check if two health data records should be merged
  /// (same user, same date)
  bool shouldMerge(HealthData existing, HealthData incoming) {
    return existing.userId == incoming.userId &&
        existing.date.year == incoming.date.year &&
        existing.date.month == incoming.date.month &&
        existing.date.day == incoming.date.day;
  }

  /// Deduplicate a list of health data records
  /// Returns a map of date string to merged HealthData
  Map<String, HealthData> deduplicateList(List<HealthData> records) {
    final Map<String, HealthData> deduped = {};

    for (final record in records) {
      final dateKey = record.dateString;

      if (deduped.containsKey(dateKey)) {
        deduped[dateKey] = smartMerge(deduped[dateKey]!, record);
      } else {
        deduped[dateKey] = record;
      }
    }

    return deduped;
  }
}
