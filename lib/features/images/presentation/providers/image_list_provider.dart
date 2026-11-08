import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/image.dart' as entity;
import '../../domain/entities/image_filter.dart';
import '../../data/repositories/graphql_image_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'image_browser_context.dart';

part 'image_list_provider.g.dart';

final imageRepositoryProvider = Provider<GraphQLImageRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLImageRepository(client);
});

@Riverpod(keepAlive: true, dependencies: [imageBrowserContext])
class ImageRandomSeed extends _$ImageRandomSeed {
  @override
  int build() => Random().nextInt(10000000);

  void next() => state = Random().nextInt(10000000);
}

/// Broadcasts confirmed edits to every live browser without refetching its query.
final imageChangedProvider = NotifierProvider<ImageChanged, entity.Image?>(
  ImageChanged.new,
);

class ImageChanged extends Notifier<entity.Image?> {
  @override
  entity.Image? build() {
    ref.watch(imageRepositoryProvider);
    return null;
  }

  void publish(entity.Image image) => state = image;

  /// Completes independently of the viewer, but never publishes to another server.
  Future<void> updateRating(entity.Image image, int rating) async {
    final repository = ref.read(imageRepositoryProvider);
    await repository.updateImageRating(image.id, rating);
    if (ref.mounted &&
        identical(repository, ref.read(imageRepositoryProvider))) {
      publish(image.copyWith(rating100: rating));
    }
  }
}

/// Resolves library deep links outside the currently loaded page without
/// substituting the first image in the library.
final imageByIdProvider = FutureProvider.autoDispose
    .family<entity.Image, String>((ref, id) {
      final repository = ref.watch(imageRepositoryProvider);
      final changed = ref.watch(imageChangedProvider);
      if (changed?.id == id) return changed!;
      return repository.getImageById(id);
    });

/// Tracks the image currently shown by the fullscreen viewer for return focus.
final imageFullscreenCurrentIdProvider =
    NotifierProvider<ImageFullscreenCurrentId, String?>(
      ImageFullscreenCurrentId.new,
      dependencies: [imageBrowserContextProvider],
    );

/// Owns the transient fullscreen image selection shared with the source grid.
class ImageFullscreenCurrentId extends Notifier<String?> {
  @override
  String? build() => null;

  void setCurrent(String imageId) => state = imageId;
}

@Riverpod(keepAlive: true, dependencies: [imageBrowserContext, ImageRandomSeed])
class ImageSort extends _$ImageSort {
  static const _sortKey = 'image_sort_field';
  static const _descKey = 'image_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    if (ref.watch(imageBrowserContextProvider) != null) {
      return (sort: 'path', descending: false, randomSeed: null);
    }
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'path';
    final descending = prefs.getBool(_descKey) ?? false;

    final seed = sort == 'random' ? ref.read(imageRandomSeedProvider) : null;

    return (sort: sort, descending: descending, randomSeed: seed);
  }

  void setSort({String? sort, bool descending = true}) {
    final seed = sort == 'random' ? ref.read(imageRandomSeedProvider) : null;
    state = (sort: sort, descending: descending, randomSeed: seed);
  }

  Future<void> saveAsDefault() async {
    if (ref.read(imageBrowserContextProvider) != null) return;
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sort != null) await prefs.setString(_sortKey, state.sort!);
    await prefs.setBool(_descKey, state.descending);
  }
}

@Riverpod(keepAlive: true, dependencies: [imageBrowserContext])
class ImageSearchQuery extends _$ImageSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true, dependencies: [imageBrowserContext])
class ImageFilterState extends _$ImageFilterState {
  static const _storageKey = 'image_filter_state';

  @override
  ({String? galleryId, ImageFilter filter}) build() {
    final browser = ref.watch(imageBrowserContextProvider);
    if (browser != null) {
      return (galleryId: browser.galleryId, filter: const ImageFilter());
    }
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      try {
        return (
          galleryId: null,
          filter: ImageFilter.fromJson(
            jsonDecode(jsonString) as Map<String, dynamic>,
          ),
        );
      } on Object catch (error, stackTrace) {
        AppLogStore.instance.addError(
          'build',
          error,
          stackTrace,
          source: 'image_list_provider',
        );
        // Malformed stored data can also fail with a cast error.
        // Fall through to the empty default for corrupt legacy preferences.
      }
    }
    return (galleryId: null, filter: ImageFilter.empty());
  }

  void setGalleryId(String? id) {
    final browser = ref.read(imageBrowserContextProvider);
    state = (
      galleryId: browser == null ? id : browser.galleryId,
      filter: state.filter,
    );
  }

  void updateFilter(ImageFilter filter) =>
      state = (galleryId: state.galleryId, filter: filter);
  void clear() => state = (
    galleryId: ref.read(imageBrowserContextProvider)?.galleryId,
    filter: const ImageFilter(),
  );
  void clearGalleryId() => setGalleryId(null);

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (ref.read(imageBrowserContextProvider) != null) return;
    await prefs.setString(_storageKey, jsonEncode(state.filter.toJson()));
  }
}

