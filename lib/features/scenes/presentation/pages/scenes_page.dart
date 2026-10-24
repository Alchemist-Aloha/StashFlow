import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../navigation/presentation/current_route_provider.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../providers/playback_queue_provider.dart';
import '../providers/scene_list_provider.dart';
import '../providers/player_view_mode.dart';
import '../providers/video_player_provider.dart';
import '../widgets/scene_card.dart';
import '../widgets/tiktok_scenes_view.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/presentation/providers/list_scroll_controller_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/list_sort_bottom_sheet.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_log_store.dart';

import '../scene_sort.dart';
import '../widgets/scene_filter_panel.dart';
import '../widgets/scene_saved_filter_dialog.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';

/// The main browsing page for scenes.
///
/// This page supports three layout modes:
/// 1. **List**: Standard vertical list of large [SceneCard]s.
/// 2. **Grid**: Two-column grid of compact [SceneCard]s.
/// 3. **TikTok**: Infinite scrolling full-screen video feed via [TiktokScenesView].
///
/// It also provides comprehensive sorting and filtering capabilities, search integration,
/// and a random navigation feature ("Casino mode").
class ScenesPage extends ConsumerStatefulWidget {
  const ScenesPage({super.key});

  @override
  ConsumerState<ScenesPage> createState() => _ScenesPageState();
}

class _ScenesPageState extends ConsumerState<ScenesPage> {
  /// The current field used for sorting scenes.
  SceneSortField _sortField = SceneSortField.date;

  /// Whether the sort is in descending order.
  bool _sortDescending = true;

  /// Remembers the last random scene ID to avoid consecutive duplicates in "Casino mode".
  String? _lastRandomSceneId;
  final _returnedSceneFocusNode = FocusNode(debugLabel: 'returned_scene');
  GlobalKey _focusedSceneKey = GlobalKey();
  String? _focusedSceneId;
  String? _lastRoutePath;
  bool _restoreFocusPending = false;

  @override
  void dispose() {
    _returnedSceneFocusNode.dispose();
    super.dispose();
  }

  void _handleLayoutModeTransition({
    required bool? previousIsTiktok,
    required bool isTiktok,
  }) {
    if (previousIsTiktok != true || isTiktok || !mounted) return;

    final currentPath = GoRouter.of(context).state.uri.path;
    if (currentPath != '/scenes') return;

    final playerState = ref.read(playerStateProvider);
    final isFeedOwnedPlayback =
        playerState.viewMode == PlayerViewMode.tiktok ||
        playerState.streamSource == 'tiktok-promotion' ||
        playerState.streamSource == 'tiktok-handoff';

    ref.read(fullScreenModeProvider.notifier).set(false);

    if (!isFeedOwnedPlayback) return;

    AppLogStore.instance.add(
      'ScenesPage: stopping feed playback after leaving TikTok layout',
      source: 'scenes_page',
    );
    ref.read(playerStateProvider.notifier).stop();
  }

