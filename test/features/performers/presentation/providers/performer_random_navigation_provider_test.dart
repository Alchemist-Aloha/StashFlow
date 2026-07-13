import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer_filter.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_random_navigation_provider.dart';

import '../../../../helpers/test_helpers.dart';

class _CapturingPerformerRepository extends MockGraphQLPerformerRepository {
  final List<
    ({
      int? page,
      int? perPage,
      String? filter,
      String? sort,
      bool descending,
      PerformerFilter? performerFilter,
    })
  >
  findCalls = [];

  final List<List<Performer>> queuedResponses = [];

  @override
  Future<List<Performer>> findPerformers({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    PerformerFilter? performerFilter,
    bool favoritesOnly = false,
    List<String>? genders,
  }) async {
    findCalls.add((
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort,
      descending: descending,
      performerFilter: performerFilter,
    ));
    if (queuedResponses.isNotEmpty) {
      return queuedResponses.removeAt(0);
    }
    return super.findPerformers(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort,
      descending: descending,
      performerFilter: performerFilter,
      favoritesOnly: favoritesOnly,
      genders: genders,
    );
  }
}

const _filteredPerformer = Performer(
  id: 'p1',
  name: 'Filtered Performer',
  disambiguation: null,
  urls: [],
  gender: 'FEMALE',
  birthdate: null,
  aliasList: [],
  favorite: false,
  imagePath: null,
  sceneCount: 0,
  imageCount: 0,
  galleryCount: 0,
  groupCount: 0,
  tagIds: [],
  tagNames: [],
);

const _loadedPerformer = Performer(
  id: 'loaded',
  name: 'Loaded Performer',
  disambiguation: null,
  urls: [],
  gender: 'FEMALE',
  birthdate: null,
  aliasList: [],
  favorite: false,
  imagePath: null,
  sceneCount: 0,
  imageCount: 0,
  galleryCount: 0,
  groupCount: 0,
  tagIds: [],
  tagNames: [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'performer random controller forwards active filters when enabled',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = _CapturingPerformerRepository()
        ..queuedResponses.addAll([
          [_loadedPerformer],
          [_filteredPerformer],
        ]);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          performerRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.read(performerSearchQueryProvider.notifier).update('filtered');
      container
          .read(performerFilterStateProvider.notifier)
          .update(const PerformerFilter(rating100: IntCriterion(value: 80)));

      final performer = await container
          .read(performerRandomNavigationControllerProvider)
          .getRandomPerformer(excludePerformerId: 'current');

      expect(performer?.id, _filteredPerformer.id);
      expect(repo.findCalls.last.filter, 'filtered');
      expect(repo.findCalls.last.sort, 'random');
      expect(
        repo.findCalls.last.performerFilter,
        const PerformerFilter(rating100: IntCriterion(value: 80)),
      );
    },
  );

  test(
    'performer random controller ignores active filters when disabled',
    () async {
      SharedPreferences.setMockInitialValues({
        'scene_random_respect_active_filter': false,
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = _CapturingPerformerRepository()
        ..queuedResponses.addAll([
          [_loadedPerformer],
          [_filteredPerformer],
        ]);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          performerRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.read(performerSearchQueryProvider.notifier).update('filtered');
      container
          .read(performerFilterStateProvider.notifier)
          .update(const PerformerFilter(rating100: IntCriterion(value: 80)));

      await container
          .read(performerRandomNavigationControllerProvider)
          .getRandomPerformer();

      expect(repo.findCalls.last.filter, isNull);
      expect(repo.findCalls.last.performerFilter, PerformerFilter.empty());
    },
  );

  test(
    'performer random stays server-backed when retries only return excluded id',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = _CapturingPerformerRepository()
        ..queuedResponses.addAll([
          [_loadedPerformer],
          const [_filteredPerformer],
          const [_filteredPerformer],
          const [_filteredPerformer],
        ]);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          performerRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(performerListProvider.future);

      final performer = await container
          .read(performerRandomNavigationControllerProvider)
          .getRandomPerformer(excludePerformerId: _filteredPerformer.id);

      expect(performer, isNull);
      expect(repo.findCalls.length, 4);
    },
  );
}
