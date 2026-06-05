import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_performer.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_studio.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_tag.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_tagger_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/stashbox_provider.dart';
import 'package:stash_app_flutter/features/tools/presentation/pages/tools_page.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('ToolsPage links to Scene Tagger subpage', (tester) async {
    final router = GoRouter(
      initialLocation: '/tools',
      routes: [
        GoRoute(
          path: '/tools',
          builder: (context, state) => const ToolsPage(),
          routes: [
            GoRoute(
              path: 'scene-tagger',
              builder: (context, state) =>
                  const Scaffold(body: Text('Tagger target')),
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Scene Tagger'));
    await tester.pumpAndSettle();

    expect(find.text('Tagger target'), findsOneWidget);
  });

  testWidgets('ToolsPage falls back to scenes when opened as root', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/tools',
      routes: [
        GoRoute(
          path: '/scenes',
          builder: (context, state) =>
              const Scaffold(body: Text('Scenes target')),
        ),
        GoRoute(path: '/tools', builder: (context, state) => const ToolsPage()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/scenes');
    expect(find.text('Scenes target'), findsOneWidget);
  });

  testWidgets('SceneTaggerPage scrapes current page and reviews results', (
    tester,
  ) async {
    final repo = MockSceneRepository()
      ..setData([
        toolTaggerScene(id: 'scene-a', title: 'Local A'),
        toolTaggerScene(id: 'scene-b', title: 'Local B'),
      ])
      ..scrapedScenesBySceneId['scene-a'] = [
        const ScrapedScene(
          title: 'Scraped A',
          details: 'Remote details A',
          studio: ScrapedStudio(name: 'Remote Studio', storedId: 'studio-1'),
          performers: [ScrapedPerformer(name: 'Remote Performer')],
          tags: [ScrapedTag(name: 'Remote Tag', storedId: 'tag-1')],
        ),
      ];

    await _pumpSceneTagger(
      tester,
      prefs: prefs,
      repo: repo,
      stashBoxes: [
        StashBoxEndpoint(
          name: 'Primary Box',
          endpoint: 'https://box.test/graphql',
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.text('Scene Tagger'), findsOneWidget);
    expect(repo.lastFindScenesPage, 1);
    expect(repo.lastFindScenesPerPage, 25);
    expect(find.text('Local A'), findsWidgets);
    expect(find.text('Local B'), findsWidgets);

    await tester.tap(find.text('Start tagging'));
    await tester.pumpAndSettle();

    expect(repo.scrapeSceneCalls.map((call) => call.sceneId), [
      'scene-a',
      'scene-b',
    ]);
    expect(repo.scrapeSceneCalls.map((call) => call.stashBoxEndpoint).toSet(), {
      'https://box.test/graphql',
    });
    expect(find.text('Scraped A'), findsOneWidget);
    expect(find.text('Remote details A'), findsOneWidget);
    expect(find.text('Remote Studio'), findsOneWidget);
    expect(find.text('Remote Performer'), findsOneWidget);
    expect(find.text('Remote Tag'), findsOneWidget);
    expect(find.text('No match found'), findsOneWidget);

    await tester.ensureVisible(find.text('Apply').first);
    await tester.tap(find.text('Apply').first);
    await tester.pumpAndSettle();

    expect(repo.savedScrapedScenes, hasLength(1));
    expect(repo.savedScrapedScenes.single.sceneId, 'scene-a');
    expect(repo.savedScrapedScenes.single.scraped.title, 'Scraped A');
  });

  testWidgets('SceneTaggerPage opens scene details from tools route', (
    tester,
  ) async {
    final repo = MockSceneRepository()
      ..setData([toolTaggerScene(id: 'scene-a', title: 'Local A')]);

    final router = GoRouter(
      initialLocation: '/tools/scene-tagger',
      routes: [
        GoRoute(
          path: '/tools',
          builder: (context, state) => const ToolsPage(),
          routes: [
            GoRoute(
              path: 'scene-tagger',
              builder: (context, state) => const SceneTaggerPage(),
            ),
          ],
        ),
        GoRoute(
          path: '/scenes',
          builder: (context, state) =>
              const Scaffold(body: Text('Scene list target')),
        ),
        GoRoute(
          path: '/scene/:id',
          builder: (context, state) => Scaffold(
            body: Text('Scene details ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(repo),
          stashBoxEndpointsProvider.overrideWith(
            (ref) async => [
              StashBoxEndpoint(
                name: 'Primary Box',
                endpoint: 'https://box.test/graphql',
              ),
            ],
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final openButton = find.byIcon(Icons.open_in_new);
    await tester.ensureVisible(openButton);
    final iconButton = tester.widget<IconButton>(
      find.ancestor(of: openButton, matching: find.byType(IconButton)),
    );
    iconButton.onPressed!();
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/scene/scene-a');
    expect(find.text('Scene details scene-a'), findsOneWidget);
    expect(find.text('Scene list target'), findsNothing);
  });

  testWidgets(
    'SceneTaggerPage random unorganized mode shows only matched scenes',
    (tester) async {
      final repo = MockSceneRepository()
        ..findScenesResponses.addAll([
          <Scene>[],
          [
            toolTaggerScene(id: 'random-miss', title: 'Random Miss'),
            toolTaggerScene(id: 'random-hit', title: 'Random Hit'),
          ],
          [toolTaggerScene(id: 'random-hit-2', title: 'Random Hit 2')],
          <Scene>[],
        ])
        ..scrapedScenesBySceneId['random-hit'] = [
          const ScrapedScene(
            title: 'Matched Random Scene',
            studio: ScrapedStudio(name: 'Matched Studio', storedId: 'studio-1'),
          ),
        ]
        ..scrapedScenesBySceneId['random-hit-2'] = [
          const ScrapedScene(
            title: 'Matched Random Scene 2',
            studio: ScrapedStudio(
              name: 'Matched Studio 2',
              storedId: 'studio-2',
            ),
          ),
        ];

      await _pumpSceneTagger(
        tester,
        prefs: prefs,
        repo: repo,
        stashBoxes: [
          StashBoxEndpoint(
            name: 'Primary Box',
            endpoint: 'https://box.test/graphql',
          ),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Current page').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Random unorganized').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start tagging'));
      await tester.pumpAndSettle();

      expect(repo.scrapeSceneCalls.map((call) => call.sceneId), [
        'random-miss',
        'random-hit',
        'random-hit-2',
      ]);
      expect(repo.findSceneCalls.skip(1).map((call) => call.page), [1, 2, 3]);
      expect(repo.findSceneCalls.skip(1).map((call) => call.perPage).toSet(), {
        25,
      });
      expect(
        repo.findSceneCalls.skip(1).map((call) => call.organized).toSet(),
        {false},
      );
      expect(
        repo.findSceneCalls
            .skip(1)
            .every((call) => call.sort?.startsWith('random_') ?? false),
        isTrue,
      );
      expect(find.text('Random Miss'), findsNothing);
      expect(find.text('Random Hit'), findsWidgets);
      expect(find.text('Matched Random Scene'), findsOneWidget);
      expect(find.text('Random Hit 2'), findsWidgets);
      expect(find.text('Matched Random Scene 2'), findsOneWidget);
      expect(find.text('No match found'), findsNothing);
    },
  );
}

Future<void> _pumpSceneTagger(
  WidgetTester tester, {
  required SharedPreferences prefs,
  required MockSceneRepository repo,
  required List<StashBoxEndpoint> stashBoxes,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWithValue(repo),
        stashBoxEndpointsProvider.overrideWith((ref) async => stashBoxes),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        home: const SceneTaggerPage(),
      ),
    ),
  );
}

Scene toolTaggerScene({
  required String id,
  required String title,
  String? details,
}) {
  return Scene(
    id: id,
    title: title,
    details: details,
    path: '/media/$id.mp4',
    date: DateTime(2024),
    rating100: null,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    playDuration: null,
    files: const [
      SceneFile(
        format: 'mp4',
        width: 1920,
        height: 1080,
        videoCodec: 'h264',
        audioCodec: 'aac',
        bitRate: 1200,
        duration: 60,
        frameRate: 30,
        fingerprints: [Fingerprint(type: 'phash', value: 'abcdef')],
      ),
    ],
    paths: const ScenePaths(
      screenshot: null,
      preview: null,
      stream: null,
      caption: null,
      vtt: null,
      sprite: null,
    ),
    captions: const [],
    urls: const [],
    studioId: null,
    studioName: 'Local Studio',
    studioImagePath: null,
    performerIds: const [],
    performerNames: const ['Local Performer'],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const ['Local Tag'],
  );
}
