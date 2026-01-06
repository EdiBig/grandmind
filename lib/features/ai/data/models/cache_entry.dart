import 'package:freezed_annotation/freezed_annotation.dart';

part 'cache_entry.freezed.dart';
part 'cache_entry.g.dart';

/// Represents a cached AI response with metadata
@freezed
class CacheEntry with _$CacheEntry {
  const factory CacheEntry({
    required String id,
    required String promptHash,
    required String response,
    required DateTime createdAt,
    required DateTime expiresAt,
    required int inputTokens,
    required int outputTokens,
    required double cost,
    String? userId,
    String? promptType,
    Map<String, dynamic>? metadata,
  }) = _CacheEntry;

  factory CacheEntry.fromJson(Map<String, dynamic> json) =>
      _$CacheEntryFromJson(json);
}

extension CacheEntryExtensions on CacheEntry {
  /// Check if this cache entry is still valid
  bool get isValid => DateTime.now().isBefore(expiresAt);

  /// Check if this cache entry has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get time remaining until expiry
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());

  /// Calculate cache age
  Duration get age => DateTime.now().difference(createdAt);

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'promptHash': promptHash,
      'response': response,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'inputTokens': inputTokens,
      'outputTokens': outputTokens,
      'cost': cost,
      if (userId != null) 'userId': userId,
      if (promptType != null) 'promptType': promptType,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create from Firestore document
  static CacheEntry fromFirestore(Map<String, dynamic> doc) {
    return CacheEntry(
      id: doc['id'] as String,
      promptHash: doc['promptHash'] as String,
      response: doc['response'] as String,
      createdAt: DateTime.parse(doc['createdAt'] as String),
      expiresAt: DateTime.parse(doc['expiresAt'] as String),
      inputTokens: doc['inputTokens'] as int,
      outputTokens: doc['outputTokens'] as int,
      cost: (doc['cost'] as num).toDouble(),
      userId: doc['userId'] as String?,
      promptType: doc['promptType'] as String?,
      metadata: doc['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Request object for cache lookup
@freezed
class CacheLookupRequest with _$CacheLookupRequest {
  const factory CacheLookupRequest({
    required String promptHash,
    String? userId,
    String? promptType,
  }) = _CacheLookupRequest;
}

/// Statistics about cache usage
@freezed
class CacheStats with _$CacheStats {
  const factory CacheStats({
    required int totalRequests,
    required int cacheHits,
    required int cacheMisses,
    required double totalCostSaved,
    required int tier1Hits,
    required int tier2Hits,
    required int tier3Hits,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) = _CacheStats;

  factory CacheStats.fromJson(Map<String, dynamic> json) =>
      _$CacheStatsFromJson(json);
}

extension CacheStatsExtensions on CacheStats {
  /// Calculate cache hit rate as percentage
  double get hitRate {
    if (totalRequests == 0) return 0.0;
    return (cacheHits / totalRequests) * 100;
  }

  /// Calculate cache miss rate as percentage
  double get missRate {
    if (totalRequests == 0) return 0.0;
    return (cacheMisses / totalRequests) * 100;
  }

  /// Get distribution of hits across tiers
  Map<String, int> get tierDistribution => {
        'tier1': tier1Hits,
        'tier2': tier2Hits,
        'tier3': tier3Hits,
      };

  /// Calculate average cost saved per hit
  double get averageCostSavedPerHit {
    if (cacheHits == 0) return 0.0;
    return totalCostSaved / cacheHits;
  }
}
