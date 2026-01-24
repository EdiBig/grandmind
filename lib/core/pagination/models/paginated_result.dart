/// Paginated result model for Firestore cursor-based pagination
class PaginatedResult<T> {
  /// The items for this page
  final List<T> items;

  /// Whether there are more items to load
  final bool hasMore;

  /// Cursor for fetching the next page (last document snapshot)
  final dynamic nextCursor;

  /// Total count (if available, otherwise -1)
  final int totalCount;

  /// Current page number (0-indexed)
  final int page;

  /// Page size used for this query
  final int pageSize;

  const PaginatedResult({
    required this.items,
    required this.hasMore,
    this.nextCursor,
    this.totalCount = -1,
    this.page = 0,
    this.pageSize = 20,
  });

  /// Create an empty result
  factory PaginatedResult.empty({int pageSize = 20}) {
    return PaginatedResult(
      items: [],
      hasMore: false,
      pageSize: pageSize,
    );
  }

  /// Create initial loading state
  factory PaginatedResult.loading({int pageSize = 20}) {
    return PaginatedResult(
      items: [],
      hasMore: true,
      pageSize: pageSize,
    );
  }

  /// Whether this is the first page
  bool get isFirstPage => page == 0;

  /// Whether there are any items
  bool get isEmpty => items.isEmpty;

  /// Whether there are items
  bool get isNotEmpty => items.isNotEmpty;

  /// Number of items in this result
  int get length => items.length;

  /// Copy with new values
  PaginatedResult<T> copyWith({
    List<T>? items,
    bool? hasMore,
    dynamic nextCursor,
    int? totalCount,
    int? page,
    int? pageSize,
  }) {
    return PaginatedResult(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Append items from another page
  PaginatedResult<T> appendPage(PaginatedResult<T> nextPage) {
    return PaginatedResult(
      items: [...items, ...nextPage.items],
      hasMore: nextPage.hasMore,
      nextCursor: nextPage.nextCursor,
      totalCount: nextPage.totalCount,
      page: nextPage.page,
      pageSize: pageSize,
    );
  }

  @override
  String toString() {
    return 'PaginatedResult(items: ${items.length}, hasMore: $hasMore, page: $page)';
  }
}

/// State for paginated data loading
enum PaginationStatus {
  /// Initial state, no data loaded yet
  initial,

  /// Currently loading first page
  loading,

  /// Currently loading more items
  loadingMore,

  /// Data loaded successfully
  loaded,

  /// Error occurred
  error,

  /// All data has been loaded (no more pages)
  complete,
}

/// Pagination state wrapper
class PaginationState<T> {
  final PaginatedResult<T> result;
  final PaginationStatus status;
  final String? errorMessage;

  const PaginationState({
    required this.result,
    required this.status,
    this.errorMessage,
  });

  factory PaginationState.initial({int pageSize = 20}) {
    return PaginationState(
      result: PaginatedResult.empty(pageSize: pageSize),
      status: PaginationStatus.initial,
    );
  }

  factory PaginationState.loading({int pageSize = 20}) {
    return PaginationState(
      result: PaginatedResult.loading(pageSize: pageSize),
      status: PaginationStatus.loading,
    );
  }

  bool get isLoading =>
      status == PaginationStatus.loading ||
      status == PaginationStatus.loadingMore;

  bool get canLoadMore =>
      status != PaginationStatus.loading &&
      status != PaginationStatus.loadingMore &&
      result.hasMore;

  bool get hasError => status == PaginationStatus.error;

  bool get isEmpty =>
      status == PaginationStatus.loaded && result.isEmpty;

  List<T> get items => result.items;

  PaginationState<T> copyWith({
    PaginatedResult<T>? result,
    PaginationStatus? status,
    String? errorMessage,
  }) {
    return PaginationState(
      result: result ?? this.result,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
