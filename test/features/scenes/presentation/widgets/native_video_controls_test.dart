import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:mockito/mockito.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/native_video_controls.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

class FakePlayer extends Mock implements mk.Player {
  @override
  mk.PlayerStream get stream => MockPlayerStream();

  @override
  mk.PlayerState get state => mk.PlayerState();
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

  @override
  Stream<List<mk.AudioTrack>> get audioTracks => const Stream.empty();

  @override
  Stream<List<mk.VideoTrack>> get videoTracks => const Stream.empty();

  @override
  Stream<List<mk.SubtitleTrack>> get subtitleTracks => const Stream.empty();

  @override
  Stream<mk.AudioTrack> get audioTrack => const Stream.empty();

  @override
  Stream<mk.VideoTrack> get videoTrack => const Stream.empty();

  @override
  Stream<mk.SubtitleTrack> get subtitleTrack => const Stream.empty();

  @override
  Stream<List<String>> get subtitle => const Stream.empty();
}

class FakeVideoController extends Mock implements VideoController {
  @override
  mk.Player get player => FakePlayer();

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
}) async {
  final mockController = FakeVideoController();

  final mockPrefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
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
