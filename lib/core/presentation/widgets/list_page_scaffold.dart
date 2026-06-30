import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/services.dart';
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
import '../../data/preferences/search_history_provider.dart';
import '../../../features/scenes/presentation/widgets/scene_card.dart';
import 'grid_utils.dart';
import 'stats_floating_panel.dart';

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
    this.actionsInTopPanel = false,
    this.sortBar,
    this.emptyMessage = 'No items found',
    this.onRefresh,
    this.onFetchNextPage,
    this.floatingActionButton,
    this.padding,
    this.hideAppBar = false,
    this.scrollController,
    this.useResponsiveGrid = true,
    this.useMasonry = false,
    this.mobileCrossAxisCount,
    this.tabletCrossAxisCount,
    this.onSortPressed,
    this.onFilterPressed,
    this.memCacheWidthBuilder,
    this.itemExtent,
    this.onPageSizeChanged,
    this.loadingItemBuilder,
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
  final EdgeInsetsGeometry? padding;

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

  /// Optional callback to get the memCacheWidth for prefetching.
  final int? Function(BuildContext context, bool isGrid)? memCacheWidthBuilder;

  /// Optional fixed extent (height for list, or main axis extent for grid if applicable) for items.
  /// For list view, this enables [ListView.itemExtent] optimization.
  final double? itemExtent;

  /// Triggered when the calculated page size (fitting 2 screens) changes.
  final ValueChanged<int>? onPageSizeChanged;

  /// Optional builder used for loading placeholders.
  final Widget Function(BuildContext context, bool isGrid, int index)?
  loadingItemBuilder;

  /// Whether to render [actions] in the top AppBar instead of the floating bottom pill.
  final bool actionsInTopPanel;

  @override
  ConsumerState<ListPageScaffold<T>> createState() =>
      _ListPageScaffoldState<T>();
}

class _ListPageScaffoldState<T> extends ConsumerState<ListPageScaffold<T>> {
  late final String _historyKey;
  final _searchController = SearchController();
  String? _currentQuery;
  String? _lastSubmittedText;

  bool _pageSizeReportScheduled = false;
  int? _lastReportedPageSize;
  double? _measuredItemExtent;
  final GlobalKey _firstItemKey = GlobalKey();

  DateTime? _lastHorizontalSwipeTime;
  static const _horizontalSwipeThreshold = Duration(milliseconds: 500);

  DateTime? _lastFetchTime;
  static const _fetchThreshold = Duration(milliseconds: 500);

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

  int _getPageSize(
    BuildContext context,
    SliverGridDelegate? responsiveDelegate,
  ) {
    final effectivePadding =
        widget.padding ?? EdgeInsets.all(context.dimensions.spacingMedium);
    return GridUtils.calculateItemsPerPage(
      context: context,
      gridDelegate: responsiveDelegate,
      padding: effectivePadding,
      screens: 2.0,
      itemExtent: widget.itemExtent,
      measuredItemExtent: _measuredItemExtent,
    );
  }

