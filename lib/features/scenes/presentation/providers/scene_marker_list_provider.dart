import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';
import '../../data/repositories/graphql_scene_marker_repository.dart';
import '../../domain/entities/scene_marker.dart';

part 'scene_marker_list_provider.g.dart';

final sceneMarkerRepositoryProvider = Provider<GraphQLSceneMarkerRepository>((
  ref,
) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLSceneMarkerRepository(client);
});

@Riverpod(keepAlive: true)
class SceneMarkerSort extends _$SceneMarkerSort {
  static const _sortKey = 'scene_marker_sort_field';
  static const _descKey = 'scene_marker_sort_descending';

  @override
  ({String sort, bool descending}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return (
      sort: prefs.getString(_sortKey) ?? 'created_at',
      descending: prefs.getBool(_descKey) ?? true,
    );
  }

  void setSort({required String sort, required bool descending}) {
    state = (sort: sort, descending: descending);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_sortKey, state.sort);
    await prefs.setBool(_descKey, state.descending);
  }
}

@Riverpod(keepAlive: true)
class SceneMarkerSearchQuery extends _$SceneMarkerSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
class SceneMarkerFilterState extends _$SceneMarkerFilterState {
  static const _storageKey = 'scene_marker_filter_state';

  @override
  SceneMarkerFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        return SceneMarkerFilter.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );
      } catch (_) {
        return const SceneMarkerFilter();
      }
    }
    return const SceneMarkerFilter();
  }

  void update(SceneMarkerFilter filter) => state = filter;
  void clear() => state = const SceneMarkerFilter();

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}

@Riverpod(keepAlive: true)
class SceneMarkerList extends _$SceneMarkerList {
  int _currentPage = 1;
  int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<SceneMarkerSummary>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;

    final query = ref.watch(sceneMarkerSearchQueryProvider);
    final sortConfig = ref.watch(sceneMarkerSortProvider);
    final filter = ref.watch(sceneMarkerFilterStateProvider);
    final repository = ref.watch(sceneMarkerRepositoryProvider);

    return repository.findSceneMarkers(
      page: _currentPage,
      perPage: _perPage,
      searchQuery: query.isEmpty ? null : query,
      sort: sortConfig.sort,
      descending: sortConfig.descending,
      filter: filter,
    );
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
    await future;
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    final currentMarkers = state.value ?? [];
    _isLoadingMore = true;
    _currentPage++;

    try {
      final query = ref.read(sceneMarkerSearchQueryProvider);
      final sortConfig = ref.read(sceneMarkerSortProvider);
      final filter = ref.read(sceneMarkerFilterStateProvider);
      final repository = ref.read(sceneMarkerRepositoryProvider);
      final nextMarkers = await repository.findSceneMarkers(
        page: _currentPage,
        perPage: _perPage,
        searchQuery: query.isEmpty ? null : query,
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        filter: filter,
      );

      if (nextMarkers.length < _perPage) {
        _hasMore = false;
      }
      state = AsyncData([...currentMarkers, ...nextMarkers]);
    } catch (error, stackTrace) {
      _currentPage--;
      state = AsyncError(error, stackTrace);
    } finally {
      _isLoadingMore = false;
    }
  }

  void setPerPage(int perPage) {
    if (perPage <= 0 || perPage == _perPage) return;
    _perPage = perPage;
    ref.invalidateSelf();
  }
}
