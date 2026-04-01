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

@riverpod
class ImageSort extends _$ImageSort {
  static const _sortKey = 'image_sort_field';
  static const _descKey = 'image_sort_descending';

  @override
  ({String? sort, bool descending}) build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'path';
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
class ImageSearchQuery extends _$ImageSearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@riverpod
class ImageFilterState extends _$ImageFilterState {
  @override
  ({String? galleryId, ImageFilter filter}) build() {
    ref.keepAlive();
    return (galleryId: null, filter: const ImageFilter());
  }

  void setGalleryId(String? id) => state = (galleryId: id, filter: state.filter);
  void updateFilter(ImageFilter filter) => state = (galleryId: state.galleryId, filter: filter);
  void clear() => state = (galleryId: null, filter: const ImageFilter());
  void clearGalleryId() => state = (galleryId: null, filter: state.filter);

  Future<void> saveAsDefault() async {
    // Implementation for saving filter as default if desired.
  }
}

@riverpod
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

@riverpod
class ImageList extends _$ImageList {
  int _currentPage = 1;
  static const int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<entity.Image>> build() async {
    ref.keepAlive();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;

    final query = ref.watch(imageSearchQueryProvider);
    final sortConfig = ref.watch(imageSortProvider);
    final filterState = ref.watch(imageFilterStateProvider);
    final organizedOnly = ref.watch(imageOrganizedOnlyProvider);
    final repository = ref.read(imageRepositoryProvider);

    return repository.findImages(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: sortConfig.sort,
      descending: sortConfig.descending,
      galleryId: filterState.galleryId,
      imageFilter: filterState.filter.copyWith(
        organized: organizedOnly ? true : filterState.filter.organized,
      ),
    );
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

    try {
      final nextPage = _currentPage + 1;
      final nextImages = await repository.findImages(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: sortConfig.sort,
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
