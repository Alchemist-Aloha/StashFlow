import 'dart:async';
import 'dart:io';

import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_video_player.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/global_fullscreen_overlay.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_prewarmer.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/data/services/cast_service.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

class MockPlayerState extends PlayerState {
  static String? lastPlayedSceneId;
  static Scene? initialActiveScene;
  static int fullscreenEntryRequests = 0;

  @override
  GlobalPlayerState build() =>
      GlobalPlayerState(activeScene: initialActiveScene);

  @override
  Future<void> playScene(
    Scene scene,
    String streamUrl, {
    String? mimeType,
    String? streamLabel,
    String? streamSource,
    Map<String, String>? httpHeaders,
    bool? prewarmAttempted,
    bool? prewarmSucceeded,
    int? prewarmLatencyMs,
    Duration? initialPosition,
    bool force = false,
  }) async {
    lastPlayedSceneId = scene.id;
    state = state.copyWith(activeScene: scene, isPlaying: true);
  }

  @override
  void requestEnterFullscreen() {
    fullscreenEntryRequests++;
    super.requestEnterFullscreen();
  }
}

class _DelayedPlayerState extends MockPlayerState {
  final startupGate = Completer<void>();

  @override
  Future<void> playScene(
    Scene scene,
    String streamUrl, {
    String? mimeType,
    String? streamLabel,
    String? streamSource,
    Map<String, String>? httpHeaders,
    bool? prewarmAttempted,
    bool? prewarmSucceeded,
    int? prewarmLatencyMs,
    Duration? initialPosition,
    bool force = false,
  }) async {
    MockPlayerState.lastPlayedSceneId = scene.id;
    state = state.copyWith(activeScene: scene, isPlaying: true);
    await startupGate.future;
  }
}

Future<StreamChoice?> mockNullStreamResolver(Scene scene) async => null;

Future<StreamChoice?> mockStreamResolver(Scene scene) async =>
    const StreamChoice(
      url: 'http://test.com/stream.mp4',
      mimeType: 'video/mp4',
      label: 'direct',
    );

class MockStreamPrewarmer extends StreamPrewarmer {
  @override
  void build() {}

