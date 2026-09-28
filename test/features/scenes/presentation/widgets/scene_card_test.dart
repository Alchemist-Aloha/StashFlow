import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/sprite_info.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/utils/vtt_service.dart';

class MockVttService implements VttService {
  MockVttService({this.hasSprites = true, this.fetchResult});

  final bool hasSprites;
  final Future<List<SpriteInfo>?>? fetchResult;
  int fetchCount = 0;

  @override
  String? get apiKey => null;

  @override
  Future<List<SpriteInfo>?> fetchSpriteInfo(
    String vttUrl,
    Map<String, String>? headers,
  ) async {
    fetchCount++;
    final pendingResult = fetchResult;
    if (pendingResult != null) {
      return pendingResult;
    }
    if (hasSprites && vttUrl.contains('sprites.vtt')) {
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

  Widget buildTestWidget(Widget child, {VttService? vttService}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        mediaHeadersProvider.overrideWithValue(const {}),
        vttServiceProvider.overrideWithValue(vttService ?? MockVttService()),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  Scene videoScene({required int width, required int height}) {
    return defaultTestScene.copyWith(
      files: [
        defaultTestScene.files.first.copyWith(width: width, height: height),
      ],
      paths: defaultTestScene.paths.copyWith(
        screenshot: 'http://test.com/thumbnail.jpg',
      ),
    );
  }

  Future<ui.Image> createTestImage(int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      Paint()..color = Colors.blue,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    picture.dispose();
    return image;
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

  testWidgets('square video thumbnail keeps native square layout bounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        SizedBox(
          width: 200,
          child: SceneCard(
            scene: videoScene(width: 1080, height: 1080),
            isGrid: true,
            useHero: false,
          ),
        ),
      ),
    );

    final imageFinder = find.byType(StashImage);
    final image = tester.widget<StashImage>(imageFinder);
    expect(image.frameBuilder, isNotNull);

    final aspectRatioFinder = find.descendant(
      of: find.byType(SceneCard),
      matching: find.byType(AspectRatio),
    );
    expect(tester.widget<AspectRatio>(aspectRatioFinder).aspectRatio, 1);
    expect(tester.getSize(aspectRatioFinder), const Size(200, 200));
  });

  testWidgets('square decoded cover stretches vertically within its bounds', (
    tester,
  ) async {
    final image = await tester.runAsync(() => createTestImage(64, 64));
    expect(image, isNotNull);
    addTearDown(image!.dispose);

    await tester.pumpWidget(
      buildTestWidget(
        SizedBox(
          width: 200,
          child: SceneCard(
            scene: videoScene(width: 1080, height: 1080),
            isGrid: true,
            useHero: false,
          ),
        ),
      ),
    );

    final stashImage = tester.widget<StashImage>(find.byType(StashImage));
    final child = RawImage(image: image);
    final transformed = stashImage.frameBuilder!(
      tester.element(find.byType(StashImage)),
      child,
      1,
      false,
    );

    await tester.pumpWidget(
      buildTestWidget(SizedBox(width: 200, height: 200, child: transformed)),
    );

    expect(tester.getSize(find.byType(SizedBox).first), const Size(200, 200));
    expect(tester.getSize(find.byType(ClipRect)), const Size(200, 200));
    final transformFinder = find.byWidgetPredicate(
      (widget) => widget is Transform && widget.transform.storage[5] == 2,
    );
    expect(tester.getSize(transformFinder), const Size(200, 200));
    final transform = tester.widget<Transform>(transformFinder);
    expect(transform.transform.storage[5], 2);

    final clipBox = tester.renderObject<RenderBox>(find.byType(ClipRect));
    final rawImageBox = tester.renderObject<RenderBox>(find.byType(RawImage));
    final paintedTopLeft = rawImageBox.localToGlobal(
      Offset.zero,
      ancestor: clipBox,
    );
    final paintedBottomRight = rawImageBox.localToGlobal(
      const Offset(200, 200),
      ancestor: clipBox,
    );
    expect(paintedTopLeft.dy, -100);
    expect(paintedBottomRight.dy, 300);
    expect(paintedTopLeft.dx, 0);
    expect(paintedBottomRight.dx, 200);
  });

