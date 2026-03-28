import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';

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
    urls: [],
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

void main() {
  group('PlaybackQueueState', () {
    test('initializes with default values', () {
      final state = PlaybackQueueState();

      expect(state.sequence, isEmpty);
      expect(state.currentIndex, -1);
    });

    test('initializes with provided values', () {
      final scene1 = mockScene(id: '1', title: 'Scene 1');
      final sequence = [scene1];
      final state = PlaybackQueueState(sequence: sequence, currentIndex: 0);

      expect(state.sequence, equals(sequence));
      expect(state.currentIndex, 0);
    });

    group('copyWith', () {
      test('returns same values when called without arguments', () {
        final scene1 = mockScene(id: '1', title: 'Scene 1');
        final sequence = [scene1];
        final state = PlaybackQueueState(sequence: sequence, currentIndex: 0);

        final newState = state.copyWith();

        expect(newState.sequence, equals(sequence));
        expect(newState.currentIndex, 0);
      });

      test('updates sequence while keeping currentIndex', () {
        final scene1 = mockScene(id: '1', title: 'Scene 1');
        final scene2 = mockScene(id: '2', title: 'Scene 2');
        final oldSequence = [scene1];
        final newSequence = [scene1, scene2];

        final state = PlaybackQueueState(sequence: oldSequence, currentIndex: 0);
        final newState = state.copyWith(sequence: newSequence);

        expect(newState.sequence, equals(newSequence));
        expect(newState.currentIndex, 0);
      });

      test('updates currentIndex while keeping sequence', () {
        final scene1 = mockScene(id: '1', title: 'Scene 1');
        final scene2 = mockScene(id: '2', title: 'Scene 2');
        final sequence = [scene1, scene2];

        final state = PlaybackQueueState(sequence: sequence, currentIndex: 0);
        final newState = state.copyWith(currentIndex: 1);

        expect(newState.sequence, equals(sequence));
        expect(newState.currentIndex, 1);
      });

      test('updates both sequence and currentIndex', () {
        final scene1 = mockScene(id: '1', title: 'Scene 1');
        final scene2 = mockScene(id: '2', title: 'Scene 2');
        final oldSequence = [scene1];
        final newSequence = [scene1, scene2];

        final state = PlaybackQueueState(sequence: oldSequence, currentIndex: 0);
        final newState = state.copyWith(sequence: newSequence, currentIndex: 1);

        expect(newState.sequence, equals(newSequence));
        expect(newState.currentIndex, 1);
      });
    });
  });
}
