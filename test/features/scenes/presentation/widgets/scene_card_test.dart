import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'server_base_url': 'http://localhost:9999',
    });
    prefs = await SharedPreferences.getInstance();
  });

  final defaultTestScene = Scene(
    id: 's1',
    title: 'Test Scene',
    date: DateTime(2024, 1, 1),
    rating100: 40,
    oCounter: 5,
    organized: true,
    interactive: false,
    resumeTime: null,
    playCount: 10,
    urls: [],
    files: [
      const SceneFile(
        format: 'mp4',
        duration: 3665.0, // 1 hour, 1 min, 5 secs -> 1:01:05
        videoCodec: 'h264',
        audioCodec: 'aac',
        width: 1920,
        height: 1080,
        frameRate: 30,
        bitRate: 5000,
      ),
    ],
    paths: const ScenePaths(
      screenshot: null,
      preview: null,
      stream: 'http://test.com/stream.mp4',
      vtt: 'http://test.com/sprites.vtt',
      sprite: 'http://test.com/sprites.jpg',
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

  Widget buildTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mediaHeadersProvider.overrideWithValue(const {}),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  testWidgets('SceneCard renders list mode properly', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: defaultTestScene, isGrid: false)),
    );

    await tester.pumpAndSettle();

    // Check title
    expect(find.text('Test Scene'), findsOneWidget);

    // Check studio and year
    expect(find.text('Test Studio • 2024'), findsOneWidget);

    // Check duration formatting
    expect(find.text('1:01:05'), findsOneWidget);
  });

  testWidgets('SceneCard renders grid mode properly', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: defaultTestScene, isGrid: true)),
    );

    await tester.pumpAndSettle();

    // Check title
    expect(find.text('Test Scene'), findsOneWidget);

    // Check studio without year
    expect(find.text('Test Studio'), findsOneWidget);

    // Check duration formatting
    expect(find.text('1:01:05'), findsOneWidget);
  });

  testWidgets('SceneCard handles missing duration gracefully', (tester) async {
    final sceneWithoutFiles = Scene(
      id: 's2',
      title: 'Scene No Files',
      date: DateTime(2023, 5, 5),
      rating100: 0,
      oCounter: 0,
      organized: false,
      interactive: false,
      resumeTime: null,
      playCount: 0,
      urls: [],
      files: [], // empty
      paths: const ScenePaths(screenshot: null, preview: null, stream: null),
      studioId: null,
      studioName: null,
      studioImagePath: null,
      performerIds: [],
      performerNames: [],
      performerImagePaths: [],
      tagIds: [],
      tagNames: [],
    );

    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: sceneWithoutFiles, isGrid: false)),
    );

    await tester.pumpAndSettle();

    expect(find.text('--:--'), findsOneWidget);
  });

  testWidgets('SceneCard handles missing studio gracefully in list mode', (
    tester,
  ) async {
    final sceneWithoutStudio = Scene(
      id: 's3',
      title: 'Scene No Studio',
      date: DateTime(2023, 5, 5),
      rating100: 0,
      oCounter: 0,
      organized: false,
      interactive: false,
      resumeTime: null,
      playCount: 0,
      urls: [],
      files: [], // empty
      paths: const ScenePaths(screenshot: null, preview: null, stream: null),
      studioId: null,
      studioName: null,
      studioImagePath: null,
      performerIds: [],
      performerNames: [],
      performerImagePaths: [],
      tagIds: [],
      tagNames: [],
    );

    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: sceneWithoutStudio, isGrid: false)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unknown • 2023'), findsOneWidget);
  });

  testWidgets('SceneCard handles missing studio gracefully in grid mode', (
    tester,
  ) async {
    final sceneWithoutStudio = Scene(
      id: 's4',
      title: 'Scene No Studio',
      date: DateTime(2023, 5, 5),
      rating100: 0,
      oCounter: 0,
      organized: false,
      interactive: false,
      resumeTime: null,
      playCount: 0,
      urls: [],
      files: [], // empty
      paths: const ScenePaths(screenshot: null, preview: null, stream: null),
      studioId: null,
      studioName: null,
      studioImagePath: null,
      performerIds: [],
      performerNames: [],
      performerImagePaths: [],
      tagIds: [],
      tagNames: [],
    );

    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: sceneWithoutStudio, isGrid: true)),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unknown'), findsOneWidget);
  });

  testWidgets('SceneCard triggers onTap when tapped', (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      buildTestWidget(
        SceneCard(
          scene: defaultTestScene,
          isGrid: false,
          onTap: () {
            tapped = true;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on the InkWell, but let's just tap the title text to be safe
    await tester.tap(find.text('Test Scene'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('SceneCard shows metadata overlay in list mode', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: defaultTestScene, isGrid: false)),
    );

    await tester.pumpAndSettle();

    // Check for water_drop_outlined and star icons in the overlay
    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    // Check values
    expect(find.text('5'), findsOneWidget); // oCounter
    expect(find.text('2.0'), findsOneWidget); // rating100: 40 -> 40/20 = 2.0
  });

  testWidgets('SceneCard shows metadata overlay in grid mode', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: defaultTestScene, isGrid: true)),
    );

    await tester.pumpAndSettle();

    // Check for water_drop_outlined and star icons in the overlay
    expect(find.byIcon(Icons.water_drop_outlined), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    // Check values
    expect(find.text('5'), findsOneWidget); // oCounter
    expect(find.text('2.0'), findsOneWidget); // rating100: 40 -> 40/20 = 2.0
  });

  testWidgets('SceneCard shows performer avatars when enabled', (tester) async {
    final sceneWithPerformers = defaultTestScene.copyWith(
      performerNames: ['Performer 1', 'Performer 2'],
      performerImagePaths: ['path/1', 'path/2'],
      performerIds: ['p1', 'p2'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          mediaHeadersProvider.overrideWithValue(const {}),
          showPerformerAvatarsProvider.overrideWithValue(true),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: SceneCard(scene: sceneWithPerformers, isGrid: false)),
        ),
      ),
    );

    await tester.pump();

    // Should find the Tooltips with performer names
    // Note: Icons.more_vert also uses Tooltip "More"
    expect(find.byType(Tooltip), findsNWidgets(3));

    // Check if CircleAvatar is present (one for each performer)
    expect(find.byType(CircleAvatar), findsNWidgets(2));
  });

  testWidgets('SceneCard hides performer avatars when disabled', (tester) async {
    final sceneWithPerformers = defaultTestScene.copyWith(
      performerNames: ['Performer 1', 'Performer 2'],
      performerImagePaths: ['path/1', 'path/2'],
      performerIds: ['p1', 'p2'],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          mediaHeadersProvider.overrideWithValue(const {}),
          showPerformerAvatarsProvider.overrideWithValue(false),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: SceneCard(scene: sceneWithPerformers, isGrid: false)),
        ),
      ),
    );

    await tester.pump();

    // Should only find 1 Tooltip (the "More" button)
    expect(find.byType(Tooltip), findsOneWidget);

    // Should not find any CircleAvatar
    expect(find.byType(CircleAvatar), findsNothing);
  });

  testWidgets('SceneCard uses dynamic aspect ratio when useMasonry is true', (
    tester,
  ) async {
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final portraitScene = defaultTestScene.copyWith(
      files: [
        const SceneFile(
          width: 1000,
          height: 2000, // 0.5 aspect ratio
          duration: 100,
          format: 'mp4',
          videoCodec: 'h264',
          audioCodec: 'aac',
          bitRate: 5000,
          frameRate: 30,
        ),
      ],
    );

    await tester.pumpWidget(
      buildTestWidget(
        Center(
          child: SizedBox(
            width: 200,
            child: SceneCard(scene: portraitScene, isGrid: true, useMasonry: true),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final aspectRatioWidget = tester.widget<AspectRatio>(
      find.byType(AspectRatio),
    );
    expect(aspectRatioWidget.aspectRatio, closeTo(0.5, 0.01));
  });

  testWidgets(
    'SceneCard uses fixed 16/9 aspect ratio when useMasonry is false in grid mode',
    (tester) async {
      final portraitScene = defaultTestScene.copyWith(
        files: [
          const SceneFile(
            width: 1000,
            height: 2000, // 0.5 aspect ratio
            duration: 100,
            format: 'mp4',
            videoCodec: 'h264',
            audioCodec: 'aac',
            bitRate: 5000,
            frameRate: 30,
          ),
        ],
      );

      await tester.pumpWidget(
        buildTestWidget(
          Center(
            child: SizedBox(
              width: 200,
              child: SceneCard(
                scene: portraitScene,
                isGrid: true,
                useMasonry: false,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final aspectRatioWidget = tester.widget<AspectRatio>(
        find.byType(AspectRatio),
      );
      expect(aspectRatioWidget.aspectRatio, closeTo(16 / 9, 0.01));
    },
  );

  testWidgets('SceneCard pan gesture is disabled when VTT is missing', (
    tester,
  ) async {
    final sceneNoVtt = defaultTestScene.copyWith(
      paths: defaultTestScene.paths.copyWith(vtt: null),
    );

    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: sceneNoVtt, isGrid: true)),
    );

    await tester.pumpAndSettle();

    final detectorFinder = find.descendant(
      of: find.byType(Hero),
      matching: find.byType(GestureDetector),
    );
    final detector = tester.widget<GestureDetector>(detectorFinder);

    expect(detector.onHorizontalDragStart, isNull);
    expect(detector.onHorizontalDragUpdate, isNull);
    expect(detector.onHorizontalDragEnd, isNull);
    expect(detector.onHorizontalDragCancel, isNull);
  });

  testWidgets('SceneCard pan gesture is enabled when VTT is present', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: defaultTestScene, isGrid: true)),
    );

    await tester.pumpAndSettle();

    final detectorFinder = find.descendant(
      of: find.byType(Hero),
      matching: find.byType(GestureDetector),
    );
    final detector = tester.widget<GestureDetector>(detectorFinder);

    expect(detector.onHorizontalDragStart, isNotNull);
    expect(detector.onHorizontalDragUpdate, isNotNull);
    expect(detector.onHorizontalDragEnd, isNotNull);
    expect(detector.onHorizontalDragCancel, isNotNull);
  });
}