  @override
  void initState() {
    super.initState();
    // Initialize state from persisted providers after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sortConfig = ref.read(sceneSortProvider);
      setState(() {
        _sortField = SceneSortField.fromKey(sortConfig.sort);
        _sortDescending = sortConfig.descending;
      });
      _applyServerSort();
    });
  }

  int _getGridColumnCount(BuildContext context) {
    return Responsive.isMobile(context) ? 2 : 3;
  }

  /// Updates the search query in the provider, triggering a data refresh.
  void _onSearchChanged(String query) {
    ref.read(sceneSearchQueryProvider.notifier).update(query);
  }

  /// Syncs the local UI sort state with the [sceneListProvider] and triggers a fetch.
  void _applyServerSort() {
    ref
        .read(sceneSortProvider.notifier)
        .setSort(sort: _sortField.key, descending: _sortDescending);
  }

  /// Opens the "Casino mode" random scene view.
  Future<void> _openRandomScene() async {
    final randomScene = await ref
        .read(sceneListProvider.notifier)
        .getRandomScene(excludeSceneId: _lastRandomSceneId);
    if (!mounted || randomScene == null) return;

    _lastRandomSceneId = randomScene.id;
    await context.push<void>('/scenes/scene/${randomScene.id}', extra: true);
  }

  Future<void> _openScene(Scene scene, int index, int itemCount) async {
    ref.read(sceneListRandomReturnProvider.notifier).reset();
    AppLogStore.instance.add(
      'ScenesPage: Scene card tapped: ${scene.id}, index=$index, total=$itemCount',
      source: 'scenes_page',
    );
    if (index != -1) {
      ref
          .read(playbackQueueProvider.notifier)
          .setIndex(index, queueId: PlaybackQueueIds.main);
    }
    await context.push<void>('/scenes/scene/${scene.id}', extra: true);
  }

  void _restoreSceneFocus() {
    final scenes = ref.read(sceneListProvider).value;
    if (scenes == null) return;

    final queue = ref.read(playbackQueueProvider);
    final mainQueue = queue.queues[PlaybackQueueIds.main];
    final playlistScene =
        mainQueue != null &&
            mainQueue.currentIndex >= 0 &&
            mainQueue.currentIndex < mainQueue.sequence.length
        ? mainQueue.sequence[mainQueue.currentIndex]
        : null;
    final usePlaylist = ref.read(sceneListRandomReturnProvider);
    ref.read(sceneListRandomReturnProvider.notifier).reset();

    final preferredId = usePlaylist
        ? playlistScene?.id
        : ref.read(playerStateProvider).activeScene?.id;
    final fallbackId = usePlaylist
        ? ref.read(playerStateProvider).activeScene?.id
        : playlistScene?.id;
    var index = scenes.indexWhere((scene) => scene.id == preferredId);
    if (index == -1) {
      index = scenes.indexWhere((scene) => scene.id == fallbackId);
    }
    if (index == -1) return;

    setState(() {
      _focusedSceneId = scenes[index].id;
      _focusedSceneKey = GlobalKey();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_focusSceneCard(index, scenes.length));
    });
  }

  Future<void> _focusSceneCard(int index, int itemCount) async {
    final controller = ref.read(
      listScrollControllerProvider(ListScrollTarget.scene),
    );
    if (_focusedSceneKey.currentContext == null && controller.hasClients) {
      final position = controller.position;
      final fraction = itemCount <= 1 ? 0.0 : index / (itemCount - 1);
      controller.jumpTo(
        (position.maxScrollExtent * fraction)
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble(),
      );
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
    }

    final targetContext = _focusedSceneKey.currentContext;
    if (targetContext != null && targetContext.mounted) {
      await Scrollable.ensureVisible(
        targetContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
    if (mounted && _returnedSceneFocusNode.canRequestFocus) {
      _returnedSceneFocusNode.requestFocus();
    }
  }

  /// Displays the sort selection bottom sheet.
  void _showSortPanel() {
    unawaited(
      showFrostedPanelBottomSheet<void>(
        context: context,
        builder: (context) => ListSortBottomSheet<SceneSortField>(
          title: context.l10n.sort_scenes,
          options: SceneSortField.values,
          commonOptions: SceneSortField.commonOptions,
          initialOption: _sortField,
          initialDescending: _sortDescending,
          resetOption: SceneSortField.date,
          resetDescending: true,
          optionLabel: (field) => field.label(context),
          onApply: (field, descending) {
            setState(() {
              _sortField = field;
              _sortDescending = descending;
            });
            _applyServerSort();
          },
          onSaveDefault: () =>
              ref.read(sceneSortProvider.notifier).saveAsDefault(),
          saveDefaultSuccessMessage: context.l10n.scenes_sort_saved_default,
        ),
      ),
    );
  }

  /// Displays the filter configuration bottom sheet.
  void _showFilterPanel() {
    unawaited(
      showFrostedPanelBottomSheet<void>(
        context: context,
        builder: (context) => const SceneFilterPanel(),
      ),
    );
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(sceneSortProvider);
    final filter = ref.read(sceneFilterStateProvider);
    final organizedFilter = ref.read(sceneOrganizedOnlyProvider);
    final effectiveFilter = filter.copyWith(
      organized: organizedFilter.toBool() ?? filter.organized,
    );

    unawaited(
      showFrostedPanelBottomSheet<void>(
        context: context,
        builder: (context) => SceneSavedFilterDialog(
          searchQuery: ref.read(sceneSearchQueryProvider),
          sort: sortConfig.sort,
          descending: sortConfig.descending,
          filter: effectiveFilter,
          onLoad: _applySavedFilterConfig,
        ),
      ),
    );
  }

  void _applySavedFilterConfig(SceneSavedFilterConfig config) {
    setState(() {
      _sortField = SceneSortField.fromKey(config.sort);
      _sortDescending = config.descending;
    });

    ref.read(sceneSearchQueryProvider.notifier).update(config.searchQuery);
    ref
        .read(sceneFilterStateProvider.notifier)
        .update(config.filter.copyWith(organized: null));
    ref
        .read(sceneOrganizedOnlyProvider.notifier)
        .set(OrganizedFilter.fromBool(config.filter.organized));
    ref
        .read(sceneSortProvider.notifier)
        .setSort(sort: config.sort ?? 'date', descending: config.descending);
    ref.invalidate(sceneListProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Fullscreen auto-exit is handled by the SceneDetailsPage so the
    // ScenesPage should not pop routes when the player toggles fullscreen.
    // This avoids double-pop behavior that could remove the details route.

    ref.listen<bool>(sceneTiktokLayoutProvider, (previous, next) {
      _handleLayoutModeTransition(previousIsTiktok: previous, isTiktok: next);
    });

    final isTiktokLayout = ref.watch(sceneTiktokLayoutProvider);
    final isGridView = ref.watch(sceneGridLayoutProvider);
    final gridColumns = ref.watch(
      gridColumnSettingProvider(GridColumnSetting.scene),
    );
    final scenesAsync = ref.watch(sceneListProvider);

    // Use select for more granular watching where possible
    final filterActive = ref.watch(
      sceneFilterStateProvider.select((s) => s != SceneFilter.empty()),
    );
    final organizedFilter = ref.watch(sceneOrganizedOnlyProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final isFullScreen = ref.watch(fullScreenModeProvider);
    final scrollController = ref.watch(
      listScrollControllerProvider(ListScrollTarget.scene),
    );

    final hasActiveFilters =
        filterActive || organizedFilter != OrganizedFilter.all;

    // ⚡ Bolt: Hoist scene lookup map out of the itemBuilder loop.
    // Why: Previously, every item built during scrolling performed an O(N) indexWhere lookup,
    // causing O(N^2) complexity and potential frame drops.
    // Impact: Reduces lookup from O(N) to O(1), significantly improving scrolling performance.
    final scenes = scenesAsync.value ?? [];
    final sceneIndexMap = {
      for (var i = 0; i < scenes.length; i++) scenes[i].id: i,
    };

    // ⚡ Bolt: Hoist routing layout variables out of the itemBuilder loop.
    // Why: Looking up the router via InheritedWidget causes redundant O(1) traversals
    // on every rendered list item during scroll.
    // Impact: Avoids GC pressure and reduces scroll stuttering.
    final router = GoRouter.of(context);
    final currentPath = ref.watch(currentRouteUriProvider(router)).path;
    final rootPath = GoRouterState.of(context).matchedLocation;
    final isAtRoot = currentPath == rootPath;
    if (isAtRoot && _lastRoutePath != null && _lastRoutePath != rootPath) {
      _restoreFocusPending = true;
    }
    _lastRoutePath = currentPath;
    if (!isAtRoot || isTiktokLayout) _restoreFocusPending = false;
    if (_restoreFocusPending &&
        !scenesAsync.isLoading &&
        scenesAsync.hasValue) {
      _restoreFocusPending = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            router.state.uri.path != rootPath ||
            ref.read(sceneTiktokLayoutProvider)) {
          return;
        }
        _restoreSceneFocus();
      });
    }
    final sceneActions = <Widget>[
      Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: context.l10n.scenes_sort_tooltip,
            onPressed: _showSortPanel,
          ),
          if (_sortField != SceneSortField.date || !_sortDescending)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: context.colors.secondary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            ),
        ],
      ),
      Stack(
        children: [
          IconButton(
            tooltip: context.l10n.common_filter,
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterPanel,
          ),
          if (hasActiveFilters)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: context.colors.secondary,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
              ),
            ),
        ],
      ),
      IconButton(
        tooltip: context.l10n.common_saved_filters,
        icon: const Icon(Icons.bookmarks_outlined),
        onPressed: _showSavedFilterDialog,
      ),
      IconButton(
        tooltip: context.l10n.scenes_page_markers_tooltip,
        icon: const Icon(Icons.sell_outlined),
        onPressed: () => context.push('/scenes/markers'),
      ),
    ];

    return ListPageScaffold<Scene>(
      gridColumnSetting: GridColumnSetting.scene,
      title: context.l10n.appTitle,
      searchHint: context.l10n.scenes_search_hint,
      onSearchChanged: _onSearchChanged,
      provider: scenesAsync,
      memCacheWidthBuilder: (context, isGrid) {
        if (!isGrid) return 640;
        final padding = AppTheme.spacingSmall * 2;
        final crossAxisCount = _getGridColumnCount(context);
        // Using MediaQuery.sizeOf(context) instead of MediaQuery.of(context).size
        // to prevent unnecessary rebuilds when unrelated MediaQueryData properties change.
        final availableWidth = MediaQuery.sizeOf(context).width - padding;
        final itemWidth =
            (availableWidth - (AppTheme.spacingSmall * (crossAxisCount - 1))) /
            crossAxisCount;
        return (itemWidth * 2).toInt();
      },
      customBody: isTiktokLayout
          ? TiktokScenesView(actions: sceneActions)
          : null,
      scrollController: scrollController,
      useMasonry: isGridView,
      hideAppBar: isTiktokLayout && isFullScreen,
      onRefresh: () => ref.read(sceneListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(sceneListProvider.notifier).fetchNextPage(),
      loadingItemBuilder: (context, isGrid, index) =>
          SceneCard.skeleton(isGrid: isGrid, useMasonry: isGrid),
      actions: isTiktokLayout ? const [] : sceneActions,
      gridDelegate: isGridView
          ? GridUtils.createDelegate(
              context,
              crossAxisCount: gridColumns ?? _getGridColumnCount(context),
            )
          : null,
      padding: isGridView ? GridUtils.defaultPadding(context) : EdgeInsets.zero,
      itemBuilder: (context, scene, memCacheWidth, memCacheHeight) {
        final index = sceneIndexMap[scene.id] ?? -1;
        final focused = scene.id == _focusedSceneId;

        // Keep masonry parent data when the return-focus target changes key.
        return SizedBox(
          key: ValueKey<String>('scene_card_${scene.id}'),
          child: SceneCard(
            key: focused ? _focusedSceneKey : null,
            scene: scene,
            isGrid: isGridView,
            useMasonry: isGridView,
            memCacheWidth: memCacheWidth,
            memCacheHeight: memCacheHeight,
            useHero: isAtRoot,
            focusNode: focused ? _returnedSceneFocusNode : null,
            onTap: () => _openScene(scene, index, scenes.length),
          ),
        );
      },
      floatingActionButton: (randomNavigationEnabled && !isTiktokLayout)
          ? scenesAsync.maybeWhen(
              data: (scenes) => FloatingActionButton.small(
                heroTag: 'scenes_random_fab',
                onPressed: _openRandomScene,
                tooltip: context.l10n.random_scene,
                child: const Icon(Icons.casino_outlined),
              ),
              orElse: () => null,
            )
          : null,
    );
  }
}
