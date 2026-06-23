import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../../images/domain/entities/image_filter.dart';
import '../../domain/entities/gallery_filter.dart';

part 'entity_gallery_filter_scope.g.dart';

enum EntityGalleryFilterKind { performer, studio, tag }

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
}) => switch (kind) {
  EntityGalleryFilterKind.performer => ImageFilter(
    performers: MultiCriterion(value: [entityId]),
  ),
  EntityGalleryFilterKind.studio => ImageFilter(
    studios: HierarchicalMultiCriterion(value: [entityId]),
  ),
  EntityGalleryFilterKind.tag => ImageFilter(
    tags: HierarchicalMultiCriterion(value: [entityId]),
  ),
};

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
