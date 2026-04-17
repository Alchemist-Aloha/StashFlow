import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
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
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
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
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text(context.l10n.common_sort_method, style: context.textTheme.labelLarge),
                    const SizedBox(height: AppTheme.spacingSmall),
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
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
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text(context.l10n.common_direction, style: context.textTheme.labelLarge),
                    const SizedBox(height: AppTheme.spacingSmall),
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
                    const SizedBox(height: AppTheme.spacingLarge),
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
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_apply_sort),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
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
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppTheme.spacingMedium,
                          ),
                        ),
                        child: Text(context.l10n.common_save_default),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
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
    final organizedOnly = ref.watch(sceneOrganizedOnlyProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final isFullScreen = ref.watch(fullScreenModeProvider);
    final scrollController = ref.watch(sceneScrollControllerProvider);

    final hasActiveFilters = filterActive || organizedOnly;

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
        final availableWidth = MediaQuery.of(context).size.width - padding;
        final itemWidth =
            (availableWidth - (AppTheme.spacingSmall * (crossAxisCount - 1))) /
            crossAxisCount;
        return (itemWidth * 2).toInt();
      },
      customBody: isTiktokLayout ? const TiktokScenesView() : null,
      scrollController: scrollController,
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
        final scenes = scenesAsync.value ?? [];
        final index = scenes.indexWhere((s) => s.id == scene.id);

        return SceneCard(
          scene: scene,
          isGrid: isGridView,
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
