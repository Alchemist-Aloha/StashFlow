import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
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

class _DelayedPageRepository extends MockGraphQLSceneRepository {
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
    return Future.value([_scene(filter == 'new' ? 'new' : 'initial')]);
  }
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

  test('scene list ignores an old next page after a search rebuild', () async {
    final prefs = await SharedPreferences.getInstance();
    final repository = _DelayedPageRepository();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(sceneListProvider.future);
    final notifier = container.read(sceneListProvider.notifier);
    final oldRequest = notifier.fetchNextPage();

    container.read(sceneSearchQueryProvider.notifier).update('new');
    expect(
      (await container.read(sceneListProvider.future)).map((scene) => scene.id),
      ['new'],
    );

    repository.nextPage.complete([_scene('stale')]);
    await oldRequest;

    expect(
      container.read(sceneListProvider).requireValue.map((scene) => scene.id),
      ['new'],
    );
    expect(notifier.isLoadingMore, isFalse);
  });
}
