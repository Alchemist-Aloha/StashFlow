import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_filter.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../../data/repositories/graphql_gallery_repository.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/pagination.dart';

part 'gallery_list_provider.g.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLGalleryRepository(client);
});

@riverpod
class GalleryScrollController extends _$GalleryScrollController {
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
class GalleryRandomSeed extends _$GalleryRandomSeed {
  @override
  int build() => Random().nextInt(10000000);

  void next() => state = Random().nextInt(10000000);
}

@Riverpod(keepAlive: true)
class GallerySort extends _$GallerySort {
  static const _sortKey = 'gallery_sort_field';
  static const _descKey = 'gallery_sort_descending';

  @override
  ({String? sort, bool descending, int? randomSeed}) build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey) ?? 'path';
    final descending = prefs.getBool(_descKey) ?? false;

    int? seed;
    if (sort == 'random') {
      seed = ref.watch(galleryRandomSeedProvider);
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
class GallerySearchQuery extends _$GallerySearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
class GalleryFilterState extends _$GalleryFilterState {
  static const _filterKey = 'gallery_filter_state';

  @override
  GalleryFilter build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_filterKey);
    if (jsonStr != null) {
      try {
        return GalleryFilter.fromJson(jsonDecode(jsonStr));
      } catch (_) {
        return GalleryFilter.empty();
      }
    }
    return GalleryFilter.empty();
  }

  void update(GalleryFilter filter) => state = filter;
  void clear() => state = GalleryFilter.empty();

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_filterKey, jsonEncode(state.toJson()));
  }
}

@riverpod
class GalleryOrganizedOnly extends _$GalleryOrganizedOnly {
  static const _organizedKey = 'gallery_organized_only';

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
class GalleryGridLayout extends _$GalleryGridLayout {
  static const _storageKey = 'gallery_grid_layout';

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getBool(_storageKey) ?? true;
  }

  Future<void> set(bool value) async {
    if (state == value) return;
    state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_storageKey, value);
  }
}

@Riverpod(keepAlive: true)
class GalleryList extends _$GalleryList {
  int _currentPage = 1;
  int _perPage = kDefaultPageSize;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  FutureOr<List<Gallery>> build() async {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    final query = ref.watch(gallerySearchQueryProvider);
    final sortConfig = ref.watch(gallerySortProvider);
    final filter = ref.watch(galleryFilterStateProvider);
    final organizedOnly = ref.watch(galleryOrganizedOnlyProvider);
    final repository = ref.watch(galleryRepositoryProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    return repository.findGalleries(
      page: _currentPage,
      perPage: _perPage,
      filter: query.isEmpty ? null : query,
      sort: effectiveSort,
      descending: sortConfig.descending,
      galleryFilter: filter.copyWith(
        organized: organizedOnly ? true : filter.organized,
      ),
    );
  }

  /// Manually refreshes the gallery list and generates a new random seed.
  Future<void> refresh() async {
    ref.read(galleryRandomSeedProvider.notifier).next();
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
    ref.invalidateSelf();
    await future;
  }

  void setSort({required String sort, required bool descending}) {
    ref
        .read(gallerySortProvider.notifier)
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

    _isLoadingMore = true;
    final repository = ref.read(galleryRepositoryProvider);
    final query = ref.read(gallerySearchQueryProvider);
    final sortConfig = ref.read(gallerySortProvider);
    final filter = ref.read(galleryFilterStateProvider);
    final organizedOnly = ref.read(galleryOrganizedOnlyProvider);

    String? effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random' && sortConfig.randomSeed != null) {
      effectiveSort = 'random_${sortConfig.randomSeed}';
    }

    try {
      final nextPage = _currentPage + 1;
      final nextGalleries = await repository.findGalleries(
        page: nextPage,
        perPage: _perPage,
        filter: query.isEmpty ? null : query,
        sort: effectiveSort,
        descending: sortConfig.descending,
        galleryFilter: filter.copyWith(
          organized: organizedOnly ? true : filter.organized,
        ),
      );

      if (nextGalleries.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        state = AsyncData([...state.value ?? [], ...nextGalleries]);
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  /// Updates a single gallery in the current list state.
  void updateGalleryInList(Gallery updatedGallery) {
    if (state.hasValue) {
      final galleries = state.value!;
      final index = galleries.indexWhere((g) => g.id == updatedGallery.id);
      if (index != -1) {
        final newList = List<Gallery>.from(galleries);
        newList[index] = updatedGallery;
        state = AsyncData(newList);
      }
    }
  }

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<Gallery?> getRandomGallery({
    bool useCurrentFilter = false,
    String? performerId,
    String? studioId,
    String? tagId,
    String? excludeGalleryId,
  }) async {
    final repository = ref.read(galleryRepositoryProvider);
    final query = useCurrentFilter ? ref.read(gallerySearchQueryProvider) : '';
    final filter = useCurrentFilter
        ? ref.read(galleryFilterStateProvider)
        : GalleryFilter.empty();
    final organizedOnly = useCurrentFilter
        ? ref.read(galleryOrganizedOnlyProvider)
        : false;

    // Ask backend for random ordering; if needed, retry to avoid returning same id.
    final attempts = excludeGalleryId == null ? 1 : 3;
    for (var i = 0; i < attempts; i++) {
      final randomPage = await repository.findGalleries(
        page: 1,
        perPage: 1,
        filter: query.isEmpty ? null : query,
        sort: 'random',
        descending: true,
        galleryFilter: filter.copyWith(
          organized: organizedOnly ? true : filter.organized,
        ),
        performerId: performerId,
        studioId: studioId,
        tagId: tagId,
      );
      if (randomPage.isEmpty) continue;
      final candidate = randomPage.first;
      if (excludeGalleryId == null || candidate.id != excludeGalleryId) {
        return candidate;
      }
    }

    final loadedGalleries = state.asData?.value;
    if (loadedGalleries != null && loadedGalleries.isNotEmpty) {
      final candidates = excludeGalleryId == null
          ? loadedGalleries
          : loadedGalleries
                .where((gallery) => gallery.id != excludeGalleryId)
                .toList();
      if (candidates.isEmpty) return null;
      final random = Random();
      return candidates[random.nextInt(candidates.length)];
    }

    return null;
  }
}
