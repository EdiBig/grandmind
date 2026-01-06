import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:kinesa/features/ai/data/models/cache_entry.dart';
import 'package:kinesa/core/config/ai_config.dart';

/// Three-tier caching repository for AI responses
/// Tier 1: In-memory (session-only, fastest)
/// Tier 2: SharedPreferences (24-hour TTL)
/// Tier 3: Firestore (persistent, cross-device)
class AICacheRepository {
  final SharedPreferences _prefs;
  final FirebaseFirestore _firestore;
  final Logger _logger;

  // Tier 1: In-memory cache (fastest, session-only)
  final Map<String, CacheEntry> _memoryCache = {};

  // Cache key prefixes
  static const String _cacheKeyPrefix = 'ai_cache_';
  static const String _statsKey = 'ai_cache_stats';

  // Collection name in Firestore
  static const String _cacheCollection = 'ai_cache';

  // Statistics tracking
  CacheStats _stats = const CacheStats(
    totalRequests: 0,
    cacheHits: 0,
    cacheMisses: 0,
    totalCostSaved: 0.0,
    tier1Hits: 0,
    tier2Hits: 0,
    tier3Hits: 0,
  );

  AICacheRepository({
    required SharedPreferences prefs,
    required FirebaseFirestore firestore,
    Logger? logger,
  })  : _prefs = prefs,
        _firestore = firestore,
        _logger = logger ?? Logger() {
    _loadStats();
    _logger.i('AICacheRepository initialized');
  }

  // ============================================================================
  // PUBLIC API
  // ============================================================================

  /// Look up a cached response for a given prompt
  /// Returns null if no valid cache entry exists
  Future<CacheEntry?> getCachedResponse({
    required String systemPrompt,
    required String userPrompt,
    String? userId,
    String? promptType,
  }) async {
    final promptHash = _generatePromptHash(systemPrompt, userPrompt);
    _logger.d('Looking up cache for promptHash: $promptHash');

    _incrementTotalRequests();

    // Tier 1: Check in-memory cache (fastest)
    final memoryEntry = _getFromMemory(promptHash);
    if (memoryEntry != null && memoryEntry.isValid) {
      _logger.d('✓ Tier 1 HIT (in-memory)');
      _incrementCacheHit(tier: 1, costSaved: memoryEntry.cost);
      return memoryEntry;
    }

    // Tier 2: Check SharedPreferences (fast)
    final prefsEntry = await _getFromPrefs(promptHash);
    if (prefsEntry != null && prefsEntry.isValid) {
      _logger.d('✓ Tier 2 HIT (SharedPreferences)');
      _saveToMemory(promptHash, prefsEntry); // Promote to Tier 1
      _incrementCacheHit(tier: 2, costSaved: prefsEntry.cost);
      return prefsEntry;
    }

    // Tier 3: Check Firestore (slower, but persistent)
    final firestoreEntry = await _getFromFirestore(promptHash, userId);
    if (firestoreEntry != null && firestoreEntry.isValid) {
      _logger.d('✓ Tier 3 HIT (Firestore)');
      _saveToMemory(promptHash, firestoreEntry); // Promote to Tier 1
      await _saveToPrefs(promptHash, firestoreEntry); // Promote to Tier 2
      _incrementCacheHit(tier: 3, costSaved: firestoreEntry.cost);
      return firestoreEntry;
    }

    // Cache MISS
    _logger.d('✗ CACHE MISS');
    _incrementCacheMiss();
    return null;
  }

