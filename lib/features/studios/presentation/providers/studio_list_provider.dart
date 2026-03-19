import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/studio.dart';
import '../../domain/repositories/studio_repository.dart';
import '../../data/repositories/graphql_studio_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/utils/pagination.dart';

part 'studio_list_provider.g.dart';

final studioRepositoryProvider = Provider<StudioRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLStudioRepository(client);
});

@riverpod
class StudioSearchQuery extends _$StudioSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class StudioList extends _$StudioList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _sort;
  bool? _descending;

  @override
  FutureOr<List<Studio>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(studioSearchQueryProvider);
    final repository = ref.watch(studioRepositoryProvider);
    return repository.findStudios(
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
    final repository = ref.read(studioRepositoryProvider);
    final query = ref.read(studioSearchQueryProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextStudios = await repository.findStudios(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: _sort,
        descending: _descending,
      );

      if (nextStudios.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextStudios]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
