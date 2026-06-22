import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../../../../core/domain/entities/filter_options.dart';
import '../../domain/entities/scene_filter.dart';

part 'entity_media_filter_scope.g.dart';

enum EntityMediaFilterKind { performer, studio, tag, group }

SceneFilter sceneFilterForEntityMedia({
  required SceneFilter filter,
  required EntityMediaFilterKind kind,
  required String entityId,
}) {
  return switch (kind) {
    EntityMediaFilterKind.performer => filter.copyWith(
      performers: MultiCriterion(value: [entityId]),
    ),
    EntityMediaFilterKind.studio => filter.copyWith(
      studios: HierarchicalMultiCriterion(value: [entityId]),
    ),
    EntityMediaFilterKind.tag => filter.copyWith(
      tags: HierarchicalMultiCriterion(value: [entityId]),
    ),
    EntityMediaFilterKind.group => filter.copyWith(
      groups: HierarchicalMultiCriterion(value: [entityId]),
    ),
  };
}

@Riverpod(keepAlive: true)
class EntityMediaSort extends _$EntityMediaSort {
  @override
  ({String? sort, bool descending, int? randomSeed}) build(
    EntityMediaFilterKind kind,
  ) {
    final prefs = ref.read(sharedPreferencesProvider);
    final sort = prefs.getString(_sortKey(kind)) ?? 'date';
    final descending = prefs.getBool(_descKey(kind)) ?? true;
    final seed = sort == 'random'
        ? ref.read(entityMediaRandomSeedProvider(kind))
        : null;

    return (sort: sort, descending: descending, randomSeed: seed);
  }

  void setSort({String? sort, bool descending = true}) {
    final seed = sort == 'random'
        ? ref.read(entityMediaRandomSeedProvider(kind))
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

  static String _sortKey(EntityMediaFilterKind kind) =>
      'entity_media_${kind.name}_sort_field';
  static String _descKey(EntityMediaFilterKind kind) =>
      'entity_media_${kind.name}_sort_descending';
}

@Riverpod(keepAlive: true)
class EntityMediaSearchQuery extends _$EntityMediaSearchQuery {
  @override
  String build(EntityMediaFilterKind kind) => '';

  void update(String query) => state = query;
}

@Riverpod(keepAlive: true)
class EntityMediaFilterState extends _$EntityMediaFilterState {
  @override
  SceneFilter build(EntityMediaFilterKind kind) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonString = prefs.getString(_storageKey(kind));
    if (jsonString != null) {
      try {
        return SceneFilter.fromJson(jsonDecode(jsonString));
      } catch (_) {
        return SceneFilter.empty();
      }
    }
    return SceneFilter.empty();
  }

  void update(SceneFilter filter) => state = filter;
  void clear() => state = SceneFilter.empty();

  Future<void> saveAsDefault() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_storageKey(kind), jsonEncode(state.toJson()));
  }

  static String _storageKey(EntityMediaFilterKind kind) =>
      'entity_media_${kind.name}_filter_state';
}

@Riverpod(keepAlive: true)
class EntityMediaOrganizedOnly extends _$EntityMediaOrganizedOnly {
  @override
  OrganizedFilter build(EntityMediaFilterKind kind) {
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

  static String _storageKey(EntityMediaFilterKind kind) =>
      'entity_media_${kind.name}_organized_only_v2';
}

@Riverpod(keepAlive: true)
class EntityMediaRandomSeed extends _$EntityMediaRandomSeed {
  @override
  int build(EntityMediaFilterKind kind) =>
      DateTime.now().microsecondsSinceEpoch.remainder(10000000);

  void next() =>
      state = DateTime.now().microsecondsSinceEpoch.remainder(10000000);
}
