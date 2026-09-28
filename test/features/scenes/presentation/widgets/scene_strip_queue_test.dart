import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';

Scene _scene(String id, String title) {
  return Scene(
    id: id,
    title: title,
    date: DateTime(2024, 1, 1),
    rating100: 0,
    oCounter: 0,
    organized: true,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    playDuration: 0,
    files: const [],
    paths: const ScenePaths(screenshot: null, preview: null, stream: null),
    urls: const [],
    studioId: 'studio-1',
    studioName: 'Studio',
    studioImagePath: null,
    performerIds: const [],
    performerNames: const [],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const [],
  );
}

void main() {
  testWidgets('SceneStrip disables SceneCard VTT scrubbing on Android', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'server_base_url': 'http://localhost:9999',
    });
    final prefs = await SharedPreferences.getInstance();
    final scene = _scene('scene-1', 'Scene 1').copyWith(
      files: const [
        SceneFile(
          format: null,
          width: null,
          height: null,
          videoCodec: null,
          audioCodec: null,
          bitRate: null,
          duration: 60,
          frameRate: null,
        ),
      ],
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: null,
        vtt: 'http://test.com/sprites.vtt',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          home: Scaffold(body: SceneStrip(scenes: [scene])),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final detector = tester.widget<GestureDetector>(
      find.descendant(
        of: find.byType(AspectRatio),
        matching: find.byType(GestureDetector),
      ),
    );
    expect(detector.onHorizontalDragStart, isNull);
    expect(detector.onHorizontalDragUpdate, isNull);
    expect(detector.onHorizontalDragEnd, isNull);
    expect(detector.onHorizontalDragCancel, isNull);
  });

  for (final scale in [0.8, 1.0, 1.5]) {
    testWidgets(
      'SceneStrip scrollbar stays at the bottom with an inset at scale $scale',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'server_base_url': 'http://localhost:9999',
        });
        final prefs = await SharedPreferences.getInstance();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(
              theme:
                  AppTheme.buildTheme(
                    Brightness.light,
                    Colors.teal,
                    fontSizeFactor: scale,
                  ).copyWith(
                    scrollbarTheme: const ScrollbarThemeData(
                      thickness: WidgetStatePropertyAll(12),
                    ),
                  ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(padding: const EdgeInsets.only(bottom: 66)),
                    child: SceneStrip(
                      scenes: List.generate(
                        12,
                        (index) => _scene('scene-$index', 'Scene $index'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar));
        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(scrollbar.controller, same(listView.controller));
        expect(scrollbar.interactive, isTrue);

        final bounds = tester.getRect(find.byType(Scrollbar));
        final gesture = await tester.startGesture(
          Offset(bounds.left + 20, bounds.bottom - 6),
          kind: PointerDeviceKind.mouse,
        );
        await gesture.moveBy(const Offset(200, 0));
        await gesture.up();
        await tester.pumpAndSettle();

        expect(listView.controller!.offset, greaterThan(0));
      },
    );
  }

  testWidgets(
    'SceneStrip activates a contextual queue for its displayed list',
    (tester) async {
      final mainScene = _scene('main-1', 'Main Scene');
      final relatedOne = _scene('related-1', 'Related One');
      final relatedTwo = _scene('related-2', 'Related Two');
      final selected = <String>[];
      SharedPreferences.setMockInitialValues({
        'server_base_url': 'http://localhost:9999',
      });
      final prefs = await SharedPreferences.getInstance();

      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  container = ProviderScope.containerOf(context);
                  return SceneStrip(
                    scenes: [relatedOne, relatedTwo],
                    queueId: 'scene:main-1:more-from-studio:studio-1',
                    onTap: (scene) => selected.add(scene.id),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      container
          .read(playbackQueueProvider.notifier)
          .setSequence([mainScene], 0, queueId: PlaybackQueueIds.main);

      await tester.tap(find.byType(SceneCard).at(1));
      await tester.pump();

      expect(selected, ['related-2']);
      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((scene) => scene.id), [
        'related-1',
        'related-2',
      ]);
      expect(state.currentIndex, 1);

      container
          .read(playbackQueueProvider.notifier)
          .setIndex(0, queueId: PlaybackQueueIds.main);

      final mainState = container.read(playbackQueueProvider);
      expect(mainState.sequence.map((scene) => scene.id), ['main-1']);
      expect(mainState.currentIndex, 0);
    },
  );
}
