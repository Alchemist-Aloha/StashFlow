import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/domain/entities/filter_options.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/list_sort_bottom_sheet.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/entities/scene_saved_filter_config.dart';
import '../scene_sort.dart';
import '../providers/entity_media_filter_scope.dart';
import '../providers/playback_queue_provider.dart';
import 'scene_card.dart';
import 'scene_filter_panel.dart';
import 'scene_saved_filter_dialog.dart';

class EntitySceneMediaGrid extends ConsumerStatefulWidget {
  const EntitySceneMediaGrid({
    required this.title,
    required this.entityId,
    required this.filterKind,
    required this.mediaAsync,
    required this.isGridView,
    required this.gridColumns,
    this.gridColumnSetting,
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

  /// Category preference shared with the Interface settings page.
  final GridColumnSetting? gridColumnSetting;
  final String queueId;
  final Future<void> Function() onRefresh;
  final VoidCallback onFetchNextPage;

  @override
  ConsumerState<EntitySceneMediaGrid> createState() =>
      _EntitySceneMediaGridState();
}

class _EntitySceneMediaGridState extends ConsumerState<EntitySceneMediaGrid> {
  SceneSortField _sortField = SceneSortField.random;
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final sortConfig = ref.read(entityMediaSortProvider(widget.filterKind));
      setState(() {
        _sortField = SceneSortField.fromKey(sortConfig.sort);
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

  void _applyServerSort() {
    ref
        .read(entityMediaSortProvider(widget.filterKind).notifier)
        .setSort(sort: _sortField.key, descending: _sortDescending);
  }

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
          resetOption: SceneSortField.random,
          resetDescending: true,
          optionLabel: (field) => field.label(context),
          onApply: (field, descending) {
            setState(() {
              _sortField = field;
              _sortDescending = descending;
            });
            _applyServerSort();
          },
          onSaveDefault: () => ref
              .read(entityMediaSortProvider(widget.filterKind).notifier)
              .saveAsDefault(),
          saveDefaultSuccessMessage: context.l10n.scenes_sort_saved_default,
        ),
      ),
    );
  }

  void _showFilterPanel() {
    unawaited(
      showFrostedPanelBottomSheet<void>(
        context: context,
        builder: (context) => SceneFilterPanel(
          initialFilter: ref.read(
            entityMediaFilterStateProvider(widget.filterKind),
          ),
          initialOrganized: ref.read(
            entityMediaOrganizedOnlyProvider(widget.filterKind),
          ),
          onApply: (filter, organized) {
            ref
                .read(
                  entityMediaFilterStateProvider(widget.filterKind).notifier,
                )
                .update(filter);
            ref
                .read(
                  entityMediaOrganizedOnlyProvider(widget.filterKind).notifier,
                )
                .set(organized);
          },
          onSaveDefault: (filter, organized) async {
            ref
                .read(
                  entityMediaFilterStateProvider(widget.filterKind).notifier,
                )
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
                    entityMediaOrganizedOnlyProvider(
                      widget.filterKind,
                    ).notifier,
                  )
                  .saveAsDefault(),
            ]);
          },
          saveSuccessMessage: context.l10n.scenes_filter_saved,
        ),
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

    unawaited(
      showFrostedPanelBottomSheet<void>(
        context: context,
        builder: (context) => SceneSavedFilterDialog(
          searchQuery: ref.read(
            entityMediaSearchQueryProvider(widget.filterKind),
          ),
          sort: sortConfig.sort,
          descending: sortConfig.descending,
          filter: effectiveFilter,
          onLoad: _applySavedFilterConfig,
        ),
      ),
    );
  }

  void _applySavedFilterConfig(SceneSavedFilterConfig config) {
    final scopedFilter = _scopedFilter(config.filter);
    setState(() {
      _sortField = SceneSortField.fromKey(config.sort ?? 'random');
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
        .setSort(sort: config.sort, descending: config.descending);
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
      gridColumnSetting: widget.gridColumnSetting,
      title: widget.title,
      searchOnlyAppBar: true,
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
          ? GridUtils.createDelegate(
              context,
              crossAxisCount: widget.gridColumns ?? 2,
            )
          : null,
      useMasonry: widget.isGridView,
      padding: widget.isGridView
          ? GridUtils.defaultPadding(context)
          : EdgeInsets.zero,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.scenes_sort_tooltip,
              onPressed: _showSortPanel,
            ),
            if (_sortField != SceneSortField.date || !_sortDescending)
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
            unawaited(context.push('/scenes/scene/${item.id}', extra: true));
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
