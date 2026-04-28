import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/sprite_info.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/utils/vtt_service.dart';

class MockVttService implements VttService {
  @override
  String? get apiKey => null;

  @override
  Future<List<SpriteInfo>?> fetchSpriteInfo(
    String vttUrl,
    Map<String, String>? headers,
  ) async {
    if (vttUrl.contains('sprites.vtt')) {
      return [
        const SpriteInfo(
          url: 'http://test.com/sprites.jpg',
          start: 0,
          end: 10,
          x: 0,
          y: 0,
          w: 100,
          h: 100,
        ),
      ];
    }
    return [];
  }
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
    playDuration: 0,
    urls: const [],
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
    performerIds: const [],
    performerNames: const [],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const [],
  );

  Widget buildTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mediaHeadersProvider.overrideWithValue(const {}),
        vttServiceProvider.overrideWithValue(MockVttService()),
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

    expect(find.text('Test Scene'), findsOneWidget);
  });

  testWidgets('SceneCard pan gesture is enabled when VTT is present', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: defaultTestScene, isGrid: true)),
    );

    // Initial pump
    await tester.pump();
    // Wait for _refreshSpriteAvailability to complete
    await tester.pump(Duration.zero);
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

  testWidgets('SceneCard pan gesture is disabled when VTT is absent', (
    tester,
  ) async {
    final noVttScene = defaultTestScene.copyWith(
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: 'http://test.com/stream.mp4',
        vtt: null,
        sprite: null,
      ),
    );

    await tester.pumpWidget(
      buildTestWidget(SceneCard(scene: noVttScene, isGrid: true)),
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
}
