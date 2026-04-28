import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';

import 'activity_tracking_test.mocks.dart';

@GenerateMocks([SceneRepository, VideoPlayerController])
class MockVideoPlayerPlatform extends VideoPlayerPlatform {
  @override
  Future<void> init() async {}
  @override
  Future<void> dispose(int textureId) async {}
  @override
  Future<int?> create(DataSource dataSource) async => 1;
  @override
  Future<void> setVolume(int textureId, double volume) async {}
}

class TestController extends VideoPlayerController {
  TestController() : super.networkUrl(Uri.parse('https://example.com'));

  VideoPlayerValue _value = const VideoPlayerValue(
    duration: Duration(seconds: 100),
    isInitialized: true,
  );

  @override
  VideoPlayerValue get value => _value;

  void updateValue(VideoPlayerValue newValue) {
    _value = newValue;
    notifyListeners();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> play() async {
    updateValue(_value.copyWith(isPlaying: true));
  }

  @override
  Future<void> pause() async {
    updateValue(_value.copyWith(isPlaying: false));
  }

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> dispose() async {
    // Don't call super.dispose() to avoid platform calls
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  VideoPlayerPlatform.instance = MockVideoPlayerPlatform();

  late MockSceneRepository mockRepo;
  late ProviderContainer container;
  late Scene testScene;

  setUp(() async {
    mockRepo = MockSceneRepository();
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
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

    // Default mock behavior
    when(mockRepo.incrementScenePlayCount(any)).thenAnswer((_) async {});
    when(mockRepo.saveSceneActivity(any,
            resumeTime: anyNamed('resumeTime'),
            playDuration: anyNamed('playDuration')))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    container.dispose();
  });

  test('increments play count after 5 seconds of playback', () {
    fakeAsync((async) {
      final controller = TestController();
      final notifier = container.read(playerStateProvider.notifier);

      // 1. Attach controller
      notifier.attachController(testScene, controller);
      
      // 2. Start playing
      controller.play();
      async.flushMicrotasks();

      // 3. Wait 4 seconds - should not call yet
      async.elapse(const Duration(seconds: 4));
      controller.updateValue(controller.value.copyWith(position: const Duration(seconds: 4)));
      async.flushMicrotasks();
      verifyNever(mockRepo.incrementScenePlayCount('scene-1'));

      // 4. Wait another 1.1 seconds (total > 5s)
      async.elapse(const Duration(milliseconds: 1100));
      controller.updateValue(controller.value.copyWith(position: const Duration(milliseconds: 5100)));
      async.flushMicrotasks();
      verify(mockRepo.incrementScenePlayCount('scene-1')).called(1);

      // 5. Wait more - should not call again
      async.elapse(const Duration(seconds: 10));
      verifyNoMoreInteractions(mockRepo);
    });
  });

  test('does not increment play count if playback is stopped before 5 seconds', () {
    fakeAsync((async) {
      final controller = TestController();
      final notifier = container.read(playerStateProvider.notifier);

      notifier.attachController(testScene, controller);
      controller.play();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 4));
      controller.updateValue(controller.value.copyWith(position: const Duration(seconds: 4)));
      async.flushMicrotasks();
      
      // Stop/Pause
      controller.pause();
      async.flushMicrotasks();

      // Wait more
      async.elapse(const Duration(seconds: 5));
      verifyNever(mockRepo.incrementScenePlayCount('scene-1'));
    });
  });