@Riverpod(keepAlive: true, dependencies: [imageBrowserContext])
class ImageOrganizedOnly extends _$ImageOrganizedOnly {
  static const _organizedKey = 'image_organized_only_v2';

  @override
  OrganizedFilter build() {
    if (ref.watch(imageBrowserContextProvider) != null) {
      return OrganizedFilter.all;
    }
    final prefs = ref.watch(sharedPreferencesProvider);
    final val = prefs.getString(_organizedKey);
    return OrganizedFilter.values.firstWhere(
      (e) => e.name == val,
      orElse: () {
        // Fallback for migration
        final oldVal = prefs.getBool('image_organized_only');
        if (oldVal == true) return OrganizedFilter.organized;
        return OrganizedFilter.all;
      },
    );
  }

  void set(OrganizedFilter value) => state = value;

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (ref.read(imageBrowserContextProvider) != null) return;
    await prefs.setString(_organizedKey, state.name);
  }
}

@Riverpod(
  keepAlive: true,
  dependencies: [ImageFilterState, ImageOrganizedOnly, imageBrowserContext],
)
ImageFilter imageEffectiveFilter(Ref ref) {
  final filter = ref.watch(imageFilterStateProvider).filter;
  final organized = ref.watch(imageOrganizedOnlyProvider);
  var effective = filter.copyWith(
    organized: organized.toBool() ?? filter.organized,
  );
  final browser = ref.watch(imageBrowserContextProvider);
  if (browser?.entityKind != null) {
    final restriction = imageFilterForEntityGalleries(
      kind: browser!.entityKind!,
      entityId: browser.entityId!,
      method: ref.watch(entityImageFilterMethodSettingProvider),
    );
    effective = effective.copyWith(
      performers: restriction.performers ?? effective.performers,
      studios: restriction.studios ?? effective.studios,
      tags: restriction.tags ?? effective.tags,
      galleriesFilter: restriction.galleriesFilter ?? effective.galleriesFilter,
    );
  }
  return effective;
}

@Riverpod(
  keepAlive: true,
  dependencies: [
    ImageSearchQuery,
    ImageSort,
    ImageFilterState,
    imageEffectiveFilter,
    ImageRandomSeed,
  ],
)
class ImageList extends _$ImageList {
  int _currentPage = 1;
  int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  int _requestGeneration = 0;

  @override
  FutureOr<List<entity.Image>> build() async {
    _requestGeneration++;
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;

    final query = ref.watch(imageSearchQueryProvider);
    final sortConfig = ref.watch(imageSortProvider);
    final filterState = ref.watch(imageFilterStateProvider);
    final imageFilter = ref.watch(imageEffectiveFilterProvider);
    final repository = ref.watch(imageRepositoryProvider);
    ref.listen(imageChangedProvider, (_, image) {
      if (image != null) updateImageInList(image);
    });

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort = 'random_${ref.watch(imageRandomSeedProvider)}';
    }

    return repository.findImages(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      galleryId: filterState.galleryId,
      imageFilter: imageFilter,
    );
  }

  /// Manually refreshes the image list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(imageRandomSeedProvider.notifier).next();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
    await future;
  }

  void setSort({String? sort, bool descending = true}) {
    ref
        .read(imageSortProvider.notifier)
        .setSort(sort: sort, descending: descending);
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  void setPerPage(int perPage) {
    if (_perPage == perPage) return;
    _perPage = perPage;
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    final generation = _requestGeneration;
    _isLoadingMore = true;
    final repository = ref.read(imageRepositoryProvider);
    final query = ref.read(imageSearchQueryProvider);
    final sortConfig = ref.read(imageSortProvider);
    final filterState = ref.read(imageFilterStateProvider);
    final imageFilter = ref.read(imageEffectiveFilterProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort = 'random_${ref.read(imageRandomSeedProvider)}';
    }

    try {
      final nextPage = _currentPage + 1;
      final nextImages = await repository.findImages(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        galleryId: filterState.galleryId,
        imageFilter: imageFilter,
      );

      if (!ref.mounted || generation != _requestGeneration) return;

      if (nextImages.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextImages]);
      }
    } finally {
      if (ref.mounted && generation == _requestGeneration) {
        _isLoadingMore = false;
      }
    }
  }

  /// Replaces a single image entry in the current in-memory list state.
  ///
  /// Useful for optimistic or post-mutation UI refreshes (for example after
  /// rating updates) without invalidating and refetching the entire page.
  void updateImageInList(entity.Image updatedImage) {
    if (state.hasValue) {
      final images = state.value!;
      final index = images.indexWhere((image) => image.id == updatedImage.id);
      if (index != -1) {
        final newList = List<entity.Image>.from(images);
        newList[index] = updatedImage;
        state = AsyncData(newList);
      }
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
