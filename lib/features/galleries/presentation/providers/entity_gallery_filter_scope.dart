import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../images/domain/entities/image_filter.dart';
import '../../domain/entities/gallery.dart';
import '../../domain/entities/gallery_filter.dart';
import 'gallery_list_provider.dart';

part 'entity_gallery_filter_scope.g.dart';

enum EntityGalleryFilterKind { performer, studio, tag }

enum EntityImageFilterMethod { directEntity, relatedGalleries }

const entityImageFilterMethodPreferenceKey = 'entity_image_filter_method';

GalleryFilter galleryFilterForEntityGalleries({
  required GalleryFilter filter,
  required EntityGalleryFilterKind kind,
  required String entityId,
}) {
  return switch (kind) {
    EntityGalleryFilterKind.performer => filter.copyWith(
      performers: MultiCriterion(value: [entityId]),
    ),
    EntityGalleryFilterKind.studio => filter.copyWith(
      studios: HierarchicalMultiCriterion(value: [entityId]),
    ),
    EntityGalleryFilterKind.tag => filter.copyWith(
      tags: HierarchicalMultiCriterion(value: [entityId]),
    ),
  };
}

ImageFilter imageFilterForEntityGalleries({
  required EntityGalleryFilterKind kind,
  required String entityId,
  EntityImageFilterMethod method = EntityImageFilterMethod.directEntity,
}) => switch (method) {
  EntityImageFilterMethod.directEntity => switch (kind) {
    EntityGalleryFilterKind.performer => ImageFilter(
      performers: MultiCriterion(value: [entityId]),
    ),
    EntityGalleryFilterKind.studio => ImageFilter(
      studios: HierarchicalMultiCriterion(value: [entityId]),
    ),
    EntityGalleryFilterKind.tag => ImageFilter(
      tags: HierarchicalMultiCriterion(value: [entityId]),
    ),
  },
  EntityImageFilterMethod.relatedGalleries => ImageFilter(
    galleriesFilter: switch (kind) {
      EntityGalleryFilterKind.performer => GalleryFilter(
        performers: MultiCriterion(value: [entityId]),
      ),
      EntityGalleryFilterKind.studio => GalleryFilter(
        studios: HierarchicalMultiCriterion(value: [entityId]),
      ),
      EntityGalleryFilterKind.tag => GalleryFilter(
        tags: HierarchicalMultiCriterion(value: [entityId]),
      ),
    },
  ),
};

@Riverpod(keepAlive: true)
class EntityImageFilterMethodSetting extends _$EntityImageFilterMethodSetting {
  @override
  EntityImageFilterMethod build() {
    final stored = ref
        .read(sharedPreferencesProvider)
        .getString(entityImageFilterMethodPreferenceKey);
    return EntityImageFilterMethod.values.firstWhere(
      (method) => method.name == stored,
      orElse: () => EntityImageFilterMethod.directEntity,
    );
  }

  Future<void> set(EntityImageFilterMethod method) async {
    state = method;
    await ref
        .read(sharedPreferencesProvider)
        .setString(entityImageFilterMethodPreferenceKey, method.name);
  }
}

@Riverpod(keepAlive: true)
class EntityGallerySort extends _$EntityGallerySort {
  @override
  ({String? sort, bool descending, int? randomSeed}) build(
    EntityGalleryFilterKind kind,
  ) {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey(kind)) ?? 'path';
    final descending = prefs.getBool(_descKey(kind)) ?? false;
    final seed = sort == 'random'
        ? ref.read(entityGalleryRandomSeedProvider(kind))
        : null;

    return (sort: sort, descending: descending, randomSeed: seed);
  }

  void setSort({String? sort, bool descending = false}) {
    final seed = sort == 'random'
        ? ref.read(entityGalleryRandomSeedProvider(kind))
        : null;
    state = (sort: sort, descending: descending, randomSeed: seed);
  }

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final currentSort = state.sort;
    if (currentSort != null) {
      await prefs.setString(_sortKey(kind), currentSort);
    }
    await prefs.setBool(_descKey(kind), state.descending);
  }

  static String _sortKey(EntityGalleryFilterKind kind) =>
      'entity_galleries_${kind.name}_sort_field';
  static String _descKey(EntityGalleryFilterKind kind) =>
      'entity_galleries_${kind.name}_sort_descending';
}

