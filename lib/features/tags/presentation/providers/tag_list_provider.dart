import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:math';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../data/repositories/graphql_tag_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'tag_list_provider.g.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLTagRepository(client);
});

@riverpod
class TagSort extends _$TagSort {
  static const _sortKey = 'tag_sort_field';
  static const _descKey = 'tag_sort_descending';

  @override
  ({String? sort, bool descending}) build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'name';
    final descending = prefs.getBool(_descKey) ?? false;
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
class TagSearchQuery extends _$TagSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final tagFavoritesOnlyProvider =
    NotifierProvider<TagFavoritesOnlyNotifier, bool>(
      TagFavoritesOnlyNotifier.new,
    );

class TagFavoritesOnlyNotifier extends Notifier<bool> {
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

@riverpod
class TagList extends _$TagList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Tag>> build() async {
    ref.keepAlive();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(tagSearchQueryProvider);
    final sortConfig = ref.watch(tagSortProvider);
    final favoritesOnly = ref.watch(tagFavoritesOnlyProvider);
    final repository = ref.read(tagRepositoryProvider);
    return repository.findTags(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: sortConfig.sort,
      descending: sortConfig.descending,
      favoritesOnly: favoritesOnly,
    );
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

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    _isLoadingMore = true;
    final repository = ref.read(tagRepositoryProvider);
    final query = ref.read(tagSearchQueryProvider);
    final sortConfig = ref.read(tagSortProvider);
    final favoritesOnly = ref.read(tagFavoritesOnlyProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextTags = await repository.findTags(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: sortConfig.sort,
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

    final loaded = state.asData?.value;
    if (loaded != null && loaded.isNotEmpty) {
      final candidates = excludeTagId == null
          ? loaded
          : loaded.where((tag) => tag.id != excludeTagId).toList();
      if (candidates.isEmpty) return null;
      final random = Random();
      return candidates[random.nextInt(candidates.length)];
    }

    return null;
  }
}
