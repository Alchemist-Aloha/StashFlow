import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../../data/repositories/graphql_group_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'group_list_provider.g.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLGroupRepository(client);
});

@Riverpod(keepAlive: true)
class GroupRandomSeed extends _$GroupRandomSeed {
  @override
  int build() => Random().nextInt(10000000);

  void next() => state = Random().nextInt(10000000);
}

@Riverpod(keepAlive: true)
class GroupSort extends _$GroupSort {
  static const _sortKey = 'group_sort_field';
  static const _descKey = 'group_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'name';
    final descending = prefs.getBool(_descKey) ?? false;

    int? seed;
    if (sort == 'random') {
      seed = ref.watch(groupRandomSeedProvider);
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

@riverpod
class GroupSearchQuery extends _$GroupSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class GroupList extends _$GroupList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Group>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(groupSearchQueryProvider);
    final sortConfig = ref.watch(groupSortProvider);
    final repository = ref.watch(groupRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    return repository.findGroups(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
    );
  }

  /// Manually refreshes the group list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(groupRandomSeedProvider.notifier).next();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
    await future;
  }

  void setSort({required String sort, required bool descending}) {
    ref
        .read(groupSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    _isLoadingMore = true;
    final repository = ref.read(groupRepositoryProvider);
    final query = ref.read(groupSearchQueryProvider);
    final sortConfig = ref.read(groupSortProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    try {
      final nextPage = _currentPage + 1;
      final nextGroups = await repository.findGroups(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
      );

      if (nextGroups.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextGroups]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
