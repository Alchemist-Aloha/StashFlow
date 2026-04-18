import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:convert';
import '../../domain/entities/performer.dart';
import '../../domain/entities/performer_filter.dart' as domain;
import '../../domain/repositories/performer_repository.dart';
import '../../data/repositories/graphql_performer_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'performer_list_provider.g.dart';


// Provider for Repository interface
final performerRepositoryProvider = Provider<PerformerRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLPerformerRepository(client);
});

final performerScrollControllerProvider =
    NotifierProvider<PerformerScrollController, ScrollController>(
      PerformerScrollController.new,
    );

class PerformerScrollController extends Notifier<ScrollController> {
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
class PerformerRandomSeed extends _$PerformerRandomSeed {
  @override
  int build() => Random().nextInt(10000000);

  void next() => state = Random().nextInt(10000000);
}

@Riverpod(keepAlive: true)
class PerformerSort extends _$PerformerSort {
  static const _sortKey = 'performer_sort_field';
  static const _descKey = 'performer_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'name';
    final descending = prefs.getBool(_descKey) ?? false;

    int? seed;
    if (sort == 'random') {
      seed = ref.watch(performerRandomSeedProvider);
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
        return domain.PerformerFilter.fromJson(jsonDecode(jsonString));
      } catch (_) {
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
class PerformerList extends _$PerformerList {
  int _currentPage = 1;
  int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Performer>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(performerSearchQueryProvider);
    final sortConfig = ref.watch(performerSortProvider);
    final filterState = ref.watch(performerFilterStateProvider);
    final repository = ref.read(performerRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    return repository.findPerformers(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      performerFilter: filterState,
    );
  }

  /// Manually refreshes the performer list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(performerRandomSeedProvider.notifier).next();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
    await future;
  }

  void setSort({String? sort, bool descending = true}) {
    ref
        .read(performerSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  void setFavoritesOnly(bool enabled) {
    final currentFilter = ref.read(performerFilterStateProvider);
    ref.read(performerFilterStateProvider.notifier).update(
          currentFilter.copyWith(favorite: enabled),
        );
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  void setPerPage(int perPage) {
    if (_perPage == perPage) return;
    _perPage = perPage;
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    _isLoadingMore = true;
    final repository = ref.read(performerRepositoryProvider);
    final query = ref.read(performerSearchQueryProvider);
    final sortConfig = ref.read(performerSortProvider);
    final filterState = ref.read(performerFilterStateProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    try {
      final nextPage = _currentPage + 1;
      final nextPerformers = await repository.findPerformers(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        performerFilter: filterState,
      );

      if (nextPerformers.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextPerformers]);
      }
    } catch (e) {
      // In a real app, you might want to show a snackbar for error during pagination
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<Performer?> getRandomPerformer({
    bool useCurrentFilter = false,
    String? excludePerformerId,
  }) async {
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

    final loaded = state.asData?.value;
    if (loaded != null && loaded.isNotEmpty) {
      final candidates = excludePerformerId == null
          ? loaded
          : loaded
                .where((performer) => performer.id != excludePerformerId)
                .toList();
      if (candidates.isEmpty) return null;
      final random = Random();
      return candidates[random.nextInt(candidates.length)];
    }

    return null;
  }
}
