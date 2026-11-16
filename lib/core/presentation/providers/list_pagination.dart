import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared paging state for async lists. Reset on every new query/build.
///
/// Failed pages leave the list and page number unchanged and propagate to the
/// caller, which owns error feedback. Results and failures from old queries or
/// disposed providers are ignored.
mixin ListPagination<T> on AnyNotifier<AsyncValue<List<T>>, List<T>> {
  int _currentPage = 1;
  int _generation = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  /// Invalidates in-flight pages and returns the generation for the first page.
  int resetPagination() {
    _generation++;
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    return _generation;
  }

  /// Records whether the first page can be followed by another page.
  void updatePagination(List<T> firstPage, int perPage, int generation) {
    if (ref.mounted && generation == _generation) {
      _hasMore = firstPage.length >= perPage;
    }
  }

  /// Appends one page, coalescing overlapping requests for the current query.
  Future<void> loadNextPage({
    required int perPage,
    required Future<List<T>> Function(int page) fetch,
    void Function(List<T> items)? onLoaded,
  }) async {
    if (!ref.mounted ||
        state.isLoading ||
        !state.hasValue ||
        _isLoadingMore ||
        !_hasMore) {
      return;
    }

    final generation = _generation;
    final nextPage = _currentPage + 1;
    _isLoadingMore = true;
    try {
      final items = await fetch(nextPage);
      if (!ref.mounted || generation != _generation) return;

      _hasMore = items.length >= perPage;
      if (items.isNotEmpty) {
        _currentPage = nextPage;
        state = AsyncData([...(state.value ?? <T>[]), ...items]);
        onLoaded?.call(items);
      }
    } on Object {
      if (ref.mounted && generation == _generation) rethrow;
    } finally {
      if (ref.mounted && generation == _generation) _isLoadingMore = false;
    }
  }
}