  void _reportPageSize(SliverGridDelegate? responsiveDelegate) {
    if (_pageSizeReportScheduled ||
        widget.onPageSizeChanged == null ||
        !mounted) {
      return;
    }

    _pageSizeReportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _pageSizeReportScheduled = false;
      final pageSize = _getPageSize(context, responsiveDelegate);
      if (pageSize == _lastReportedPageSize) return;
      _lastReportedPageSize = pageSize;
      widget.onPageSizeChanged!(pageSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ref.watch(desktopCapabilitiesProvider);

    // Hoist layout values out of the build sub-trees.
    // Why: Previously, MediaQuery.sizeOf and _getResponsiveGridDelegate were queried repeatedly
    // during layout and scroll operations.
    // Impact: Avoids multiple O(1) inherited widget lookups and redundant layout mathematics per frame.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final viewportCacheExtent = MediaQuery.sizeOf(context).height;
    final isGrid = widget.gridDelegate != null;
    final responsiveDelegate = isGrid
        ? _getResponsiveGridDelegate(context)
        : null;
    final fixedDelegate =
        responsiveDelegate is SliverGridDelegateWithFixedCrossAxisCount
        ? responsiveDelegate
        : null;

    return Scaffold(
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              scrolledUnderElevation: 4.0,
              title: Tooltip(
                message: context.l10n.stats_library_stats_tooltip,
                child: Material(
                  color: Colors.transparent,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  child: InkWell(
                    onLongPress: () {
                      HapticFeedback.lightImpact();
                      StatsFloatingPanel.show(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.dimensions.spacingSmall,
                        vertical: context.dimensions.spacingSmall / 2,
                      ),
                      child: Text(
                        widget.title,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
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
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                            context.dimensions.spacingMedium,
                                        vertical:
                                            context.dimensions.spacingSmall,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            context.l10n.recent_searches,
                                            style: context.textTheme.titleSmall
                                                ?.copyWith(
                                                  color: context
                                                      .colors
                                                      .onSurface
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
                                            child: Text(
                                              context.l10n.common_clear_history,
                                            ),
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
                  icon: const Icon(Icons.construction),
                  onPressed: () => context.push('/tools'),
                  tooltip: context.l10n.tools,
                ),
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.push('/settings'),
                  tooltip: context.l10n.common_settings,
                ),
                if (widget.actionsInTopPanel) ...widget.actions,
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
                pointerSignal.kind == PointerDeviceKind.trackpad &&
                pointerSignal.scrollDelta.dy < -50) {
              widget.onRefresh!();
            }
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                if (_currentQuery != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.dimensions.spacingMedium,
                      vertical: context.dimensions.spacingSmall,
                    ),
                    color: context.colors.surfaceVariant,
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 16 * context.dimensions.fontSizeFactor,
                        ),
                        SizedBox(width: context.dimensions.spacingSmall),
                        Expanded(
                          child: Text(
                            context.l10n.common_searching_for(
                              _currentQuery ?? '',
                            ),
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          tooltip: context.l10n.common_close,
                          icon: Icon(
                            Icons.close,
                            size: 20 * context.dimensions.fontSizeFactor,
                          ),
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
                      _reportPageSize(responsiveDelegate);

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

                      int? memCacheWidth;
                      if (widget.itemBuilder != null) {
                        if (widget.memCacheWidthBuilder != null) {
                          memCacheWidth = widget.memCacheWidthBuilder!(
                            context,
                            isGrid,
                          );
                        } else {
                          if (fixedDelegate != null) {
                            memCacheWidth =
                                (screenWidth /
                                        fixedDelegate.crossAxisCount *
                                        1.5)
                                    .toInt();
                          } else {
                            memCacheWidth = screenWidth > 600
                                ? 600
                                : screenWidth.toInt();
                          }
                        }
                      }

                      Widget body =
                          widget.customBody ??
                          (isGrid
                              ? LayoutBuilder(
                                  builder: (context, constraints) {
                                    final horizontalPadding =
                                        widget.padding
                                            ?.resolve(
                                              Directionality.of(context),
                                            )
                                            .horizontal ??
                                        0.0;
                                    if (!constraints.hasBoundedWidth ||
                                        constraints.maxWidth -
                                                horizontalPadding <=
                                            0) {
                                      return const SizedBox.shrink();
                                    }

                                    if (widget.useMasonry) {
                                      return MasonryGridView.builder(
                                        controller: widget.scrollController,
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        padding: widget.padding,
                                        cacheExtent: viewportCacheExtent,
                                        gridDelegate:
                                            SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount:
                                                  fixedDelegate
                                                      ?.crossAxisCount ??
                                                  1,
                                            ),
                                        mainAxisSpacing:
                                            fixedDelegate?.mainAxisSpacing ??
                                            0.0,
                                        crossAxisSpacing:
                                            fixedDelegate?.crossAxisSpacing ??
                                            0.0,
                                        itemCount: items.length,
                                        itemBuilder: (context, index) {
                                          if (index == 0 &&
                                              widget.onPageSizeChanged !=
                                                  null &&
                                              _measuredItemExtent == null) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback((_) {
                                                  if (!mounted) return;
                                                  if (_measuredItemExtent ==
                                                          null &&
                                                      _firstItemKey
                                                              .currentContext !=
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
                                              key: index == 0
                                                  ? _firstItemKey
                                                  : null,
                                              child: widget.itemBuilder!(
                                                context,
                                                items[index],
                                                memCacheWidth,
                                                null,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }

                                    return GridView.builder(
                                      controller: widget.scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: widget.padding,
                                      scrollCacheExtent:
                                          const ScrollCacheExtent.viewport(2.0),
                                      gridDelegate: responsiveDelegate!,
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        if (index == 0 &&
                                            widget.onPageSizeChanged != null &&
                                            _measuredItemExtent == null) {
                                          WidgetsBinding.instance
                                              .addPostFrameCallback((_) {
                                                if (!mounted) return;
                                                if (_measuredItemExtent ==
                                                        null &&
                                                    _firstItemKey
                                                            .currentContext !=
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
                                            key: index == 0
                                                ? _firstItemKey
                                                : null,
                                            child: widget.itemBuilder!(
                                              context,
                                              items[index],
                                              memCacheWidth,
                                              null,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              : ListView.builder(
                                  controller: widget.scrollController,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: widget.padding,
                                  scrollCacheExtent:
                                      const ScrollCacheExtent.viewport(2.0),
                                  itemCount: items.length,
                                  itemExtent: widget.itemExtent,
                                  itemBuilder: (context, index) {
                                    if (index == 0 &&
                                        widget.onPageSizeChanged != null &&
                                        widget.itemExtent == null &&
                                        _measuredItemExtent == null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (!mounted) return;
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
                            final now = DateTime.now();
                            if (_lastFetchTime == null ||
                                now.difference(_lastFetchTime!) >
                                    _fetchThreshold) {
                              _lastFetchTime = now;
                              widget.onFetchNextPage?.call();
                            }
                          }
                          return false;
                        },
                        child: body,
                      );
                    },
                    loading: () {
                      final loadingItemBuilder = widget.loadingItemBuilder;

                      if (isGrid) {
                        return GridView.builder(
                          padding: widget.padding,
                          scrollCacheExtent: const ScrollCacheExtent.viewport(
                            1.0,
                          ),
                          gridDelegate: responsiveDelegate!,
                          itemCount: 8,
                          itemBuilder: (context, index) =>
                              loadingItemBuilder != null
                              ? loadingItemBuilder(context, true, index)
                              : SceneCard.skeleton(isGrid: true),
                        );
                      }
                      return ListView.builder(
                        padding: widget.padding,
                        scrollCacheExtent: const ScrollCacheExtent.viewport(
                          1.0,
                        ),
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            loadingItemBuilder != null
                            ? loadingItemBuilder(context, false, index)
                            : SceneCard.skeleton(isGrid: false),
                      );
                    },
                    error: (err, stack) => ErrorStateView(
                      message: context.l10n.common_error(err.toString()),
                      onRetry: widget.onRefresh,
                    ),
                  ),
                ),
              ],
            ),
            if (widget.actions.isNotEmpty && !widget.actionsInTopPanel)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceVariant.withValues(
                        alpha: 0.95,
                      ),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.actions,
                    ),
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