  /// Save a new response to all cache tiers
  Future<void> cacheResponse({
    required String systemPrompt,
    required String userPrompt,
    required String response,
    required int inputTokens,
    required int outputTokens,
    required double cost,
    String? userId,
    String? promptType,
    Map<String, dynamic>? metadata,
  }) async {
    final promptHash = _generatePromptHash(systemPrompt, userPrompt);
    final now = DateTime.now();
    final expiresAt = now.add(Duration(hours: AIConfig.cacheExpiryHours));

    final cacheEntry = CacheEntry(
      id: const Uuid().v4(),
      promptHash: promptHash,
      response: response,
      createdAt: now,
      expiresAt: expiresAt,
      inputTokens: inputTokens,
      outputTokens: outputTokens,
      cost: cost,
      userId: userId,
      promptType: promptType,
      metadata: metadata,
    );

    _logger.d('Caching response (hash: $promptHash, expires: $expiresAt)');

    // Save to all tiers
    _saveToMemory(promptHash, cacheEntry);
    await _saveToPrefs(promptHash, cacheEntry);
    await _saveToFirestore(cacheEntry);

    _logger.i('Response cached to all tiers');
  }

  /// Clear all caches (useful for testing or user logout)
  Future<void> clearAll() async {
    _logger.i('Clearing all caches');

    // Clear Tier 1
    _memoryCache.clear();

    // Clear Tier 2
    final keys = _prefs.getKeys().where((k) => k.startsWith(_cacheKeyPrefix));
    for (final key in keys) {
      await _prefs.remove(key);
    }

    // Tier 3: Only clear user-specific entries (not global cache)
    // This requires userId to be passed, so we skip global clear for Firestore
    _logger.w('Firestore cache not cleared (requires user-specific operation)');

    _logger.i('Memory and SharedPreferences caches cleared');
  }

  /// Clear expired cache entries from all tiers
  Future<void> cleanupExpired() async {
    _logger.i('Starting cache cleanup');

    // Tier 1: Remove expired from memory
    _memoryCache.removeWhere((key, entry) {
      if (entry.isExpired) {
        _logger.d('Removing expired from memory: $key');
        return true;
      }
      return false;
    });

    // Tier 2: Remove expired from SharedPreferences
    final keys = _prefs.getKeys().where((k) => k.startsWith(_cacheKeyPrefix));
    for (final key in keys) {
      final jsonString = _prefs.getString(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          final entry = CacheEntry.fromJson(json);
          if (entry.isExpired) {
            await _prefs.remove(key);
            _logger.d('Removing expired from prefs: $key');
          }
        } catch (e) {
          _logger.e('Error parsing cache entry during cleanup: $e');
          await _prefs.remove(key);
        }
      }
    }

    // Tier 3: Remove expired from Firestore (batch delete)
    try {
      final now = DateTime.now();
      final expiredDocs = await _firestore
          .collection(_cacheCollection)
          .where('expiresAt', isLessThan: now.toIso8601String())
          .limit(500) // Batch limit
          .get();

      final batch = _firestore.batch();
      for (final doc in expiredDocs.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _logger.i('Removed ${expiredDocs.docs.length} expired entries from Firestore');
    } catch (e) {
      _logger.e('Error cleaning Firestore cache: $e');
    }

    _logger.i('Cache cleanup complete');
  }

  /// Get cache statistics
  CacheStats getStats() => _stats;

  /// Reset cache statistics
  Future<void> resetStats() async {
    _stats = const CacheStats(
      totalRequests: 0,
      cacheHits: 0,
      cacheMisses: 0,
      totalCostSaved: 0.0,
      tier1Hits: 0,
      tier2Hits: 0,
      tier3Hits: 0,
      periodStart: null,
      periodEnd: null,
    );
    await _saveStats();
    _logger.i('Cache statistics reset');
  }

  /// Get cache size information
  Future<Map<String, int>> getCacheSizes() async {
    final tier1Size = _memoryCache.length;

    final tier2Keys =
        _prefs.getKeys().where((k) => k.startsWith(_cacheKeyPrefix));
    final tier2Size = tier2Keys.length;

    int tier3Size = 0;
    try {
      final snapshot =
          await _firestore.collection(_cacheCollection).count().get();
      tier3Size = snapshot.count ?? 0;
    } catch (e) {
      _logger.e('Error getting Firestore cache size: $e');
    }

    return {
      'tier1': tier1Size,
      'tier2': tier2Size,
      'tier3': tier3Size,
      'total': tier1Size + tier2Size + tier3Size,
    };
  }

