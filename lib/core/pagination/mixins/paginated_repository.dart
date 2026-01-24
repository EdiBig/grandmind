import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/paginated_result.dart';

/// Mixin providing cursor-based pagination for Firestore repositories
mixin PaginatedRepository {
  /// Default page size
  static const int defaultPageSize = 20;

  /// Execute a paginated query
  ///
  /// [baseQuery] - The base Firestore query (with filters but no limit)
  /// [pageSize] - Number of items per page
  /// [startAfterDocument] - Document snapshot to start after (for pagination)
  /// [fromJson] - Function to convert Firestore document to model
  Future<PaginatedResult<T>> executePaginatedQuery<T>({
    required Query baseQuery,
    required T Function(Map<String, dynamic> json) fromJson,
    int pageSize = defaultPageSize,
    DocumentSnapshot? startAfterDocument,
    int page = 0,
  }) async {
    // Build query with pagination
    Query query = baseQuery.limit(pageSize + 1); // Fetch one extra to check hasMore

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    // Execute query
    final snapshot = await query.get();
    final docs = snapshot.docs;

    // Determine if there are more items
    final hasMore = docs.length > pageSize;

    // Get the actual items (excluding the extra one)
    final itemDocs = hasMore ? docs.take(pageSize).toList() : docs;

    // Convert to models
    final items = itemDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return fromJson({...data, 'id': doc.id});
    }).toList();

    // Get cursor for next page
    final nextCursor = itemDocs.isNotEmpty ? itemDocs.last : null;

    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Execute a paginated query with real-time updates (first page only)
  ///
  /// For real-time updates with pagination, typically only the first page
  /// is streamed. Use [executePaginatedQuery] for loading more pages.
  Stream<PaginatedResult<T>> streamFirstPage<T>({
    required Query baseQuery,
    required T Function(Map<String, dynamic> json) fromJson,
    int pageSize = defaultPageSize,
  }) {
    final query = baseQuery.limit(pageSize + 1);

    return query.snapshots().map((snapshot) {
      final docs = snapshot.docs;
      final hasMore = docs.length > pageSize;
      final itemDocs = hasMore ? docs.take(pageSize).toList() : docs;

      final items = itemDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return fromJson({...data, 'id': doc.id});
      }).toList();

      final nextCursor = itemDocs.isNotEmpty ? itemDocs.last : null;

      return PaginatedResult(
        items: items,
        hasMore: hasMore,
        nextCursor: nextCursor,
        page: 0,
        pageSize: pageSize,
      );
    });
  }

  /// Helper to normalize Firestore document data
  Map<String, dynamic> normalizeDocument(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? <String, dynamic>{};
    return {...data, 'id': doc.id};
  }

  /// Helper to convert Timestamp fields to ISO strings
  Map<String, dynamic> normalizeTimestamps(
    Map<String, dynamic> data,
    List<String> timestampFields,
  ) {
    final normalized = Map<String, dynamic>.from(data);

    for (final field in timestampFields) {
      final value = normalized[field];
      if (value is Timestamp) {
        normalized[field] = value.toDate().toIso8601String();
      }
    }

    return normalized;
  }
}

/// Extension for Query to add pagination helpers
extension PaginatedQueryExtension on Query {
  /// Add pagination to a query
  Query paginate({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
  }) {
    Query query = limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query;
  }
}
