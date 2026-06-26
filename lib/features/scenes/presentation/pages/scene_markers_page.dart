import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/providers/layout_settings_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/widgets/list_sort_bottom_sheet.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/scene_marker.dart';
import '../../domain/entities/scene_marker_saved_filter_config.dart';
import '../providers/scene_marker_list_provider.dart';
import '../widgets/scene_marker_card.dart';
import '../widgets/scene_marker_filter_panel.dart';
import '../widgets/scene_marker_saved_filter_dialog.dart';

enum _MarkerSortField { createdAt, updatedAt, title, seconds, random }

class SceneMarkersPage extends ConsumerStatefulWidget {
  const SceneMarkersPage({super.key});

  @override
  ConsumerState<SceneMarkersPage> createState() => _SceneMarkersPageState();
}

class _SceneMarkersPageState extends ConsumerState<SceneMarkersPage> {
  _MarkerSortField _sortField = _MarkerSortField.createdAt;
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    final sortConfig = ref.read(sceneMarkerSortProvider);
    _sortField = _sortFieldForKey(sortConfig.sort);
    _sortDescending = sortConfig.descending;
  }

  String _sortKey(_MarkerSortField field) {
    return switch (field) {
      _MarkerSortField.createdAt => 'created_at',
      _MarkerSortField.updatedAt => 'updated_at',
      _MarkerSortField.title => 'title',
      _MarkerSortField.seconds => 'seconds',
      _MarkerSortField.random => 'random',
    };
  }

  _MarkerSortField _sortFieldForKey(String? key) {
    return switch (key) {
      'updated_at' => _MarkerSortField.updatedAt,
      'title' => _MarkerSortField.title,
      'seconds' => _MarkerSortField.seconds,
      'random' => _MarkerSortField.random,
      _ => _MarkerSortField.createdAt,
    };
  }

  String _sortLabel(BuildContext context, _MarkerSortField field) {
    return switch (field) {
      _MarkerSortField.createdAt => context.l10n.sort_created_at,
      _MarkerSortField.updatedAt => context.l10n.sort_updated_at,
      _MarkerSortField.title => context.l10n.common_title,
      _MarkerSortField.seconds => 'Marker time',
      _MarkerSortField.random => context.l10n.sort_random,
    };
  }

  void _applySort() {
    ref
        .read(sceneMarkerSortProvider.notifier)
        .setSort(sort: _sortKey(_sortField), descending: _sortDescending);
  }

  void _onSearchChanged(String query) {
    ref.read(sceneMarkerSearchQueryProvider.notifier).update(query);
  }

  void _showSortPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ListSortBottomSheet<_MarkerSortField>(
        title: context.l10n.sort_markers_title,
        options: _MarkerSortField.values,
        initialOption: _sortField,
        initialDescending: _sortDescending,
        resetOption: _MarkerSortField.createdAt,
        resetDescending: true,
        optionLabel: (field) => _sortLabel(context, field),
        onApply: (field, descending) {
          setState(() {
            _sortField = field;
            _sortDescending = descending;
          });
          _applySort();
        },
        onSaveDefault: () =>
            ref.read(sceneMarkerSortProvider.notifier).saveAsDefault(),
        saveDefaultSuccessMessage: context.l10n.sort_markers_saved,
      ),
    );
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SceneMarkerFilterPanel(),
    );
  }

  void _showSavedFilterDialog() {
    final sortConfig = ref.read(sceneMarkerSortProvider);
    final filter = ref.read(sceneMarkerFilterStateProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SceneMarkerSavedFilterDialog(
        searchQuery: ref.read(sceneMarkerSearchQueryProvider),
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        filter: filter,
        onLoad: _applySavedFilterConfig,
      ),
    );
  }

  void _applySavedFilterConfig(SceneMarkerSavedFilterConfig config) {
    setState(() {
      _sortField = _sortFieldForKey(config.sort);
      _sortDescending = config.descending;
    });

    ref
        .read(sceneMarkerSearchQueryProvider.notifier)
        .update(config.searchQuery);
    ref.read(sceneMarkerFilterStateProvider.notifier).update(config.filter);
    ref
        .read(sceneMarkerSortProvider.notifier)
        .setSort(
          sort: config.sort ?? 'created_at',
          descending: config.descending,
        );
  }

  @override
  Widget build(BuildContext context) {
    final markersAsync = ref.watch(sceneMarkerListProvider);
    final filter = ref.watch(sceneMarkerFilterStateProvider);
    final isGridLayout = ref.watch(sceneMarkerGridLayoutProvider);
    final gridColumns = ref.watch(sceneMarkerGridColumnsProvider) ?? 2;
    final hasCustomSort =
        _sortField != _MarkerSortField.createdAt || !_sortDescending;

    return ListPageScaffold<SceneMarkerSummary>(
      title: context.l10n.markers_title,
      searchHint: 'Search markers',
      onSearchChanged: _onSearchChanged,
      provider: markersAsync,
      emptyMessage: 'No markers found',
      onRefresh: () => ref.read(sceneMarkerListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(sceneMarkerListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(sceneMarkerListProvider.notifier).setPerPage(pageSize),
      useMasonry: isGridLayout,
      gridDelegate: isGridLayout
          ? GridUtils.createDelegate(crossAxisCount: gridColumns)
          : null,
      padding: GridUtils.defaultPadding,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: context.l10n.common_sort,
              onPressed: _showSortPanel,
            ),
            if (hasCustomSort)
              const Positioned(right: 8, top: 8, child: _ActionDot()),
          ],
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: context.l10n.common_filter,
              onPressed: _showFilterPanel,
            ),
            if (!filter.isEmpty)
              const Positioned(right: 8, top: 8, child: _ActionDot()),
          ],
        ),
        IconButton(
          tooltip: context.l10n.common_saved_filters,
          icon: const Icon(Icons.bookmarks_outlined),
          onPressed: _showSavedFilterDialog,
        ),
      ],
      itemBuilder: (context, marker, memCacheWidth, memCacheHeight) {
        return SceneMarkerCard(marker: marker, isGrid: isGridLayout);
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
