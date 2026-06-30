import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';

import '../../../../helpers/test_helpers.dart';

final _testGraphQLSceneRepositoryProvider =
    NotifierProvider<_TestGraphQLSceneRepository, GraphQLSceneRepository>(
      _TestGraphQLSceneRepository.new,
    );

class _TestGraphQLSceneRepository extends Notifier<GraphQLSceneRepository> {
  @override
  GraphQLSceneRepository build() => MockGraphQLSceneRepository();
}

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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('scene list rebuilds when the repository dependency changes', () async {
    final prefs = await SharedPreferences.getInstance();
    final firstRepo = MockGraphQLSceneRepository()..setData([_scene('old')]);
    final secondRepo = MockGraphQLSceneRepository()..setData([_scene('new')]);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWith(
          (ref) => ref.watch(_testGraphQLSceneRepositoryProvider),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(_testGraphQLSceneRepositoryProvider.notifier).state =
        firstRepo;

    expect(
      (await container.read(sceneListProvider.future)).map((scene) => scene.id),
      ['old'],
    );

    container.read(_testGraphQLSceneRepositoryProvider.notifier).state =
        secondRepo;

    expect(
      (await container.read(sceneListProvider.future)).map((scene) => scene.id),
      ['new'],
    );
  });
}
