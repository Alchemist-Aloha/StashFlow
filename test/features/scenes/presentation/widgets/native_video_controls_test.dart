import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/native_video_controls.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:async';

class FakeVideoPlayerPlatform extends VideoPlayerPlatform
    with MockPlatformInterfaceMixin {
  final Completer<bool> initialized = Completer<bool>();
  final List<String> calls = <String>[];

  @override
  Future<void> init() async {
    calls.add('init');
    initialized.complete(true);
  }

  @override
  Future<void> dispose(int textureId) async {
    calls.add('dispose');
  }

  @override
  Future<int?> create(DataSource dataSource) async {
    calls.add('create');
    return 1;
  }

  @override
  Future<void> setLooping(int textureId, bool looping) async {
    calls.add('setLooping');
  }

  @override
  Future<void> play(int textureId) async {
    calls.add('play');
  }

  @override
  Future<void> pause(int textureId) async {
    calls.add('pause');
  }

  @override
  Future<void> setVolume(int textureId, double volume) async {
    calls.add('setVolume');
  }

  @override
  Future<void> setPlaybackSpeed(int textureId, double speed) async {
    calls.add('setPlaybackSpeed');
  }

  @override
  Future<void> seekTo(int textureId, Duration position) async {
    calls.add('seekTo');
  }

  @override
  Future<Duration> getPosition(int textureId) async {
    calls.add('getPosition');
    return const Duration(seconds: 0);
  }

  @override
  Stream<VideoEvent> videoEventsFor(int textureId) {
    return Stream<VideoEvent>.fromIterable(<VideoEvent>[
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 10),
        size: const Size(100, 100),
      ),
    ]);
  }

  @override
  Widget buildView(int textureId) {
    return Texture(textureId: textureId);
  }
}

void main() {
  final testScene = Scene(
    id: 'test_scene_id',
    title: 'Test Scene',
    date: DateTime.now(),
    rating100: 0,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    files: [],
    paths: const ScenePaths(screenshot: null, preview: null, stream: null),
    studioId: '',
    studioName: '',
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );

  setUp(() {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  testWidgets('NativeVideoControls instantiation test', (tester) async {
    final mockController = VideoPlayerController.networkUrl(Uri.parse('http://example.com/video.mp4'));
    await mockController.initialize();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerStateProvider.overrideWith(() => _MockPlayerStateNotifier(testScene)),
          playbackQueueProvider.overrideWith(() => _MockPlaybackQueueNotifier()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: NativeVideoControls(
              controller: mockController,
              useDoubleTapSeek: true,
              enableNativePip: false,
              scene: testScene,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(NativeVideoControls), findsOneWidget);
  });
}

class _MockPlayerStateNotifier extends PlayerState {
  final Scene activeScene;
  _MockPlayerStateNotifier(this.activeScene);

  @override
  GlobalPlayerState build() => GlobalPlayerState(activeScene: activeScene);
}

class _MockPlaybackQueueNotifier extends PlaybackQueue {
  @override
  PlaybackQueueState build() => PlaybackQueueState();
}
