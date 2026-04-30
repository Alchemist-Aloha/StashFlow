import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../../galleries/domain/entities/gallery.dart';

part 'performer_galleries_provider.g.dart';

@riverpod
FutureOr<List<Gallery>> performerGalleries(
  Ref ref,
  String performerId,
) async {
  ref.keepAlive();
  final repository = ref.read(galleryRepositoryProvider);

  return repository.findGalleries(
    perPage: 24,
    performerId: performerId,
  );
}

@riverpod
class PerformerGalleriesGrid extends _$PerformerGalleriesGrid {
  static const int _perPage = 30;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _performerId;

  @override
  FutureOr<List<Gallery>> build(String performerId) async {
    ref.keepAlive();
    _performerId = performerId;
    _currentPage = 1;
    _hasMore = true;
    final repository = ref.read(galleryRepositoryProvider);
    return repository.findGalleries(
      page: _currentPage,
      perPage: _perPage,
      performerId: performerId,
    );
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _performerId == null) return;

    _isLoadingMore = true;
    try {
      final repository = ref.read(galleryRepositoryProvider);
      final nextPage = _currentPage + 1;
      final nextItems = await repository.findGalleries(
        page: nextPage,
        perPage: _perPage,
        performerId: _performerId,
      );

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
