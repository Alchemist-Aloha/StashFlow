import 'package:flutter/material.dart';
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
import '../../../../core/utils/app_log_store.dart';
import 'playback_queue_provider.dart';

part 'scene_list_provider.g.dart';

// Provider for Repository interface
final sceneRepositoryProvider = Provider<SceneRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLSceneRepository(client);
});

final sceneScrollControllerProvider =
    NotifierProvider<SceneScrollController, ScrollController>(
      SceneScrollController.new,
    );

class SceneScrollController extends Notifier<ScrollController> {
  @override
  ScrollController build() {
    final controller = ScrollController();
    ref.onDispose(controller.dispose);
    return controller;
  }

  void scrollToTop() {
    if (state.hasClients) {
      state.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

@Riverpod(keepAlive: true)
class SceneRandomSeed extends _$SceneRandomSeed {
  @override
  int build() => Random().nextInt(10000000);

  void next() => state = Random().nextInt(10000000);
}

@Riverpod(keepAlive: true)
class SceneSort extends _$SceneSort {
  static const _sortKey = 'scene_sort_field';
  static const _descKey = 'scene_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'date';
    final descending = prefs.getBool(_descKey) ?? true;

    int? seed;
    if (sort == 'random') {
      seed = ref.watch(sceneRandomSeedProvider);
    }

    return (sort: sort, descending: descending, randomSeed: seed);
  }

  void setSort({String? sort, bool descending = true}) {
    state = (sort: sort, descending: descending, randomSeed: state.randomSeed);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sort != null) await prefs.setString(_sortKey, state.sort!);
    await prefs.setBool(_descKey, state.descending);
  }
}

@Riverpod(keepAlive: true)
class SceneSearchQuery extends _$SceneSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
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

@Riverpod(keepAlive: true)
class SceneOrganizedOnly extends _$SceneOrganizedOnly {
  static const _organizedKey = 'scene_organized_only';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_organizedKey) ?? false;
  }

  void set(bool value) => state = value;

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_organizedKey, state);
  }
}

@Riverpod(keepAlive: true)
class SceneTiktokLayout extends _$SceneTiktokLayout {
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

@Riverpod(keepAlive: true)
class SceneGridLayout extends _$SceneGridLayout {
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

/// A notifier that manages the primary list of scenes with support for
/// filtering, sorting, and infinite pagination.
///
/// This provider is responsible for:
/// - Initializing and refreshing the scene list from the [SceneRepository].
/// - Managing the current page state and loading more scenes as the user scrolls.
/// - Providing search and filtering capabilities.
/// - Synchronizing the initial playback sequence with the [playbackQueueProvider].
@Riverpod(keepAlive: true)
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
    final organizedOnly = ref.watch(sceneOrganizedOnlyProvider);
    final repository = ref.read(sceneRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    final scenes = await repository.findScenes(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      organized: organizedOnly ? true : null,
      sceneFilter: filter,
    );

    // Initialize playback queue sequence with the initial load.
    // We use index -1 to allow the queue to recover its index if the
    // user is already playing something and just refreshed the list.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogStore.instance.add(
        'SceneList build: initializing playback queue with ${scenes.length} scenes',
        source: 'scene_list',
      );
      ref.read(playbackQueueProvider.notifier).setSequence(scenes, -1);
    });

    return scenes;
  }

  /// Manually refreshes the scene list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(sceneRandomSeedProvider.notifier).next();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
    await future;
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

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    try {
      final nextPage = _currentPage + 1;
      final nextScenes = await repository.findScenes(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        organized: organizedOnly ? true : null,
        sceneFilter: filter,
      );

      if (nextScenes.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextScenes]);
        AppLogStore.instance.add(
          'SceneList fetchNextPage: updating playback queue with ${nextScenes.length} more scenes',
          source: 'scene_list',
        );
        // Update playback queue sequence
        ref.read(playbackQueueProvider.notifier).updateSequence(nextScenes);
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
