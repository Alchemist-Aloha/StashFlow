import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/group.dart';
import '../../domain/repositories/group_repository.dart';
import '../../data/repositories/graphql_group_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/utils/pagination.dart';

part 'group_list_provider.g.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLGroupRepository(client);
});

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
  String? _sort;
  bool? _descending;

  @override
  FutureOr<List<Group>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(groupSearchQueryProvider);
    final repository = ref.watch(groupRepositoryProvider);
    return repository.findGroups(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: _sort,
      descending: _descending,
    );
  }

  void setSort({required String sort, required bool descending}) {
    _sort = sort;
    _descending = descending;
    ref.invalidateSelf();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    _isLoadingMore = true;
    final repository = ref.read(groupRepositoryProvider);
    final query = ref.read(groupSearchQueryProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextGroups = await repository.findGroups(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: _sort,
        descending: _descending,
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
