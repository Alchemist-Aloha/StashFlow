import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/group.dart';
import '../../domain/entities/group_filter.dart';
import '../../data/repositories/graphql_group_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/presentation/providers/list_random_seed_provider.dart';
import '../../../../core/utils/pagination.dart';
import '../../../../core/presentation/providers/list_pagination.dart';
import '../../../../core/utils/app_log_store.dart';

part 'group_list_provider.g.dart';

final groupRepositoryProvider = Provider<GraphQLGroupRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLGroupRepository(client);
});

final groupRandomSeedProvider = listRandomSeedProvider('group');

@Riverpod(keepAlive: true)
class GroupSort extends _$GroupSort {
  static const _sortKey = 'group_sort_field';
  static const _descKey = 'group_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'name';
    final descending = prefs.getBool(_descKey) ?? false;

    final seed = sort == 'random' ? ref.read(groupRandomSeedProvider) : null;

    return (sort: sort, descending: descending, randomSeed: seed);
  }

  void setSort({String? sort, bool descending = true}) {
    final seed = sort == 'random' ? ref.read(groupRandomSeedProvider) : null;
    state = (sort: sort, descending: descending, randomSeed: seed);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sort != null) await prefs.setString(_sortKey, state.sort!);
    await prefs.setBool(_descKey, state.descending);
  }
}

@riverpod
class GroupSearchQuery extends _$GroupSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final groupListFilterProvider =
    NotifierProvider<GroupListFilterNotifier, GroupFilter>(
      GroupListFilterNotifier.new,
    );

class GroupListFilterNotifier extends Notifier<GroupFilter> {
  static const _storageKey = 'group_list_filter';

  @override
  GroupFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return GroupFilter.empty();

    try {
      return GroupFilter.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'build',
        error,
        stackTrace,
        source: 'group_list_provider',
      );
      // Malformed stored data can also fail with a cast error.
      return GroupFilter.empty();
    }
  }

  void set(GroupFilter filter) {
    state = filter;
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}

@riverpod
class GroupList extends _$GroupList with ListPagination<Group> {
  int _perPage = kDefaultPageSize;

  @override
  FutureOr<List<Group>> build() async {
    final generation = resetPagination();
    final query = ref.watch(groupSearchQueryProvider);
    final sortConfig = ref.watch(groupSortProvider);
    final groupFilter = ref.watch(groupListFilterProvider);
    final repository = ref.watch(groupRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort = 'random_${ref.watch(groupRandomSeedProvider)}';
    }

    final firstPage = await repository.findGroups(
      page: 1,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      groupFilter: groupFilter.isEmpty ? null : groupFilter,
    );
    // A short page is the last one; this also stops layout-driven paging.
    updatePagination(firstPage, _perPage, generation);
    return firstPage;
  }

  /// Manually refreshes the group list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(groupRandomSeedProvider.notifier).next();
    resetPagination();
    ref.invalidateSelf();
    await future;
  }

  void setSort({required String sort, required bool descending}) {
    ref
        .read(groupSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    resetPagination();
    ref.invalidateSelf();
  }

  void setFilter(GroupFilter filter) {
    ref.read(groupListFilterProvider.notifier).set(filter);
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
      final repository = ref.read(groupRepositoryProvider);
      final query = ref.read(groupSearchQueryProvider);
      final sortConfig = ref.read(groupSortProvider);
      final groupFilter = ref.read(groupListFilterProvider);

      String? effectiveSort = sortConfig.sort;
      if (effectiveSort == 'random') {
        effectiveSort = 'random_${ref.read(groupRandomSeedProvider)}';
      }
      return repository.findGroups(
        page: page,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        groupFilter: groupFilter.isEmpty ? null : groupFilter,
      );
    },
  );
}
