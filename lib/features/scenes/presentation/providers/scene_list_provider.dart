import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../data/repositories/graphql_scene_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/utils/pagination.dart';

part 'scene_list_provider.g.dart';

// Provider for Repository interface
final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLSceneRepository(client);
});

@riverpod
class SceneSort extends _$SceneSort {
  @override
  ({String? sort, bool descending}) build() {
    return (sort: 'date', descending: true);
  }

  void setSort({String? sort, bool descending = true}) {
    state = (sort: sort, descending: descending);
  }
}

@riverpod
class SceneSearchQuery extends _$SceneSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class SceneFilterState extends _$SceneFilterState {
  @override
  SceneFilter build() => SceneFilter.empty();

  void update(SceneFilter filter) => state = filter;
  void clear() => state = SceneFilter.empty();
}

@riverpod
class SceneList extends _$SceneList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Scene>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(sceneSearchQueryProvider);
    final sortConfig = ref.watch(sceneSortProvider);
    final filter = ref.watch(sceneFilterStateProvider);
    final repository = ref.watch(sceneRepositoryProvider);
    
    return repository.findScenes(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: sortConfig.sort,
      descending: sortConfig.descending,
      sceneFilter: filter,
    );
  }

  void setSort({String? sort, bool descending = true}) {
    ref
        .read(sceneSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    _isLoadingMore = true;
    final repository = ref.read(sceneRepositoryProvider);
    final query = ref.read(sceneSearchQueryProvider);
    final sortConfig = ref.read(sceneSortProvider);
    final filter = ref.read(sceneFilterStateProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextScenes = await repository.findScenes(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        sceneFilter: filter,
      );

      if (nextScenes.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextScenes]);
      }
    } catch (e) {
      // In a real app, you might want to show a snackbar for error during pagination
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<Scene?> getRandomScene({
    bool useCurrentFilter = false,
    String? performerId,
    String? studioId,
    String? tagId,
  }) async {
    final repository = ref.read(sceneRepositoryProvider);
    final query = useCurrentFilter ? ref.read(sceneSearchQueryProvider) : '';
    final filter = useCurrentFilter ? ref.read(sceneFilterStateProvider) : null;

    // Ask backend for true random ordering and pick a single item.
    final randomPage = await repository.findScenes(
      page: 1,
      perPage: 1,
      filter: query.isEmpty ? null : query,
      sort: 'random',
      descending: true,
      performerId: performerId,
      studioId: studioId,
      tagId: tagId,
      sceneFilter: filter,
    );
    if (randomPage.isNotEmpty) {
      return randomPage.first;
    }

    final loadedScenes = state.asData?.value;
    if (loadedScenes != null && loadedScenes.isNotEmpty) {
      final random = Random();
      return loadedScenes[random.nextInt(loadedScenes.length)];
    }

    return null;
  }
}
