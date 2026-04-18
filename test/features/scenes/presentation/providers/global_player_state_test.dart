import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';

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
  group('GlobalPlayerState', () {
    test('initializes with default values', () {
      final state = GlobalPlayerState();

      expect(state.activeScene, isNull);
      expect(state.videoPlayerController, isNull);
      expect(state.isPlaying, isFalse);
      expect(state.isFullScreen, isFalse);
      expect(state.isInPipMode, isFalse);
      expect(state.streamMimeType, isNull);
      expect(state.streamLabel, isNull);
      expect(state.streamSource, isNull);
      expect(state.startupLatencyMs, isNull);
      expect(state.prewarmAttempted, isNull);
      expect(state.prewarmSucceeded, isNull);
      expect(state.prewarmLatencyMs, isNull);
      expect(state.autoplayNext, isFalse);
      expect(state.showVideoDebugInfo, isFalse);
      expect(state.useDoubleTapSeek, isTrue);
      expect(state.enableBackgroundPlayback, isFalse);
      expect(state.enableNativePip, isFalse);
      expect(state.videoGravityOrientation, isTrue);
      expect(state.subtitleTextAlignment, equals('center'));
    });

    test('initializes with provided values', () {
      final scene = mockScene(id: '1', title: 'Scene 1');
      final state = GlobalPlayerState(
        activeScene: scene,
        isPlaying: true,
        isFullScreen: true,
        isInPipMode: true,
        streamMimeType: 'video/mp4',
        streamLabel: 'Direct',
        streamSource: 'source1',
        startupLatencyMs: 100,
        prewarmAttempted: true,
        prewarmSucceeded: true,
        prewarmLatencyMs: 50,
        autoplayNext: true,
        showVideoDebugInfo: true,
        useDoubleTapSeek: false,
        enableBackgroundPlayback: true,
        enableNativePip: true,
        videoGravityOrientation: false,
      );

      expect(state.activeScene, equals(scene));
      expect(state.isPlaying, isTrue);
      expect(state.isFullScreen, isTrue);
      expect(state.isInPipMode, isTrue);
      expect(state.streamMimeType, equals('video/mp4'));
      expect(state.streamLabel, equals('Direct'));
      expect(state.streamSource, equals('source1'));
      expect(state.startupLatencyMs, equals(100));
      expect(state.prewarmAttempted, isTrue);
      expect(state.prewarmSucceeded, isTrue);
      expect(state.prewarmLatencyMs, equals(50));
      expect(state.autoplayNext, isTrue);
      expect(state.showVideoDebugInfo, isTrue);
      expect(state.useDoubleTapSeek, isFalse);
      expect(state.enableBackgroundPlayback, isTrue);
      expect(state.enableNativePip, isTrue);
      expect(state.videoGravityOrientation, isFalse);
    });

    group('copyWith', () {
      test('returns same values when called without arguments', () {
        final scene = mockScene(id: '1', title: 'Scene 1');
        final state = GlobalPlayerState(
          activeScene: scene,
          isPlaying: true,
          streamMimeType: 'video/mp4',
          autoplayNext: true,
        );

        final newState = state.copyWith();

        expect(newState.activeScene, equals(scene));
        expect(newState.isPlaying, isTrue);
        expect(newState.streamMimeType, equals('video/mp4'));
        expect(newState.autoplayNext, isTrue);
      });

      test('updates specified values', () {
        final state = GlobalPlayerState(isPlaying: false, isFullScreen: false);

        final newState = state.copyWith(
          isPlaying: true,
          isFullScreen: true,
          streamMimeType: 'video/webm',
          subtitleTextAlignment: 'left',
        );

        expect(newState.isPlaying, isTrue);
        expect(newState.isFullScreen, isTrue);
        expect(newState.streamMimeType, equals('video/webm'));
        expect(newState.subtitleTextAlignment, equals('left'));
      });

      test('clears active values when clearActive is true', () {
        final scene = mockScene(id: '1', title: 'Scene 1');
        final state = GlobalPlayerState(
          activeScene: scene,
          isPlaying: true,
          streamMimeType: 'video/mp4',
          streamLabel: 'Direct',
          streamSource: 'source1',
          startupLatencyMs: 100,
          prewarmAttempted: true,
          prewarmSucceeded: true,
          prewarmLatencyMs: 50,
          autoplayNext: true, // Should remain true
        );

        final newState = state.copyWith(clearActive: true);

        // Cleared fields
        expect(newState.activeScene, isNull);
        expect(newState.videoPlayerController, isNull);
        expect(newState.streamMimeType, isNull);
        expect(newState.streamLabel, isNull);
        expect(newState.streamSource, isNull);
        expect(newState.startupLatencyMs, isNull);
        expect(newState.prewarmAttempted, isNull);
        expect(newState.prewarmSucceeded, isNull);
        expect(newState.prewarmLatencyMs, isNull);

        // Retained fields
        expect(newState.isPlaying, isTrue);
        expect(newState.autoplayNext, isTrue);
      });
    });
  });
}