@Riverpod(keepAlive: true)
class EntityGallerySearchQuery extends _$EntityGallerySearchQuery {
  @override
  String build(EntityGalleryFilterKind kind) => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
class EntityGalleryFilterState extends _$EntityGalleryFilterState {
  @override
  GalleryFilter build(EntityGalleryFilterKind kind) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonString = prefs.getString(_storageKey(kind));
    if (jsonString != null) {
      try {
        return GalleryFilter.fromJson(jsonDecode(jsonString));
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
    await prefs.setString(_storageKey(kind), jsonEncode(state.toJson()));
  }

  static String _storageKey(EntityGalleryFilterKind kind) =>
      'entity_galleries_${kind.name}_filter_state';
}

@Riverpod(keepAlive: true)
class EntityGalleryOrganizedOnly extends _$EntityGalleryOrganizedOnly {
  @override
  OrganizedFilter build(EntityGalleryFilterKind kind) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final value = prefs.getString(_storageKey(kind));
    return OrganizedFilter.values.firstWhere(
      (item) => item.name == value,
      orElse: () => OrganizedFilter.all,
    );
  }

  void set(OrganizedFilter value) => state = value;

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey(kind), state.name);
  }

  static String _storageKey(EntityGalleryFilterKind kind) =>
      'entity_galleries_${kind.name}_organized_only_v2';
}

@Riverpod(keepAlive: true)
class EntityGalleryRandomSeed extends _$EntityGalleryRandomSeed {
  @override
  int build(EntityGalleryFilterKind kind) =>
      DateTime.now().microsecondsSinceEpoch.remainder(10000000);

  void next() =>
      state = DateTime.now().microsecondsSinceEpoch.remainder(10000000);
}

@riverpod
FutureOr<List<Gallery>> entityGalleryPreview(
  Ref ref,
  EntityGalleryFilterKind kind,
  String entityId,
) async {
  ref.keepAlive();
  final repository = ref.read(galleryRepositoryProvider);

  return switch (kind) {
    EntityGalleryFilterKind.performer => repository.findGalleries(
      perPage: 24,
      performerId: entityId,
    ),
    EntityGalleryFilterKind.studio => repository.findGalleries(
      perPage: 24,
      studioId: entityId,
    ),
    EntityGalleryFilterKind.tag => repository.findGalleries(
      perPage: 24,
      tagId: entityId,
    ),
  };
}

@riverpod
class EntityGalleryGrid extends _$EntityGalleryGrid {
  static const int _perPage = 30;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  EntityGalleryFilterKind? _kind;
  String? _entityId;

  @override
  FutureOr<List<Gallery>> build(EntityGalleryFilterKind kind, String entityId) {
    ref.keepAlive();
    _kind = kind;
    _entityId = entityId;
    _currentPage = 1;
    _hasMore = true;
    return _fetchPage(kind: kind, entityId: entityId, page: _currentPage);
  }

  Future<List<Gallery>> _fetchPage({
    required EntityGalleryFilterKind kind,
    required String entityId,
    required int page,
  }) async {
    final repository = ref.read(galleryRepositoryProvider);
    final query = ref.read(entityGallerySearchQueryProvider(kind));
    final sortConfig = ref.read(entityGallerySortProvider(kind));
    final baseFilter = ref.read(entityGalleryFilterStateProvider(kind));
    final filter = galleryFilterForEntityGalleries(
      filter: baseFilter,
      kind: kind,
      entityId: entityId,
    );
    final organizedFilter = ref.read(entityGalleryOrganizedOnlyProvider(kind));
    var effectiveSort = sortConfig.sort;
    if (effectiveSort == 'random') {
      effectiveSort =
          'random_${ref.read(entityGalleryRandomSeedProvider(kind))}';
    }

    return repository.findGalleries(
      page: page,
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
    final kind = _kind;
    final entityId = _entityId;
    if (_isLoadingMore || !_hasMore || kind == null || entityId == null) {
      return;
    }

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final nextItems = await _fetchPage(
        kind: kind,
        entityId: entityId,
        page: nextPage,
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
