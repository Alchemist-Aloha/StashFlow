import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';

part 'performer_galleries_provider.g.dart';

class PerformerGalleryItem {
  const PerformerGalleryItem({
    required this.galleryId,
    required this.title,
    required this.thumbnailUrl,
  });

  final String galleryId;
  final String title;
  final String thumbnailUrl;
}

@riverpod
FutureOr<List<PerformerGalleryItem>> performerGalleries(
  Ref ref,
  String performerId,
) async {
  ref.keepAlive();
  final repository = ref.read(galleryRepositoryProvider);

  final galleries = await repository.findGalleries(
    perPage: 24,
    performerId: performerId,
  );

  final prefs = ref.read(sharedPreferencesProvider);
  final storedServerUrl = prefs.getString('server_base_url')?.trim() ?? '';
  final normalizedServerUrl = normalizeGraphqlServerUrl(storedServerUrl);
  final endpoint = Uri.parse(
    normalizedServerUrl.isEmpty
        ? 'http://localhost:9999/graphql'
        : normalizedServerUrl,
  );

  return galleries
      .map(
        (gallery) => PerformerGalleryItem(
          galleryId: gallery.id,
          title: gallery.displayName,
          thumbnailUrl: resolveGraphqlMediaUrl(
            rawUrl: gallery.coverPath ?? '/gallery/${gallery.id}/thumbnail',
            graphqlEndpoint: endpoint,
          ),
        ),
      )
      .toList();
}

@riverpod
class PerformerGalleriesGrid extends _$PerformerGalleriesGrid {
  static const int _perPage = 30;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _performerId;

  @override
  FutureOr<List<PerformerGalleryItem>> build(String performerId) async {
    ref.keepAlive();
    _performerId = performerId;
    _currentPage = 1;
    _hasMore = true;
    return _fetchPage(performerId, _currentPage);
  }

  Future<List<PerformerGalleryItem>> _fetchPage(
    String performerId,
    int page,
  ) async {
    final repository = ref.read(galleryRepositoryProvider);

    final galleries = await repository.findGalleries(
      page: page,
      perPage: _perPage,
      performerId: performerId,
    );

    final prefs = ref.read(sharedPreferencesProvider);
    final storedServerUrl = prefs.getString('server_base_url')?.trim() ?? '';
    final normalizedServerUrl = normalizeGraphqlServerUrl(storedServerUrl);
    final endpoint = Uri.parse(
      normalizedServerUrl.isEmpty
          ? 'http://localhost:9999/graphql'
          : normalizedServerUrl,
    );

    return galleries
        .map(
          (gallery) => PerformerGalleryItem(
            galleryId: gallery.id,
            title: gallery.displayName,
          thumbnailUrl: resolveGraphqlMediaUrl(
            rawUrl: gallery.coverPath ?? '/gallery/${gallery.id}/thumbnail',
            graphqlEndpoint: endpoint,
          ),
          ),
        )
        .toList();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || _performerId == null) return;

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final nextItems = await _fetchPage(_performerId!, nextPage);

      if (nextItems.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([
          ...(state.value ?? <PerformerGalleryItem>[]),
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
