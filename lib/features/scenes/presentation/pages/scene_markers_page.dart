import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/grid_utils.dart';
import '../../../../core/presentation/widgets/list_page_scaffold.dart';
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
                      children: [
                        Expanded(
                          child: Text(
                            'Sort markers',
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempField = _MarkerSortField.createdAt;
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
                          maxHeight: MediaQuery.sizeOf(context).height * 0.22,
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
                              children: [
                                for (final field in _MarkerSortField.values)
                                  ChoiceChip(
                                    label: Text(_sortLabel(context, field)),
                                    selected: tempField == field,
                                    onSelected: (selected) {
                                      if (!selected) return;
                                      setModalState(() => tempField = field);
                                    },
                                  ),
                              ],
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
                          _applySort();
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
                          _applySort();
                          await ref
                              .read(sceneMarkerSortProvider.notifier)
                              .saveAsDefault();
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Marker sort saved as default'),
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
    final hasCustomSort =
        _sortField != _MarkerSortField.createdAt || !_sortDescending;

    return ListPageScaffold<SceneMarkerSummary>(
      title: 'Markers',
      searchHint: 'Search markers',
      onSearchChanged: _onSearchChanged,
      provider: markersAsync,
      emptyMessage: 'No markers found',
      onRefresh: () => ref.read(sceneMarkerListProvider.notifier).refresh(),
      onFetchNextPage: () =>
          ref.read(sceneMarkerListProvider.notifier).fetchNextPage(),
      onPageSizeChanged: (pageSize) =>
          ref.read(sceneMarkerListProvider.notifier).setPerPage(pageSize),
      useMasonry: true,
      gridDelegate: GridUtils.createDelegate(crossAxisCount: 2),
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
        return SceneMarkerCard(marker: marker, isGrid: true);
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
