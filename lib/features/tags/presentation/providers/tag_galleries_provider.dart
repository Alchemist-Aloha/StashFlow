import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';
import '../../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../../galleries/domain/entities/gallery.dart';

part 'tag_galleries_provider.g.dart';

@riverpod
FutureOr<List<Gallery>> tagGalleries(Ref ref, String tagId) async {
  ref.keepAlive();
  final repository = ref.read(galleryRepositoryProvider);

  return repository.findGalleries(perPage: 24, tagId: tagId);
}

@riverpod
class TagGalleriesGrid extends _$TagGalleriesGrid {
  static const int _perPage = 30;
  static const _filterKind = EntityGalleryFilterKind.tag;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _tagId;

  @override
  FutureOr<List<Gallery>> build(String tagId) async {
    ref.keepAlive();
    _tagId = tagId;
    _currentPage = 1;
    _hasMore = true;
    return _fetchPage(tagId, _currentPage);
  }

  Future<List<Gallery>> _fetchPage(String tagId, int page) async {
    final repository = ref.read(galleryRepositoryProvider);
    final query = ref.read(entityGallerySearchQueryProvider(_filterKind));
    final sortConfig = ref.read(entityGallerySortProvider(_filterKind));
    final baseFilter = ref.read(entityGalleryFilterStateProvider(_filterKind));
    final filter = galleryFilterForEntityGalleries(
      filter: baseFilter,
      kind: _filterKind,
      entityId: tagId,
    );
    final organizedFilter = ref.read(
      entityGalleryOrganizedOnlyProvider(_filterKind),
    );
    var effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort =
          'random_${ref.read(entityGalleryRandomSeedProvider(_filterKind))}';
    }

    return repository.findGalleries(
      page: page,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      galleryFilter: filter.copyWith(
        organized: organizedFilter.toBool() ?? filter.organized,
      ),
    );
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _tagId == null) return;

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final nextItems = await _fetchPage(_tagId!, nextPage);

      if (nextItems.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...(state.value ?? <Gallery>[]), ...nextItems]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
