import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_filter.dart';
import '../../domain/repositories/scene_repository.dart';
import '../../data/repositories/graphql_scene_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'scene_list_provider.g.dart';

// Provider for Repository interface
final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLSceneRepository(client);
});

final sceneOrganizedOnlyProvider = NotifierProvider<SceneOrganizedOnly, bool>(
  SceneOrganizedOnly.new,
);

final sceneGridLayoutProvider = NotifierProvider<SceneGridLayout, bool>(
  SceneGridLayout.new,
);

final sceneTiktokLayoutProvider = NotifierProvider<SceneTiktokLayout, bool>(
  SceneTiktokLayout.new,
);

class SceneTiktokLayout extends Notifier<bool> {
  static const _storageKey = 'scene_tiktok_layout';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? false;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
    ref.invalidate(sceneListProvider);
  }
}

class SceneGridLayout extends Notifier<bool> {
  static const _storageKey = 'scene_grid_layout';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? false;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
    ref.invalidate(sceneListProvider);
  }
}

class SceneOrganizedOnly extends Notifier<bool> {
  static const _storageKey = 'scene_organized_only';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? false;
  }

  void set(bool value) => state = value;

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, state);
  }
}

@riverpod
class SceneSort extends _$SceneSort {
  static const _sortKey = 'scene_sort_field';
  static const _descKey = 'scene_sort_descending';

  @override
  ({String? sort, bool descending}) build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'date';
    final descending = prefs.getBool(_descKey) ?? true;
    return (sort: sort, descending: descending);
  }

  void setSort({String? sort, bool descending = true}) {
    state = (sort: sort, descending: descending);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sort != null) await prefs.setString(_sortKey, state.sort!);
    await prefs.setBool(_descKey, state.descending);
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
  static const _storageKey = 'scene_filter_state';

  @override
  SceneFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        return SceneFilter.fromJson(jsonDecode(jsonString));
      } catch (_) {
        return SceneFilter.empty();
      }
    }
    return SceneFilter.empty();
  }

  void update(SceneFilter filter) => state = filter;
  void clear() => state = SceneFilter.empty();

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}

@riverpod
class SceneList extends _$SceneList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Scene>> build() async {
    ref.keepAlive();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(sceneSearchQueryProvider);
    final sortConfig = ref.watch(sceneSortProvider);
    final filter = ref.watch(sceneFilterStateProvider);
    final organizedOnly = ref.watch(sceneOrganizedOnlyProvider);
    final repository = ref.read(sceneRepositoryProvider);

    return repository.findScenes(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: sortConfig.sort,
      descending: sortConfig.descending,
      organized: organizedOnly ? true : null,
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
    final organizedOnly = ref.read(sceneOrganizedOnlyProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextScenes = await repository.findScenes(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        organized: organizedOnly ? true : null,
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
    String? excludeSceneId,
  }) async {
    final repository = ref.read(sceneRepositoryProvider);
    final query = useCurrentFilter ? ref.read(sceneSearchQueryProvider) : '';
    final filter = useCurrentFilter ? ref.read(sceneFilterStateProvider) : null;
    final organizedOnly = useCurrentFilter
        ? ref.read(sceneOrganizedOnlyProvider)
        : false;

    // Ask backend for random ordering; if needed, retry to avoid returning same id.
    final attempts = excludeSceneId == null ? 1 : 3;
    for (var i = 0; i < attempts; i++) {
      final randomPage = await repository.findScenes(
        page: 1,
        perPage: 1,
        filter: query.isEmpty ? null : query,
        sort: 'random',
        descending: true,
        organized: organizedOnly ? true : null,
        performerId: performerId,
        studioId: studioId,
        tagId: tagId,
        sceneFilter: filter,
      );
      if (randomPage.isEmpty) continue;
      final candidate = randomPage.first;
      if (excludeSceneId == null || candidate.id != excludeSceneId) {
        return candidate;
      }
    }

    final loadedScenes = state.asData?.value;
    if (loadedScenes != null && loadedScenes.isNotEmpty) {
      final candidates = excludeSceneId == null
          ? loadedScenes
          : loadedScenes.where((scene) => scene.id != excludeSceneId).toList();
      if (candidates.isEmpty) return null;
      final random = Random();
      return candidates[random.nextInt(candidates.length)];
    }

    return null;
  }
}
