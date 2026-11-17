import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:convert';

import '../../domain/entities/performer.dart';
import '../../domain/entities/performer_filter.dart' as domain;
import '../../data/repositories/graphql_performer_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/providers/list_random_seed_provider.dart';
import '../../../../core/utils/pagination.dart';
import '../../../../core/presentation/providers/list_pagination.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/utils/app_log_store.dart';

part 'performer_list_provider.g.dart';

// Provider for Repository interface
final performerRepositoryProvider = Provider<GraphQLPerformerRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLPerformerRepository(client);
});

final performerRandomSeedProvider = listRandomSeedProvider('performer');

@Riverpod(keepAlive: true)
class PerformerSort extends _$PerformerSort {
  static const _sortKey = 'performer_sort_field';
  static const _descKey = 'performer_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'name';
    final descending = prefs.getBool(_descKey) ?? false;

    final seed = sort == 'random'
        ? ref.read(performerRandomSeedProvider)
        : null;

    return (sort: sort, descending: descending, randomSeed: seed);
  }

  void setSort({String? sort, bool descending = true}) {
    final seed = sort == 'random'
        ? ref.read(performerRandomSeedProvider)
        : null;
    state = (sort: sort, descending: descending, randomSeed: seed);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sort != null) await prefs.setString(_sortKey, state.sort!);
    await prefs.setBool(_descKey, state.descending);
  }
}

@Riverpod(keepAlive: true)
class PerformerSearchQuery extends _$PerformerSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
class PerformerFilterState extends _$PerformerFilterState {
  static const _storageKey = 'performer_filter_state';

  @override
  domain.PerformerFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        return domain.PerformerFilter.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );
      } on Object catch (error, stackTrace) {
        AppLogStore.instance.addError(
          'build',
          error,
          stackTrace,
          source: 'performer_list_provider',
        );
        // Malformed stored data can also fail with a cast error.
        return domain.PerformerFilter.empty();
      }
    }
    return domain.PerformerFilter.empty();
  }

  void update(domain.PerformerFilter filter) => state = filter;
  void clear() => state = domain.PerformerFilter.empty();

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}

@Riverpod(keepAlive: true)
class PerformerList extends _$PerformerList with ListPagination<Performer> {
  int _perPage = kDefaultPageSize;

  @override
  FutureOr<List<Performer>> build() async {
    final generation = resetPagination();
    final query = ref.watch(performerSearchQueryProvider);
    final sortConfig = ref.watch(performerSortProvider);
    final filterState = ref.watch(performerFilterStateProvider);
    final repository = ref.read(performerRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort = 'random_${ref.watch(performerRandomSeedProvider)}';
    }

    final firstPage = await repository.findPerformers(
      page: 1,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      performerFilter: filterState,
    );
    // A short page is the last one; this also stops layout-driven paging.
    updatePagination(firstPage, _perPage, generation);
    return firstPage;
  }

  /// Manually refreshes the performer list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(performerRandomSeedProvider.notifier).next();
    resetPagination();
    ref.invalidateSelf();
    await future;
  }

  void setSort({String? sort, bool descending = true}) {
    ref
        .read(performerSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    resetPagination();
    ref.invalidateSelf();
  }

  void setFavoritesOnly(bool enabled) {
    final currentFilter = ref.read(performerFilterStateProvider);
    ref
        .read(performerFilterStateProvider.notifier)
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
      final repository = ref.read(performerRepositoryProvider);
      final query = ref.read(performerSearchQueryProvider);
      final sortConfig = ref.read(performerSortProvider);
      final filterState = ref.read(performerFilterStateProvider);

      String? effectiveSort = sortConfig.sort;
      if (effectiveSort == 'random') {
        effectiveSort = 'random_${ref.read(performerRandomSeedProvider)}';
      }
      return repository.findPerformers(
        page: page,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        performerFilter: filterState,
      );
    },
  );

  Future<Performer?> getRandomPerformer({String? excludePerformerId}) async {
    final useCurrentFilter = ref.read(sceneRandomRespectActiveFilterProvider);
    final repository = ref.read(performerRepositoryProvider);
    final query = useCurrentFilter
        ? ref.read(performerSearchQueryProvider)
        : '';
    final filterState = useCurrentFilter
        ? ref.read(performerFilterStateProvider)
        : domain.PerformerFilter.empty();

    final attempts = excludePerformerId == null ? 1 : 3;
    for (var i = 0; i < attempts; i++) {
      final randomPage = await repository.findPerformers(
        page: 1,
        perPage: 1,
        filter: query.isEmpty ? null : query,
        sort: 'random',
        descending: true,
        performerFilter: filterState,
      );
      if (randomPage.isEmpty) continue;
      final candidate = randomPage.first;
      if (excludePerformerId == null || candidate.id != excludePerformerId) {
        return candidate;
      }
    }

    return null;
  }
}
