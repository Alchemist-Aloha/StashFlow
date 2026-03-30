import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/image.dart' as entity;
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
    final sort = prefs.getString(_sortKey) ?? 'date';
    final descending = prefs.getBool(_descKey) ?? true;
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
  ({String? galleryId}) build() => (galleryId: null);

  void setGalleryId(String? id) => state = (galleryId: id);
  void clear() => state = (galleryId: null);
}

enum MediaViewType { images, galleries }

@riverpod
class MediaViewToggle extends _$MediaViewToggle {
  static const _storageKey = 'media_view_type';

  @override
  MediaViewType build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getString(_storageKey);
    if (value == 'galleries') return MediaViewType.galleries;
    return MediaViewType.images;
  }

  Future<void> toggle() async {
    final next = state == MediaViewType.images
        ? MediaViewType.galleries
        : MediaViewType.images;
    state = next;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey, next.name);
  }

  Future<void> setView(MediaViewType type) async {
    if (state == type) return;
    state = type;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey, type.name);
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
    final filter = ref.watch(imageFilterStateProvider);
    final repository = ref.read(imageRepositoryProvider);

    return repository.findImages(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: sortConfig.sort,
      descending: sortConfig.descending,
      galleryId: filter.galleryId,
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
    final filter = ref.read(imageFilterStateProvider);

    try {
      final nextPage = _currentPage + 1;
      final nextImages = await repository.findImages(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: sortConfig.sort,
        descending: sortConfig.descending,
        galleryId: filter.galleryId,
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

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;
}
