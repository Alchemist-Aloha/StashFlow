import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';
import '../../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../../galleries/domain/entities/gallery.dart';

part 'studio_galleries_provider.g.dart';

@riverpod
FutureOr<List<Gallery>> studioGalleries(Ref ref, String studioId) async {
  ref.keepAlive();
  final repository = ref.read(galleryRepositoryProvider);

  return repository.findGalleries(perPage: 24, studioId: studioId);
}

@riverpod
class StudioGalleriesGrid extends _$StudioGalleriesGrid {
  static const int _perPage = 30;
  static const _filterKind = EntityGalleryFilterKind.studio;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _studioId;

  @override
  FutureOr<List<Gallery>> build(String studioId) async {
    ref.keepAlive();
    _studioId = studioId;
    _currentPage = 1;
    _hasMore = true;
    final query = ref.watch(entityGallerySearchQueryProvider(_filterKind));
    final sortConfig = ref.watch(entityGallerySortProvider(_filterKind));
    final baseFilter = ref.watch(entityGalleryFilterStateProvider(_filterKind));
    final filter = galleryFilterForEntityGalleries(
      filter: baseFilter,
      kind: _filterKind,
      entityId: studioId,
    );
    final organizedFilter = ref.watch(
      entityGalleryOrganizedOnlyProvider(_filterKind),
    );
    final repository = ref.read(galleryRepositoryProvider);
    var effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort =
          'random_${ref.watch(entityGalleryRandomSeedProvider(_filterKind))}';
    }
    return repository.findGalleries(
      page: _currentPage,
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
    if (_isLoadingMore || !_hasMore || _studioId == null) return;

    _isLoadingMore = true;
    try {
      final repository = ref.read(galleryRepositoryProvider);
      final query = ref.read(entityGallerySearchQueryProvider(_filterKind));
      final sortConfig = ref.read(entityGallerySortProvider(_filterKind));
      final baseFilter = ref.read(
        entityGalleryFilterStateProvider(_filterKind),
      );
      final filter = galleryFilterForEntityGalleries(
        filter: baseFilter,
        kind: _filterKind,
        entityId: _studioId!,
      );
      final organizedFilter = ref.read(
        entityGalleryOrganizedOnlyProvider(_filterKind),
      );
      var effectiveSort = sortConfig.sort;
      if (effectiveSort == 'random') {
        effectiveSort =
            'random_${ref.read(entityGalleryRandomSeedProvider(_filterKind))}';
      }
      final nextPage = _currentPage + 1;
      final nextItems = await repository.findGalleries(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        galleryFilter: filter.copyWith(
          organized: organizedFilter.toBool() ?? filter.organized,
        ),
      );

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
