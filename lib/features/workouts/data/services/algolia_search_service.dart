import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class AlgoliaSearchService {
  AlgoliaSearchService({
    required String appId,
    required String searchKey,
    required String indexName,
    Dio? dio,
  })  : _isConfigured =
            appId.isNotEmpty && searchKey.isNotEmpty && indexName.isNotEmpty,
        _dio = dio ?? Dio(),
        _appId = appId,
        _searchKey = searchKey,
        _indexName = indexName;

  final Dio _dio;
  final String _appId;
  final String _searchKey;
  final String _indexName;
  final bool _isConfigured;

  Future<List<String>> searchWorkoutIds(
    String query, {
    int limit = 50,
    String? filters,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    if (!_isConfigured) return [];

    final endpoint =
        'https://$_appId-dsn.algolia.net/1/indexes/$_indexName/query';
    final paramPairs = <String>[
      'query=${Uri.encodeQueryComponent(trimmed)}',
      'hitsPerPage=$limit',
    ];
    if (filters != null && filters.trim().isNotEmpty) {
      paramPairs.add('filters=${Uri.encodeQueryComponent(filters)}');
    }
    final params = paramPairs.join('&');
    try {
      final response = await _dio.post(
        endpoint,
        data: {'params': params},
        options: Options(
          headers: {
            'X-Algolia-API-Key': _searchKey,
            'X-Algolia-Application-Id': _appId,
          },
        ),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final hits = data['hits'];
        if (hits is List) {
          return hits
              .whereType<Map>()
              .map((hit) => hit['objectID'])
              .whereType<String>()
              .toList();
        }
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Algolia search failed: $error');
      }
    }
    return [];
  }
}

class AlgoliaConfig {
  static String get appId =>
      const String.fromEnvironment('ALGOLIA_APP_ID', defaultValue: '');
  static String get searchKey =>
      const String.fromEnvironment('ALGOLIA_SEARCH_KEY', defaultValue: '');
  static String get indexName =>
      const String.fromEnvironment('ALGOLIA_INDEX', defaultValue: '');

  static bool get isValid =>
      appId.isNotEmpty && searchKey.isNotEmpty && indexName.isNotEmpty;
}

final algoliaSearchServiceProvider = Provider<AlgoliaSearchService>((ref) {
  if (kDebugMode && !AlgoliaConfig.isValid) {
    debugPrint('Algolia keys missing. Falling back to Firestore search.');
  }
  return AlgoliaSearchService(
    appId: AlgoliaConfig.appId,
    searchKey: AlgoliaConfig.searchKey,
    indexName: AlgoliaConfig.indexName,
  );
});
