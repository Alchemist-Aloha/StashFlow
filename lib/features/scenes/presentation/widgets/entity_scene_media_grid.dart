import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/filter_options.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../providers/entity_media_filter_scope.dart';
import '../providers/playback_queue_provider.dart';
import 'scene_card.dart';
import 'scene_filter_panel.dart';
import 'scene_saved_filter_dialog.dart';

enum EntitySceneMediaSortField {
  date,
  title,
  rating,
  duration,
  playCount,
  createdAt,
  updatedAt,
  random,
}

class EntitySceneMediaGrid extends ConsumerStatefulWidget {
  const EntitySceneMediaGrid({
    required this.title,
    required this.entityId,
    required this.filterKind,
    required this.mediaAsync,
    required this.isGridView,
    required this.gridColumns,
    required this.queueId,
    required this.onRefresh,
    required this.onFetchNextPage,
    super.key,
  });

  final String title;
  final String entityId;
  final EntityMediaFilterKind filterKind;
  final AsyncValue<List<Scene>> mediaAsync;
  final bool isGridView;
  final int? gridColumns;
  final String queueId;
  final Future<void> Function() onRefresh;
  final VoidCallback onFetchNextPage;

  @override
  ConsumerState<EntitySceneMediaGrid> createState() =>
      _EntitySceneMediaGridState();
}

