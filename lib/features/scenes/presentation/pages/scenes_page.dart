import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../providers/scene_list_provider.dart';
import '../widgets/scene_card.dart';

import '../../../../core/presentation/widgets/list_page_scaffold.dart';
import '../../../../core/presentation/theme/app_theme.dart';

import '../widgets/scene_filter_panel.dart';

enum _SceneSortOption { dateNewest, dateOldest, rating, playCount, random }

class ScenesPage extends ConsumerStatefulWidget {
  const ScenesPage({super.key});

  @override
  ConsumerState<ScenesPage> createState() => _ScenesPageState();
}

class _ScenesPageState extends ConsumerState<ScenesPage> {
  bool _isGridView = false;
  _SceneSortOption _sortOption = _SceneSortOption.dateNewest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyServerSort(_sortOption);
    });
  }

  void _onSearchChanged(String query) {
    ref.read(sceneSearchQueryProvider.notifier).update(query);
  }

  void _applyServerSort(_SceneSortOption option) {
    switch (option) {
      case _SceneSortOption.dateNewest:
        ref.read(sceneListProvider.notifier).setSort(sort: 'date', descending: true);
        break;
      case _SceneSortOption.dateOldest:
        ref.read(sceneListProvider.notifier).setSort(sort: 'date', descending: false);
        break;
      case _SceneSortOption.rating:
        ref.read(sceneListProvider.notifier).setSort(sort: 'rating100', descending: true);
        break;
      case _SceneSortOption.playCount:
        ref.read(sceneListProvider.notifier).setSort(sort: 'play_count', descending: true);
        break;
      case _SceneSortOption.random:
        ref.read(sceneListProvider.notifier).setSort(sort: 'random', descending: true);
        break;
    }
  }

  Future<void> _openRandomScene() async {
    final randomScene = await ref.read(sceneListProvider.notifier).getRandomScene(useCurrentFilter: true);
    if (!mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scenes available for random navigation')),
      );
      return;
    }

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

  Widget _buildSortBar() {
    const options = [
      (_SceneSortOption.dateNewest, 'Newest'),
      (_SceneSortOption.dateOldest, 'Oldest'),
      (_SceneSortOption.rating, 'Rating'),
      (_SceneSortOption.playCount, 'Play Count'),
      (_SceneSortOption.random, 'Random'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: AppTheme.spacingSmall),
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: Text(option.$2),
              selected: _sortOption == option.$1,
              onSelected: (selected) {
                if (!selected) return;
                setState(() => _sortOption = option.$1);
                _applyServerSort(option.$1);
              },
            ),
            const SizedBox(width: AppTheme.spacingSmall),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenesAsync = ref.watch(sceneListProvider);
    final filterState = ref.watch(sceneFilterStateProvider);
    final hasActiveFilters = filterState != SceneFilter.empty();

    return ListPageScaffold<Scene>(
      title: 'Stash',
      searchHint: 'Search scenes...',
      onSearchChanged: _onSearchChanged,
      provider: scenesAsync,
      onRefresh: () => ref.refresh(sceneListProvider.future),
      onFetchNextPage: () => ref.read(sceneListProvider.notifier).fetchNextPage(),
      sortBar: _buildSortBar(),
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () => setState(() => _isGridView = !_isGridView),
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
        IconButton(
          icon: const Icon(Icons.casino_outlined),
          tooltip: 'Random scene',
          onPressed: _openRandomScene,
        ),
      ],
      gridDelegate: _isGridView
          ? const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppTheme.spacingSmall,
              mainAxisSpacing: AppTheme.spacingSmall,
              childAspectRatio: 0.8,
            )
          : null,
      padding: EdgeInsets.all(_isGridView ? AppTheme.spacingSmall : 0),
      itemBuilder: (context, scene) => SceneCard(
        scene: scene,
        isGrid: _isGridView,
        onTap: () => context.push('/scene/${scene.id}'),
      ),
    );
  }
}
