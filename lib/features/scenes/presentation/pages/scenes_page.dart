import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../providers/scene_list_provider.dart';
import '../providers/playback_queue_provider.dart';
import '../widgets/scene_card.dart';
import '../widgets/tiktok_scenes_view.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

import '../widgets/scene_filter_panel.dart';
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

  @override
  void initState() {
    super.initState();
    // Initialize state from persisted providers after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

  @override
  void dispose() {
    super.dispose();
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
    final sortKey = switch (_sortField) {
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
    ref
        .read(sceneSortProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  /// Opens the "Casino mode" random scene view.
  void _openRandomScene() {
    final scenes = ref.read(sceneListProvider).value ?? [];
    if (scenes.isEmpty) return;

    // Choose a random scene that wasn't the last one we picked.
    final random = Random();
    int index;
    do {
      index = random.nextInt(scenes.length);
    } while (scenes.length > 1 && scenes[index].id == _lastRandomSceneId);

    _lastRandomSceneId = scenes[index].id;

    // Set the queue and navigate to details.
    ref.read(playbackQueueProvider.notifier).setIndex(index);
    context.push('/scenes/scene/${scenes[index].id}');
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
      _SceneSortField.fileCount => 'File Count',
      _SceneSortField.filesize => 'Filesize',
      _SceneSortField.resolution => 'Resolution',
      _SceneSortField.lastPlayedAt => 'Last Played At',
      _SceneSortField.resumeTime => 'Resume Time',
      _SceneSortField.playDuration => 'Play Duration',
      _SceneSortField.interactive => 'Interactive',
      _SceneSortField.interactiveSpeed => 'Interactive Speed',
      _SceneSortField.perceptualSimilarity => 'Perceptual Similarity',
      _SceneSortField.performerAge => 'Performer Age',
      _SceneSortField.studio => 'Studio',
      _SceneSortField.path => 'Path',
      _SceneSortField.fileModTime => 'File Mod Time',
      _SceneSortField.tagCount => 'Tag Count',
      _SceneSortField.performerCount => 'Performer Count',
      _SceneSortField.oCounter => 'O-Counter',
      _SceneSortField.lastOAt => 'Last O At',
      _SceneSortField.groupSceneNumber => 'Group/Movie Scene Number',
      _SceneSortField.code => 'Code',
    };
  }

  /// Displays the sort selection bottom sheet.
  void _showSortPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        _SceneSortField tempField = _sortField;
        bool tempDescending = _sortDescending;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(context.dimensions.spacingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Sort Scenes',
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempField = _SceneSortField.date;
                              tempDescending = true;
                            });
                          },
                          child: Text(context.l10n.common_reset),
                        ),
                      ],
                    ),
                    SizedBox(height: context.dimensions.spacingMedium),
                    Text(
                      context.l10n.common_sort_method,
                      style: context.textTheme.labelLarge,
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // Using MediaQuery.sizeOf(context) instead of MediaQuery.of(context).size
                          // to prevent unnecessary rebuilds when unrelated MediaQueryData properties change.
                          maxHeight: MediaQuery.sizeOf(context).height * 0.35,
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              vertical: context.dimensions.spacingSmall,
                            ),
                            child: Wrap(
                              spacing: context.dimensions.spacingSmall,
                              runSpacing: context.dimensions.spacingSmall,
                              children: _SceneSortField.values
                                  .map(
                                    (field) => ChoiceChip(
                                      label: Text(_sortFieldLabel(field)),
                                      selected: tempField == field,
                                      onSelected: (selected) {
                                        if (!selected) return;
                                        setModalState(() {
                                          tempField = field;
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.dimensions.spacingMedium),
                    Text(
                      context.l10n.common_direction,
                      style: context.textTheme.labelLarge,
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        segments: [
                          ButtonSegment(
                            value: true,
                            label: Text(context.l10n.common_descending),
                            icon: Icon(Icons.arrow_downward),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text(context.l10n.common_ascending),
                            icon: Icon(Icons.arrow_upward),
                          ),
                        ],
                        selected: {tempDescending},
                        onSelectionChanged: (value) =>
                            setModalState(() => tempDescending = value.first),
                      ),
                    ),
                    SizedBox(height: context.dimensions.spacingLarge),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _sortField = tempField;
                            _sortDescending = tempDescending;
                          });
                          _applyServerSort();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimensions.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_apply_sort),
                      ),
                    ),
                    SizedBox(height: context.dimensions.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () async {
                          setState(() {
                            _sortField = tempField;
                            _sortDescending = tempDescending;
                          });
                          _applyServerSort();
                          await ref
                              .read(sceneSortProvider.notifier)
                              .saveAsDefault();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.scenes_sort_saved_default,
                                ),
                              ),
                            );
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: context.dimensions.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_save_default),
                      ),
                    ),
                    SizedBox(height: context.dimensions.spacingMedium),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Displays the filter configuration bottom sheet.
  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SceneFilterPanel(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fullscreen auto-exit is handled by the SceneDetailsPage so the
    // ScenesPage should not pop routes when the player toggles fullscreen.
    // This avoids double-pop behavior that could remove the details route.

    final isTiktokLayout = ref.watch(sceneTiktokLayoutProvider);
    final isGridView = ref.watch(sceneGridLayoutProvider);
    final gridColumns = ref.watch(sceneGridColumnsProvider);
    final scenesAsync = ref.watch(sceneListProvider);

    // Use select for more granular watching where possible
    final filterActive = ref.watch(
      sceneFilterStateProvider.select((s) => s != SceneFilter.empty()),
    );
    final organizedFilter = ref.watch(sceneOrganizedOnlyProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final isFullScreen = ref.watch(fullScreenModeProvider);
    final scrollController = ref.watch(sceneScrollControllerProvider);

    final hasActiveFilters = filterActive || organizedFilter != OrganizedFilter.all;

    // ⚡ Bolt: Hoist scene lookup map out of the itemBuilder loop.
    // Why: Previously, every item built during scrolling performed an O(N) indexWhere lookup,
    // causing O(N^2) complexity and potential frame drops.
    // Impact: Reduces lookup from O(N) to O(1), significantly improving scrolling performance.
    final scenes = scenesAsync.value ?? [];
    final sceneIndexMap = {for (var i = 0; i < scenes.length; i++) scenes[i].id: i};

    return ListPageScaffold<Scene>(
      title: context.l10n.appTitle,
      searchHint: context.l10n.scenes_search_hint,
      onSearchChanged: _onSearchChanged,
      provider: scenesAsync,
      imageUrlBuilder: (scene) => scene.paths.screenshot,
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
          onTap: () {
            if (index != -1) {
              ref.read(playbackQueueProvider.notifier).setIndex(index);
            }
            context.push('/scenes/scene/${scene.id}');
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
