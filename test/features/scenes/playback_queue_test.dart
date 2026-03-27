import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

Scene mockScene({required String id, required String title}) {
  return Scene(
    id: id,
    title: title,
    details: '',
    date: DateTime(2023),
    rating100: 0,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: 0.0,
    playCount: 0,
    files: [],
    paths: const ScenePaths(screenshot: '', preview: '', stream: ''),
    studioId: 's1',
    studioName: 'Studio 1',
    studioImagePath: '',
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );
}

class MockPlayerState extends PlayerState {
  @override
  GlobalPlayerState build() => GlobalPlayerState();
}

class MockSceneList extends SceneList {
  final List<Scene> initialScenes;
  MockSceneList(this.initialScenes);

  @override
  FutureOr<List<Scene>> build() => initialScenes;

  @override
  Future<void> fetchNextPage() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('PlaybackQueue', () {
    late SharedPreferences prefs;

    setUp(() async {
      prefs = await SharedPreferences.getInstance();
    });

    ProviderContainer createContainer({List<Scene> initialScenes = const []}) {
      return ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneListProvider.overrideWith(() => MockSceneList(initialScenes)),
          playerStateProvider.overrideWith(MockPlayerState.new),
        ],
      );
    }

    test('initial state is empty', () {
      final container = createContainer();
      final state = container.read(playbackQueueProvider);
      expect(state.sequence, isEmpty);
      expect(state.currentIndex, -1);
    });

    test('setSequence updates sequence and index', () {
      final container = createContainer();
      final scene = mockScene(id: '1', title: 'Scene 1');

      container.read(playbackQueueProvider.notifier).setSequence([scene], 0);
      final state = container.read(playbackQueueProvider);
      expect(state.sequence, [scene]);
      expect(state.currentIndex, 0);
    });

    test('setSequence preserves index if same list and index is -1', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');

      // Set initial sequence and index
      container.read(playbackQueueProvider.notifier).setSequence([scene1], 0);
      expect(container.read(playbackQueueProvider).currentIndex, 0);

      // Re-set same sequence with -1 (like SceneList build does)
      container.read(playbackQueueProvider.notifier).setSequence([scene1], -1);

      // Should STILL be 0
      expect(container.read(playbackQueueProvider).currentIndex, 0);
    });

    test('getNextScene returns next scene in sequence', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');

      container.read(playbackQueueProvider.notifier).setSequence([
        scene1,
        scene2,
      ], 0);

      final next = container
          .read(playbackQueueProvider.notifier)
          .getNextScene();
      expect(next?.id, '2');
    });

    test('playNext increments index', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');

      container.read(playbackQueueProvider.notifier).setSequence([
        scene1,
        scene2,
      ], 0);
      container.read(playbackQueueProvider.notifier).playNext();

      final state = container.read(playbackQueueProvider);
      expect(state.currentIndex, 1);
    });
  });
}
