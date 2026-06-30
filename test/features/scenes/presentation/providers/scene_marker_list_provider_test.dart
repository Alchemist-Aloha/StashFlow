import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_marker.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_marker_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_marker_list_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'scene marker list forwards search sort and filter to repository',
    () async {
      final repository = _FakeGraphQLSceneMarkerRepository([
        _marker('m1', title: 'Opening beat'),
      ]);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneMarkerRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      container.read(sceneMarkerSearchQueryProvider.notifier).update('beat');
      container
          .read(sceneMarkerSortProvider.notifier)
          .setSort(sort: 'seconds', descending: false);
      container
          .read(sceneMarkerFilterStateProvider.notifier)
          .update(
            const SceneMarkerFilter(
              tags: HierarchicalMultiCriterion(value: ['t1']),
              scenes: MultiCriterion(value: ['s1']),
              duration: IntCriterion(value: 30),
              sceneDate: DateCriterion(value: '2024-01-01'),
            ),
          );

      final markers = await container.read(sceneMarkerListProvider.future);

      expect(markers.single.id, 'm1');
      expect(repository.calls, hasLength(1));
      expect(repository.calls.single.page, 1);
      expect(repository.calls.single.perPage, isNotNull);
      expect(repository.calls.single.searchQuery, 'beat');
      expect(repository.calls.single.sort, 'seconds');
      expect(repository.calls.single.descending, isFalse);
      expect(repository.calls.single.filter.tags?.value, ['t1']);
      expect(repository.calls.single.filter.scenes?.value, ['s1']);
      expect(repository.calls.single.filter.duration?.value, 30);
      expect(repository.calls.single.filter.sceneDate?.value, '2024-01-01');
    },
  );

  test('scene marker list appends next page', () async {
    final repository = _FakeGraphQLSceneMarkerRepository([
      _marker('m1'),
      _marker('m2'),
    ]);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneMarkerRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sceneMarkerListProvider.future);
    await container.read(sceneMarkerListProvider.notifier).fetchNextPage();

    final markers = container.read(sceneMarkerListProvider).value!;
    expect(markers.map((marker) => marker.id), ['m1', 'm2']);
    expect(repository.calls.map((call) => call.page), [1, 2]);
  });

  test('scene marker defaults use marker-specific preference keys', () async {
    SharedPreferences.setMockInitialValues({
      'scene_sort_field': 'date',
      'scene_sort_descending': true,
      'scene_marker_sort_field': 'seconds',
      'scene_marker_sort_descending': false,
      'scene_filter_state': '{"duration":{"value":999}}',
      'scene_marker_filter_state':
          '{"duration":{"value":30,"modifier":"GREATER_THAN"}}',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final sort = container.read(sceneMarkerSortProvider);
    final filter = container.read(sceneMarkerFilterStateProvider);

    expect(sort.sort, 'seconds');
    expect(sort.descending, isFalse);
    expect(filter.duration?.value, 30);
    expect(filter.duration?.modifier, CriterionModifier.greaterThan);

    container
        .read(sceneMarkerSortProvider.notifier)
        .setSort(sort: 'updated_at', descending: true);
    container
        .read(sceneMarkerFilterStateProvider.notifier)
        .update(
          const SceneMarkerFilter(
            sceneDate: DateCriterion(value: '2024-06-01'),
          ),
        );

    await container.read(sceneMarkerSortProvider.notifier).saveAsDefault();
    await container
        .read(sceneMarkerFilterStateProvider.notifier)
        .saveAsDefault();

    expect(prefs.getString('scene_marker_sort_field'), 'updated_at');
    expect(prefs.getBool('scene_marker_sort_descending'), isTrue);
    expect(prefs.getString('scene_sort_field'), 'date');
    expect(prefs.getString('scene_filter_state'), '{"duration":{"value":999}}');
    expect(
      prefs.getString('scene_marker_filter_state'),
      contains(
        '"sceneDate":{"value":"2024-06-01","value2":null,"modifier":"EQUALS"}',
      ),
    );
  });
}

SceneMarkerSummary _marker(String id, {String title = 'Marker'}) {
  return SceneMarkerSummary(
    id: id,
    title: title,
    seconds: 10,
    endSeconds: null,
    screenshot: null,
    preview: null,
    stream: null,
    primaryTagName: null,
    tagNames: const [],
    sceneId: 's1',
    sceneTitle: 'Scene 1',
    performerNames: const [],
  );
}

class _FakeGraphQLSceneMarkerRepository
    implements GraphQLSceneMarkerRepository {
  _FakeGraphQLSceneMarkerRepository(this.responses);

  final List<SceneMarkerSummary> responses;
  final List<
    ({
      int? page,
      int? perPage,
      String? searchQuery,
      String? sort,
      bool descending,
      SceneMarkerFilter filter,
    })
  >
  calls = [];

  @override
  Future<List<SceneMarkerSummary>> findSceneMarkers({
    int? page,
    int? perPage,
    String? searchQuery,
    String? sort,
    bool descending = true,
    SceneMarkerFilter filter = const SceneMarkerFilter(),
  }) async {
    calls.add((
      page: page,
      perPage: perPage,
      searchQuery: searchQuery,
      sort: sort,
      descending: descending,
      filter: filter,
    ));
    if (responses.isEmpty) return const [];
    return [responses[(page ?? 1) - 1]];
  }
}
