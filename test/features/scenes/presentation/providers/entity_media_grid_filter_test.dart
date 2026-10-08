import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/domain/entities/filter_options.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';

import '../../../../helpers/test_helpers.dart';

class _DelayedPaginationRepository extends MockGraphQLSceneRepository {
  final nextPage = Completer<List<Scene>>();

  @override
  Future<List<Scene>> findScenes({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    bool? organized,
    bool? performerFavorite,
    String? performerId,
    String? studioId,
    String? tagId,
    SceneFilter? sceneFilter,
  }) {
    if (page == 2) return nextPage.future;
    return super.findScenes(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort,
      descending: descending,
      organized: organized,
      sceneFilter: sceneFilter,
    );
  }
}

Future<ProviderContainer> _containerWith(
  MockGraphQLSceneRepository repository,
) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      sceneRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('applying a query ignores an old in-flight pagination result', () async {
    final repository = _DelayedPaginationRepository();
    final container = await _containerWith(repository);
    const kind = EntityMediaFilterKind.performer;
    final provider = entityMediaGridProvider(kind, 'page-performer');
    container.listen(provider, (_, _) {});
    await container.read(provider.future);

    final pagination = container.read(provider.notifier).fetchNextPage();
    expect(container.read(provider.notifier).isLoadingMore, true);
    container
        .read(entityMediaSortProvider(kind).notifier)
        .setSort(sort: 'title', descending: false);
    await container.read(provider.future);
    expect(container.read(provider.notifier).isLoadingMore, false);

    repository.nextPage.complete([]);
    await pagination;
    expect(container.read(provider.notifier).hasMore, true);
    expect(repository.lastFindScenesPage, 1);
  });

  for (final kind in EntityMediaFilterKind.values) {
    test('$kind media grid reloads when query settings are applied', () async {
      final repository = MockGraphQLSceneRepository();
      final container = await _containerWith(repository);
      final provider = entityMediaGridProvider(kind, 'page-entity');
      container.listen(provider, (_, _) {});
      await container.read(provider.future);

      await container.read(provider.notifier).fetchNextPage();
      expect(repository.lastFindScenesPage, 2);

      container
          .read(entityMediaSortProvider(kind).notifier)
          .setSort(sort: 'title', descending: false);
      await container.read(provider.future);
      expect(repository.lastFindScenesPage, 1);
      expect(repository.lastFindScenesSort, 'title');
      expect(repository.lastFindScenesDescending, false);
      expect(container.read(provider.notifier).hasMore, true);

      final callsBeforeFilter = repository.findSceneCalls.length;
      container
          .read(entityMediaFilterStateProvider(kind).notifier)
          .update(const SceneFilter(rating100: IntCriterion(value: 80)));
      container
          .read(entityMediaOrganizedOnlyProvider(kind).notifier)
          .set(OrganizedFilter.organized);
      await container.read(provider.future);
      expect(repository.findSceneCalls.length, callsBeforeFilter + 1);
      expect(repository.lastFindScenesPage, 1);
      expect(repository.lastFindScenesSceneFilter?.rating100?.value, 80);
      expect(repository.findSceneCalls.last.organized, true);
      expect(repository.lastFindScenesSort, 'title');
      expect(repository.lastFindScenesDescending, false);
      final scopedFilter = sceneFilterForEntityMedia(
        filter: SceneFilter.empty(),
        kind: kind,
        entityId: 'page-entity',
      );
      expect(
        repository.lastFindScenesSceneFilter?.performers,
        scopedFilter.performers,
      );
      expect(
        repository.lastFindScenesSceneFilter?.studios,
        scopedFilter.studios,
      );
      expect(repository.lastFindScenesSceneFilter?.tags, scopedFilter.tags);
      expect(repository.lastFindScenesSceneFilter?.groups, scopedFilter.groups);

      container
          .read(entityMediaSearchQueryProvider(kind).notifier)
          .update('search');
      await container.read(provider.future);
      expect(repository.lastFindScenesFilter, 'search');
      expect(repository.lastFindScenesPage, 1);
    });
  }

  test(
    'performer media grid overwrites saved performer filter with page performer',
    () async {
      final repository = MockGraphQLSceneRepository();
      final container = await _containerWith(repository);

      container
          .read(
            entityMediaFilterStateProvider(
              EntityMediaFilterKind.performer,
            ).notifier,
          )
          .update(
            const SceneFilter(
              performers: MultiCriterion(value: ['preset-performer']),
              tags: HierarchicalMultiCriterion(value: ['preset-tag']),
            ),
          );

      await container.read(
        entityMediaGridProvider(
          EntityMediaFilterKind.performer,
          'page-performer',
        ).future,
      );

      expect(repository.lastFindScenesSceneFilter?.performers?.value, [
        'page-performer',
      ]);
      expect(repository.lastFindScenesSceneFilter?.tags?.value, ['preset-tag']);
    },
  );

  test(
    'entity media grids do not inherit scene list sort and filters',
    () async {
      final repository = MockGraphQLSceneRepository();
      final container = await _containerWith(repository);

      container
          .read(sceneSortProvider.notifier)
          .setSort(sort: 'title', descending: false);
      container
          .read(sceneFilterStateProvider.notifier)
          .update(const SceneFilter(rating100: IntCriterion(value: 80)));

      await container.read(
        entityMediaGridProvider(
          EntityMediaFilterKind.performer,
          'page-performer',
        ).future,
      );

      expect(repository.lastFindScenesSort, 'date');
      expect(repository.lastFindScenesDescending, true);
      expect(repository.lastFindScenesSceneFilter?.rating100, isNull);
      expect(repository.lastFindScenesSceneFilter?.performers?.value, [
        'page-performer',
      ]);
    },
  );

  test('entity media grid can overwrite group filters from a preset', () {
    final presetFilter = const SceneFilter(
      groups: HierarchicalMultiCriterion(value: ['preset-group']),
      studios: HierarchicalMultiCriterion(value: ['preset-studio']),
    );

    final scopedFilter = presetFilter.copyWith(
      groups: const HierarchicalMultiCriterion(value: ['page-group']),
    );

    expect(scopedFilter.groups?.value, ['page-group']);
    expect(scopedFilter.studios?.value, ['preset-studio']);
  });
}
