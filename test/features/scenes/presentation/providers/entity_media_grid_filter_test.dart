import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/entity_media_filter_scope.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';

import '../../../../helpers/test_helpers.dart';

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
