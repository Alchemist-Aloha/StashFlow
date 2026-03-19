import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/scene.dart';
import '../../../../core/utils/pagination.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../providers/scene_list_provider.dart';
import '../widgets/scene_card.dart';

enum _SceneSortOption { dateNewest, dateOldest, rating, playCount, random }

class ScenesPage extends ConsumerStatefulWidget {
  const ScenesPage({super.key});

  @override
  ConsumerState<ScenesPage> createState() => _ScenesPageState();
}

class _ScenesPageState extends ConsumerState<ScenesPage> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  bool _isGridView = false;
  _SceneSortOption _sortOption = _SceneSortOption.dateNewest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(sceneSearchQueryProvider.notifier).update(query);
  }

  List<Scene> _sortScenes(List<Scene> input) {
    final scenes = [...input];
    switch (_sortOption) {
      case _SceneSortOption.dateNewest:
      case _SceneSortOption.dateOldest:
      case _SceneSortOption.rating:
      case _SceneSortOption.playCount:
        // Server-side ordering handles these options.
        break;
      case _SceneSortOption.random:
        scenes.shuffle();
        break;
    }
    return scenes;
  }

  void _applyServerSort(_SceneSortOption option) {
    switch (option) {
      case _SceneSortOption.dateNewest:
        ref.read(sceneListProvider.notifier).setSort(
          sort: 'date',
          descending: true,
        );
        break;
      case _SceneSortOption.dateOldest:
        ref.read(sceneListProvider.notifier).setSort(
          sort: 'date',
          descending: false,
        );
        break;
      case _SceneSortOption.rating:
        ref.read(sceneListProvider.notifier).setSort(
          sort: 'rating100',
          descending: true,
        );
        break;
      case _SceneSortOption.playCount:
        ref.read(sceneListProvider.notifier).setSort(
          sort: 'play_count',
          descending: true,
        );
        break;
      case _SceneSortOption.random:
        // Random option intentionally remains client-side shuffle.
        ref.read(sceneListProvider.notifier).setSort(
          sort: 'date',
          descending: true,
        );
        break;
    }
  }

  Future<void> _openRandomScene() async {
    final randomScene = await ref
        .read(sceneListProvider.notifier)
        .getRandomScene();
    if (!mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No scenes available for random navigation'),
        ),
      );
      return;
    }

    context.push('/scene/${randomScene.id}');
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
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
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
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scenesAsync = ref.watch(sceneListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search scenes...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _onSearchChanged,
              )
            : const Text(
                'Stash',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() => _isSearching = false);
                _searchController.clear();
                _onSearchChanged('');
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _isSearching = true),
            ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Random scene',
            onPressed: _openRandomScene,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              radius: 14,
              child: Icon(Icons.person, size: 18),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSortBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(sceneListProvider.future),
              child: scenesAsync.when(
                data: (scenes) {
                  final sortedScenes = _sortScenes(scenes);
                  if (sortedScenes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No scenes found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (shouldLoadNextPage(scrollInfo.metrics)) {
                        ref.read(sceneListProvider.notifier).fetchNextPage();
                      }
                      return false;
                    },
                    child: _isGridView
                        ? GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  childAspectRatio: 0.8,
                                ),
                            padding: const EdgeInsets.all(8),
                            itemCount: sortedScenes.length,
                            itemBuilder: (context, index) => SceneCard(
                              scene: sortedScenes[index],
                              isGrid: true,
                              onTap: () => context.push(
                                '/scene/${sortedScenes[index].id}',
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: sortedScenes.length,
                            itemBuilder: (context, index) => SceneCard(
                              scene: sortedScenes[index],
                              isGrid: false,
                              onTap: () => context.push(
                                '/scene/${sortedScenes[index].id}',
                              ),
                            ),
                          ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => ErrorStateView(
                  message: 'Failed to load scenes.\n$err',
                  onRetry: () => ref.refresh(sceneListProvider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
