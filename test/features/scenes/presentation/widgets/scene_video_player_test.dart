import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_video_player.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_prewarmer.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

class MockPlayerState extends PlayerState {
  static String? lastPlayedSceneId;

  @override
  GlobalPlayerState build() => GlobalPlayerState();

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
}

class MockStreamResolverNull extends StreamResolver {
  @override
  void build() {}

  @override
  Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
    return Future.value(null);
  }
}

class MockStreamResolverChoice extends StreamResolver {
  @override
  void build() {}

  @override
  Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
    return Future.value(
      const StreamChoice(
        url: 'http://test.com/stream.mp4',
        mimeType: 'video/mp4',
        label: 'direct',
      ),
    );
  }
}

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
          streamResolverProvider.overrideWith(MockStreamResolverNull.new),
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
          streamResolverProvider.overrideWith(MockStreamResolverChoice.new),
          streamPrewarmerProvider.overrideWith(MockStreamPrewarmer.new),
          mediaHeadersProvider.overrideWithValue(const {}),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SceneVideoPlayer(
              scene: autoplayScene,
              autoPlayOnMount: true,
            ),
          ),
        ),
      ),
    );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 10));

    expect(MockPlayerState.lastPlayedSceneId, autoplayScene.id);
  });
}
