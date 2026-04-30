import 'package:riverpod_annotation/riverpod_annotation.dart';
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

    return repository.findGalleries(
      page: page,
      perPage: _perPage,
      tagId: tagId,
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
        state = AsyncData([
          ...(state.value ?? <Gallery>[]),
          ...nextItems,
        ]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