  @override
  Future<void> prewarm(
    Scene scene,
    String url, {
    Map<String, String>? headers,
    int rangeBytes = 10 * 1024 * 1024,
  }) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'server_base_url': 'http://localhost:9999',
    });
    prefs = await SharedPreferences.getInstance();
    MockPlayerState.initialActiveScene = null;
    MockPlayerState.fullscreenEntryRequests = 0;
  });

  final testScene = Scene(
    id: 's1',
    title: 'Test Scene',
    date: DateTime(2024, 1, 1),
    rating100: 40,
    oCounter: 5,
    organized: true,
    interactive: false,
    resumeTime: null,
    playCount: 10,
    playDuration: 0,
    files: [],
    urls: [],
    paths: const ScenePaths(
      screenshot: null,
      preview: null,
      stream: 'http://test.com/stream.mp4',
    ),
    studioId: 'st1',
    studioName: 'Test Studio',
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );

  testWidgets('SceneVideoPlayer renders initial placeholder with play button', (
    tester,
  ) async {
    MockPlayerState.lastPlayedSceneId = null;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          playerStateProvider.overrideWith(MockPlayerState.new),
          streamResolverProvider.overrideWithValue(mockNullStreamResolver),
          streamPrewarmerProvider.overrideWith(MockStreamPrewarmer.new),
          mediaHeadersProvider.overrideWithValue(const {}),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: SceneVideoPlayer(scene: testScene)),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(find.byType(AspectRatio), findsWidgets);
    expect(find.byType(Container), findsWidgets);

    // The play button should be visible since this scene is not active.
    final iconFinder = find.byIcon(Icons.play_arrow_rounded);
    expect(iconFinder, findsOneWidget);
    expect(
      find.ancestor(of: iconFinder, matching: find.byType(IconButton)),
      findsOneWidget,
    );
  });

  testWidgets('SceneVideoPlayer auto-starts when mount autoplay is forced', (
    tester,
  ) async {
    MockPlayerState.lastPlayedSceneId = null;
    final autoplayScene = Scene(
      id: 's2',
      title: 'Autoplay Scene',
      date: DateTime(2024, 1, 2),
      rating100: 40,
      oCounter: 5,
      organized: true,
      interactive: false,
      resumeTime: null,
      playCount: 10,
      playDuration: 0,
      files: [],
      urls: [],
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: 'http://test.com/stream.mp4',
      ),
      studioId: 'st1',
      studioName: 'Test Studio',
      studioImagePath: null,
      performerIds: [],
      performerNames: [],
      performerImagePaths: [],
      tagIds: [],
      tagNames: [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          playerStateProvider.overrideWith(MockPlayerState.new),
          streamResolverProvider.overrideWithValue(mockStreamResolver),
          streamPrewarmerProvider.overrideWith(MockStreamPrewarmer.new),
          mediaHeadersProvider.overrideWithValue(const {}),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SceneVideoPlayer(scene: autoplayScene, autoPlayOnMount: true),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));

    expect(MockPlayerState.lastPlayedSceneId, autoplayScene.id);
    expect(MockPlayerState.fullscreenEntryRequests, 0);
  });

  testWidgets('preferred fullscreen opens while playback is still starting', (
    tester,
  ) async {
    MockPlayerState.lastPlayedSceneId = null;
    final playerState = _DelayedPlayerState();
    await prefs.setBool(
      PlayerSettingsStore.enterFullscreenOnNavigationKey,
      true,
    );
    final router = GoRouter(
      initialLocation: '/scenes/scene/s1',
      routes: [
        GoRoute(
          path: '/scenes/scene/:id',
          builder: (context, state) => Scaffold(
            body: Stack(
              children: [
                SceneVideoPlayer(scene: testScene, autoPlayOnMount: true),
                const Positioned.fill(child: GlobalFullscreenOverlay()),
              ],
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          playerStateProvider.overrideWith(() => playerState),
          streamResolverProvider.overrideWithValue(mockStreamResolver),
          streamPrewarmerProvider.overrideWith(MockStreamPrewarmer.new),
          mediaHeadersProvider.overrideWithValue(const {}),
        ],
        child: MaterialApp.router(
          theme: AppTheme.darkTheme,
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SceneVideoPlayer)),
    );
    expect(MockPlayerState.lastPlayedSceneId, testScene.id);
    expect(MockPlayerState.fullscreenEntryRequests, 1);
    expect(container.read(playerStateProvider).isFullScreen, isTrue);
    expect(
      find.byKey(const ValueKey('global_fullscreen_overlay_slide')),
      findsOneWidget,
    );

    playerState.startupGate.complete();
    await tester.pump();

    final notifier = container.read(playerStateProvider.notifier);
    notifier.requestExitFullscreen();
    notifier.markFullscreenExited();
    await tester.pump();

    expect(container.read(playerStateProvider).isFullScreen, isFalse);
    expect(MockPlayerState.fullscreenEntryRequests, 1);
  });

  testWidgets('preferred fullscreen does not affect details-only navigation', (
    tester,
  ) async {
    MockPlayerState.initialActiveScene = testScene;
    await prefs.setBool(
      PlayerSettingsStore.enterFullscreenOnNavigationKey,
      true,
    );
    final router = GoRouter(
      initialLocation: '/scenes/scene/s1',
      routes: [
        GoRoute(
          path: '/scenes/scene/:id',
          builder: (context, state) =>
              Scaffold(body: SceneVideoPlayer(scene: testScene)),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          playerStateProvider.overrideWith(MockPlayerState.new),
          streamResolverProvider.overrideWithValue(mockStreamResolver),
          streamPrewarmerProvider.overrideWith(MockStreamPrewarmer.new),
          mediaHeadersProvider.overrideWithValue(const {}),
        ],
        child: MaterialApp.router(
          theme: AppTheme.darkTheme,
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(MockPlayerState.fullscreenEntryRequests, 0);
  });

  testWidgets('top-level scene alias always starts the navigated scene', (
    tester,
  ) async {
    MockPlayerState.lastPlayedSceneId = null;
    MockPlayerState.initialActiveScene = testScene;
    await prefs.setBool('video_direct_play_on_navigation', false);
    final targetScene = testScene.copyWith(id: 's2', title: 'Target Scene');
    final router = GoRouter(
      initialLocation: '/scene/s2',
      routes: [
        GoRoute(
          path: '/scene/:id',
          builder: (context, state) =>
              Scaffold(body: SceneVideoPlayer(scene: targetScene)),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          playerStateProvider.overrideWith(MockPlayerState.new),
          streamResolverProvider.overrideWithValue(mockStreamResolver),
          streamPrewarmerProvider.overrideWith(MockStreamPrewarmer.new),
          mediaHeadersProvider.overrideWithValue(const {}),
        ],
        child: MaterialApp.router(
          theme: AppTheme.darkTheme,
          routerConfig: router,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(MockPlayerState.lastPlayedSceneId, targetScene.id);
  });

  testWidgets('forced scene switch restarts active cast on the same session', (
    tester,
  ) async {
    MockPlayerState.lastPlayedSceneId = null;
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        playerStateProvider.overrideWith(MockPlayerState.new),
        streamResolverProvider.overrideWithValue(mockStreamResolver),
        streamPrewarmerProvider.overrideWith(MockStreamPrewarmer.new),
        mediaHeadersProvider.overrideWithValue(const {}),
        castServiceProvider.overrideWith(_FakeAppCastService.new),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SceneVideoPlayer(scene: testScene, autoPlayOnMount: true),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final castService =
        container.read(castServiceProvider.notifier) as _FakeAppCastService;

    expect(MockPlayerState.lastPlayedSceneId, testScene.id);
    expect(castService.restartCalls, 1);
    expect(castService.lastMedia?.url, 'http://test.com/stream.mp4');
  });
}

class _FakeAppCastService extends AppCastService {
  int restartCalls = 0;
  dc.CastMedia? lastMedia;

  @override
  CastState build() {
    return CastState(isCasting: true, activeSession: _FakeCastSession());
  }

  @override
  Future<void> restartActiveSessionWithMedia(
    dc.CastMedia media, {
    Duration localResumePosition = Duration.zero,
    bool localWasPlaying = false,
  }) async {
    restartCalls++;
    lastMedia = media;
  }
}

class _FakeCastSession extends dc.CastSession {
  _FakeCastSession()
    : super(
        dc.CastDevice(
          id: 'fake',
          name: 'Fake Cast',
          protocol: dc.CastProtocol.airplay,
          address: InternetAddress.loopbackIPv4,
          port: 8009,
        ),
      );

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> loadMedia(dc.CastMedia media) async {}

  @override
  Future<void> pause() async {}

  @override
  Future<void> play() async {}

  @override
  Future<void> seek(Duration position) async {}

  @override
  Future<void> setSubtitle(dc.CastSubtitle? subtitle) async {}

  @override
  Future<void> setVolume(double volume) async {}

  @override
  Future<void> stop() async {}
}
