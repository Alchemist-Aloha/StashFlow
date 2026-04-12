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
  final List<String> calls = <String>[];

  @override
  Future<void> init() async {
    calls.add('init');
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
    return const SizedBox.shrink();
  }
}

void main() {
  setUp(() {
    VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();
  });

  testWidgets('renders controls normally', (tester) async {
    final scene = _buildScene();
    await _pumpControls(tester, scene: scene);

    expect(find.byType(NativeVideoControls), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets(
    'hides subtitle button when no captions and caption path is null',
    (tester) async {
      final scene = _buildScene(captions: const [], captionPath: null);
      await _pumpControls(tester, scene: scene);

      expect(find.byIcon(Icons.subtitles_rounded), findsNothing);
    },
  );

  testWidgets(
    'hides subtitle button when no captions and caption path is empty',
    (tester) async {
      final scene = _buildScene(captions: const [], captionPath: '   ');
      await _pumpControls(tester, scene: scene);

      expect(find.byIcon(Icons.subtitles_rounded), findsNothing);
    },
  );

  testWidgets(
    'shows subtitle button and Default option when vtt path is present',
    (tester) async {
      final scene = _buildScene(captions: const [], vttPath: '/api/vtt');
      await _pumpControls(tester, scene: scene);

      expect(find.byIcon(Icons.subtitles_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.subtitles_rounded));
      await tester.pumpAndSettle();

      expect(find.text('None'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
    },
  );

  testWidgets(
    'hides subtitle button when only caption endpoint exists but no vtt/metadata',
    (tester) async {
      final scene = _buildScene(captions: const [], captionPath: '/api/caption');
      await _pumpControls(tester, scene: scene);

      expect(find.byIcon(Icons.subtitles_rounded), findsNothing);
    },
  );

  testWidgets(
    'does not show Default option when captions metadata exists but vtt path is empty',
    (tester) async {
      final scene = _buildScene(
        captions: const [VideoCaption(languageCode: 'en', captionType: 'srt')],
        vttPath: ' ',
      );
      await _pumpControls(tester, scene: scene);

      expect(find.byIcon(Icons.subtitles_rounded), findsOneWidget);

      await tester.tap(find.byIcon(Icons.subtitles_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsNothing);
      expect(find.text('EN (srt)'), findsOneWidget);
    },
  );

  testWidgets('marks None as selected when subtitle language is null', (
    tester,
  ) async {
    final scene = _buildScene(captions: const [], vttPath: '/api/vtt');
    await _pumpControls(
      tester,
      scene: scene,
      playerState: GlobalPlayerState(
        activeScene: scene,
        selectedSubtitleLanguage: null,
        selectedSubtitleType: null,
      ),
    );

    await tester.tap(find.byIcon(Icons.subtitles_rounded));
    await tester.pumpAndSettle();

    final noneRow = find.ancestor(of: find.text('None'), matching: find.byType(Row));
    expect(
      find.descendant(of: noneRow, matching: find.byIcon(Icons.check_circle)),
      findsOneWidget,
    );
  });

  testWidgets('marks Unknown (srt) as selected for 00/srt selection', (
    tester,
  ) async {
    final scene = _buildScene(
      captions: const [VideoCaption(languageCode: '00', captionType: 'srt')],
      captionPath: null,
    );
    await _pumpControls(
      tester,
      scene: scene,
      playerState: GlobalPlayerState(
        activeScene: scene,
        selectedSubtitleLanguage: '00',
        selectedSubtitleType: 'srt',
      ),
    );

    await tester.tap(find.byIcon(Icons.subtitles_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Unknown (srt)'), findsOneWidget);
    final unknownRow = find.ancestor(
      of: find.text('Unknown (srt)'),
      matching: find.byType(Row),
    );
    expect(
      find.descendant(of: unknownRow, matching: find.byIcon(Icons.check_circle)),
      findsOneWidget,
    );
  });
}

Scene _buildScene({
  List<VideoCaption> captions = const [],
  String? captionPath,
  String? vttPath,
}) {
  return Scene(
    id: 'test_scene_id',
    title: 'Test Scene',
    date: DateTime(2025, 1, 1),
    rating100: 0,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    files: const [],
    urls: const [],
    captions: captions,
    paths: ScenePaths(
      screenshot: null,
      preview: null,
      stream: null,
      caption: captionPath,
      vtt: vttPath,
    ),
    studioId: '',
    studioName: '',
    studioImagePath: null,
    performerIds: const [],
    performerNames: const [],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const [],
  );
}

Future<void> _pumpControls(
  WidgetTester tester, {
  required Scene scene,
  GlobalPlayerState? playerState,
}) async {
  final mockController = VideoPlayerController.networkUrl(
    Uri.parse('http://example.com/video.mp4'),
  );
  addTearDown(mockController.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        playerStateProvider.overrideWith(
          () => _MockPlayerStateNotifier(
            playerState ?? GlobalPlayerState(activeScene: scene),
          ),
        ),
        playbackQueueProvider.overrideWith(
          () => _MockPlaybackQueueNotifier(),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: NativeVideoControls(
            controller: mockController,
            useDoubleTapSeek: true,
            enableNativePip: false,
            scene: scene,
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

class _MockPlayerStateNotifier extends PlayerState {
  _MockPlayerStateNotifier(this.mockState);
  final GlobalPlayerState mockState;

  @override
  GlobalPlayerState build() => mockState;
}

class _MockPlaybackQueueNotifier extends PlaybackQueue {
  @override
  PlaybackQueueState build() => PlaybackQueueState();
}
