import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dart:convert';

import '../../domain/entities/studio.dart';
import '../../domain/entities/studio_filter.dart' as domain;
import '../../data/repositories/graphql_studio_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/providers/list_random_seed_provider.dart';
import '../../../../core/utils/pagination.dart';
import '../../../../core/presentation/providers/list_pagination.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/utils/app_log_store.dart';

part 'studio_list_provider.g.dart';

final studioRepositoryProvider = Provider<GraphQLStudioRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLStudioRepository(client);
});

final studioRandomSeedProvider = listRandomSeedProvider('studio');

@Riverpod(keepAlive: true)
class StudioSort extends _$StudioSort {
  static const _sortKey = 'studio_sort_field';
  static const _descKey = 'studio_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'name';
    final descending = prefs.getBool(_descKey) ?? false;

    final seed = sort == 'random' ? ref.read(studioRandomSeedProvider) : null;

    return (sort: sort, descending: descending, randomSeed: seed);
  }

  void setSort({String? sort, bool descending = true}) {
    final seed = sort == 'random' ? ref.read(studioRandomSeedProvider) : null;
    state = (sort: sort, descending: descending, randomSeed: seed);
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
class StudioFilterState extends _$StudioFilterState {
  static const _storageKey = 'studio_filter_state';

  @override
  domain.StudioFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        return domain.StudioFilter.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );
      } on Object catch (error, stackTrace) {
        AppLogStore.instance.addError(
          'build',
          error,
          stackTrace,
          source: 'studio_list_provider',
        );
        // Malformed stored data can also fail with a cast error.
        return domain.StudioFilter.empty();
      }
    }
    return domain.StudioFilter.empty();
  }

  void update(domain.StudioFilter filter) => state = filter;
  void clear() => state = domain.StudioFilter.empty();

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}

@Riverpod(keepAlive: true)
class StudioList extends _$StudioList with ListPagination<Studio> {
  int _perPage = kDefaultPageSize;

  @override
  FutureOr<List<Studio>> build() async {
    final generation = resetPagination();
    final query = ref.watch(studioSearchQueryProvider);
    final sortConfig = ref.watch(studioSortProvider);
    final filterState = ref.watch(studioFilterStateProvider);
    final repository = ref.read(studioRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort = 'random_${ref.watch(studioRandomSeedProvider)}';
    }

    final firstPage = await repository.findStudios(
      page: 1,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      studioFilter: filterState,
    );
    // A short page is the last one; this also stops layout-driven paging.
    updatePagination(firstPage, _perPage, generation);
    return firstPage;
  }

  /// Manually refreshes the studio list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(studioRandomSeedProvider.notifier).next();
    resetPagination();
    ref.invalidateSelf();
    await future;
  }

  void setSort({required String sort, required bool descending}) {
    ref
        .read(studioSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    resetPagination();
    ref.invalidateSelf();
  }

  void setFavoritesOnly(bool enabled) {
    final currentFilter = ref.read(studioFilterStateProvider);
    ref
        .read(studioFilterStateProvider.notifier)
        .update(currentFilter.copyWith(favorite: enabled));
    resetPagination();
    ref.invalidateSelf();
  }

  void setPerPage(int perPage) {
    if (_perPage == perPage) return;
    _perPage = perPage;
    resetPagination();
    ref.invalidateSelf();
  }

  Future<void> fetchNextPage() => loadNextPage(
    perPage: _perPage,
    fetch: (page) {
      final repository = ref.read(studioRepositoryProvider);
      final query = ref.read(studioSearchQueryProvider);
      final sortConfig = ref.read(studioSortProvider);
      final filterState = ref.read(studioFilterStateProvider);

      String? effectiveSort = sortConfig.sort;
      if (effectiveSort == 'random') {
        effectiveSort = 'random_${ref.read(studioRandomSeedProvider)}';
      }
      return repository.findStudios(
        page: page,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        studioFilter: filterState,
      );
    },
  );

  Future<Studio?> getRandomStudio({String? excludeStudioId}) async {
    final useCurrentFilter = ref.read(sceneRandomRespectActiveFilterProvider);
    final repository = ref.read(studioRepositoryProvider);
    final query = useCurrentFilter ? ref.read(studioSearchQueryProvider) : '';
    final filterState = useCurrentFilter
        ? ref.read(studioFilterStateProvider)
        : domain.StudioFilter.empty();

    final attempts = excludeStudioId == null ? 1 : 3;
    for (var i = 0; i < attempts; i++) {
      final randomPage = await repository.findStudios(
        page: 1,
        perPage: 1,
        filter: query.isEmpty ? null : query,
        sort: 'random',
        descending: true,
        studioFilter: filterState,
      );
      if (randomPage.isEmpty) continue;
      final candidate = randomPage.first;
      if (excludeStudioId == null || candidate.id != excludeStudioId) {
        return candidate;
      }
    }

    return null;
  }
}
