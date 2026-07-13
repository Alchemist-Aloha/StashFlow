import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../providers/scene_list_provider.dart';
import '../providers/playback_queue_provider.dart';
import '../providers/scene_random_navigation_provider.dart';
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

import '../widgets/scene_filter_panel.dart';
import '../widgets/scene_saved_filter_dialog.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';

enum _SceneSortField {
  date,
  rating,
  playCount,
  title,
  duration,
  bitrate,
  framerate,
  updatedAt,
  createdAt,
  random,
  fileCount,
  filesize,
  resolution,
  lastPlayedAt,
  resumeTime,
  playDuration,
  interactive,
  interactiveSpeed,
  perceptualSimilarity,
  performerAge,
  studio,
  path,
  fileModTime,
  tagCount,
  performerCount,
  oCounter,
  lastOAt,
  groupSceneNumber,
  code,
}

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
  _SceneSortField _sortField = _SceneSortField.date;

  /// Whether the sort is in descending order.
  bool _sortDescending = true;

  /// Remembers the last random scene ID to avoid consecutive duplicates in "Casino mode".
  String? _lastRandomSceneId;

  void _handleLayoutModeTransition({
    required bool? previousIsTiktok,
    required bool isTiktok,
  }) {
    if (previousIsTiktok != true || isTiktok || !mounted) return;

    final currentPath = GoRouter.of(
      context,
    ).routeInformationProvider.value.uri.path;
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
        _sortField = switch (sortConfig.sort) {
          'date' => _SceneSortField.date,
          'rating' => _SceneSortField.rating,
          'play_count' => _SceneSortField.playCount,
          'title' => _SceneSortField.title,
          'duration' => _SceneSortField.duration,
          'bitrate' => _SceneSortField.bitrate,
          'framerate' => _SceneSortField.framerate,
          'updated_at' => _SceneSortField.updatedAt,
          'created_at' => _SceneSortField.createdAt,
          'random' => _SceneSortField.random,
          'file_count' => _SceneSortField.fileCount,
          'filesize' => _SceneSortField.filesize,
          'resolution' => _SceneSortField.resolution,
          'last_played_at' => _SceneSortField.lastPlayedAt,
          'resume_time' => _SceneSortField.resumeTime,
          'play_duration' => _SceneSortField.playDuration,
          'interactive' => _SceneSortField.interactive,
          'interactive_speed' => _SceneSortField.interactiveSpeed,
          'perceptual_similarity' => _SceneSortField.perceptualSimilarity,
          'performer_age' => _SceneSortField.performerAge,
          'studio' => _SceneSortField.studio,
          'path' => _SceneSortField.path,
          'file_mod_time' => _SceneSortField.fileModTime,
          'tag_count' => _SceneSortField.tagCount,
          'performer_count' => _SceneSortField.performerCount,
          'o_counter' => _SceneSortField.oCounter,
          'last_o_at' => _SceneSortField.lastOAt,
          'group_scene_number' => _SceneSortField.groupSceneNumber,
          'code' => _SceneSortField.code,
          _ => _SceneSortField.date,
        };
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
        .setSort(
          sort: _sortKeyForField(_sortField),
          descending: _sortDescending,
        );
  }

  String _sortKeyForField(_SceneSortField field) {
    return switch (field) {
      _SceneSortField.date => 'date',
      _SceneSortField.rating => 'rating',
      _SceneSortField.playCount => 'play_count',
      _SceneSortField.title => 'title',
      _SceneSortField.duration => 'duration',
      _SceneSortField.bitrate => 'bitrate',
      _SceneSortField.framerate => 'framerate',
      _SceneSortField.updatedAt => 'updated_at',
      _SceneSortField.createdAt => 'created_at',
      _SceneSortField.random => 'random',
      _SceneSortField.fileCount => 'file_count',
      _SceneSortField.filesize => 'filesize',
      _SceneSortField.resolution => 'resolution',
      _SceneSortField.lastPlayedAt => 'last_played_at',
      _SceneSortField.resumeTime => 'resume_time',
      _SceneSortField.playDuration => 'play_duration',
      _SceneSortField.interactive => 'interactive',
      _SceneSortField.interactiveSpeed => 'interactive_speed',
      _SceneSortField.perceptualSimilarity => 'perceptual_similarity',
      _SceneSortField.performerAge => 'performer_age',
      _SceneSortField.studio => 'studio',
      _SceneSortField.path => 'path',
      _SceneSortField.fileModTime => 'file_mod_time',
      _SceneSortField.tagCount => 'tag_count',
      _SceneSortField.performerCount => 'performer_count',
      _SceneSortField.oCounter => 'o_counter',
      _SceneSortField.lastOAt => 'last_o_at',
      _SceneSortField.groupSceneNumber => 'group_scene_number',
      _SceneSortField.code => 'code',
    };
  }

  _SceneSortField _sortFieldForKey(String? sort) {
    return switch (sort) {
      'date' => _SceneSortField.date,
      'rating' => _SceneSortField.rating,
      'play_count' => _SceneSortField.playCount,
      'title' => _SceneSortField.title,
      'duration' => _SceneSortField.duration,
      'bitrate' => _SceneSortField.bitrate,
      'framerate' => _SceneSortField.framerate,
      'updated_at' => _SceneSortField.updatedAt,
      'created_at' => _SceneSortField.createdAt,
      'random' => _SceneSortField.random,
      'file_count' => _SceneSortField.fileCount,
      'filesize' => _SceneSortField.filesize,
      'resolution' => _SceneSortField.resolution,
      'last_played_at' => _SceneSortField.lastPlayedAt,
      'resume_time' => _SceneSortField.resumeTime,
      'play_duration' => _SceneSortField.playDuration,
      'interactive' => _SceneSortField.interactive,
      'interactive_speed' => _SceneSortField.interactiveSpeed,
      'perceptual_similarity' => _SceneSortField.perceptualSimilarity,
      'performer_age' => _SceneSortField.performerAge,
      'studio' => _SceneSortField.studio,
      'path' => _SceneSortField.path,
      'file_mod_time' => _SceneSortField.fileModTime,
      'tag_count' => _SceneSortField.tagCount,
      'performer_count' => _SceneSortField.performerCount,
      'o_counter' => _SceneSortField.oCounter,
      'last_o_at' => _SceneSortField.lastOAt,
      'group_scene_number' => _SceneSortField.groupSceneNumber,
      'code' => _SceneSortField.code,
      _ => _SceneSortField.date,
    };
  }

  /// Opens the "Casino mode" random scene view.
  Future<void> _openRandomScene() async {
    final randomScene = await ref
        .read(sceneRandomNavigationControllerProvider)
        .getRandomScene(excludeSceneId: _lastRandomSceneId);
    if (!mounted || randomScene == null) return;

    _lastRandomSceneId = randomScene.id;
    context.push('/scenes/scene/${randomScene.id}', extra: true);
  }

  /// Formats a [_SceneSortField] enum value for display in the UI.
  String _sortFieldLabel(_SceneSortField field) {
    return switch (field) {
      _SceneSortField.date => context.l10n.common_date,
      _SceneSortField.rating => context.l10n.common_rating,
      _SceneSortField.playCount => context.l10n.performers_play_count,
      _SceneSortField.title => context.l10n.common_title,
      _SceneSortField.duration => context.l10n.scenes_sort_duration,
      _SceneSortField.bitrate => context.l10n.scenes_sort_bitrate,
      _SceneSortField.framerate => context.l10n.scenes_sort_framerate,
      _SceneSortField.updatedAt => context.l10n.sort_updated_at,
      _SceneSortField.createdAt => context.l10n.sort_created_at,
      _SceneSortField.random => context.l10n.sort_random,
      _SceneSortField.fileCount => context.l10n.scenes_sort_file_count,
      _SceneSortField.filesize => context.l10n.scenes_sort_filesize,
      _SceneSortField.resolution => context.l10n.scenes_sort_resolution,
      _SceneSortField.lastPlayedAt => context.l10n.scenes_sort_last_played_at,
      _SceneSortField.resumeTime => context.l10n.scenes_sort_resume_time,
      _SceneSortField.playDuration => context.l10n.scenes_sort_play_duration,
      _SceneSortField.interactive => context.l10n.scenes_sort_interactive,
      _SceneSortField.interactiveSpeed =>
        context.l10n.scenes_sort_interactive_speed,
      _SceneSortField.perceptualSimilarity =>
        context.l10n.scenes_sort_perceptual_similarity,
      _SceneSortField.performerAge => context.l10n.scenes_sort_performer_age,
      _SceneSortField.studio => context.l10n.scenes_sort_studio,
      _SceneSortField.path => context.l10n.scenes_sort_path,
      _SceneSortField.fileModTime => context.l10n.scenes_sort_file_mod_time,
      _SceneSortField.tagCount => context.l10n.scenes_sort_tag_count,
      _SceneSortField.performerCount =>
        context.l10n.scenes_sort_performer_count,
      _SceneSortField.oCounter => context.l10n.scenes_sort_o_counter,
      _SceneSortField.lastOAt => context.l10n.scenes_sort_last_o_at,
      _SceneSortField.groupSceneNumber =>
        context.l10n.scenes_sort_group_scene_number,
      _SceneSortField.code => context.l10n.scenes_sort_code,
    };
  }

  /// Displays the sort selection bottom sheet.
  void _showSortPanel() {
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => ListSortBottomSheet<_SceneSortField>(
        title: context.l10n.sort_scenes,
        options: _SceneSortField.values,
        initialOption: _sortField,
        initialDescending: _sortDescending,
        resetOption: _SceneSortField.date,
        resetDescending: true,
        optionLabel: _sortFieldLabel,
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
    );
  }

  /// Displays the filter configuration bottom sheet.
  void _showFilterPanel() {
    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => const SceneFilterPanel(),
    );
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(sceneSortProvider);
    final filter = ref.read(sceneFilterStateProvider);
    final organizedFilter = ref.read(sceneOrganizedOnlyProvider);
    final effectiveFilter = filter.copyWith(
      organized: organizedFilter.toBool() ?? filter.organized,
    );

    showFrostedPanelBottomSheet(
      context: context,
      builder: (context) => SceneSavedFilterDialog(
        searchQuery: ref.read(sceneSearchQueryProvider),
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        filter: effectiveFilter,
        onLoad: _applySavedFilterConfig,
      ),
    );
  }

  void _applySavedFilterConfig(SceneSavedFilterConfig config) {
    setState(() {
      _sortField = _sortFieldForKey(config.sort);
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
    final currentPath = router.routeInformationProvider.value.uri.path;
    final isAtRoot = currentPath == '/scenes';

    return ListPageScaffold<Scene>(
      title: context.l10n.appTitle,
      searchHint: context.l10n.scenes_search_hint,
      onSearchChanged: _onSearchChanged,
      provider: scenesAsync,
      actionsInTopPanel: isTiktokLayout,
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
      customBody: isTiktokLayout ? const TiktokScenesView() : null,
      scrollController: scrollController,
      useMasonry: isGridView,
      hideAppBar: isTiktokLayout && isFullScreen,
      onRefresh: () => ref.read(sceneListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(sceneListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(sceneListProvider.notifier).setPerPage(pageSize),
      loadingItemBuilder: (context, isGrid, index) =>
          SceneCard.skeleton(isGrid: isGrid, useMasonry: isGrid),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.scenes_sort_tooltip,
              onPressed: _showSortPanel,
            ),
            if (_sortField != _SceneSortField.date || !_sortDescending)
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
      ],
      gridDelegate: isGridView
          ? GridUtils.createDelegate(
              crossAxisCount: gridColumns ?? _getGridColumnCount(context),
            )
          : null,
      padding: isGridView ? GridUtils.defaultPadding : EdgeInsets.zero,
      itemBuilder: (context, scene, memCacheWidth, memCacheHeight) {
        final index = sceneIndexMap[scene.id] ?? -1;

        return SceneCard(
          scene: scene,
          isGrid: isGridView,
          useMasonry: isGridView,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
          useHero: isAtRoot,
          onTap: () {
            AppLogStore.instance.add(
              'ScenesPage: Scene card tapped: ${scene.id}, index=$index, total=${scenes.length}',
              source: 'scenes_page',
            );
            if (index != -1) {
              ref
                  .read(playbackQueueProvider.notifier)
                  .setIndex(index, queueId: PlaybackQueueIds.main);
              AppLogStore.instance.add(
                'ScenesPage: Queue index set to $index for scene ${scene.id}',
                source: 'scenes_page',
              );
            }
            context.push('/scenes/scene/${scene.id}', extra: true);
            AppLogStore.instance.add(
              'ScenesPage: Navigated to scene detail page for ${scene.id} with autoPlayOnMount=true',
              source: 'scenes_page',
            );
          },
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