class _EntitySceneMediaGridState extends ConsumerState<EntitySceneMediaGrid> {
  EntitySceneMediaSortField _sortField = EntitySceneMediaSortField.date;
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sortConfig = ref.read(entityMediaSortProvider(widget.filterKind));
      setState(() {
        _sortField = _sortFieldForKey(sortConfig.sort);
        _sortDescending = sortConfig.descending;
      });
    });
  }

  SceneFilter _scopedFilter(SceneFilter filter) {
    return sceneFilterForEntityMedia(
      filter: filter,
      kind: widget.filterKind,
      entityId: widget.entityId,
    );
  }

  String _sortKeyForField(EntitySceneMediaSortField field) {
    return switch (field) {
      EntitySceneMediaSortField.date => 'date',
      EntitySceneMediaSortField.title => 'title',
      EntitySceneMediaSortField.rating => 'rating',
      EntitySceneMediaSortField.duration => 'duration',
      EntitySceneMediaSortField.playCount => 'play_count',
      EntitySceneMediaSortField.createdAt => 'created_at',
      EntitySceneMediaSortField.updatedAt => 'updated_at',
      EntitySceneMediaSortField.random => 'random',
    };
  }

  EntitySceneMediaSortField _sortFieldForKey(String? sort) {
    return switch (sort) {
      'title' => EntitySceneMediaSortField.title,
      'rating' => EntitySceneMediaSortField.rating,
      'duration' => EntitySceneMediaSortField.duration,
      'play_count' => EntitySceneMediaSortField.playCount,
      'created_at' => EntitySceneMediaSortField.createdAt,
      'updated_at' => EntitySceneMediaSortField.updatedAt,
      'random' => EntitySceneMediaSortField.random,
      _ => EntitySceneMediaSortField.date,
    };
  }

  String _sortFieldLabel(EntitySceneMediaSortField field) {
    return switch (field) {
      EntitySceneMediaSortField.date => context.l10n.common_date,
      EntitySceneMediaSortField.title => context.l10n.common_title,
      EntitySceneMediaSortField.rating => context.l10n.common_rating,
      EntitySceneMediaSortField.duration => context.l10n.scenes_sort_duration,
      EntitySceneMediaSortField.playCount => context.l10n.performers_play_count,
      EntitySceneMediaSortField.createdAt => context.l10n.sort_created_at,
      EntitySceneMediaSortField.updatedAt => context.l10n.sort_updated_at,
      EntitySceneMediaSortField.random => context.l10n.sort_random,
    };
  }

  void _applyServerSort() {
    ref
        .read(entityMediaSortProvider(widget.filterKind).notifier)
        .setSort(
          sort: _sortKeyForField(_sortField),
          descending: _sortDescending,
        );
  }

  void _showSortPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        var tempField = _sortField;
        var tempDescending = _sortDescending;

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
                            context.l10n.sort_scenes,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setModalState(() {
                            tempField = EntitySceneMediaSortField.date;
                            tempDescending = true;
                          }),
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
                    Wrap(
                      spacing: context.dimensions.spacingSmall,
                      runSpacing: context.dimensions.spacingSmall,
                      children: EntitySceneMediaSortField.values
                          .map(
                            (field) => ChoiceChip(
                              label: Text(_sortFieldLabel(field)),
                              selected: tempField == field,
                              onSelected: (selected) {
                                if (!selected) return;
                                setModalState(() => tempField = field);
                              },
                            ),
                          )
                          .toList(),
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
                            icon: const Icon(Icons.arrow_downward),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text(context.l10n.common_ascending),
                            icon: const Icon(Icons.arrow_upward),
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
                              .read(
                                entityMediaSortProvider(
                                  widget.filterKind,
                                ).notifier,
                              )
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SceneFilterPanel(
        initialFilter: ref.read(
          entityMediaFilterStateProvider(widget.filterKind),
        ),
        initialOrganized: ref.read(
          entityMediaOrganizedOnlyProvider(widget.filterKind),
        ),
        onApply: (filter, organized) {
          ref
              .read(entityMediaFilterStateProvider(widget.filterKind).notifier)
              .update(filter);
          ref
              .read(
                entityMediaOrganizedOnlyProvider(widget.filterKind).notifier,
              )
              .set(organized);
        },
        onSaveDefault: (filter, organized) async {
          ref
              .read(entityMediaFilterStateProvider(widget.filterKind).notifier)
              .update(filter);
          ref
              .read(
                entityMediaOrganizedOnlyProvider(widget.filterKind).notifier,
              )
              .set(organized);
          await Future.wait([
            ref
                .read(
                  entityMediaFilterStateProvider(widget.filterKind).notifier,
                )
                .saveAsDefault(),
            ref
                .read(
                  entityMediaOrganizedOnlyProvider(widget.filterKind).notifier,
                )
                .saveAsDefault(),
          ]);
        },
        saveSuccessMessage: context.l10n.scenes_filter_saved,
      ),
    );
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(entityMediaSortProvider(widget.filterKind));
    final filter = ref.read(entityMediaFilterStateProvider(widget.filterKind));
    final organizedFilter = ref.read(
      entityMediaOrganizedOnlyProvider(widget.filterKind),
    );
    final effectiveFilter = _scopedFilter(
      filter.copyWith(organized: organizedFilter.toBool() ?? filter.organized),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SceneSavedFilterDialog(
        searchQuery: ref.read(
          entityMediaSearchQueryProvider(widget.filterKind),
        ),
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        filter: effectiveFilter,
        onLoad: _applySavedFilterConfig,
      ),
    );
  }

  void _applySavedFilterConfig(SceneSavedFilterConfig config) {
    final scopedFilter = _scopedFilter(config.filter);
    setState(() {
      _sortField = _sortFieldForKey(config.sort);
      _sortDescending = config.descending;
    });

    ref
        .read(entityMediaSearchQueryProvider(widget.filterKind).notifier)
        .update(config.searchQuery);
    ref
        .read(entityMediaFilterStateProvider(widget.filterKind).notifier)
        .update(scopedFilter.copyWith(organized: null));
    ref
        .read(entityMediaOrganizedOnlyProvider(widget.filterKind).notifier)
        .set(OrganizedFilter.fromBool(scopedFilter.organized));
    ref
        .read(entityMediaSortProvider(widget.filterKind).notifier)
        .setSort(sort: config.sort ?? 'date', descending: config.descending);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(entityMediaFilterStateProvider(widget.filterKind));
    final scopedFilter = _scopedFilter(filter);
    final baseFilter = _scopedFilter(SceneFilter.empty());
    final organizedFilter = ref.watch(
      entityMediaOrganizedOnlyProvider(widget.filterKind),
    );
    final hasActiveFilters =
        scopedFilter != baseFilter || organizedFilter != OrganizedFilter.all;
    final scenes = widget.mediaAsync.value ?? const <Scene>[];

    return ListPageScaffold<Scene>(
      title: widget.title,
      searchHint: context.l10n.scenes_search_hint,
      onSearchChanged: (query) => ref
          .read(entityMediaSearchQueryProvider(widget.filterKind).notifier)
          .update(query),
      provider: widget.mediaAsync,
      onRefresh: widget.onRefresh,
      onFetchNextPage: widget.onFetchNextPage,
      loadingItemBuilder: (context, isGrid, index) =>
          SceneCard.skeleton(isGrid: isGrid, useMasonry: isGrid),
      gridDelegate: widget.isGridView
          ? GridUtils.createDelegate(crossAxisCount: widget.gridColumns ?? 2)
          : null,
      useMasonry: widget.isGridView,
      padding: widget.isGridView ? GridUtils.defaultPadding : EdgeInsets.zero,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.scenes_sort_tooltip,
              onPressed: _showSortPanel,
            ),
            if (_sortField != EntitySceneMediaSortField.date ||
                !_sortDescending)
              const Positioned(right: 8, top: 8, child: _ActionDot()),
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
              const Positioned(right: 8, top: 8, child: _ActionDot()),
          ],
        ),
        IconButton(
          tooltip: context.l10n.common_saved_filters,
          icon: const Icon(Icons.bookmarks_outlined),
          onPressed: _showSavedFilterDialog,
        ),
      ],
      itemBuilder: (context, item, memCacheWidth, memCacheHeight) {
        return SceneCard(
          scene: item,
          isGrid: widget.isGridView,
          useMasonry: widget.isGridView,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
          useHero: GoRouter.of(
            context,
          ).routeInformationProvider.value.uri.path.endsWith('/media'),
          onTap: () {
            ref
                .read(playbackQueueProvider.notifier)
                .setSequenceForScene(widget.queueId, scenes, item.id);
            context.push('/scenes/scene/${item.id}', extra: true);
          },
        );
      },
    );
  }
}

class _ActionDot extends StatelessWidget {
  const _ActionDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
    );
  }
}
