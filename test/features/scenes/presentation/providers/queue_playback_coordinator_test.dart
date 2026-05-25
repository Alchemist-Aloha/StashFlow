import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/queue_playback_coordinator.dart';

Scene _scene(String id) {
  return Scene(
    id: id,
    title: 'Scene $id',
    details: '',
    date: DateTime(2023),
    rating100: 0,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: 0.0,
    playCount: 0,
    playDuration: 0,
    files: const [],
    paths: const ScenePaths(screenshot: '', preview: '', stream: ''),
    urls: const [],
    studioId: 's1',
    studioName: 'Studio 1',
    studioImagePath: '',
    performerIds: const [],
    performerNames: const [],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const [],
  );
}

void main() {
  group('QueuePlaybackCoordinator', () {
    const coordinator = QueuePlaybackCoordinator();

    test('findTarget returns next scene and index', () {
      final scenes = [_scene('1'), _scene('2'), _scene('3')];
      final state = PlaybackQueueState(sequence: scenes, currentIndex: 0);

      final target = coordinator.findTarget(
        queueState: state,
        direction: QueueAdvanceDirection.next,
      );

      expect(target?.scene.id, '2');
      expect(target?.targetIndex, 1);
    });

    test(
      'findTarget resolves index from active scene when current index invalid',
      () {
        final scenes = [_scene('1'), _scene('2'), _scene('3')];
        final state = PlaybackQueueState(sequence: scenes, currentIndex: -1);

        final target = coordinator.findTarget(
          queueState: state,
          direction: QueueAdvanceDirection.next,
          activeSceneId: '2',
        );

        expect(target?.scene.id, '3');
        expect(target?.targetIndex, 2);
      },
    );

    test('findTarget returns null when target would be out of bounds', () {
      final scenes = [_scene('1'), _scene('2')];
      final state = PlaybackQueueState(sequence: scenes, currentIndex: 1);

      final target = coordinator.findTarget(
        queueState: state,
        direction: QueueAdvanceDirection.next,
      );

      expect(target, isNull);
    });
  });
}
