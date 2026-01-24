import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/paginated_result.dart';

/// Base class for paginated data notifiers
///
/// Usage:
/// ```dart
/// class MealsPaginationNotifier extends PaginationNotifier<Meal> {
///   final MealRepository _repository;
///
///   MealsPaginationNotifier(this._repository) : super(pageSize: 20);
///
///   @override
///   Future<PaginatedResult<Meal>> fetchPage(int page, dynamic cursor) {
///     return _repository.getMealsPaginated(
///       pageSize: pageSize,
///       startAfter: cursor,
///     );
///   }
/// }
/// ```
abstract class PaginationNotifier<T> extends StateNotifier<PaginationState<T>> {
  final int pageSize;

  PaginationNotifier({this.pageSize = 20})
      : super(PaginationState.initial(pageSize: pageSize));

  /// Override this to implement the actual data fetching
  Future<PaginatedResult<T>> fetchPage(int page, dynamic cursor);

  /// Load the first page (refresh)
  Future<void> loadFirstPage() async {
    if (state.status == PaginationStatus.loading) return;

    state = state.copyWith(
      status: PaginationStatus.loading,
      errorMessage: null,
    );

    try {
      final result = await fetchPage(0, null);

      state = PaginationState(
        result: result,
        status: result.hasMore
            ? PaginationStatus.loaded
            : PaginationStatus.complete,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaginationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load the next page
  Future<void> loadNextPage() async {
    if (!state.canLoadMore) return;
    if (state.status == PaginationStatus.loadingMore) return;

    state = state.copyWith(status: PaginationStatus.loadingMore);

    try {
      final nextPage = state.result.page + 1;
      final result = await fetchPage(nextPage, state.result.nextCursor);

      state = PaginationState(
        result: state.result.appendPage(result),
        status: result.hasMore
            ? PaginationStatus.loaded
            : PaginationStatus.complete,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaginationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh the list (reload from first page)
  Future<void> refresh() async {
    state = PaginationState.initial(pageSize: pageSize);
    await loadFirstPage();
  }

  /// Add an item to the beginning of the list (optimistic update)
  void prependItem(T item) {
    final newItems = [item, ...state.result.items];
    state = state.copyWith(
      result: state.result.copyWith(items: newItems),
    );
  }

  /// Remove an item from the list (optimistic update)
  void removeItem(T item) {
    final newItems = state.result.items.where((i) => i != item).toList();
    state = state.copyWith(
      result: state.result.copyWith(items: newItems),
    );
  }

  /// Remove an item by predicate (optimistic update)
  void removeWhere(bool Function(T item) test) {
    final newItems = state.result.items.where((i) => !test(i)).toList();
    state = state.copyWith(
      result: state.result.copyWith(items: newItems),
    );
  }

  /// Update an item in the list (optimistic update)
  void updateItem(T oldItem, T newItem) {
    final newItems = state.result.items.map((i) {
      return i == oldItem ? newItem : i;
    }).toList();
    state = state.copyWith(
      result: state.result.copyWith(items: newItems),
    );
  }

  /// Update an item by predicate (optimistic update)
  void updateWhere(bool Function(T item) test, T newItem) {
    final newItems = state.result.items.map((i) {
      return test(i) ? newItem : i;
    }).toList();
    state = state.copyWith(
      result: state.result.copyWith(items: newItems),
    );
  }
}

/// Provider creator helper for pagination notifiers
///
/// Usage:
/// ```dart
/// final mealsPaginationProvider = StateNotifierProvider<
///     MealsPaginationNotifier, PaginationState<Meal>>((ref) {
///   final repository = ref.watch(mealRepositoryProvider);
///   return MealsPaginationNotifier(repository);
/// });
/// ```

/// Extension for easy access to pagination actions
extension PaginationStateNotifierProviderExtension<T>
    on StateNotifierProvider<PaginationNotifier<T>, PaginationState<T>> {
  /// Load first page using the notifier
  void loadFirstPage(WidgetRef ref) {
    ref.read(notifier).loadFirstPage();
  }

  /// Load next page using the notifier
  void loadNextPage(WidgetRef ref) {
    ref.read(notifier).loadNextPage();
  }

  /// Refresh using the notifier
  void refresh(WidgetRef ref) {
    ref.read(notifier).refresh();
  }
}

/// Auto-disposing version for screen-level pagination
abstract class AutoDisposePaginationNotifier<T>
    extends AutoDisposeNotifier<PaginationState<T>> {
  int get pageSize => 20;

  @override
  PaginationState<T> build() {
    return PaginationState.initial(pageSize: pageSize);
  }

  /// Override this to implement the actual data fetching
  Future<PaginatedResult<T>> fetchPage(int page, dynamic cursor);

  /// Load the first page
  Future<void> loadFirstPage() async {
    if (state.status == PaginationStatus.loading) return;

    state = state.copyWith(
      status: PaginationStatus.loading,
      errorMessage: null,
    );

    try {
      final result = await fetchPage(0, null);

      state = PaginationState(
        result: result,
        status: result.hasMore
            ? PaginationStatus.loaded
            : PaginationStatus.complete,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaginationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load the next page
  Future<void> loadNextPage() async {
    if (!state.canLoadMore) return;
    if (state.status == PaginationStatus.loadingMore) return;

    state = state.copyWith(status: PaginationStatus.loadingMore);

    try {
      final nextPage = state.result.page + 1;
      final result = await fetchPage(nextPage, state.result.nextCursor);

      state = PaginationState(
        result: state.result.appendPage(result),
        status: result.hasMore
            ? PaginationStatus.loaded
            : PaginationStatus.complete,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaginationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Refresh the list
  Future<void> refresh() async {
    state = PaginationState.initial(pageSize: pageSize);
    await loadFirstPage();
  }
}
