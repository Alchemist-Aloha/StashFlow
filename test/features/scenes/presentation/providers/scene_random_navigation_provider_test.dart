import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_random_navigation_provider.dart';

import '../../../../helpers/test_helpers.dart';

Scene _scene(String id) {
  return Scene(
    id: id,
    title: 'Scene $id',
    date: DateTime(2024, 1, 1),
    rating100: null,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: 0,
    playCount: 0,
    playDuration: 0,
    files: const [],
    paths: const ScenePaths(screenshot: '', preview: '', stream: ''),
    urls: const [],
    studioId: null,
    studioName: null,
    studioImagePath: null,
    performerIds: const [],
    performerNames: const [],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'scene random controller forwards the preference and exclusion id',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = MockGraphQLSceneRepository()
        ..findScenesResponses.addAll([
          [_scene('listed')],
          [_scene('random-a')],
        ]);

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      container.read(sceneSearchQueryProvider.notifier).update('tag:demo');
      container
          .read(sceneFilterStateProvider.notifier)
          .update(const SceneFilter(organized: true));

      final scene = await container
          .read(sceneRandomNavigationControllerProvider)
          .getRandomScene(excludeSceneId: 'current');

      expect(scene?.id, 'random-a');
      expect(repo.findSceneCalls.last.filter, 'tag:demo');
      expect(repo.findSceneCalls.last.sort, 'random');
    },
  );

  test('scene random controller can ignore active filters', () async {
    SharedPreferences.setMockInitialValues({
      'scene_random_respect_active_filter': false,
    });
    final prefs = await SharedPreferences.getInstance();
    final repo = MockGraphQLSceneRepository()
      ..findScenesResponses.addAll([
        [_scene('listed')],
        [_scene('random-b')],
      ]);

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    container.read(sceneSearchQueryProvider.notifier).update('filtered');
    container
        .read(sceneFilterStateProvider.notifier)
        .update(const SceneFilter(organized: true));

    await container
        .read(sceneRandomNavigationControllerProvider)
        .getRandomScene();

    expect(repo.findSceneCalls.last.filter, isNull);
    expect(repo.findSceneCalls.last.sceneFilter, SceneFilter.empty());
  });
}
