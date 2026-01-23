import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../models/paginated_result.dart';

/// A ListView that supports infinite scroll pagination
class PaginatedListView<T> extends StatefulWidget {
  /// The pagination state containing items and loading status
  final PaginationState<T> state;

  /// Called when more items should be loaded
  final VoidCallback? onLoadMore;

  /// Builder for each item
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Builder for the loading indicator at the bottom
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Builder for empty state
  final Widget Function(BuildContext context)? emptyBuilder;

  /// Builder for error state
  final Widget Function(BuildContext context, String? error)? errorBuilder;

  /// Builder for initial loading state
  final Widget Function(BuildContext context)? initialLoadingBuilder;

  /// Separator between items (optional)
  final Widget Function(BuildContext context, int index)? separatorBuilder;

  /// Header widget above the list
  final Widget? header;

  /// Footer widget below the list (before load more indicator)
  final Widget? footer;

  /// Scroll physics
  final ScrollPhysics? physics;

  /// Scroll controller
  final ScrollController? controller;

  /// Padding around the list
  final EdgeInsetsGeometry? padding;

  /// Whether to shrink wrap the list
  final bool shrinkWrap;

  /// Threshold to trigger load more (distance from bottom in pixels)
  final double loadMoreThreshold;

  /// Whether the list scrolls in reverse
  final bool reverse;

  const PaginatedListView({
    super.key,
    required this.state,
    required this.itemBuilder,
    this.onLoadMore,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.initialLoadingBuilder,
    this.separatorBuilder,
    this.header,
    this.footer,
    this.physics,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.loadMoreThreshold = 200,
    this.reverse = false,
  });

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_onScroll);
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_isLoadingMore &&
        widget.state.canLoadMore &&
        widget.onLoadMore != null) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      final threshold = widget.loadMoreThreshold;

      if (currentScroll >= maxScroll - threshold) {
        _isLoadingMore = true;
        widget.onLoadMore!();
      }
    }
  }

  @override
  void didUpdateWidget(PaginatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset loading flag when state changes
    if (oldWidget.state.status != widget.state.status) {
      _isLoadingMore = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    // Initial loading
    if (state.status == PaginationStatus.initial ||
        (state.status == PaginationStatus.loading && state.items.isEmpty)) {
      return widget.initialLoadingBuilder?.call(context) ??
          const Center(child: CircularProgressIndicator());
    }

    // Error with no items
    if (state.hasError && state.items.isEmpty) {
      return widget.errorBuilder?.call(context, state.errorMessage) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'An error occurred'),
                if (widget.onLoadMore != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.onLoadMore,
                    child: const Text('Retry'),
                  ),
                ],
              ],
            ),
          );
    }

    // Empty state
    if (state.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No items found'));
    }

    // Build list
    return _buildList(state);
  }

  Widget _buildList(PaginationState<T> state) {
    final items = state.items;
    final hasHeader = widget.header != null;
    final hasFooter = widget.footer != null;
    final showLoadMore = state.status == PaginationStatus.loadingMore ||
        (state.canLoadMore && state.items.isNotEmpty);

    // Calculate total count
    int itemCount = items.length;
    if (hasHeader) itemCount++;
    if (hasFooter) itemCount++;
    if (showLoadMore) itemCount++;

    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: _scrollController,
        physics: widget.physics,
        padding: widget.padding,
        shrinkWrap: widget.shrinkWrap,
        reverse: widget.reverse,
        itemCount: itemCount,
        separatorBuilder: (context, index) {
          // Don't show separator for header/footer/load more
          if (hasHeader && index == 0) return const SizedBox.shrink();
          if (hasFooter && index == itemCount - 2) return const SizedBox.shrink();
          if (showLoadMore && index == itemCount - 2) return const SizedBox.shrink();

          final adjustedIndex = hasHeader ? index - 1 : index;
          return widget.separatorBuilder!(context, adjustedIndex);
        },
        itemBuilder: (context, index) =>
            _buildItem(context, index, items, hasHeader, hasFooter, showLoadMore, state),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: widget.physics,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      reverse: widget.reverse,
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          _buildItem(context, index, items, hasHeader, hasFooter, showLoadMore, state),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    List<T> items,
    bool hasHeader,
    bool hasFooter,
    bool showLoadMore,
    PaginationState<T> state,
  ) {
    // Header
    if (hasHeader && index == 0) {
      return widget.header!;
    }

    // Adjust index for header
    int adjustedIndex = hasHeader ? index - 1 : index;

    // Items
    if (adjustedIndex < items.length) {
      return widget.itemBuilder(context, items[adjustedIndex], adjustedIndex);
    }

    // Footer
    if (hasFooter && adjustedIndex == items.length) {
      return widget.footer!;
    }

    // Load more indicator
    if (showLoadMore) {
      if (state.status == PaginationStatus.loadingMore) {
        return widget.loadingBuilder?.call(context) ??
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
      }
      // Invisible trigger for preloading
      return const SizedBox(height: 1);
    }

    return const SizedBox.shrink();
  }
}

/// A SliverList that supports infinite scroll pagination
class PaginatedSliverList<T> extends StatelessWidget {
  final PaginationState<T> state;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;

  const PaginatedSliverList({
    super.key,
    required this.state,
    required this.itemBuilder,
    this.loadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final items = state.items;
    final showLoadMore = state.status == PaginationStatus.loadingMore;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < items.length) {
            return itemBuilder(context, items[index], index);
          }
          if (showLoadMore) {
            return loadingBuilder?.call(context) ??
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
          }
          return null;
        },
        childCount: items.length + (showLoadMore ? 1 : 0),
      ),
    );
  }
}

/// Load more button widget for manual pagination
class LoadMoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String? label;

  const LoadMoreButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : OutlinedButton(
                onPressed: onPressed,
                child: Text(label ?? 'Load More'),
              ),
      ),
    );
  }
}