  // ============================================================================
  // TIER 1: IN-MEMORY CACHE
  // ============================================================================

  CacheEntry? _getFromMemory(String promptHash) {
    return _memoryCache[promptHash];
  }

  void _saveToMemory(String promptHash, CacheEntry entry) {
    _memoryCache[promptHash] = entry;
  }

  // ============================================================================
  // TIER 2: SHARED PREFERENCES CACHE
  // ============================================================================

  Future<CacheEntry?> _getFromPrefs(String promptHash) async {
    final key = _cacheKeyPrefix + promptHash;
    final jsonString = _prefs.getString(key);

    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CacheEntry.fromJson(json);
    } catch (e) {
      _logger.e('Error parsing cache entry from prefs: $e');
      await _prefs.remove(key);
      return null;
    }
  }

  Future<void> _saveToPrefs(String promptHash, CacheEntry entry) async {
    final key = _cacheKeyPrefix + promptHash;
    final jsonString = jsonEncode(entry.toJson());
    await _prefs.setString(key, jsonString);
  }

  // ============================================================================
  // TIER 3: FIRESTORE CACHE
  // ============================================================================

  Future<CacheEntry?> _getFromFirestore(
    String promptHash,
    String? userId,
  ) async {
    try {
      // Query by promptHash
      var query = _firestore
          .collection(_cacheCollection)
          .where('promptHash', isEqualTo: promptHash)
          .orderBy('createdAt', descending: true)
          .limit(1);

      // Optionally filter by userId for user-specific caching
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      return CacheEntryExtensions.fromFirestore(doc.data());
    } catch (e) {
      _logger.e('Error fetching from Firestore cache: $e');
      return null;
    }
  }

  Future<void> _saveToFirestore(CacheEntry entry) async {
    try {
      await _firestore
          .collection(_cacheCollection)
          .doc(entry.id)
          .set(entry.toFirestore());
    } catch (e) {
      _logger.e('Error saving to Firestore cache: $e');
      // Don't throw - caching failure shouldn't break the app
    }
  }

  // ============================================================================
  // STATISTICS TRACKING
  // ============================================================================

  void _incrementTotalRequests() {
    _stats = _stats.copyWith(
      totalRequests: _stats.totalRequests + 1,
    );
    _saveStats();
  }

  void _incrementCacheHit({required int tier, required double costSaved}) {
    _stats = _stats.copyWith(
      cacheHits: _stats.cacheHits + 1,
      totalCostSaved: _stats.totalCostSaved + costSaved,
      tier1Hits: tier == 1 ? _stats.tier1Hits + 1 : _stats.tier1Hits,
      tier2Hits: tier == 2 ? _stats.tier2Hits + 1 : _stats.tier2Hits,
      tier3Hits: tier == 3 ? _stats.tier3Hits + 1 : _stats.tier3Hits,
    );
    _saveStats();
  }

  void _incrementCacheMiss() {
    _stats = _stats.copyWith(
      cacheMisses: _stats.cacheMisses + 1,
    );
    _saveStats();
  }

  Future<void> _loadStats() async {
    final jsonString = _prefs.getString(_statsKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        _stats = CacheStats.fromJson(json);
        _logger.d('Loaded cache stats: ${_stats.hitRate.toStringAsFixed(1)}% hit rate');
      } catch (e) {
        _logger.e('Error loading cache stats: $e');
      }
    }
  }

  Future<void> _saveStats() async {
    try {
      final jsonString = jsonEncode(_stats.toJson());
      await _prefs.setString(_statsKey, jsonString);
    } catch (e) {
      _logger.e('Error saving cache stats: $e');
    }
  }

  // ============================================================================
  // UTILITIES
  // ============================================================================

  /// Generate a deterministic hash for a prompt
  String _generatePromptHash(String systemPrompt, String userPrompt) {
    final combined = '$systemPrompt|||$userPrompt';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
