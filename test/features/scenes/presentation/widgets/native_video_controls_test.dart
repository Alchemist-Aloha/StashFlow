import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/native_video_controls.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/video_controls/video_progress_bar.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

class FakePlayer extends Mock implements mk.Player {
  FakePlayer({this.isPlaying = false});

  final bool isPlaying;

  @override
  mk.PlayerStream get stream => MockPlayerStream();

  @override
  mk.PlayerState get state => mk.PlayerState(playing: isPlaying);
}

class MockPlayerStream extends Fake implements mk.PlayerStream {
  @override
  Stream<bool> get playing => const Stream.empty();

  @override
  Stream<bool> get completed => const Stream.empty();

  @override
  Stream<Duration> get position => const Stream.empty();

  @override
  Stream<Duration> get duration => const Stream.empty();

  @override
  Stream<double> get volume => const Stream.empty();

  @override
  Stream<double> get rate => const Stream.empty();

  @override
  Stream<int> get width => const Stream.empty();

  @override
  Stream<int> get height => const Stream.empty();

  @override
  Stream<bool> get buffering => const Stream.empty();

  @override
  Stream<mk.Playlist> get playlist => const Stream.empty();

  @override
  Stream<mk.AudioParams> get audioParams => const Stream.empty();

  @override
  Stream<mk.VideoParams> get videoParams => const Stream.empty();

  Stream<List<mk.AudioTrack>> get audioTracks => const Stream.empty();

  Stream<List<mk.VideoTrack>> get videoTracks => const Stream.empty();

  Stream<List<mk.SubtitleTrack>> get subtitleTracks => const Stream.empty();

  Stream<mk.AudioTrack> get audioTrack => const Stream.empty();

  Stream<mk.VideoTrack> get videoTrack => const Stream.empty();

  Stream<mk.SubtitleTrack> get subtitleTrack => const Stream.empty();

  @override
  Stream<List<String>> get subtitle => const Stream.empty();
}

class FakeVideoController extends Mock implements VideoController {
  FakeVideoController({this.isPlaying = false});

  final bool isPlaying;

  @override
  mk.Player get player => FakePlayer(isPlaying: isPlaying);

  @override
  ValueNotifier<PlatformVideoController?> get notifier => ValueNotifier(null);

  @override
  Future<void> get waitUntilFirstFrameRendered async {}
}

void main() {
  setUpAll(() {
    mk.MediaKit.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('renders controls normally', (tester) async {
    final scene = _buildScene();
    await _pumpControls(tester, scene: scene);

    expect(find.byType(NativeVideoControls), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
  });

  testWidgets('can render without visible controls', (tester) async {
    final scene = _buildScene();
    await _pumpControls(tester, scene: scene, showControls: false);

    expect(find.byType(NativeVideoControls), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
    expect(find.byType(VideoProgressBar), findsNothing);
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

  testWidgets('hides subtitle button when only vtt path is present', (
    tester,
  ) async {
    final scene = _buildScene(captions: const [], vttPath: '/api/vtt');
    await _pumpControls(tester, scene: scene);

    expect(find.byIcon(Icons.subtitles_rounded), findsNothing);
  });

  testWidgets(
    'hides subtitle button when only caption endpoint exists but no vtt/metadata',
    (tester) async {
      final scene = _buildScene(
        captions: const [],
        captionPath: '/api/caption',
      );
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
    final scene = _buildScene(
      captions: const [VideoCaption(languageCode: 'en', captionType: 'srt')],
      vttPath: '/api/vtt',
    );
    await _pumpControls(tester, scene: scene);

    await tester.tap(find.byIcon(Icons.subtitles_rounded));
    await tester.pumpAndSettle();

    expect(find.text('None'), findsOneWidget);
  });

  testWidgets('marks Unknown (srt) as selected for 00/srt selection', (
    tester,
  ) async {
    final scene = _buildScene(
      captions: const [VideoCaption(languageCode: '00', captionType: 'srt')],
      captionPath: null,
    );
    await _pumpControls(tester, scene: scene);

    await tester.tap(find.byIcon(Icons.subtitles_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Unknown (srt)'), findsOneWidget);
  });

  testWidgets('inline back control follows video controls visibility', (
    tester,
  ) async {
    var backPressed = false;

    await _pumpControls(
      tester,
      scene: _buildScene(),
      isPlaying: true,
      onInlineBack: () => backPressed = true,
    );

    expect(find.byKey(const Key('inline_video_back_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('inline_video_back_button')));
    await tester.pump();

    expect(backPressed, isTrue);

    await tester.pump(const Duration(milliseconds: 1100));

    expect(
      find.byKey(const Key('inline_video_back_button')).hitTestable(),
      findsNothing,
    );
  });

  testWidgets('renders grey top gradient behind inline back row', (
    tester,
  ) async {
    await _pumpControls(tester, scene: _buildScene(), onInlineBack: () {});

    expect(find.byKey(const Key('inline_video_top_gradient')), findsOneWidget);
  });

  testWidgets('renders grey top gradient behind fullscreen back row', (
    tester,
  ) async {
    await _pumpControls(
      tester,
      scene: _buildScene(),
      onFullScreenToggle: () {},
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NativeVideoControls)),
    );
    container.read(playerStateProvider.notifier).setFullScreen(true);
    await tester.pump();

    expect(
      find.byKey(const Key('fullscreen_video_top_gradient')),
      findsOneWidget,
    );
  });

  testWidgets('fullscreen controls render and trigger the random scene button', (
    tester,
  ) async {
    var randomPressed = false;

    await _pumpControls(
      tester,
      scene: _buildScene(),
      onFullScreenToggle: () {},
      onRandomScene: () => randomPressed = true,
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(NativeVideoControls)),
    );
    container.read(playerStateProvider.notifier).setFullScreen(true);
    await tester.pump();

    final randomButton = find.byKey(
      const Key('fullscreen_random_scene_button'),
    );
    expect(randomButton, findsOneWidget);

    await tester.tap(randomButton);
    await tester.pump();

    expect(randomPressed, isTrue);
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
    playDuration: 0,
    files: const [],
    urls: const [],
    captions: captions,
    paths: ScenePaths(
      screenshot: null,
      preview: null,
      stream: null,
      caption: captionPath,
      vtt: vttPath,
      sprite: null,
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
  bool showControls = true,
  bool isPlaying = false,
  VoidCallback? onInlineBack,
  VoidCallback? onFullScreenToggle,
  VoidCallback? onRandomScene,
}) async {
  final mockController = FakeVideoController(isPlaying: isPlaying);

  final mockPrefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(mockPrefs)],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(
          body: NativeVideoControls(
            controller: mockController,
            useDoubleTapSeek: true,
            enableNativePip: false,
            onInlineBack: onInlineBack,
            onFullScreenToggle: onFullScreenToggle,
            onRandomScene: onRandomScene,
            showControls: showControls,
            scene: scene,
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}
