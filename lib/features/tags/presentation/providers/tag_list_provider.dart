import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../data/repositories/graphql_tag_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/utils/pagination.dart';

part 'tag_list_provider.g.dart';

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLTagRepository(client);
});

@riverpod
class TagSearchQuery extends _$TagSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class TagList extends _$TagList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _sort;
  bool? _descending;

  @override
  FutureOr<List<Tag>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(tagSearchQueryProvider);
    final repository = ref.watch(tagRepositoryProvider);
    return repository.findTags(
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
    final repository = ref.read(tagRepositoryProvider);
    final query = ref.read(tagSearchQueryProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextTags = await repository.findTags(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: _sort,
        descending: _descending,
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
}
