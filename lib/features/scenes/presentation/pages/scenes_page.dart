import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../domain/entities/scene.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/scene_filter.dart';
import '../providers/scene_list_provider.dart';
import '../providers/playback_queue_provider.dart';
import '../providers/video_player_provider.dart';
import '../widgets/scene_card.dart';
import '../widgets/tiktok_scenes_view.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/responsive.dart';

import '../widgets/scene_filter_panel.dart';

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

  /// Flag to ensure initial prefetch only runs once per result set.
  bool _didPrefetchInitialScenes = false;

  // Visible-range prefetch helpers
  /// Key used to measure the height of the first item in the list.
  final GlobalKey _firstItemKey = GlobalKey();

  /// The measured height of a single item in list view, used for scroll prefetch math.
  double? _measuredItemExtent;

  /// Tracks if the scroll listener has been successfully attached.
  bool _didAttachScrollListener = false;

  /// Reference to the active scroll controller for listener management.
  ScrollController? _attachedScrollController;

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
    // Clean up scroll listener if it was attached.
    if (_didAttachScrollListener && _attachedScrollController != null) {
      try {
        _attachedScrollController!.removeListener(_onScroll);
      } catch (_) {}
    }
    super.dispose();
  }

  int _getGridColumnCount(BuildContext context) {
    return Responsive.isMobile(context) ? 2 : 3;
  }

  /// Handles intelligent image prefetching based on scroll position.
  ///
  /// This method calculates which items are likely to become visible soon
  /// and triggers a background prefetch of their thumbnails. It adapts
  /// its math based on whether the layout is a Grid or a List.
  void _onScroll() {
    final controller = _attachedScrollController;
    if (controller == null || !mounted) return;

    final scenes = ref.read(sceneListProvider).value ?? [];
    if (scenes.isEmpty) return;

    final offset = controller.position.pixels;
    final int kPrefetchDistance = StashImage.defaultPrefetchDistance;

    if (ref.read(sceneGridLayoutProvider)) {
      // Grid layout: compute item sizes based on viewport width and fixed columns.
      final padding = AppTheme.spacingSmall * 2;
      final crossAxisCount = _getGridColumnCount(context);
      final availableWidth = MediaQuery.of(context).size.width - padding;
      final itemWidth =
          (availableWidth - (AppTheme.spacingSmall * (crossAxisCount - 1))) / crossAxisCount;
      // Note: itemHeight here is an estimate; actual height depends on childAspectRatio.
      final itemHeight = itemWidth * (1 / 1.15); 
      final stride = itemHeight + AppTheme.spacingMedium;
      final visibleRow = (offset / stride).floor().clamp(0, scenes.length - 1);
      final visibleIndex = (visibleRow * crossAxisCount).clamp(
        0,
        scenes.length - 1,
      );

      for (var i = 1; i <= kPrefetchDistance; i++) {
        final ahead = visibleIndex + i;
        if (ahead < scenes.length) {
          StashImage.prefetch(
            context,
            imageUrl: scenes[ahead].paths.screenshot,
            memCacheWidth: (itemWidth * 2).toInt(),
          );
        }
        final behind = visibleIndex - i;
        if (behind >= 0) {
          StashImage.prefetch(
            context,
            imageUrl: scenes[behind].paths.screenshot,
            memCacheWidth: (itemWidth * 2).toInt(),
          );
        }
      }
    } else {
      // List layout: use measured extent of the first item for precise math.
      final stride = _measuredItemExtent ?? 300.0;
      final visibleIndex = (offset / stride).floor().clamp(
        0,
        scenes.length - 1,
      );

      for (var i = 1; i <= kPrefetchDistance; i++) {
        final ahead = visibleIndex + i;
        if (ahead < scenes.length) {
          StashImage.prefetch(
            context,
            imageUrl: scenes[ahead].paths.screenshot,
            memCacheWidth: 640,
          );
        }
        final behind = visibleIndex - i;
        if (behind >= 0) {
          StashImage.prefetch(
            context,
            imageUrl: scenes[behind].paths.screenshot,
            memCacheWidth: 640,
          );
        }
      }
    }
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
    ref.read(sceneSortProvider.notifier).setSort(sort: sortKey, descending: _sortDescending);
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
      _SceneSortField.date => 'Date',
      _SceneSortField.rating => 'Rating',
      _SceneSortField.playCount => 'Play Count',
      _SceneSortField.title => 'Title',
      _SceneSortField.duration => 'Duration',
      _SceneSortField.bitrate => 'Bitrate',
      _SceneSortField.framerate => 'Framerate',
      _SceneSortField.updatedAt => 'Updated At',
      _SceneSortField.createdAt => 'Created At',
      _SceneSortField.random => 'Random',
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
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Text('Sort Method', style: context.textTheme.labelLarge),
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
                    Text('Direction', style: context.textTheme.labelLarge),
                    const SizedBox(height: AppTheme.spacingSmall),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: true,
                            label: Text('Descending'),
                            icon: Icon(Icons.arrow_downward),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text('Ascending'),
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
                        child: const Text('Apply Sort'),
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
                              const SnackBar(
                                content: Text(
                                  'Sort preferences saved as default',
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
                        child: const Text('Save as Default'),
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
    final scenesAsync = ref.watch(sceneListProvider);

    // Reset initial-prefetch flag when search or filters change so the
    // initial warm runs for new result sets (prevents relying solely on
    // per-item warming when user applies a filter/search).
    ref.listen(sceneSearchQueryProvider, (previous, next) {
      _didPrefetchInitialScenes = false;
    });
    ref.listen(sceneFilterStateProvider, (previous, next) {
      _didPrefetchInitialScenes = false;
    });

    // Use select for more granular watching where possible
    final filterActive = ref.watch(
      sceneFilterStateProvider.select((s) => s != SceneFilter.empty()),
    );
    final organizedOnly = ref.watch(sceneOrganizedOnlyProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final isFullScreen = ref.watch(fullScreenModeProvider);
    final scrollController = ref.watch(sceneScrollControllerProvider);

    final hasActiveFilters = filterActive || organizedOnly;

    // Prefetch first N thumbnails once on initial data arrival (avoids
    // relying on itemBuilder which only runs for built items).
    scenesAsync.maybeWhen(
      data: (items) {
        if (!_didPrefetchInitialScenes && items.isNotEmpty) {
          _didPrefetchInitialScenes = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final int kPrefetchDistance = StashImage.defaultPrefetchDistance;
            final count = items.length < kPrefetchDistance
                ? items.length
                : kPrefetchDistance;
            if (isGridView) {
              final padding = AppTheme.spacingSmall * 2;
              final crossAxisCount = _getGridColumnCount(context);
              final availableWidth =
                  MediaQuery.of(context).size.width - padding;
              final itemWidth =
                  (availableWidth - (AppTheme.spacingSmall * (crossAxisCount - 1))) / crossAxisCount;
              for (var i = 0; i < count; i++) {
                StashImage.prefetch(
                  context,
                  imageUrl: items[i].paths.screenshot,
                  memCacheWidth: (itemWidth * 2).toInt(),
                );
              }
            } else {
              for (var i = 0; i < count; i++) {
                StashImage.prefetch(
                  context,
                  imageUrl: items[i].paths.screenshot,
                  memCacheWidth: 640,
                );
              }
            }
          });
        }
      },
      orElse: () {},
    );

    return ListPageScaffold<Scene>(
      title: 'StashFlow',
      searchHint: 'Search scenes...',
      onSearchChanged: _onSearchChanged,
      provider: scenesAsync,
      customBody: isTiktokLayout ? const TiktokScenesView() : null,
      scrollController: scrollController,
      hideAppBar: isTiktokLayout && isFullScreen,
      onRefresh: () => ref.refresh(sceneListProvider.future),
      onFetchNextPage: () =>
          ref.read(sceneListProvider.notifier).fetchNextPage(),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort options',
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
          ? SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getGridColumnCount(context),
              crossAxisSpacing: AppTheme.spacingSmall,
              mainAxisSpacing: AppTheme.spacingMedium,
              // Taller items to allow more space for Title and Studio metadata.
              // A ratio of 1.15 (down from 1.33) provides significantly more
              // vertical breathing room below the 16:9 image.
              childAspectRatio: 1.15,
            )
          : null,
      padding: EdgeInsets.all(isGridView ? AppTheme.spacingSmall : 0),
      itemBuilder: (context, scene) {
        final scenes = scenesAsync.value ?? [];
        final index = scenes.indexWhere((s) => s.id == scene.id);

        // Attach scroll listener once (after controller becomes available).
        if (!_didAttachScrollListener && scrollController != null) {
          _didAttachScrollListener = true;
          _attachedScrollController = scrollController;
          try {
            _attachedScrollController!.addListener(_onScroll);
          } catch (_) {}
        }

        final sceneCard = SceneCard(
          key: index == 0 ? _firstItemKey : null,
          scene: scene,
          isGrid: isGridView,
          onTap: () {
            if (index != -1) {
              ref.read(playbackQueueProvider.notifier).setIndex(index);
            }
            context.push('/scenes/scene/${scene.id}');
          },
        );

        // Measure first item height once to speed up visible-index math for list layout.
        if (index == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_measuredItemExtent == null &&
                _firstItemKey.currentContext != null) {
              final size = _firstItemKey.currentContext!.size;
              if (size != null) {
                setState(() {
                  _measuredItemExtent = size.height;
                });
              }
            }
          });
        }

        return sceneCard;
      },
      floatingActionButton: (randomNavigationEnabled && !isTiktokLayout)
          ? scenesAsync.maybeWhen(
              data: (scenes) => FloatingActionButton.small(
                onPressed: _openRandomScene,
                tooltip: 'Random scene',
                child: const Icon(Icons.casino_outlined),
              ),
              orElse: () => null,
            )
          : null,
    );
  }
}
