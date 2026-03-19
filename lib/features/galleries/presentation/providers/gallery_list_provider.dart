import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../data/repositories/graphql_gallery_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/utils/pagination.dart';

part 'gallery_list_provider.g.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLGalleryRepository(client);
});

@riverpod
class GallerySearchQuery extends _$GallerySearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class GalleryList extends _$GalleryList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _sort;
  bool? _descending;

  @override
  FutureOr<List<Gallery>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(gallerySearchQueryProvider);
    final repository = ref.watch(galleryRepositoryProvider);
    return repository.findGalleries(
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
    final repository = ref.read(galleryRepositoryProvider);
    final query = ref.read(gallerySearchQueryProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextGalleries = await repository.findGalleries(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: _sort,
        descending: _descending,
      );

      if (nextGalleries.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextGalleries]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
