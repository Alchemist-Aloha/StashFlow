import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:math';
import '../../domain/entities/studio.dart';
import '../../domain/repositories/studio_repository.dart';
import '../../data/repositories/graphql_studio_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'studio_list_provider.g.dart';

final studioRepositoryProvider = Provider<StudioRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLStudioRepository(client);
});

final studioScrollControllerProvider =
    NotifierProvider<StudioScrollController, ScrollController>(
      StudioScrollController.new,
    );

class StudioScrollController extends Notifier<ScrollController> {
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
class StudioRandomSeed extends _$StudioRandomSeed {
  @override
  int build() => Random().nextInt(10000000);

  void next() => state = Random().nextInt(10000000);
}

@Riverpod(keepAlive: true)
class StudioSort extends _$StudioSort {
  static const _sortKey = 'studio_sort_field';
  static const _descKey = 'studio_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'name';
    final descending = prefs.getBool(_descKey) ?? false;

    int? seed;
    if (sort == 'random') {
      seed = ref.watch(studioRandomSeedProvider);
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
class StudioSearchQuery extends _$StudioSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
class StudioFavoritesOnly extends _$StudioFavoritesOnly {
  static const _storageKey = 'studio_favorites_only';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? false;
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, state);
  }
}

@Riverpod(keepAlive: true)
class StudioList extends _$StudioList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Studio>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(studioSearchQueryProvider);
    final sortConfig = ref.watch(studioSortProvider);
    final favoritesOnly = ref.watch(studioFavoritesOnlyProvider);
    final repository = ref.read(studioRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    return repository.findStudios(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      favoritesOnly: favoritesOnly,
    );
  }

  /// Manually refreshes the studio list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(studioRandomSeedProvider.notifier).next();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
    await future;
  }

  void setSort({required String sort, required bool descending}) {
    ref
        .read(studioSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  void setFavoritesOnly(bool enabled) {
    ref.read(studioFavoritesOnlyProvider.notifier).state = enabled;
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    _isLoadingMore = true;
    final repository = ref.read(studioRepositoryProvider);
    final query = ref.read(studioSearchQueryProvider);
    final sortConfig = ref.read(studioSortProvider);
    final favoritesOnly = ref.read(studioFavoritesOnlyProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    try {
      final nextPage = _currentPage + 1;
      final nextStudios = await repository.findStudios(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        favoritesOnly: favoritesOnly,
      );

      if (nextStudios.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextStudios]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<Studio?> getRandomStudio({
    bool useCurrentFilter = false,
    String? excludeStudioId,
  }) async {
    final repository = ref.read(studioRepositoryProvider);
    final query = useCurrentFilter ? ref.read(studioSearchQueryProvider) : '';
    final favoritesOnly = useCurrentFilter
        ? ref.read(studioFavoritesOnlyProvider)
        : false;

    final attempts = excludeStudioId == null ? 1 : 3;
    for (var i = 0; i < attempts; i++) {
      final randomPage = await repository.findStudios(
        page: 1,
        perPage: 1,
        filter: query.isEmpty ? null : query,
        sort: 'random',
        descending: true,
        favoritesOnly: favoritesOnly,
      );
      if (randomPage.isEmpty) continue;
      final candidate = randomPage.first;
      if (excludeStudioId == null || candidate.id != excludeStudioId) {
        return candidate;
      }
    }

    final loaded = state.asData?.value;
    if (loaded != null && loaded.isNotEmpty) {
      final candidates = excludeStudioId == null
          ? loaded
          : loaded.where((studio) => studio.id != excludeStudioId).toList();
      if (candidates.isEmpty) return null;
      final random = Random();
      return candidates[random.nextInt(candidates.length)];
    }

    return null;
  }
}
