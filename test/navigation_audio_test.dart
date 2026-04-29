import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_video_player.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

class MockStreamResolver extends StreamResolver {
  final Map<String, String> _streamMap;
  MockStreamResolver(this._streamMap);
  @override
  void build() {}

  @override
  Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
    return StreamChoice(url: _streamMap[scene.id]!, label: 'Direct', mimeType: 'video/mp4');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;

  setUpAll(() {
    MediaKit.ensureInitialized();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'server_base_url': 'http://localhost:9999',
    });
    prefs = await SharedPreferences.getInstance();
  });

  Scene createScene(String id) => Scene(
    id: id,
    title: 'Scene $id',
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
    paths: const ScenePaths(stream: 'http://test.com/stream.mp4', screenshot: null, preview: null),
    studioId: 'st1',
    studioName: 'Test Studio',
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );

  testWidgets('Audio initializes correctly for consecutive video navigations', (tester) async {
    final scene1 = createScene('s1');
    final scene2 = createScene('s2');
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        streamResolverProvider.overrideWith(() => MockStreamResolver({'s1': 'http://test.com/s1.mp4', 's2': 'http://test.com/s2.mp4'})),
        mediaHeadersProvider.overrideWithValue(const {}),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: ListView(children: [SceneVideoPlayer(scene: scene1), SceneVideoPlayer(scene: scene2)])),
        ),
      ),
    );

    // Play first video
    await tester.tap(find.byIcon(Icons.play_arrow_rounded).first);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify player is active for scene1
    final playerState1 = container.read(playerStateProvider);
    expect(playerState1.activeScene?.id, 's1');

    // Play second video
    await tester.tap(find.byIcon(Icons.play_arrow_rounded).last);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify player is active for scene2
    final playerState2 = container.read(playerStateProvider);
    expect(playerState2.activeScene?.id, 's2');

    // Check if player is initialized and playing
    expect(playerState2.player?.state.playing, isTrue);
  });
}
