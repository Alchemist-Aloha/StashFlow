import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../providers/desktop_capabilities_provider.dart';
import 'error_state_view.dart';
import '../../utils/pagination.dart';
import 'stash_image.dart';
import '../../data/graphql/media_headers_provider.dart';
import '../../data/preferences/search_history_provider.dart';
import 'grid_utils.dart';

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
    this.searchHistoryKey,
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
    this.useMasonry = false,
    this.mobileCrossAxisCount,
    this.tabletCrossAxisCount,
    this.onSortPressed,
    this.onFilterPressed,
    this.imageUrlBuilder,
    this.memCacheWidthBuilder,
    this.prefetchDistance = StashImage.defaultPrefetchDistance,
    this.itemExtent,
    this.onPageSizeChanged,
  });

  /// The page title displayed in the AppBar.
  final String title;

  /// Whether to use a dynamic height Masonry grid layout instead of fixed ratio.
  final bool useMasonry;

  /// The hint text shown in the search field.
  final String searchHint;

  /// Callback triggered when the search query changes.
  final ValueChanged<String> onSearchChanged;

  /// Optional storage key for search history. Defaults to a sanitized title if null.
  final String? searchHistoryKey;

  /// Optional callback for the sort action in the AppBar.
  final VoidCallback? onSortPressed;

  /// Optional callback for the filter action in the AppBar.
  final VoidCallback? onFilterPressed;

  /// The [AsyncValue] provider supplying the list of items [T].
  final AsyncValue<List<T>> provider;

  /// Builder function for individual list/grid items.
  /// Receives the [item] and optional [memCacheWidth] / [memCacheHeight] for optimization.
  final Widget Function(
    BuildContext context,
    T item,
    int? memCacheWidth,
    int? memCacheHeight,
  )?
  itemBuilder;

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

  /// Optional callback to get the image URL for an item. If provided, prefetching is enabled.
  final String? Function(T item)? imageUrlBuilder;

  /// Optional callback to get the memCacheWidth for prefetching.
  final int? Function(BuildContext context, bool isGrid)? memCacheWidthBuilder;

  /// Distance (in items) to prefetch ahead and behind the visible range.
  final int prefetchDistance;

  /// Optional fixed extent (height for list, or main axis extent for grid if applicable) for items.
  /// For list view, this enables [ListView.itemExtent] optimization.
  final double? itemExtent;

  /// Triggered when the calculated page size (fitting 2 screens) changes.
  final ValueChanged<int>? onPageSizeChanged;

  @override
  ConsumerState<ListPageScaffold<T>> createState() =>
      _ListPageScaffoldState<T>();
}

class _ListPageScaffoldState<T> extends ConsumerState<ListPageScaffold<T>> {
  late final String _historyKey;
  final _searchController = SearchController();
  String? _currentQuery;
  String? _lastSubmittedText;

  // Prefetch state
  bool _didPrefetchInitial = false;
  double? _measuredItemExtent;
  int? _lastVisibleIndexPrefetched;
  final GlobalKey _firstItemKey = GlobalKey();

