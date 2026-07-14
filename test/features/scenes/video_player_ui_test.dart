import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_video_player.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
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

  Scene sceneWithoutStudio(String id, String title) {
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
      files: [],
      paths: ScenePaths(
        screenshot: null,
        preview: null,
        stream: 'http://test.com/$id.mp4',
      ),
      urls: const [],
      studioId: null,
      studioName: null,
      studioImagePath: null,
      performerIds: const [],
      performerNames: const [],
      performerImagePaths: const [],
      tagIds: const [],
      tagNames: const [],
    );
  }

  testWidgets('SceneDetailsPage renders scene info', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Test Scene'), findsOneWidget);
    expect(find.text('Test Studio'), findsOneWidget);
    expect(find.byKey(const Key('scene_header_metadata')), findsNothing);
    expect(find.byKey(const Key('scene_show_metadata')), findsOneWidget);
    expect(
      tester
          .widget<TextButton>(find.byKey(const Key('scene_show_metadata')))
          .style
          ?.foregroundColor
          ?.resolve({}),
      Theme.of(
        tester.element(find.byKey(const Key('scene_show_metadata'))),
      ).colorScheme.onSurfaceVariant,
    );
    expect(
      tester.getTopRight(find.byKey(const Key('scene_show_metadata'))).dx,
      closeTo(
        tester.getTopRight(find.byKey(const Key('scene_header_identity'))).dx,
        0.1,
      ),
    );
    expect(
      tester.widget<Text>(find.text('Test Studio')).style?.decoration,
      TextDecoration.none,
    );
    expect(
      tester.getCenter(find.byKey(const Key('scene_show_metadata'))).dx,
      greaterThan(tester.getCenter(find.text('Test Studio')).dx),
    );
    expect(
      tester.getCenter(find.text('2024')).dx,
      greaterThan(tester.getCenter(find.text('Test Studio')).dx),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('scene_header_controls'))).dy -
          tester
              .getBottomLeft(find.byKey(const Key('scene_header_identity')))
              .dy,
      closeTo(6, 0.1),
    );
  });

  testWidgets('SceneDetailsPage reveals hidden technical metadata', (
    tester,
  ) async {
    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('scene_show_metadata')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('scene_show_metadata')), findsNothing);
    expect(find.byKey(const Key('scene_header_metadata')), findsOneWidget);
  });

  testWidgets('SceneDetailsPage shows metadata when default hiding is off', (
    tester,
  ) async {
    await prefs.setBool('hide_scene_technical_metadata', false);
    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const Key('scene_header_metadata')), findsOneWidget);
    expect(find.byKey(const Key('scene_show_metadata')), findsNothing);
  });

  testWidgets('SceneDetailsPage matches header and details section surfaces', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final scene = testScene.copyWith(details: 'Scene details');
    final mockRepo = MockGraphQLSceneRepository()..withData([scene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: scene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    final header = find.byKey(const Key('scene_header_section'));
    final details = find.byKey(const Key('scene_details_section'));
    expect(
      find.descendant(of: header, matching: find.text('Test Scene')),
      findsNothing,
    );
    expect(
      find.descendant(of: header, matching: find.text('Test Studio')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: header,
        matching: find.byKey(const Key('scene_action_delete')),
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<Card>(header).color,
      tester.widget<Card>(details).color,
    );
  });

  testWidgets(
    'SceneDetailsPage aligns tablet rating and action groups on one line',
    (tester) async {
      tester.view.physicalSize = const Size(1100, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
        child: SceneDetailsPage(sceneId: testScene.id),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(AppBar), findsNothing);
      expect(find.byKey(const Key('scene_action_add_marker')), findsOneWidget);
      expect(find.byKey(const Key('scene_action_info')), findsOneWidget);
      expect(find.byKey(const Key('scene_action_download')), findsOneWidget);
      expect(find.byKey(const Key('scene_action_edit')), findsOneWidget);
      expect(find.byKey(const Key('scene_action_delete')), findsOneWidget);

      final rating = find.byKey(const Key('scene_rating_controls'));
      final actions = find.byKey(const Key('scene_action_buttons'));
      expect(
        tester.getCenter(actions).dy,
        closeTo(tester.getCenter(rating).dy, 0.1),
      );
      expect(
        tester.getTopRight(actions).dx,
        closeTo(
          tester.getTopRight(find.byKey(const Key('scene_header_controls'))).dx,
          0.1,
        ),
      );
    },
  );

  testWidgets('SceneDetailsPage places metadata below identity and controls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    final controls = find.byKey(const Key('scene_header_controls'));
    await tester.tap(find.byKey(const Key('scene_show_metadata')));
    await tester.pumpAndSettle();
    final metadata = find.byKey(const Key('scene_header_metadata'));
    final studio = find.text('Test Studio');

    expect(
      tester.getBottomLeft(studio).dy,
      lessThan(tester.getTopLeft(metadata).dy),
    );
    expect(
      tester.getBottomLeft(metadata).dy,
      lessThan(tester.getTopLeft(controls).dy),
    );
  });

  testWidgets(
    'SceneDetailsPage stacks its header without scaled-text overflow',
    (tester) async {
      tester.view.physicalSize = const Size(400, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
          child: SceneDetailsPage(sceneId: testScene.id),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final identity = find.byKey(const Key('scene_header_identity'));
      final controls = find.byKey(const Key('scene_header_controls'));
      await tester.tap(find.byKey(const Key('scene_show_metadata')));
      await tester.pumpAndSettle();
      final metadata = find.byKey(const Key('scene_header_metadata'));
      final rating = find.byKey(const Key('scene_rating_controls'));
      final actions = find.byKey(const Key('scene_action_buttons'));

      expect(
        tester.getBottomLeft(identity).dy,
        lessThan(tester.getTopLeft(controls).dy),
      );
      expect(tester.getTopLeft(metadata).dy, greaterThan(0));
      expect(
        tester.getSize(controls).width,
        lessThan(tester.getSize(identity).width),
      );
      expect(
        tester.getTopLeft(actions).dy,
        greaterThan(tester.getTopLeft(rating).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('SceneDetailsPage offsets video below top safe area on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: const MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.only(top: 24)),
        child: SceneDetailsPage(sceneId: 's1'),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(tester.getTopLeft(find.byType(SceneVideoPlayer)).dy, equals(24));
  });

  testWidgets('SceneDetailsPage updates rating', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    final starIcons = find.byWidgetPredicate(
      (widget) =>
          widget is Icon && widget.icon == Icons.star && widget.size == 24,
    );
    final borderIcons = find.byWidgetPredicate(
      (widget) =>
          widget is Icon &&
          widget.icon == Icons.star_border &&
          widget.size == 24,
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

    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('5'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.water_drop_outlined));
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets(
    'SceneDetailsPage hides markers section when scene has no markers',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
        child: SceneDetailsPage(sceneId: testScene.id),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Markers'), findsNothing);
    },
  );

  testWidgets('SceneDetailsPage displays existing scene markers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sceneWithMarker = testScene.copyWith(
      markers: const [
        SceneMarker(
          id: 'm1',
          title: 'Opening beat',
          seconds: 65,
          endSeconds: 95,
          screenshot: null,
          preview: null,
          stream: null,
          primaryTagId: 't1',
          primaryTagName: 'Beat',
          tagIds: ['t1'],
          tagNames: ['Beat'],
        ),
      ],
    );
    final mockRepo = MockGraphQLSceneRepository()..withData([sceneWithMarker]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: sceneWithMarker.id),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Markers'), findsOneWidget);
    expect(find.text('Opening beat'), findsOneWidget);
    expect(find.text('01:05 - 01:35'), findsOneWidget);
    expect(find.text('Beat'), findsOneWidget);
  });

  testWidgets('SceneDetailsPage creates marker then refreshes scene details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byTooltip('Add marker'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'New marker');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(mockRepo.createdSceneMarkers, hasLength(1));
    expect(mockRepo.createdSceneMarkers.single.sceneId, testScene.id);
    expect(mockRepo.createdSceneMarkers.single.title, 'New marker');
    expect(mockRepo.createdSceneMarkers.single.seconds, 0);
    expect(mockRepo.getSceneByIdRefreshValues, contains(true));
  });

  testWidgets(
    'SceneDetailsPage uses current player time and fallback title for unnamed marker',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [
          sceneRepositoryProvider.overrideWithValue(mockRepo),
          playerStateProvider.overrideWith(
            () => _TestPlayerState(
              activeScene: testScene,
              position: const Duration(seconds: 65),
            ),
          ),
        ],
        child: SceneDetailsPage(sceneId: testScene.id),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byTooltip('Add marker'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(mockRepo.createdSceneMarkers, hasLength(1));
      expect(mockRepo.createdSceneMarkers.single.title, 'Test Scene - 01:05');
      expect(mockRepo.createdSceneMarkers.single.seconds, 65);
    },
  );

  testWidgets('SceneDetailsPage deletes marker after confirmation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final sceneWithMarker = testScene.copyWith(
      markers: const [
        SceneMarker(
          id: 'm1',
          title: 'Opening beat',
          seconds: 65,
          endSeconds: null,
          screenshot: null,
          preview: null,
          stream: null,
          primaryTagId: 't1',
          primaryTagName: 'Beat',
          tagIds: ['t1'],
          tagNames: ['Beat'],
        ),
      ],
    );
    final mockRepo = MockGraphQLSceneRepository()..withData([sceneWithMarker]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: sceneWithMarker.id),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byTooltip('Delete marker Opening beat'));
    await tester.pumpAndSettle();

    expect(find.text('Delete marker'), findsOneWidget);
    expect(find.text('Delete marker "Opening beat"?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(mockRepo.deletedSceneMarkerIds, ['m1']);
    expect(mockRepo.getSceneByIdRefreshValues, contains(true));
  });

  testWidgets('SceneDetailsPage deletes metadata only by default', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Delete scene'), findsOneWidget);
    expect(find.textContaining('Delete metadata only'), findsOneWidget);
    expect(find.text('Files'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(mockRepo.deletedSceneId, testScene.id);
    expect(mockRepo.deletedSceneDeleteFile, isFalse);
    expect(mockRepo.deletedSceneDeleteGenerated, isTrue);
  });

  testWidgets('SceneDetailsPage can delete scene files', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Files'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(mockRepo.deletedSceneId, testScene.id);
    expect(mockRepo.deletedSceneDeleteFile, isTrue);
    expect(mockRepo.deletedSceneDeleteGenerated, isTrue);
  });

  testWidgets('SceneDetailsPage cancel leaves scene and queue unchanged', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final deletedScene = sceneWithoutStudio('s1', 'Deleted Scene');
    final nextScene = sceneWithoutStudio('s2', 'Next Scene');
    final mockRepo = MockGraphQLSceneRepository()
      ..withData([deletedScene, nextScene]);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);
    container.read(playbackQueueProvider.notifier).setSequence([
      deletedScene,
      nextScene,
    ], 0);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    SceneDetailsPage(sceneId: deletedScene.id),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    final queueState = container.read(playbackQueueProvider);
    expect(mockRepo.deletedSceneId, isNull);
    expect(queueState.sequence.map((scene) => scene.id), ['s1', 's2']);
    expect(queueState.currentIndex, 0);
    expect(find.text('Deleted Scene'), findsOneWidget);
  });

  testWidgets('SceneDetailsPage failed deletion preserves queue and route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final deletedScene = sceneWithoutStudio('s1', 'Deleted Scene');
    final nextScene = sceneWithoutStudio('s2', 'Next Scene');
    final mockRepo = MockGraphQLSceneRepository()
      ..withData([deletedScene, nextScene]);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);
    container.read(playbackQueueProvider.notifier).setSequence([
      deletedScene,
      nextScene,
    ], 0);
    final router = GoRouter(
      initialLocation: '/scenes/scene/${deletedScene.id}',
      routes: [
        GoRoute(
          path: '/scenes',
          builder: (context, state) => const Scaffold(body: Text('Scene list')),
          routes: [
            GoRoute(
              path: 'scene/:id',
              builder: (context, state) =>
                  SceneDetailsPage(sceneId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    mockRepo.withError('server refused deletion');
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    final queueState = container.read(playbackQueueProvider);
    expect(router.routeInformationProvider.value.uri.path, '/scenes/scene/s1');
    expect(queueState.sequence.map((scene) => scene.id), ['s1', 's2']);
    expect(queueState.currentIndex, 0);
    expect(find.textContaining('Failed to delete scene'), findsOneWidget);
  });

  testWidgets('SceneDetailsPage removes deleted scene from playback queue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final previousScene = sceneWithoutStudio('s0', 'Previous Scene');
    final deletedScene = sceneWithoutStudio('s1', 'Deleted Scene');
    final nextScene = sceneWithoutStudio('s2', 'Next Scene');
    final mockRepo = MockGraphQLSceneRepository()
      ..withData([previousScene, deletedScene, nextScene]);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
    addTearDown(container.dispose);
    container.read(playbackQueueProvider.notifier).setSequence([
      previousScene,
      deletedScene,
      nextScene,
    ], 1);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    SceneDetailsPage(sceneId: deletedScene.id),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    final queueState = container.read(playbackQueueProvider);
    expect(queueState.sequence.map((scene) => scene.id), ['s0', 's2']);
    expect(queueState.currentIndex, 0);
  });

  testWidgets(
    'SceneDetailsPage deletion redirects direct details to scene list',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final deletedScene = sceneWithoutStudio('s1', 'Deleted Scene');
      final mockRepo = MockGraphQLSceneRepository()..withData([deletedScene]);
      final router = GoRouter(
        initialLocation: '/scenes/scene/${deletedScene.id}',
        routes: [
          GoRoute(
            path: '/scenes',
            builder: (context, state) =>
                const Scaffold(body: Text('Scene list')),
            routes: [
              GoRoute(
                path: 'scene/:id',
                builder: (context, state) =>
                    SceneDetailsPage(sceneId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            sceneRepositoryProvider.overrideWithValue(mockRepo),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(router.routeInformationProvider.value.uri.path, '/scenes');
      expect(find.text('Scene list'), findsOneWidget);
    },
  );

  testWidgets('SceneDetailsPage deletion pops to previous scene details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final previousScene = sceneWithoutStudio('s0', 'Previous Scene');
    final deletedScene = sceneWithoutStudio('s1', 'Deleted Scene');
    final mockRepo = MockGraphQLSceneRepository()
      ..withData([previousScene, deletedScene]);
    final router = GoRouter(
      initialLocation: '/scenes/scene/${previousScene.id}',
      routes: [
        GoRoute(
          path: '/scenes',
          builder: (context, state) => const Scaffold(body: Text('Scene list')),
          routes: [
            GoRoute(
              path: 'scene/:id',
              builder: (context, state) =>
                  SceneDetailsPage(sceneId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    router.push('/scenes/scene/${deletedScene.id}');
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(
      router.routeInformationProvider.value.uri.path,
      '/scenes/scene/${previousScene.id}',
    );
    expect(find.text('Previous Scene'), findsOneWidget);
  });

  testWidgets('SceneDetailsPage constrains video height', (tester) async {
    // Set a specific screen size
    const screenWidth = 1000.0;
    const screenHeight = 2000.0;
    tester.view.physicalSize = const Size(screenWidth, screenHeight);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockRepo = MockGraphQLSceneRepository()..withData([testScene]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [sceneRepositoryProvider.overrideWithValue(mockRepo)],
      child: SceneDetailsPage(sceneId: testScene.id),
    );
    await tester.pumpAndSettle();

    // Without a top AppBar, safeMaxHeight = 2000 - 8 = 1992.

    final playerFinder = find.byType(SceneVideoPlayer);
    final player = tester.widget<SceneVideoPlayer>(playerFinder);
    expect(player.maxHeight, equals(1992.0));
  });

  testWidgets('SceneCard long press opens scene info media section', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    final sceneWithMedia = sceneWithoutStudio('s1', 'Test Scene').copyWith(
      paths: testScene.paths.copyWith(
        screenshot: 'http://test.com/cover.jpg',
        preview: 'http://test.com/preview.mp4',
      ),
    );

    await pumpTestWidget(
      tester,
      prefs: prefs,
      child: Scaffold(body: SceneCard(scene: sceneWithMedia, isGrid: false)),
    );

    await tester.pump(const Duration(milliseconds: 500));

    await tester.longPress(
      find.descendant(
        of: find.byType(SceneCard),
        matching: find.byWidgetPredicate(
          (widget) => widget is InkWell && widget.onLongPress != null,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    final l10n = AppLocalizations.of(tester.element(find.byType(SceneCard)))!;
    expect(find.text(l10n.details_scene), findsOneWidget);
    final mediaSection = find.byKey(const Key('scene_info_media_section'));
    expect(mediaSection, findsOneWidget);
    expect(
      tester.getTopLeft(mediaSection).dy,
      lessThan(tester.getTopLeft(find.byIcon(Icons.calendar_today_rounded)).dy),
    );
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

class _TestPlayerState extends PlayerState {
  _TestPlayerState({required this.activeScene, required this.position});

  final Scene activeScene;
  final Duration position;

  @override
  GlobalPlayerState build() {
    return GlobalPlayerState(
      activeScene: activeScene,
      player: _TestPlayer(position),
    );
  }
}

class _TestPlayer extends Mock implements mk.Player {
  _TestPlayer(this.position);

  final Duration position;

  @override
  mk.PlayerState get state => _TestMediaPlayerState(position: position);

  @override
  Future<void> play() async {}
}

class _TestMediaPlayerState extends Mock implements mk.PlayerState {
  _TestMediaPlayerState({required this.position});

  @override
  final Duration position;

  @override
  bool get playing => true;
}
