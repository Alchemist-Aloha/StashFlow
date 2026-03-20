import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../providers/scene_list_provider.dart';
import '../widgets/scene_card.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';

import '../widgets/scene_filter_panel.dart';

enum _SceneSortField {
  date,
  rating,
  playCount,
  title,
  duration,
  bitrate,
  framerate,
  filesize,
  random,
}

class ScenesPage extends ConsumerStatefulWidget {
  const ScenesPage({super.key});

  @override
  ConsumerState<ScenesPage> createState() => _ScenesPageState();
}

class _ScenesPageState extends ConsumerState<ScenesPage> {
  static const _sceneGridLayoutKey = 'scene_grid_layout';
  _SceneSortField _sortField = _SceneSortField.date;
  bool _sortDescending = true;
  String? _lastRandomSceneId;

  @override
  void initState() {
    super.initState();
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
          'filesize' => _SceneSortField.filesize,
          'random' => _SceneSortField.random,
          _ => _SceneSortField.date,
        };
        _sortDescending = sortConfig.descending;
      });
      _applyServerSort();
    });
  }

  void _onSearchChanged(String query) {
    ref.read(sceneSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort() {
    final sortKey = switch (_sortField) {
      _SceneSortField.date => 'date',
      _SceneSortField.rating => 'rating',
      _SceneSortField.playCount => 'play_count',
      _SceneSortField.title => 'title',
      _SceneSortField.duration => 'duration',
      _SceneSortField.bitrate => 'bitrate',
      _SceneSortField.framerate => 'framerate',
      _SceneSortField.filesize => 'size',
      _SceneSortField.random => 'random',
    };

    ref
        .read(sceneListProvider.notifier)
        .setSort(sort: sortKey, descending: _sortDescending);
  }

  Future<void> _openRandomScene() async {
    final randomScene = await ref
        .read(sceneListProvider.notifier)
        .getRandomScene(
          useCurrentFilter: true,
          excludeSceneId: _lastRandomSceneId,
        );
    if (!mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No scenes available for random navigation'),
        ),
      );
      return;
    }

    _lastRandomSceneId = randomScene.id;
    context.push('/scene/${randomScene.id}');
  }

  void _showFilterPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SceneFilterPanel(),
    );
  }

  String _sortFieldLabel(_SceneSortField field) {
    return switch (field) {
      _SceneSortField.date => 'Date',
      _SceneSortField.rating => 'Rating',
      _SceneSortField.playCount => 'Play Count',
      _SceneSortField.title => 'Title',
      _SceneSortField.duration => 'Duration',
      _SceneSortField.bitrate => 'Bitrate',
      _SceneSortField.framerate => 'Framerate',
      _SceneSortField.filesize => 'Filesize',
      _SceneSortField.random => 'Random',
    };
  }

  void _showSortPanel() {
    var tempField = _sortField;
    var tempDescending = _sortDescending;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusExtraLarge),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sort Scenes',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
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
                        await ref.read(sceneSortProvider.notifier).saveAsDefault();
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sort preferences saved as default'),
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
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isGridView = prefs.getBool(_sceneGridLayoutKey) ?? false;
    final scenesAsync = ref.watch(sceneListProvider);
    final filterState = ref.watch(sceneFilterStateProvider);
    final organizedOnly = ref.watch(sceneOrganizedOnlyProvider);
    final hasActiveFilters =
        filterState != SceneFilter.empty() || organizedOnly;

    return ListPageScaffold<Scene>(
      title: 'Stash',
      searchHint: 'Search scenes...',
      onSearchChanged: _onSearchChanged,
      provider: scenesAsync,
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
          ? const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacingSmall,
              mainAxisSpacing: AppTheme.spacingSmall,
              childAspectRatio: 0.8,
            )
          : null,
      padding: EdgeInsets.all(isGridView ? AppTheme.spacingSmall : 0),
      itemBuilder: (context, scene) => SceneCard(
        scene: scene,
        isGrid: isGridView,
        onTap: () => context.push('/scene/${scene.id}'),
      ),
      floatingActionButton: scenesAsync.maybeWhen(
        data: (scenes) => FloatingActionButton.small(
          onPressed: _openRandomScene,
          tooltip: 'Random scene',
          child: const Icon(Icons.casino_outlined),
        ),
        orElse: () => null,
      ),
    );
  }
}
