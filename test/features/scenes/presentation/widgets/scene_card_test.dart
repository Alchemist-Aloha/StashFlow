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
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_playback_position_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/providers/layout_settings_provider.dart';
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

  for (final layout in ['list', 'grid', 'masonry']) {
    testWidgets('SceneCard shows saved progress below $layout thumbnail', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(
          SizedBox(
            width: 240,
            child: SceneCard(
              scene: defaultTestScene.copyWith(resumeTime: 916.25),
              isGrid: layout != 'list',
              useMasonry: layout == 'masonry',
            ),
          ),
        ),
      );

      final progress = find.byType(LinearProgressIndicator);
      expect(tester.widget<LinearProgressIndicator>(progress).value, 0.25);
      final frame = find.byType(AspectRatio);
      expect(tester.getRect(progress).top, tester.getRect(frame).bottom);
      expect(tester.getSize(progress).height, 4);
      expect(tester.getSize(progress).width, tester.getSize(frame).width);
      final semanticsData = tester.getSemantics(progress).getSemanticsData();
      expect(semanticsData.label, contains('Playback progress'));
      expect(semanticsData.value, '25');
      expect(tester.takeException(), isNull);
    });
  }

  for (final sample in [
    (resume: null, duration: 100.0, expected: null),
    (resume: 0.0, duration: 100.0, expected: null),
    (resume: -10.0, duration: 100.0, expected: null),
    (resume: double.nan, duration: 100.0, expected: null),
    (resume: double.infinity, duration: 100.0, expected: null),
    (resume: 20.0, duration: null, expected: null),
    (resume: 20.0, duration: 0.0, expected: null),
    (resume: 20.0, duration: -100.0, expected: null),
    (resume: 20.0, duration: double.nan, expected: null),
    (resume: 20.0, duration: double.infinity, expected: null),
    (resume: 100.0, duration: 100.0, expected: 1.0),
    (resume: 120.0, duration: 100.0, expected: 1.0),
  ]) {
    testWidgets('SceneCard handles playback data $sample', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          SceneCard(
            scene: defaultTestScene.copyWith(
              resumeTime: sample.resume,
              files: [
                defaultTestScene.files.first.copyWith(
                  duration: sample.duration,
                ),
              ],
            ),
            isGrid: true,
          ),
        ),
      );

      final progress = find.byType(LinearProgressIndicator);
      if (sample.expected == null) {
        expect(progress, findsNothing);
      } else {
        expect(
          tester.widget<LinearProgressIndicator>(progress).value,
          sample.expected,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'SceneCard hides playback progress with no files or while loading',
    (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          SceneCard(
            scene: defaultTestScene.copyWith(resumeTime: 20, files: []),
            isGrid: true,
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);

      await tester.pumpWidget(
        buildTestWidget(
          SceneCard(
            scene: defaultTestScene.copyWith(resumeTime: 20),
            isGrid: true,
            skeletonize: true,
          ),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsNothing);
    },
  );

  testWidgets('SceneCard reacts to progress updates and the persisted toggle', (
    tester,
  ) async {
    await prefs.setBool('show_scene_playback_progress', false);
    await tester.pumpWidget(
      buildTestWidget(
        SceneCard(
          scene: defaultTestScene.copyWith(resumeTime: 20),
          isGrid: true,
        ),
      ),
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SceneCard)),
    );
    await container.read(showScenePlaybackProgressProvider.notifier).set(true);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(prefs.getBool('show_scene_playback_progress'), isTrue);

    await tester.pumpWidget(
      buildTestWidget(
        SceneCard(
          scene: defaultTestScene.copyWith(resumeTime: 1832.5),
          isGrid: true,
        ),
      ),
    );
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      0.5,
    );

    await container.read(showScenePlaybackProgressProvider.notifier).set(false);
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(prefs.getBool('show_scene_playback_progress'), isFalse);
  });

  for (final isGrid in [false, true]) {
    testWidgets(
      'SceneCard follows live positions without rebuilding its image (grid: $isGrid)',
      (tester) async {
        final scene = defaultTestScene.copyWith(
          resumeTime: 10,
          files: [defaultTestScene.files.first.copyWith(duration: 100)],
        );
        final card = SizedBox(
          width: 240,
          child: SceneCard(scene: scene, isGrid: isGrid),
        );
        await tester.pumpWidget(buildTestWidget(card));
        final container = ProviderScope.containerOf(
          tester.element(find.byType(SceneCard)),
        );
        expect(container.exists(playerStateProvider), isFalse);
        final image = tester.widget<StashImage>(find.byType(StashImage));
        final position = container.read(
          scenePlaybackPositionProvider(scene.id).notifier,
        );
        position.update(const Duration(seconds: 60));
        await tester.pump();
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .value,
          0.6,
        );
        expect(tester.widget<StashImage>(find.byType(StashImage)), same(image));

        // A seek to the start must override the old saved resume point.
        position.update(Duration.zero);
        await tester.pump();
        expect(find.byType(LinearProgressIndicator), findsNothing);
        position.update(const Duration(seconds: 25));
        await tester.pump();

        // Simulate leaving and returning to the list with stale server data.
        await tester.pumpWidget(buildTestWidget(const SizedBox.shrink()));
        await tester.pump();
        await tester.pumpWidget(buildTestWidget(card));
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .value,
          0.25,
        );
        expect(container.exists(playerStateProvider), isFalse);
        expect(tester.takeException(), isNull);
      },
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
