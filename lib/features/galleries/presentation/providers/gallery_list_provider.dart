import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../data/repositories/graphql_gallery_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'gallery_list_provider.g.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLGalleryRepository(client);
});

@riverpod
class GallerySort extends _$GallerySort {
  static const _sortKey = 'gallery_sort_field';
  static const _descKey = 'gallery_sort_descending';

  @override
  ({String? sort, bool descending}) build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'title';
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

  @override
  FutureOr<List<Gallery>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(gallerySearchQueryProvider);
    final sortConfig = ref.watch(gallerySortProvider);
    final repository = ref.watch(galleryRepositoryProvider);
    return repository.findGalleries(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: sortConfig.sort,
      descending: sortConfig.descending,
    );
  }

  void setSort({required String sort, required bool descending}) {
    ref
        .read(gallerySortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    _isLoadingMore = true;
    final repository = ref.read(galleryRepositoryProvider);
    final query = ref.read(gallerySearchQueryProvider);
    final sortConfig = ref.read(gallerySortProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextGalleries = await repository.findGalleries(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: sortConfig.sort,
        descending: sortConfig.descending,
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
