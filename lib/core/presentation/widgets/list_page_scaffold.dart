import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../../utils/responsive.dart';
import 'error_state_view.dart';
import '../../utils/pagination.dart';

/// A standardized scaffold for all list and grid pages in StashFlow.
///
/// This widget provides a consistent layout for browsing content, including:
/// * An [AppBar] with integrated search and custom actions.
/// * An optional [sortBar] for filtering or ordering results.
/// * Automatic handling of [AsyncValue] states (loading, error, data).
/// * Built-in [RefreshIndicator] and pagination logic.
/// * Support for both [ListView] and [GridView] layouts.
class ListPageScaffold<T> extends ConsumerStatefulWidget {
  const ListPageScaffold({
    super.key,
    required this.title,
    required this.searchHint,
    required this.onSearchChanged,
    required this.provider,
    this.itemBuilder,
    this.customBody,
    this.gridDelegate,
    this.actions = const [],
    this.sortBar,
    this.emptyMessage = 'No items found',
    this.onRefresh,
    this.onFetchNextPage,
    this.floatingActionButton,
    this.padding = const EdgeInsets.all(AppTheme.spacingMedium),
    this.hideAppBar = false,
    this.scrollController,
    this.useResponsiveGrid = true,
    this.mobileCrossAxisCount,
    this.tabletCrossAxisCount,
  });

  /// The page title displayed in the AppBar.
  final String title;

  /// The hint text shown in the search field.
  final String searchHint;

  /// Callback triggered when the search query changes.
  final ValueChanged<String> onSearchChanged;

  /// The [AsyncValue] provider supplying the list of items [T].
  final AsyncValue<List<T>> provider;

  /// Builder function for individual list/grid items.
  final Widget Function(BuildContext context, T item)? itemBuilder;

  /// Optional custom body to replace the default list/grid view.
  final Widget? customBody;

  /// Delegate for grid layouts. If null, a [ListView] is used.
  final SliverGridDelegate? gridDelegate;

  /// Custom actions for the AppBar.
  final List<Widget> actions;

  /// Optional widget displayed between the AppBar and the list (e.g., a filter chip row).
  final Widget? sortBar;

  /// Message displayed when the data list is empty.
  final String emptyMessage;

  /// Callback for the [RefreshIndicator].
  final Future<void> Function()? onRefresh;

  /// Callback triggered when scrolling near the bottom (infinite scroll).
  final VoidCallback? onFetchNextPage;

  /// Optional FAB for the page.
  final Widget? floatingActionButton;

  /// Padding applied to the list/grid.
  final EdgeInsetsGeometry padding;

  /// If true, the AppBar is omitted.
  final bool hideAppBar;

  /// Custom [ScrollController] for tracking scroll position externally.
  final ScrollController? scrollController;

  /// Whether to automatically adapt the grid column count for larger screens.
  final bool useResponsiveGrid;

  /// Optional override for the number of columns on mobile.
  final int? mobileCrossAxisCount;

  /// Optional override for the number of columns on tablet.
  final int? tabletCrossAxisCount;

  @override
  ConsumerState<ListPageScaffold<T>> createState() =>
      _ListPageScaffoldState<T>();
}

class _ListPageScaffoldState<T> extends ConsumerState<ListPageScaffold<T>> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  SliverGridDelegate _getResponsiveGridDelegate(BuildContext context) {
    final delegate = widget.gridDelegate!;
    if (delegate is! SliverGridDelegateWithFixedCrossAxisCount) {
      return delegate;
    }

    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < Responsive.mobileBreakpoint;
    final isTablet =
        width >= Responsive.mobileBreakpoint &&
        width < Responsive.tabletBreakpoint;

    int count = delegate.crossAxisCount;

    if (isMobile && widget.mobileCrossAxisCount != null) {
      count = widget.mobileCrossAxisCount!;
    } else if (isTablet && widget.tabletCrossAxisCount != null) {
      count = widget.tabletCrossAxisCount!;
    } else if (width >= Responsive.tabletBreakpoint &&
        widget.tabletCrossAxisCount != null) {
      // Also apply tablet count for desktop if desktop count is not specified
      count = widget.tabletCrossAxisCount!;
    } else if (widget.useResponsiveGrid && !isMobile) {
      count = 3;
    }

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: count,
      mainAxisSpacing: delegate.mainAxisSpacing,
      crossAxisSpacing: delegate.crossAxisSpacing,
      childAspectRatio: delegate.childAspectRatio,
      mainAxisExtent: delegate.mainAxisExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              scrolledUnderElevation: 4.0,
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: widget.searchHint,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      style: TextStyle(color: context.colors.onSurface),
                      onChanged: widget.onSearchChanged,
                    )
                  : Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
              actions: [
                if (_isSearching)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => _isSearching = false);
                      _searchController.clear();
                      widget.onSearchChanged('');
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _isSearching = true),
                  ),
                ...widget.actions,
              ],
            ),
      body: Column(
        children: [
          if (widget.sortBar != null) widget.sortBar!,
          Expanded(
            child:
                widget.customBody ??
                RefreshIndicator(
                  onRefresh: widget.onRefresh ?? () async {},
                  child: widget.provider.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            widget.emptyMessage,
                            style: TextStyle(
                              color: context.colors.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                        );
                      }

                      return NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (shouldLoadNextPage(scrollInfo.metrics)) {
                            widget.onFetchNextPage?.call();
                          }
                          return false;
                        },
                        child: widget.gridDelegate != null
                            ? GridView.builder(
                                controller: widget.scrollController,
                                padding: widget.padding,
                                gridDelegate: _getResponsiveGridDelegate(
                                  context,
                                ),
                                itemCount: items.length,
                                itemBuilder: (context, index) =>
                                    widget.itemBuilder!(context, items[index]),
                              )
                            : ListView.builder(
                                controller: widget.scrollController,
                                padding: widget.padding,
                                itemCount: items.length,
                                itemBuilder: (context, index) =>
                                    widget.itemBuilder!(context, items[index]),
                              ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => ErrorStateView(
                      message: 'Failed to load items.\n$err',
                      onRetry: widget.onRefresh,
                    ),
                  ),
                ),
          ),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
