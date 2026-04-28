import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'prefer_scene_streams': false,
      'server_base_url': 'http://localhost:9999',
    });
    prefs = await SharedPreferences.getInstance();
  });

  final testScene = Scene(
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
    files: [],
    paths: const ScenePaths(
      screenshot: null,
      preview: null,
      stream: 'http://test.com/stream.mp4',
    ),
    urls: [],
    studioId: 'st1',
    studioName: 'Test Studio',
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );

  testWidgets('SceneDetailsPage renders scene info', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Test Scene'), findsOneWidget);
    expect(find.text('Test Studio'), findsOneWidget);
  });

  testWidgets('SceneDetailsPage updates rating', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    final starIcons = find.byWidgetPredicate(
      (widget) =>
          widget is Icon && widget.icon == Icons.star && widget.size == 28,
    );
    final borderIcons = find.byWidgetPredicate(
      (widget) =>
          widget is Icon &&
          widget.icon == Icons.star_border &&
          widget.size == 28,
    );

    expect(starIcons, findsNWidgets(2));
    expect(borderIcons, findsNWidgets(3));

    await tester.tap(borderIcons.first);
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('SceneDetailsPage increments O count', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.water_drop_outlined));
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('SceneCard three-dot opens scene info page', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: Scaffold(body: SceneCard(scene: testScene, isGrid: false)),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pump(const Duration(milliseconds: 500));

    final l10n = AppLocalizations.of(tester.element(find.byType(SceneCard)))!;
    expect(find.text(l10n.details_scene), findsOneWidget);
  });

  test(
    'shouldRouteToNextScene supports transient null active scene transitions',
    () {
      final nextScene = Scene(
        id: 's2',
        title: 'Next Scene',
        date: DateTime(2024, 1, 2),
        rating100: 60,
        oCounter: 2,
        organized: true,
        interactive: false,
        resumeTime: null,
        playCount: 1,
        playDuration: 0,
        files: [],
        paths: const ScenePaths(
          screenshot: null,
          preview: null,
          stream: 'http://test.com/stream2.mp4',
        ),
        urls: [],
        studioId: 'st1',
        studioName: 'Test Studio',
        studioImagePath: null,
        performerIds: [],
        performerNames: [],
        performerImagePaths: [],
        tagIds: [],
        tagNames: [],
      );

      expect(shouldRouteToNextScene('s1', testScene, 's1', nextScene), isTrue);
      expect(shouldRouteToNextScene('s1', null, 's1', nextScene), isTrue);
      expect(shouldRouteToNextScene('s1', testScene, 's1', testScene), isFalse);
      expect(shouldRouteToNextScene('s1', testScene, 's1', null), isFalse);
    },
  );
}
