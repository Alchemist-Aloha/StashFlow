import "dart:math";
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/image.dart' as entity;
import '../../domain/entities/image_filter.dart';
import '../../domain/repositories/image_repository.dart';
import '../../data/repositories/graphql_image_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'image_list_provider.g.dart';

final imageRepositoryProvider = Provider<ImageRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLImageRepository(client);
});

@riverpod
class ImageScrollController extends _$ImageScrollController {
  @override
  ScrollController build() {
    final controller = ScrollController();
    ref.onDispose(controller.dispose);
    return controller;
  }

  void scrollToTop() {
    if (state.hasClients) {
      state.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

@Riverpod(keepAlive: true)
class ImageRandomSeed extends _$ImageRandomSeed {
  @override
  int build() => Random().nextInt(10000000);

  void next() => state = Random().nextInt(10000000);
}

@Riverpod(keepAlive: true)
class ImageSort extends _$ImageSort {
  static const _sortKey = 'image_sort_field';
  static const _descKey = 'image_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'path';
    final descending = prefs.getBool(_descKey) ?? false;

    int? seed;
    if (sort == 'random') {
      seed = ref.watch(imageRandomSeedProvider);
    }

    return (sort: sort, descending: descending, randomSeed: seed);
  }

  void setSort({String? sort, bool descending = true}) {
    state = (sort: sort, descending: descending, randomSeed: state.randomSeed);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (state.sort != null) await prefs.setString(_sortKey, state.sort!);
    await prefs.setBool(_descKey, state.descending);
  }
}

@Riverpod(keepAlive: true)
class ImageSearchQuery extends _$ImageSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
class ImageFilterState extends _$ImageFilterState {
  @override
  ({String? galleryId, ImageFilter filter}) build() {
    return (galleryId: null, filter: const ImageFilter());
  }

  void setGalleryId(String? id) =>
      state = (galleryId: id, filter: state.filter);
  void updateFilter(ImageFilter filter) =>
      state = (galleryId: state.galleryId, filter: filter);
  void clear() => state = (galleryId: null, filter: const ImageFilter());
  void clearGalleryId() => state = (galleryId: null, filter: state.filter);

  Future<void> saveAsDefault() async {
    // Implementation for saving filter as default if desired.
  }
}

@Riverpod(keepAlive: true)
class ImageOrganizedOnly extends _$ImageOrganizedOnly {
  static const _organizedKey = 'image_organized_only';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_organizedKey) ?? false;
  }

  void set(bool value) => state = value;

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_organizedKey, state);
  }
}

@Riverpod(keepAlive: true)
class ImageList extends _$ImageList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<entity.Image>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;

    final query = ref.watch(imageSearchQueryProvider);
    final sortConfig = ref.watch(imageSortProvider);
    final filterState = ref.watch(imageFilterStateProvider);
    final organizedOnly = ref.watch(imageOrganizedOnlyProvider);
    final repository = ref.read(imageRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    return repository.findImages(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      galleryId: filterState.galleryId,
      imageFilter: filterState.filter.copyWith(
        organized: organizedOnly ? true : filterState.filter.organized,
      ),
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

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore || state.isLoading) return;

    _isLoadingMore = true;
    final repository = ref.read(imageRepositoryProvider);
    final query = ref.read(imageSearchQueryProvider);
    final sortConfig = ref.read(imageSortProvider);
    final filterState = ref.read(imageFilterStateProvider);
    final organizedOnly = ref.read(imageOrganizedOnlyProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
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
        imageFilter: filterState.filter.copyWith(
          organized: organizedOnly ? true : filterState.filter.organized,
        ),
      );

      if (nextImages.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextImages]);
      }
    } finally {
      _isLoadingMore = false;
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
