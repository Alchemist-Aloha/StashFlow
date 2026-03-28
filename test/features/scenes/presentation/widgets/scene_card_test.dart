import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'server_base_url': 'http://localhost:9999'});
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
      )
    ],
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

  Widget buildTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mediaHeadersProvider.overrideWithValue(const {}),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  testWidgets('SceneCard renders list mode properly', (tester) async {
    await tester.pumpWidget(
      buildTestWidget(
        SceneCard(scene: defaultTestScene, isGrid: false),
      ),
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
      buildTestWidget(
        SceneCard(scene: defaultTestScene, isGrid: true),
      ),
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
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: null,
      ),
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
      buildTestWidget(
        SceneCard(scene: sceneWithoutFiles, isGrid: false),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('--:--'), findsOneWidget);
  });

  testWidgets('SceneCard handles missing studio gracefully in list mode', (tester) async {
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
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: null,
      ),
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
      buildTestWidget(
        SceneCard(scene: sceneWithoutStudio, isGrid: false),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unknown Studio • 2023'), findsOneWidget);
  });

  testWidgets('SceneCard handles missing studio gracefully in grid mode', (tester) async {
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
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: null,
      ),
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
      buildTestWidget(
        SceneCard(scene: sceneWithoutStudio, isGrid: true),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Unknown Studio'), findsOneWidget);
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
}
