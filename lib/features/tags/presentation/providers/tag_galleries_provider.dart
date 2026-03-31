import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../performers/presentation/providers/performer_galleries_provider.dart';

part 'tag_galleries_provider.g.dart';

@riverpod
FutureOr<List<PerformerGalleryItem>> tagGalleries(Ref ref, String tagId) async {
  ref.keepAlive();
  final repository = ref.read(galleryRepositoryProvider);

  final galleries = await repository.findGalleries(
    perPage: 24,
    tagId: tagId,
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
class TagGalleriesGrid extends _$TagGalleriesGrid {
  static const int _perPage = 30;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  String? _tagId;

  @override
  FutureOr<List<PerformerGalleryItem>> build(String tagId) async {
    ref.keepAlive();
    _tagId = tagId;
    _currentPage = 1;
    _hasMore = true;
    return _fetchPage(tagId, _currentPage);
  }

  Future<List<PerformerGalleryItem>> _fetchPage(String tagId, int page) async {
    final repository = ref.read(galleryRepositoryProvider);

    final galleries = await repository.findGalleries(
      page: page,
      perPage: _perPage,
      tagId: tagId,
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
    if (_isLoadingMore || !_hasMore || _tagId == null) return;

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final nextItems = await _fetchPage(_tagId!, nextPage);

      if (nextItems.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...(state.value ?? <PerformerGalleryItem>[]), ...nextItems]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
