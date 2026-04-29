import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:media_kit/media_kit.dart' hide PlayerState;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/native_video_controls.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

class FakePlayer extends Mock implements Player {}

class FakeVideoController extends Mock implements VideoController {
  @override
  Player get player => FakePlayer();
}

void main() {
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

  await tester.pumpWidget(
    MaterialApp(
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
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}