  DateTime? _lastHorizontalSwipeTime;
  static const _horizontalSwipeThreshold = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _historyKey =
        widget.searchHistoryKey ??
        'search_history_${widget.title.toLowerCase().replaceAll(' ', '_')}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ListPageScaffold<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider != widget.provider) {
      // Reset prefetch flag when the data set potentially changes.
      _didPrefetchInitial = false;
    }
  }

  SliverGridDelegate _getResponsiveGridDelegate(BuildContext context) {
    final delegate =
        widget.gridDelegate ?? GridUtils.createDelegate(crossAxisCount: 1);
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
    } else if (widget.useResponsiveGrid &&
        !isMobile &&
        widget.gridDelegate == null) {
      // Only apply default responsive override (3 columns) if NO explicit gridDelegate was provided.
      // If a gridDelegate was provided (e.g., from a user setting), we respect its count.
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

  int _getEffectivePrefetchDistance(BuildContext context) {
    final itemsInTwoScreens = GridUtils.calculateItemsPerPage(
      context: context,
      gridDelegate: widget.gridDelegate != null
          ? _getResponsiveGridDelegate(context)
          : null,
      padding: widget.padding,
      screens: 2.0,
      itemExtent: widget.itemExtent,
      measuredItemExtent: _measuredItemExtent,
    );

    return itemsInTwoScreens > widget.prefetchDistance
        ? itemsInTwoScreens
        : widget.prefetchDistance;
  }

  void _handleInitialPrefetch(List<T> items) {
    if (_didPrefetchInitial ||
        items.isEmpty ||
        widget.imageUrlBuilder == null ||
        !mounted) {
      return;
    }

    _didPrefetchInitial = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final prefetchDistance = _getEffectivePrefetchDistance(context);

      if (widget.onPageSizeChanged != null) {
        widget.onPageSizeChanged!(prefetchDistance);
      }

      final count = items.length < prefetchDistance
          ? items.length
          : prefetchDistance;
      final headers = ref.read(mediaHeadersProvider);
      final isGrid = widget.gridDelegate != null;

      int? memCacheWidth;
      if (widget.memCacheWidthBuilder != null) {
        memCacheWidth = widget.memCacheWidthBuilder!(context, isGrid);
      } else {
        final screenWidth = MediaQuery.sizeOf(context).width;
        if (isGrid) {
          final delegate =
              _getResponsiveGridDelegate(context)
                  as SliverGridDelegateWithFixedCrossAxisCount;
          // Target roughly 1.5x the display width in pixels for the cache to balance
          // quality and memory. We assume a typical device pixel ratio of 2.0-3.0.
          memCacheWidth = (screenWidth / delegate.crossAxisCount * 1.5).toInt();
        } else {
          // For full-width list items, cap at a reasonable thumbnail width.
          memCacheWidth = screenWidth > 600 ? 600 : screenWidth.toInt();
        }
      }

      for (int i = 0; i < count; i++) {
        final url = widget.imageUrlBuilder!(items[i]);
        if (url != null) {
          StashImage.prefetch(
            context,
            imageUrl: url,
            headers: headers,
            memCacheWidth: memCacheWidth,
          );
        }
      }
    });
  }

  void _handleScrollPrefetch(ScrollNotification scrollInfo, List<T> items) {
    if (widget.imageUrlBuilder == null || items.isEmpty || !mounted) return;
    if (scrollInfo.metrics.axis != Axis.vertical) return;

    final offset = scrollInfo.metrics.pixels;
    final isGrid = widget.gridDelegate != null;
    final headers = ref.read(mediaHeadersProvider);
    final prefetchDistance = _getEffectivePrefetchDistance(context);

    int? memCacheWidth;
    if (widget.memCacheWidthBuilder != null) {
      memCacheWidth = widget.memCacheWidthBuilder!(context, isGrid);
    } else {
      final screenWidth = MediaQuery.sizeOf(context).width;
      if (isGrid) {
        final delegate =
            _getResponsiveGridDelegate(context)
                as SliverGridDelegateWithFixedCrossAxisCount;
        memCacheWidth = (screenWidth / delegate.crossAxisCount * 1.5).toInt();
      } else {
        memCacheWidth = screenWidth > 600 ? 600 : screenWidth.toInt();
      }
    }

    if (isGrid) {
      final delegate =
          _getResponsiveGridDelegate(context)
              as SliverGridDelegateWithFixedCrossAxisCount;
      final crossAxisCount = delegate.crossAxisCount;
      final padding = widget.padding is EdgeInsets
          ? (widget.padding as EdgeInsets).horizontal
          : 0.0;
      final availableWidth = MediaQuery.sizeOf(context).width - padding;
      final itemWidth =
          (availableWidth -
              (delegate.crossAxisSpacing * (crossAxisCount - 1))) /
          crossAxisCount;

      final itemHeight =
          delegate.mainAxisExtent ?? (itemWidth / delegate.childAspectRatio);
      final stride = itemHeight + delegate.mainAxisSpacing;

      final visibleRow = (offset / stride).floor().clamp(0, items.length - 1);
      final visibleIndex = (visibleRow * crossAxisCount).clamp(
        0,
        items.length - 1,
      );

      if (visibleIndex == _lastVisibleIndexPrefetched) return;
      _lastVisibleIndexPrefetched = visibleIndex;

      for (var i = 1; i <= prefetchDistance; i++) {
        final ahead = visibleIndex + i;
        if (ahead < items.length) {
          final url = widget.imageUrlBuilder!(items[ahead]);
          if (url != null) {
            StashImage.prefetch(
              context,
              imageUrl: url,
              headers: headers,
              memCacheWidth: memCacheWidth,
            );
          }
        }
        final behind = visibleIndex - i;
        if (behind >= 0) {
          final url = widget.imageUrlBuilder!(items[behind]);
          if (url != null) {
            StashImage.prefetch(
              context,
              imageUrl: url,
              headers: headers,
              memCacheWidth: memCacheWidth,
            );
          }
        }
      }
    } else {
      final stride = widget.itemExtent ?? _measuredItemExtent ?? 300.0;
      final visibleIndex = (offset / stride).floor().clamp(0, items.length - 1);

      if (visibleIndex == _lastVisibleIndexPrefetched) return;
      _lastVisibleIndexPrefetched = visibleIndex;

      for (var i = 1; i <= prefetchDistance; i++) {
        final ahead = visibleIndex + i;
        if (ahead < items.length) {
          final url = widget.imageUrlBuilder!(items[ahead]);
          if (url != null) {
            StashImage.prefetch(
              context,
              imageUrl: url,
              headers: headers,
              memCacheWidth: memCacheWidth,
            );
          }
        }
        final behind = visibleIndex - i;
        if (behind >= 0) {
          final url = widget.imageUrlBuilder!(items[behind]);
          if (url != null) {
            StashImage.prefetch(
              context,
              imageUrl: url,
              headers: headers,
              memCacheWidth: memCacheWidth,
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ref.watch(desktopCapabilitiesProvider);

    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              scrolledUnderElevation: 4.0,
              title: Text(
                widget.title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              actions: [
                if (widget.onSortPressed != null)
                  IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: widget.onSortPressed,
                    tooltip: context.l10n.common_sort,
                  ),
                if (widget.onFilterPressed != null)
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: widget.onFilterPressed,
                    tooltip: context.l10n.common_filter,
                  ),
                SearchAnchor(
                  searchController: _searchController,
                  viewOnClose: () {
                    final text = _searchController.text;
                    if (text != _lastSubmittedText) {
                      _lastSubmittedText = text;
                      setState(() {
                        _currentQuery = text.isEmpty ? null : text;
                      });
                      widget.onSearchChanged(text);
                      if (text.isNotEmpty) {
                        ref
                            .read(searchHistoryProvider(_historyKey).notifier)
                            .addQuery(text);
                      }
                    }
                  },
                  builder: (BuildContext context, SearchController controller) {
                    return IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _lastSubmittedText = _searchController.text;
                        controller.openView();
                      },
                      tooltip: context.l10n.common_search,
                    );
                  },
                  viewHintText: widget.searchHint,
                  viewOnSubmitted: (value) {
                    _searchController.closeView(value);
                  },
                  suggestionsBuilder:
                      (BuildContext context, SearchController controller) {
                        return [
                          Consumer(
                            builder: (context, ref, _) {
                              final history = ref.watch(
                                searchHistoryProvider(_historyKey),
                              );
                              return Column(
                                children: [
                                  if (history.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Recent Searches',
                                            style: context.textTheme.titleSmall?.copyWith(
                                              color: context.colors.onSurface
                                                  .withValues(alpha: 0.7),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    searchHistoryProvider(
                                                      _historyKey,
                                                    ).notifier,
                                                  )
                                                  .clearAll();
                                            },
                                            child: const Text('Clear History'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ...history.map((item) {
                                    return ListTile(
                                      leading: const Icon(Icons.history),
                                      title: Text(item),
                                      trailing: IconButton(
                                        tooltip: context.l10n.common_close,
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          ref
                                              .read(
                                                searchHistoryProvider(
                                                  _historyKey,
                                                ).notifier,
                                              )
                                              .removeQuery(item);
                                        },
                                      ),
                                      onTap: () {
                                        controller.closeView(item);
                                      },
                                    );
                                  }),
                                ],
                              );
                            },
                          ),
                        ];
                      },
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.push('/settings'),
                  tooltip: context.l10n.common_settings,
                ),
                ...widget.actions,
              ],
            ),
      body: Listener(
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            // Horizontal swipe for navigation (Back)
            if (isDesktop && pointerSignal.scrollDelta.dx.abs() > 30) {
              final now = DateTime.now();
              if (_lastHorizontalSwipeTime == null ||
                  now.difference(_lastHorizontalSwipeTime!) >
                      _horizontalSwipeThreshold) {
                if (pointerSignal.scrollDelta.dx < -30) {
                  // Swipe right (negative dx) -> Go Back
                  if (context.canPop()) {
                    _lastHorizontalSwipeTime = now;
                    context.pop();
                  }
                }
              }
            }

            // Vertical scroll for refresh (Pull to refresh on trackpad)
            if (widget.onRefresh != null &&
                widget.scrollController != null &&
                widget.scrollController!.hasClients &&
                widget.scrollController!.position.pixels <= 0 &&
                pointerSignal.scrollDelta.dy < -50) {
              widget.onRefresh!();
            }
          }
        },
        child: Column(
          children: [
            if (_currentQuery != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: context.colors.surfaceVariant,
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Searching for: "$_currentQuery"',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.common_close,
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          _currentQuery = null;
                        });
                        widget.onSearchChanged('');
                      },
                    ),
                  ],
                ),
              ),
            if (widget.sortBar != null) widget.sortBar!,
            Expanded(
              child: widget.provider.when(
                data: (items) {
                  _handleInitialPrefetch(items);

                  if (items.isEmpty && widget.customBody == null) {
                    return RefreshIndicator(
                      onRefresh: widget.onRefresh ?? () async {},
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.7,
                          child: Center(
                            child: Text(
                              widget.emptyMessage == 'No items found'
                                  ? context.l10n.common_no_items
                                  : widget.emptyMessage,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colors.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  final isGrid = widget.gridDelegate != null;
                  final responsiveDelegate = isGrid ? _getResponsiveGridDelegate(context) : null;
                  final fixedDelegate = responsiveDelegate is SliverGridDelegateWithFixedCrossAxisCount ? responsiveDelegate : null;

                  int? memCacheWidth;
                  if (widget.itemBuilder != null) {
                    if (widget.memCacheWidthBuilder != null) {
                      memCacheWidth = widget.memCacheWidthBuilder!(
                        context,
                        isGrid,
                      );
                    } else {
                      final screenWidth = MediaQuery.sizeOf(context).width;
                      if (fixedDelegate != null) {
                        memCacheWidth =
                            (screenWidth / fixedDelegate.crossAxisCount * 1.5)
                                .toInt();
                      } else {
                        memCacheWidth = screenWidth > 600
                            ? 600
                            : screenWidth.toInt();
                      }
                    }
                  }

                  Widget body = widget.customBody ??
                      (isGrid
                          ? (widget.useMasonry
                              ? MasonryGridView.builder(
                                  controller: widget.scrollController,
                                  padding: widget.padding,
                                  gridDelegate:
                                      SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: fixedDelegate?.crossAxisCount ?? 1,
                                      ),
                                  mainAxisSpacing: fixedDelegate?.mainAxisSpacing ?? 0.0,
                                  crossAxisSpacing: fixedDelegate?.crossAxisSpacing ?? 0.0,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    if (index == 0 &&
                                        widget.imageUrlBuilder != null &&
                                        _measuredItemExtent == null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (_measuredItemExtent == null &&
                                                _firstItemKey.currentContext !=
                                                    null) {
                                              final size = _firstItemKey
                                                  .currentContext!
                                                  .size;
                                              if (size != null) {
                                                setState(() {
                                                  _measuredItemExtent =
                                                      size.height;
                                                });
                                              }
                                            }
                                          });
                                    }

                                    return RepaintBoundary(
                                      child: KeyedSubtree(
                                        key: index == 0 ? _firstItemKey : null,
                                        child: widget.itemBuilder!(
                                          context,
                                          items[index],
                                          memCacheWidth,
                                          null,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : GridView.builder(
                                  controller: widget.scrollController,
                                  padding: widget.padding,
                                  gridDelegate: responsiveDelegate!,
                                  itemCount: items.length,
                                  itemBuilder: (context, index) {
                                    if (index == 0 &&
                                        widget.imageUrlBuilder != null &&
                                        _measuredItemExtent == null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (_measuredItemExtent == null &&
                                                _firstItemKey.currentContext !=
                                                    null) {
                                              final size = _firstItemKey
                                                  .currentContext!
                                                  .size;
                                              if (size != null) {
                                                setState(() {
                                                  _measuredItemExtent =
                                                      size.height;
                                                });
                                              }
                                            }
                                          });
                                    }

                                    return RepaintBoundary(
                                      child: KeyedSubtree(
                                        key: index == 0 ? _firstItemKey : null,
                                        child: widget.itemBuilder!(
                                          context,
                                          items[index],
                                          memCacheWidth,
                                          null,
                                        ),
                                      ),
                                    );
                                  },
                                ))
                          : ListView.builder(
                              controller: widget.scrollController,
                              padding: widget.padding,
                              itemCount: items.length,
                              itemExtent: widget.itemExtent,
                              itemBuilder: (context, index) {
                                if (index == 0 &&
                                    widget.imageUrlBuilder != null &&
                                    widget.itemExtent == null &&
                                    _measuredItemExtent == null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (_measuredItemExtent == null &&
                                        _firstItemKey.currentContext != null) {
                                      final size =
                                          _firstItemKey.currentContext!.size;
                                      if (size != null) {
                                        setState(() {
                                          _measuredItemExtent = size.height;
                                        });
                                      }
                                    }
                                  });
                                }

                                return RepaintBoundary(
                                  child: KeyedSubtree(
                                    key: index == 0 ? _firstItemKey : null,
                                    child: widget.itemBuilder!(
                                      context,
                                      items[index],
                                      memCacheWidth,
                                      null,
                                    ),
                                  ),
                                );
                              },
                            ));

                  if (widget.onRefresh != null) {
                    body = RefreshIndicator(
                      onRefresh: widget.onRefresh!,
                      child: body,
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (shouldLoadNextPage(scrollInfo.metrics)) {
                        widget.onFetchNextPage?.call();
                      }
                      _handleScrollPrefetch(scrollInfo, items);
                      return false;
                    },
                    child: body,
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ErrorStateView(
                  message: context.l10n.common_error(err.toString()),
                  onRetry: widget.onRefresh,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}
