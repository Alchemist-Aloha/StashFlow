import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';

class MockSceneRepository extends Mock implements SceneRepository {}

class MockPlayer extends Mock implements Player {}

class MockVideoController extends Mock implements VideoController {
  @override
  Player get player => MockPlayer();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late Scene testScene;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
    );

    testScene = Scene(
      id: 'scene-1',
      title: 'Test Scene',
      details: null,
      path: null,
      date: DateTime.now(),
      rating100: null,
      oCounter: 0,
      organized: false,
      interactive: false,
      resumeTime: null,
      playCount: 0,
      playDuration: 0,
      files: const [],
      paths: const ScenePaths(screenshot: null, preview: null, stream: 'https://example.com'),
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
  });

  tearDown(() {
    container.dispose();
  });

  test('GlobalPlayerState initializes with default values', () {
    final state = GlobalPlayerState();
    
    expect(state.activeScene, isNull);
    expect(state.player, isNull);
    expect(state.videoController, isNull);
    expect(state.isPlaying, isFalse);
    expect(state.isFullScreen, isFalse);
    expect(state.isInPipMode, isFalse);
  });

  test('GlobalPlayerState copyWith updates fields', () {
    final state = GlobalPlayerState();
    
    final newState = state.copyWith(
      isPlaying: true,
      isFullScreen: true,
      streamMimeType: 'video/mp4',
    );
    
    expect(newState.isPlaying, isTrue);
    expect(newState.isFullScreen, isTrue);
    expect(newState.streamMimeType, equals('video/mp4'));
  });

  test('GlobalPlayerState copyWith clearActive clears active state', () {
    final state = GlobalPlayerState(
      activeScene: testScene,
      streamMimeType: 'video/mp4',
      streamLabel: 'Direct',
      streamSource: 'source1',
      playEndBehavior: VideoEndBehavior.next,
      );

      final newState = state.copyWith(clearActive: true);

      expect(newState.activeScene, isNull);
      expect(newState.streamMimeType, isNull);
      expect(newState.streamLabel, isNull);
      expect(newState.streamSource, isNull);
      // User preferences should remain
      expect(newState.playEndBehavior, VideoEndBehavior.next);
      });}
