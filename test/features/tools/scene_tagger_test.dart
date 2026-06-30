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
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';
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

    await tester.tap(find.text('Scene Tagger'));
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
    final repo = MockGraphQLSceneRepository()
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

    await tester.tap(find.text('Start tagging'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Configuration'));
    await tester.pumpAndSettle();

    expect(find.text('Local A'), findsWidgets);

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

    final applyButton = find.widgetWithText(FilledButton, 'Apply').first;
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    expect(repo.savedScrapedScenes, hasLength(1));
    expect(repo.savedScrapedScenes.single.sceneId, 'scene-a');
    expect(repo.savedScrapedScenes.single.scraped.title, 'Scraped A');
  });

  testWidgets('SceneTaggerPage opens scene details from tools route', (
    tester,
  ) async {
    final repo = MockGraphQLSceneRepository()
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

    await tester.tap(find.text('Configuration'));
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
      final repo = MockGraphQLSceneRepository()
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Configuration'));
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
      await tester.drag(
        find.byKey(const ValueKey('scene_tagger_results_randomUnorganized')),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();
      expect(find.text('Random Hit 2'), findsWidgets);
      expect(find.text('Matched Random Scene 2'), findsOneWidget);
      expect(find.text('No match found'), findsNothing);
    },
  );

  testWidgets('SceneTaggerPage lazily renders long scene lists', (
    tester,
  ) async {
    final repo = MockGraphQLSceneRepository()
      ..setData(
        List.generate(
          60,
          (index) =>
              toolTaggerScene(id: 'scene-$index', title: 'Local Scene $index'),
        ),
      );

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

    await tester.tap(find.text('Configuration'));
    await tester.pumpAndSettle();

    expect(find.text('Local Scene 0'), findsWidgets);
    expect(find.text('Local Scene 59'), findsNothing);
  });

  testWidgets(
    'SceneTaggerPage applies the selected scraped result, shows cover image, and removes the item',
    (tester) async {
      final repo = MockGraphQLSceneRepository()
        ..setData([toolTaggerScene(id: 'scene-a', title: 'Local A')])
        ..scrapedScenesBySceneId['scene-a'] = [
          const ScrapedScene(
            title: 'Scraped A',
            details: 'Remote details A',
            image: 'https://images.test/a.jpg',
            studio: ScrapedStudio(
              name: 'Remote Studio A',
              storedId: 'studio-a',
            ),
          ),
          const ScrapedScene(
            title: 'Scraped B',
            details: 'Remote details B',
            image: 'https://images.test/b.jpg',
            studio: ScrapedStudio(
              name: 'Remote Studio B',
              storedId: 'studio-b',
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

      await tester.tap(find.text('Start tagging'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Configuration'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('/media/scene-a.mp4'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('selected_scraped_image_scene-a')),
        findsOneWidget,
      );
      expect(find.text('Show 1 more result'), findsOneWidget);

      final showMoreButton = find.widgetWithText(
        TextButton,
        'Show 1 more result',
      );
      await tester.ensureVisible(showMoreButton);
      await tester.tap(showMoreButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.text('Scraped B'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('expanded_scraped_image_scene-a_1')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('select_scraped_scene-a_1')));
      await tester.pump();

      await tester.tap(find.text('Apply'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(repo.savedScrapedScenes, hasLength(1));
      expect(repo.savedScrapedScenes.single.scraped.title, 'Scraped B');
      expect(repo.savedScrapedScenes.single.organized, isTrue);
      expect(
        repo.data.singleWhere((scene) => scene.id == 'scene-a').organized,
        isTrue,
      );
      expect(find.text('Local A'), findsNothing);
      expect(
        find.byKey(const ValueKey('selected_scraped_image_scene-a')),
        findsNothing,
      );
    },
  );

  testWidgets('SceneTaggerPage shows localized save success text', (
    tester,
  ) async {
    final repo = MockGraphQLSceneRepository()
      ..setData([toolTaggerScene(id: 'scene-a', title: 'Local A')])
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
      locale: const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('开始标注'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('配置'));
    await tester.pumpAndSettle();

    final applyButton = find.widgetWithText(FilledButton, '应用').first;
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Local A'), findsOneWidget);
  });

  testWidgets('SceneTaggerPage skip removes the item from the list', (
    tester,
  ) async {
    final repo = MockGraphQLSceneRepository()
      ..setData([toolTaggerScene(id: 'scene-a', title: 'Local A')])
      ..scrapedScenesBySceneId['scene-a'] = [
        const ScrapedScene(
          title: 'Scraped A',
          image: 'https://images.test/a.jpg',
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

    await tester.tap(find.text('Start tagging'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Configuration'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Local A'), findsWidgets);
    expect(
      find.byKey(const ValueKey('selected_scraped_image_scene-a')),
      findsOneWidget,
    );

    await tester.tap(find.text('Skip'));
    await tester.pump();

    expect(find.text('Local A'), findsNothing);
    expect(find.text('0 scenes on this page'), findsOneWidget);
    expect(repo.savedScrapedScenes, isEmpty);
  });

  testWidgets('SceneTaggerPage preview starts as a thumbnail-first control', (
    tester,
  ) async {
    final repo = MockGraphQLSceneRepository()
      ..setData([
        toolTaggerScene(
          id: 'scene-a',
          title: 'Local A',
          screenshotPath: '/scene/scene-a/screenshot',
          previewPath: '/scene/scene-a/preview',
          streamPath: '/scene/scene-a/stream',
        ),
      ]);

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Configuration'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('scene_preview_thumbnail_scene-a')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('scene_preview_activate_scene-a')),
      findsOneWidget,
    );
    expect(find.byTooltip('Pause preview'), findsNothing);
  });

  testWidgets('SceneTaggerPage renders scraped data-url images', (
    tester,
  ) async {
    final repo = MockGraphQLSceneRepository()
      ..setData([toolTaggerScene(id: 'scene-a', title: 'Local A')])
      ..scrapedScenesBySceneId['scene-a'] = [
        const ScrapedScene(
          title: 'Scraped A',
          image:
              'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4//8/AwAI/AL+X9n6VQAAAABJRU5ErkJggg==',
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

    await tester.tap(find.text('Start tagging'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Configuration'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('selected_scraped_image_scene-a')),
      findsOneWidget,
    );
    expect(find.byType(Image), findsWidgets);
  });

  testWidgets('SceneTaggerPage renders raw base64 scraped images', (
    tester,
  ) async {
    final repo = MockGraphQLSceneRepository()
      ..setData([toolTaggerScene(id: 'scene-a', title: 'Local A')])
      ..scrapedScenesBySceneId['scene-a'] = [
        const ScrapedScene(
          title: 'Scraped A',
          image:
              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4//8/AwAI/AL+X9n6VQAAAABJRU5ErkJggg==',
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

    await tester.tap(find.text('Start tagging'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Configuration'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.byKey(const ValueKey('selected_scraped_image_scene-a')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('selected_scraped_image_scene-a')),
        matching: find.byType(StashImage),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('selected_scraped_image_scene-a')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
  });
}

Future<void> _pumpSceneTagger(
  WidgetTester tester, {
  required SharedPreferences prefs,
  required MockGraphQLSceneRepository repo,
  required List<StashBoxEndpoint> stashBoxes,
  Locale? locale,
}) async {
  tester.view.physicalSize = const Size(1400, 2200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWithValue(repo),
        stashBoxEndpointsProvider.overrideWith((ref) async => stashBoxes),
      ],
      child: MaterialApp(
        locale: locale,
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
  String? screenshotPath,
  String? previewPath,
  String? streamPath,
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
    paths: ScenePaths(
      screenshot: screenshotPath,
      preview: previewPath,
      stream: streamPath,
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