  test('periodically saves activity every 30 seconds', () {
    fakeAsync((async) {
      final controller = TestController();
      final notifier = container.read(playerStateProvider.notifier);

      notifier.attachController(testScene, controller);
      controller.play();
      async.flushMicrotasks();

      // 1. Wait 31 seconds
      async.elapse(const Duration(seconds: 31));
      controller.updateValue(controller.value.copyWith(position: const Duration(seconds: 31)));
      async.flushMicrotasks();
      
      // Periodic timer fires every 30s. At 31s it should have fired once.
      verify(mockRepo.saveSceneActivity('scene-1',
              resumeTime: anyNamed('resumeTime'),
              playDuration: argThat(greaterThan(29.0), named: 'playDuration')))
          .called(1);

      // 2. Wait another 30 seconds
      async.elapse(const Duration(seconds: 30));
      controller.updateValue(controller.value.copyWith(position: const Duration(seconds: 61)));
      async.flushMicrotasks();
      verify(mockRepo.saveSceneActivity('scene-1',
              resumeTime: anyNamed('resumeTime'),
              playDuration: argThat(greaterThan(29.0), named: 'playDuration')))
          .called(1);
    });
  });

  test('saves activity on pause', () {
    fakeAsync((async) {
      final controller = TestController();
      final notifier = container.read(playerStateProvider.notifier);

      notifier.attachController(testScene, controller);
      controller.play();
      async.flushMicrotasks();

      async.elapse(const Duration(seconds: 10));
      controller.updateValue(controller.value.copyWith(position: const Duration(seconds: 10)));
      async.flushMicrotasks();
      
      controller.pause();
      async.flushMicrotasks();

      verify(mockRepo.saveSceneActivity('scene-1',
              resumeTime: anyNamed('resumeTime'),
              playDuration: argThat(closeTo(10.0, 0.5), named: 'playDuration')))
          .called(1);
    });
  });

  test('accumulates duration correctly across multiple play/pause cycles', () {
    fakeAsync((async) {
      final controller = TestController();
      final notifier = container.read(playerStateProvider.notifier);

      notifier.attachController(testScene, controller);
      
      // Cycle 1: 10s
      controller.play();
      async.elapse(const Duration(seconds: 10));
      controller.updateValue(controller.value.copyWith(position: const Duration(seconds: 10)));
      async.flushMicrotasks();

      controller.pause();
      async.flushMicrotasks();
      
      verify(mockRepo.saveSceneActivity('scene-1',
              resumeTime: anyNamed('resumeTime'),
              playDuration: argThat(closeTo(10.0, 0.5), named: 'playDuration')))
          .called(1);

      // Cycle 2: 5s
      controller.play();
      async.elapse(const Duration(seconds: 5));
      controller.updateValue(controller.value.copyWith(position: const Duration(seconds: 15)));
      async.flushMicrotasks();

      controller.pause();
      async.flushMicrotasks();

      verify(mockRepo.saveSceneActivity('scene-1',
              resumeTime: anyNamed('resumeTime'),
              playDuration: argThat(closeTo(5.0, 0.5), named: 'playDuration')))
          .called(1);
    });
  });

  test('saves pending activity when switching scenes', () {
    fakeAsync((async) {
      final controller = TestController();
      final notifier = container.read(playerStateProvider.notifier);

      notifier.attachController(testScene, controller);
      controller.play();
      async.elapse(const Duration(seconds: 8));
      controller.updateValue(controller.value.copyWith(position: const Duration(seconds: 8)));
      async.flushMicrotasks();

      // Switch to another scene
      final scene2 = testScene.copyWith(id: 'scene-2');
      final controller2 = TestController();
      
      // attachController or playScene should trigger stop of old tracking
      notifier.attachController(scene2, controller2);
      async.flushMicrotasks();

      // Should save scene-1's pending 8s
      verify(mockRepo.saveSceneActivity('scene-1',
              resumeTime: anyNamed('resumeTime'),
              playDuration: argThat(closeTo(8.0, 0.5), named: 'playDuration')))
          .called(1);
      
      // Now play scene-2
      controller2.play();
      async.elapse(const Duration(seconds: 6));
      controller2.updateValue(controller2.value.copyWith(position: const Duration(seconds: 6)));
      async.flushMicrotasks();
      verify(mockRepo.incrementScenePlayCount('scene-2')).called(1);
    });
  });
}
