import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/tag.dart';
import '../../domain/entities/tag_filter.dart';
import '../../data/repositories/graphql_tag_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/providers/list_random_seed_provider.dart';
import '../../../../core/utils/pagination.dart';
import '../../../../core/presentation/providers/list_pagination.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/utils/app_log_store.dart';

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

final tagListFilterProvider =
    NotifierProvider<TagListFilterNotifier, TagFilter>(
      TagListFilterNotifier.new,
    );

class TagListFilterNotifier extends Notifier<TagFilter> {
  static const _storageKey = 'tag_filter_state';
  static const _legacyFavoritesKey = 'tag_favorites_only';

  @override
  TagFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        return TagFilter.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } on Object catch (error, stackTrace) {
        AppLogStore.instance.addError(
          'build',
          error,
          stackTrace,
          source: 'tag_list_provider',
        );
        // Malformed stored data can also fail with a cast error.
        // Fall through to the legacy favorites-only preference.
      }
    }

    final legacyFavorite = prefs.getBool(_legacyFavoritesKey);
    return TagFilter(favorite: legacyFavorite == true ? true : null);
  }

  void set(TagFilter filter) {
    state = filter;
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
    await prefs.setBool(_legacyFavoritesKey, state.favorite == true);
  }
}

@Riverpod(keepAlive: true)
class TagList extends _$TagList with ListPagination<Tag> {
  int _perPage = kDefaultPageSize;

  @override
  FutureOr<List<Tag>> build() async {
    final generation = resetPagination();
    final query = ref.watch(tagSearchQueryProvider);
    final sortConfig = ref.watch(tagSortProvider);
    final tagFilter = ref.watch(tagListFilterProvider);
    final repository = ref.read(tagRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort = 'random_${ref.watch(tagRandomSeedProvider)}';
    }

    final firstPage = await repository.findTags(
      page: 1,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      tagFilter: tagFilter,
    );
    // A short page is the last one; this also stops layout-driven paging.
    updatePagination(firstPage, _perPage, generation);
    return firstPage;
  }

  /// Manually refreshes the tag list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(tagRandomSeedProvider.notifier).next();
    resetPagination();
    ref.invalidateSelf();
    await future;
  }

  void setSort({required String sort, required bool descending}) {
    ref
        .read(tagSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    resetPagination();
    ref.invalidateSelf();
  }

  void setFilter(TagFilter filter) {
    ref.read(tagListFilterProvider.notifier).set(filter);
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
      final repository = ref.read(tagRepositoryProvider);
      final query = ref.read(tagSearchQueryProvider);
      final sortConfig = ref.read(tagSortProvider);
      final tagFilter = ref.read(tagListFilterProvider);

      String? effectiveSort = sortConfig.sort;
      if (effectiveSort == 'random') {
        effectiveSort = 'random_${ref.read(tagRandomSeedProvider)}';
      }
      return repository.findTags(
        page: page,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        tagFilter: tagFilter,
      );
    },
  );

  Future<Tag?> getRandomTag({String? excludeTagId}) async {
    final useCurrentFilter = ref.read(sceneRandomRespectActiveFilterProvider);
    final repository = ref.read(tagRepositoryProvider);
    final query = useCurrentFilter ? ref.read(tagSearchQueryProvider) : '';
    final tagFilter = useCurrentFilter
        ? ref.read(tagListFilterProvider)
        : TagFilter.empty();

    final attempts = excludeTagId == null ? 1 : 3;
    for (var i = 0; i < attempts; i++) {
      final randomPage = await repository.findTags(
        page: 1,
        perPage: 1,
        filter: query.isEmpty ? null : query,
        sort: 'random',
        descending: true,
        tagFilter: tagFilter,
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
