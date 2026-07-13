import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/tag.dart';
import '../../data/repositories/graphql_tag_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/providers/list_random_seed_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'tag_list_provider.g.dart';

final tagRepositoryProvider = Provider<GraphQLTagRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLTagRepository(client);
});

final tagRandomSeedProvider = listRandomSeedProvider('tag');

@Riverpod(keepAlive: true)
class TagSort extends _$TagSort {
  static const _sortKey = 'tag_sort_field';
  static const _descKey = 'tag_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'name';
    final descending = prefs.getBool(_descKey) ?? false;

    final seed = sort == 'random' ? ref.read(tagRandomSeedProvider) : null;

    return (sort: sort, descending: descending, randomSeed: seed);
  }

  void setSort({String? sort, bool descending = true}) {
    final seed = sort == 'random' ? ref.read(tagRandomSeedProvider) : null;
    state = (sort: sort, descending: descending, randomSeed: seed);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sort != null) await prefs.setString(_sortKey, state.sort!);
    await prefs.setBool(_descKey, state.descending);
  }
}

@Riverpod(keepAlive: true)
class TagSearchQuery extends _$TagSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
class TagFavoritesOnly extends _$TagFavoritesOnly {
  static const _storageKey = 'tag_favorites_only';

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
class TagList extends _$TagList {
  int _currentPage = 1;
  int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Tag>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(tagSearchQueryProvider);
    final sortConfig = ref.watch(tagSortProvider);
    final favoritesOnly = ref.watch(tagFavoritesOnlyProvider);
    final repository = ref.read(tagRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort = 'random_${ref.watch(tagRandomSeedProvider)}';
    }

    return repository.findTags(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      favoritesOnly: favoritesOnly,
    );
  }

  /// Manually refreshes the tag list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(tagRandomSeedProvider.notifier).next();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
    await future;
  }

  void setSort({required String sort, required bool descending}) {
    ref
        .read(tagSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  void setFavoritesOnly(bool enabled) {
    ref.read(tagFavoritesOnlyProvider.notifier).state = enabled;
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
    final repository = ref.read(tagRepositoryProvider);
    final query = ref.read(tagSearchQueryProvider);
    final sortConfig = ref.read(tagSortProvider);
    final favoritesOnly = ref.read(tagFavoritesOnlyProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort = 'random_${ref.read(tagRandomSeedProvider)}';
    }

    try {
      final nextPage = _currentPage + 1;
      final nextTags = await repository.findTags(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        favoritesOnly: favoritesOnly,
      );

      if (nextTags.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextTags]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<Tag?> getRandomTag({
    bool useCurrentFilter = false,
    String? excludeTagId,
  }) async {
    final repository = ref.read(tagRepositoryProvider);
    final query = useCurrentFilter ? ref.read(tagSearchQueryProvider) : '';
    final favoritesOnly = useCurrentFilter
        ? ref.read(tagFavoritesOnlyProvider)
        : false;

    final attempts = excludeTagId == null ? 1 : 3;
    for (var i = 0; i < attempts; i++) {
      final randomPage = await repository.findTags(
        page: 1,
        perPage: 1,
        filter: query.isEmpty ? null : query,
        sort: 'random',
        descending: true,
        favoritesOnly: favoritesOnly,
      );
      if (randomPage.isEmpty) continue;
      final candidate = randomPage.first;
      if (excludeTagId == null || candidate.id != excludeTagId) {
        return candidate;
      }
    }

    return null;
  }
}
