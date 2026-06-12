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
    playDuration: 0,
    files: [],
    paths: const ScenePaths(screenshot: '', preview: '', stream: ''),
    urls: [],
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

    test('setIndex ignores negative and out-of-range indexes', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');
      container.read(playbackQueueProvider.notifier).setSequence([
        scene1,
        scene2,
      ], 0);

      container.read(playbackQueueProvider.notifier).setIndex(-1);
      expect(container.read(playbackQueueProvider).currentIndex, 0);

      container.read(playbackQueueProvider.notifier).setIndex(99);
      expect(container.read(playbackQueueProvider).currentIndex, 0);
    });

    test('findAndSetIndex updates index only when scene id exists', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');
      container.read(playbackQueueProvider.notifier).setSequence([
        scene1,
        scene2,
      ], 0);

      container.read(playbackQueueProvider.notifier).findAndSetIndex('2');
      expect(container.read(playbackQueueProvider).currentIndex, 1);

      container.read(playbackQueueProvider.notifier).findAndSetIndex('missing');
      expect(container.read(playbackQueueProvider).currentIndex, 1);
    });

    test('getPreviousScene and playPrevious handle boundaries', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');
      container.read(playbackQueueProvider.notifier).setSequence([
        scene1,
        scene2,
      ], 0);

      expect(
        container.read(playbackQueueProvider.notifier).getPreviousScene(),
        isNull,
      );

      container.read(playbackQueueProvider.notifier).playPrevious();
      expect(container.read(playbackQueueProvider).currentIndex, 0);

      container.read(playbackQueueProvider.notifier).setIndex(1);
      expect(
        container.read(playbackQueueProvider.notifier).getPreviousScene()?.id,
        '1',
      );

      container.read(playbackQueueProvider.notifier).playPrevious();
      expect(container.read(playbackQueueProvider).currentIndex, 0);
    });

    test('updateSequence appends items preserving existing order', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');
      final scene3 = mockScene(id: '3', title: 'S3');

      container.read(playbackQueueProvider.notifier).setSequence([scene1], 0);
      container.read(playbackQueueProvider.notifier).updateSequence([
        scene2,
        scene3,
      ]);

      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((s) => s.id).toList(), ['1', '2', '3']);
      expect(state.currentIndex, 0);
    });

    test('local queue activation preserves the main scene queue', () {
      final container = createContainer();
      final main1 = mockScene(id: 'main-1', title: 'Main 1');
      final main2 = mockScene(id: 'main-2', title: 'Main 2');
      final studio1 = mockScene(id: 'studio-1', title: 'Studio 1');
      final studio2 = mockScene(id: 'studio-2', title: 'Studio 2');

      final queue = container.read(playbackQueueProvider.notifier);

      queue.setSequence([main1, main2], 1, queueId: PlaybackQueueIds.main);
      expect(container.read(playbackQueueProvider).sequence, [main1, main2]);
      expect(container.read(playbackQueueProvider).currentIndex, 1);

      queue.setSequence(
        [studio1, studio2],
        0,
        queueId: 'scene:main-2:more-from-studio:s1',
      );

      var state = container.read(playbackQueueProvider);
      expect(state.sequence, [studio1, studio2]);
      expect(state.currentIndex, 0);
      expect(queue.getNextScene(), studio2);

      queue.setIndex(1, queueId: PlaybackQueueIds.main);

      state = container.read(playbackQueueProvider);
      expect(state.sequence, [main1, main2]);
      expect(state.currentIndex, 1);
    });

    test(
      'inactive main sequence refresh does not replace active local queue',
      () {
        final container = createContainer();
        final main1 = mockScene(id: 'main-1', title: 'Main 1');
        final main2 = mockScene(id: 'main-2', title: 'Main 2');
        final main3 = mockScene(id: 'main-3', title: 'Main 3');
        final studio1 = mockScene(id: 'studio-1', title: 'Studio 1');
        final studio2 = mockScene(id: 'studio-2', title: 'Studio 2');

        final queue = container.read(playbackQueueProvider.notifier);
        queue.setSequence([main1, main2], 0, queueId: PlaybackQueueIds.main);
        queue.setSequence([studio1, studio2], 1, queueId: 'studio:s1:strip');

        queue.setSequence(
          [main1, main2],
          -1,
          queueId: PlaybackQueueIds.main,
          activate: false,
        );
        queue.updateSequence([main3], queueId: PlaybackQueueIds.main);

        var state = container.read(playbackQueueProvider);
        expect(state.sequence, [studio1, studio2]);
        expect(state.currentIndex, 1);

        queue.setIndex(0, queueId: PlaybackQueueIds.main);

        state = container.read(playbackQueueProvider);
        expect(state.sequence, [main1, main2, main3]);
        expect(state.currentIndex, 0);
      },
    );

    test('removeScene removes deleted scene from every retained queue', () {
      final container = createContainer();
      final deleted = mockScene(id: 'deleted', title: 'Deleted');
      final main1 = mockScene(id: 'main-1', title: 'Main 1');
      final main3 = mockScene(id: 'main-3', title: 'Main 3');
      final local2 = mockScene(id: 'local-2', title: 'Local 2');

      final queue = container.read(playbackQueueProvider.notifier);
      queue.setSequence(
        [main1, deleted, main3],
        1,
        queueId: PlaybackQueueIds.main,
      );
      queue.setSequence([deleted, local2], 0, queueId: 'studio:s1:strip');
      queue.activateQueue(PlaybackQueueIds.main);

      queue.removeScene('deleted');

      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((scene) => scene.id), ['main-1', 'main-3']);
      expect(state.currentIndex, 0);

      final localQueue = state.queues['studio:s1:strip']!;
      expect(localQueue.sequence.map((scene) => scene.id), ['local-2']);
      expect(localQueue.currentIndex, 0);
    });

    test('removeScene clears current index when queue becomes empty', () {
      final container = createContainer();
      final deleted = mockScene(id: 'deleted', title: 'Deleted');

      final queue = container.read(playbackQueueProvider.notifier);
      queue.setSequence([deleted], 0);

      queue.removeScene('deleted');

      final state = container.read(playbackQueueProvider);
      expect(state.sequence, isEmpty);
      expect(state.currentIndex, -1);
    });

    test('removeScene is a no-op when scene id is not queued', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');

      final queue = container.read(playbackQueueProvider.notifier);
      queue.setSequence([scene1, scene2], 1);

      queue.removeScene('missing');

      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((scene) => scene.id), ['1', '2']);
      expect(state.currentIndex, 1);
    });

    test('removeScene shifts current index when deleting before current', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');
      final scene3 = mockScene(id: '3', title: 'S3');

      final queue = container.read(playbackQueueProvider.notifier);
      queue.setSequence([scene1, scene2, scene3], 2);

      queue.removeScene('1');

      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((scene) => scene.id), ['2', '3']);
      expect(state.currentIndex, 1);
    });

    test('removeScene preserves current index when deleting after current', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');
      final scene3 = mockScene(id: '3', title: 'S3');

      final queue = container.read(playbackQueueProvider.notifier);
      queue.setSequence([scene1, scene2, scene3], 0);

      queue.removeScene('3');

      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((scene) => scene.id), ['1', '2']);
      expect(state.currentIndex, 0);
    });

    test('removeScene selects next scene when deleting first current item', () {
      final container = createContainer();
      final scene1 = mockScene(id: '1', title: 'S1');
      final scene2 = mockScene(id: '2', title: 'S2');
      final scene3 = mockScene(id: '3', title: 'S3');

      final queue = container.read(playbackQueueProvider.notifier);
      queue.setSequence([scene1, scene2, scene3], 0);

      queue.removeScene('1');

      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((scene) => scene.id), ['2', '3']);
      expect(state.currentIndex, 0);
    });

    test('removeScene keeps index valid when duplicate ids are removed', () {
      final container = createContainer();
      final duplicate1 = mockScene(id: 'duplicate', title: 'Duplicate 1');
      final other = mockScene(id: 'other', title: 'Other');
      final duplicate2 = mockScene(id: 'duplicate', title: 'Duplicate 2');

      final queue = container.read(playbackQueueProvider.notifier);
      queue.setSequence([duplicate1, other, duplicate2], 2);

      queue.removeScene('duplicate');

      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((scene) => scene.id), ['other']);
      expect(state.currentIndex, 0);
    });

    test('removeScene preserves invalid current index for non-empty queue', () {
      final container = createContainer();
      final deleted = mockScene(id: 'deleted', title: 'Deleted');
      final remaining = mockScene(id: 'remaining', title: 'Remaining');

      final queue = container.read(playbackQueueProvider.notifier);
      queue.setSequence([deleted, remaining], -1);

      queue.removeScene('deleted');

      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((scene) => scene.id), ['remaining']);
      expect(state.currentIndex, -1);
    });
  });
}