  testWidgets('square video leaves a decoded rectangular cover unchanged', (
    tester,
  ) async {
    final image = await tester.runAsync(() => createTestImage(80, 40));
    expect(image, isNotNull);
    addTearDown(image!.dispose);

    await tester.pumpWidget(
      buildTestWidget(
        SizedBox(
          width: 200,
          child: SceneCard(
            scene: videoScene(width: 1080, height: 1080),
            isGrid: true,
            useHero: false,
          ),
        ),
      ),
    );

    final stashImage = tester.widget<StashImage>(find.byType(StashImage));
    final child = RawImage(image: image);
    final result = stashImage.frameBuilder!(
      tester.element(find.byType(StashImage)),
      child,
      1,
      false,
    );

    expect(identical(result, child), isTrue);
  });

  testWidgets('non-square video does not install a thumbnail frame builder', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(
        SizedBox(
          width: 200,
          child: SceneCard(
            scene: videoScene(width: 1920, height: 1080),
            isGrid: true,
            useHero: false,
          ),
        ),
      ),
    );

    final image = tester.widget<StashImage>(find.byType(StashImage));
    expect(image.frameBuilder, isNull);
  });

  testWidgets('SceneCard pan gesture is enabled when VTT is present', (
    tester,
  ) async {
    final vttService = MockVttService();
    await tester.pumpWidget(
      buildTestWidget(
        SceneCard(scene: defaultTestScene, isGrid: true),
        vttService: vttService,
      ),
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
    expect(vttService.fetchCount, 0);

    final gesture = await tester.startGesture(tester.getCenter(detectorFinder));
    await gesture.moveBy(const Offset(30, 0));
    await tester.pump();

    expect(vttService.fetchCount, 1);
    await gesture.up();
    await tester.pump();
  });

  testWidgets('SceneCard uses VTT cues without requiring paths.sprite', (
    tester,
  ) async {
    final vttService = MockVttService();
    final sceneWithoutSpritePath = defaultTestScene.copyWith(
      paths: defaultTestScene.paths.copyWith(sprite: null),
    );

    await tester.pumpWidget(
      buildTestWidget(
        SceneCard(scene: sceneWithoutSpritePath, isGrid: true),
        vttService: vttService,
      ),
    );
    await tester.pumpAndSettle();

    final detectorFinder = find.descendant(
      of: find.byType(Hero),
      matching: find.byType(GestureDetector),
    );
    final detector = tester.widget<GestureDetector>(detectorFinder);

    expect(detector.onHorizontalDragStart, isNotNull);
    expect(vttService.fetchCount, 0);
  });

  testWidgets('SceneCard stops probing after VTT is unavailable', (
    tester,
  ) async {
    final vttService = MockVttService(hasSprites: false);
    await tester.pumpWidget(
      buildTestWidget(
        SceneCard(scene: defaultTestScene, isGrid: true),
        vttService: vttService,
      ),
    );
    await tester.pumpAndSettle();

    final detectorFinder = find.descendant(
      of: find.byType(Hero),
      matching: find.byType(GestureDetector),
    );
    final firstGesture = await tester.startGesture(
      tester.getCenter(detectorFinder),
    );
    await firstGesture.moveBy(const Offset(30, 0));
    await tester.pump();
    await tester.pump();
    await firstGesture.up();
    await tester.pump();

    expect(vttService.fetchCount, 1);
    final detector = tester.widget<GestureDetector>(detectorFinder);
    expect(detector.onHorizontalDragStart, isNull);
  });

  testWidgets(
    'SceneCard does not show scrub time before VTT availability is verified',
    (tester) async {
      final vttCompleter = Completer<List<SpriteInfo>?>();
      final vttService = MockVttService(fetchResult: vttCompleter.future);

      await tester.pumpWidget(
        buildTestWidget(
          SceneCard(scene: defaultTestScene, isGrid: true),
          vttService: vttService,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('1:01:05'), findsOneWidget);

      final detectorFinder = find.descendant(
        of: find.byType(Hero),
        matching: find.byType(GestureDetector),
      );
      final gesture = await tester.startGesture(
        tester.getCenter(detectorFinder),
      );
      await gesture.moveBy(const Offset(30, 0));
      await tester.pump();

      expect(vttService.fetchCount, 1);
      expect(find.text('1:01:05'), findsOneWidget);
      expect(find.text('0:00'), findsNothing);

      vttCompleter.complete([]);
      await tester.pump();
      await tester.pump();

      expect(find.text('1:01:05'), findsOneWidget);
      final detector = tester.widget<GestureDetector>(detectorFinder);
      expect(detector.onHorizontalDragStart, isNull);

      await gesture.up();
      await tester.pump();
    },
  );

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
