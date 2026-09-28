import 'package:flutter/foundation.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';
import 'package:stash_app_flutter/features/groups/data/repositories/graphql_group_repository.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/navigation/presentation/router.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_deduplication.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraper.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/navigation_tabs_provider.dart';
import 'helpers/test_helpers.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';

// Helper to create a Scene with all required fields for testing
Scene createTestScene({
  required String id,
  required String title,
  bool organized = false,
}) {
  return Scene(
    id: id,
    title: title,
    date: DateTime(2023, 1, 1),
    rating100: null,
    oCounter: 0,
    organized: organized,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    playDuration: 0,
    files: [],
    paths: const ScenePaths(screenshot: null, preview: null, stream: null),
    urls: [],
    studioId: null,
    studioName: 'Test Studio',
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );
}

class LocalMockGraphQLSceneRepository implements GraphQLSceneRepository {
  final List<Scene> scenes;
  LocalMockGraphQLSceneRepository(this.scenes);

  @override
  Future<({List<Scene> scenes, int totalCount})> findScenesPage({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    bool? organized,
    bool? performerFavorite,
    String? performerId,
    String? studioId,
    String? tagId,
    SceneFilter? sceneFilter,
  }) async {
    final result = await findScenes(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort,
      descending: descending,
      organized: organized,
      performerFavorite: performerFavorite,
      performerId: performerId,
      studioId: studioId,
      tagId: tagId,
      sceneFilter: sceneFilter,
    );
    return (scenes: result, totalCount: result.length);
  }

  @override
  Future<List<Scene>> findScenes({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    bool? organized,
    String? performerId,
    String? studioId,
    String? tagId,
    bool? performerFavorite,
    SceneFilter? sceneFilter,
  }) async {
    var result = List<Scene>.from(scenes);

    if (filter != null && filter.isNotEmpty) {
      result = result
          .where((s) => s.title.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }

    if (organized == true) {
      result = result.where((s) => s.organized).toList();
    }

    if (sort == 'title') {
      result.sort((a, b) => a.title.compareTo(b.title));
      if (descending) result = result.reversed.toList();
    } else if (sort == 'o_counter') {
      result.sort((a, b) => a.oCounter.compareTo(b.oCounter));
      if (descending) result = result.reversed.toList();
    } else if (sort == 'rating') {
      result.sort((a, b) => (a.rating100 ?? 0).compareTo(b.rating100 ?? 0));
      if (descending) result = result.reversed.toList();
    }

    return result;
  }

  @override
  Future<Scene> getSceneById(String id, {bool refresh = false}) async {
    return scenes.firstWhere((s) => s.id == id);
  }

  @override
  Future<void> updateSceneRating(String id, int rating100) async {}
  @override
  Future<void> incrementSceneOCounter(String id) async {}
  @override
  Future<void> incrementScenePlayCount(String id) async {}

  @override
  Future<void> saveSceneActivity(
    String id, {
    double? resumeTime,
    double? playDuration,
  }) async {}

  @override
  Future<SceneMarker> createSceneMarker({
    required String sceneId,
    required String title,
    double seconds = 0,
    double? endSeconds,
    String? primaryTagId,
    List<String> tagIds = const [],
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteSceneMarker(String markerId) async {}

  @override
  Future<List<Scraper>> listScrapers({required List<String> types}) async => [];

  @override
  Future<List<ScrapedScene>> scrapeSingleScene({
    String? scraperId,
    String? stashBoxEndpoint,
    String? sceneId,
    String? query,
  }) async => [];

  @override
  Future<ScrapedScene?> scrapeSceneURL(String url) async => null;

  @override
  Future<void> generatePhash(String sceneId) async {}

  @override
  Future<void> saveScrapedScene({
    required String sceneId,
    required ScrapedScene scraped,
    bool mergeValues = false,
    List<String>? performerIds,
    List<String>? tagIds,
    String? studioId,
  }) async {}

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findPerformerCandidates(
    List<String> performers,
  ) async => {};

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(
    List<String> tags,
  ) async => {};

  @override
  Future<void> deleteScene(
    String id, {
    required bool deleteFile,
    bool deleteGenerated = true,
  }) async {}

  @override
  Future<List<SceneDuplicateGroup>> findDuplicateScenes({
    int distance = 0,
    double durationDiff = 1,
  }) async => [];

  @override
  Future<int> countScenesMissingPhash() async => 0;
}

class LocalMockGraphQLGroupRepository implements GraphQLGroupRepository {
  final List<Group> groups;

  LocalMockGraphQLGroupRepository([this.groups = const []]);

  @override
  Future<List<Group>> findGroups({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    dynamic groupFilter,
  }) async => groups;

  @override
  Future<Group> getGroupById(String id, {bool refresh = false}) async {
    return groups.firstWhere((group) => group.id == id);
  }
}

class MockNavigationTabsNotifier extends NavigationTabsNotifier {
  final List<NavigationTab> initialTabs;

  MockNavigationTabsNotifier(this.initialTabs);

  @override
  List<NavigationTab> build() => initialTabs;
}

// Simple test notifiers to override the layout state
class TestSceneTiktokLayout extends SceneTiktokLayout {
  @override
  bool build() => false;
}

class TestSceneGridLayout extends SceneGridLayout {
  @override
  bool build() => false;
}

class MockSceneGridLayoutTrue extends SceneGridLayout {
  @override
  bool build() => true;
}

class _FullscreenBackPlayerState extends PlayerState {
  _FullscreenBackPlayerState(this._scene);

  Scene _scene;
  int exitRequests = 0;

  @override
  GlobalPlayerState build() => GlobalPlayerState(activeScene: _scene);

  void setActiveScene(Scene scene) {
    _scene = scene;
    state = state.copyWith(activeScene: scene);
  }

  @override
  void requestExitFullscreen() {
    exitRequests++;
    super.requestExitFullscreen();
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  final testScenes = [
    createTestScene(id: '1', title: 'Apple Scene', organized: true),
    createTestScene(id: '2', title: 'Zebra Scene', organized: false),
  ];

  testWidgets('Integration: Scenes List -> Search -> Sort -> Filter', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = LocalMockGraphQLSceneRepository(testScenes);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
        sceneTiktokLayoutProvider.overrideWith(TestSceneTiktokLayout.new),
        sceneGridLayoutProvider.overrideWith(TestSceneGridLayout.new),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final goRouter = ref.watch(routerProvider);
          return MaterialApp.router(
            routerConfig: goRouter,
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial list
    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsOneWidget);

    // Test Search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Apple');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsNothing);

    // Clear Search - tapping the close icon in the "Searching for" bar
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsOneWidget);

    // Test Sorting (Title Descending)
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();

    final titleOption = find.text('Title').last;
    await tester.tap(titleOption);
    await tester.pumpAndSettle();

    final descendingOption = find.text('Descending').last;
    await tester.tap(descendingOption);
    await tester.pumpAndSettle();

    final applySort = find.text('Apply Sort').last;
    await tester.tap(applySort);
    await tester.pumpAndSettle();

    // Re-verify positions
    final sceneCards = find.byType(SceneCard);
    expect(sceneCards, findsNWidgets(2));

    final firstSceneTitle = tester
        .widget<Text>(
          find
              .descendant(
                of: sceneCards.at(0),
                matching: find.textContaining('Scene'),
              )
              .first,
        )
        .data;
    final secondSceneTitle = tester
        .widget<Text>(
          find
              .descendant(
                of: sceneCards.at(1),
                matching: find.textContaining('Scene'),
              )
              .first,
        )
        .data;

    expect(firstSceneTitle, 'Zebra Scene');
    expect(secondSceneTitle, 'Apple Scene');

    // Test Filtering (Organized only)
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    final organizedOnly = find.text('ORGANIZED');
    await tester.tap(organizedOnly);
    await tester.pumpAndSettle();

    final applyFilters = find.text('Apply Filters');
    await tester.tap(applyFilters);
    await tester.pumpAndSettle();

    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsNothing);
  });

  testWidgets('Integration: Navigation to Details and back', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = LocalMockGraphQLSceneRepository(testScenes);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
        sceneTiktokLayoutProvider.overrideWith(TestSceneTiktokLayout.new),
        sceneGridLayoutProvider.overrideWith(TestSceneGridLayout.new),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final goRouter = ref.watch(routerProvider);
          return MaterialApp.router(
            routerConfig: goRouter,
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Apple Scene'));
    await tester.pumpAndSettle();

    expect(find.text('Apple Scene'), findsAtLeast(1));

    final detailsPage = find.byType(SceneDetailsPage);
    if (detailsPage.evaluate().isNotEmpty) {
      Navigator.of(tester.element(detailsPage)).pop();
    }

    await tester.pumpAndSettle();
    expect(find.text('Zebra Scene'), findsOneWidget);
  });

  testWidgets('Integration: scene card preference opens fullscreen overlay', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    await prefs.setBool(
      PlayerSettingsStore.enterFullscreenOnNavigationKey,
      true,
    );

    final playerState = _FullscreenBackPlayerState(testScenes.first);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(
            LocalMockGraphQLSceneRepository(testScenes),
          ),
          sceneTiktokLayoutProvider.overrideWith(TestSceneTiktokLayout.new),
          sceneGridLayoutProvider.overrideWith(TestSceneGridLayout.new),
          playerStateProvider.overrideWith(() => playerState),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final goRouter = ref.watch(routerProvider);
            return MaterialApp.router(
              routerConfig: goRouter,
              theme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byType(SceneCard).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    final detailsFinder = find.byType(SceneDetailsPage);
    expect(
      tester.widget<SceneDetailsPage>(detailsFinder).autoPlayOnMount,
      isTrue,
    );
    final container = ProviderScope.containerOf(tester.element(detailsFinder));
    expect(container.read(playerStateProvider).isFullScreen, isTrue);
    expect(
      find.byKey(const ValueKey('global_fullscreen_overlay_slide')),
      findsOneWidget,
    );
  });

  testWidgets(
    'Integration: Android fullscreen back returns to the active details route',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        debugDefaultTargetPlatformOverride = null;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            SystemChannels.platform,
            (call) async => null,
          );

      final prefixScene = createTestScene(id: '10', title: 'Prefix Scene');
      final playerState = _FullscreenBackPlayerState(testScenes.first);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(
            LocalMockGraphQLSceneRepository([...testScenes, prefixScene]),
          ),
          sceneTiktokLayoutProvider.overrideWith(TestSceneTiktokLayout.new),
          sceneGridLayoutProvider.overrideWith(TestSceneGridLayout.new),
          playerStateProvider.overrideWith(() => playerState),
        ],
      );
      addTearDown(container.dispose);
      late GoRouter router;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              router = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: router,
                theme: AppTheme.darkTheme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<void> expectFullscreenBackAt({
        required Scene backgroundScene,
        required Scene activeScene,
      }) async {
        if (router.routeInformationProvider.value.uri.path !=
            '/scenes/scene/${backgroundScene.id}') {
          router.go('/scenes/scene/${backgroundScene.id}');
          await tester.pump(const Duration(seconds: 1));
        }
        expect(
          router.routeInformationProvider.value.uri.path,
          '/scenes/scene/${backgroundScene.id}',
        );

        playerState.setActiveScene(activeScene);
        final previousExitRequests = playerState.exitRequests;
        playerState.requestEnterFullscreen();
        await tester.pump(const Duration(milliseconds: 500));
        expect(container.read(playerStateProvider).isFullScreen, isTrue);

        await tester.binding.handlePopRoute();
        await tester.pump(const Duration(seconds: 1));

        expect(playerState.exitRequests, previousExitRequests + 1);
        expect(
          router.routeInformationProvider.value.uri.path,
          '/scenes/scene/${activeScene.id}',
        );
        expect(container.read(playerStateProvider).isFullScreen, isFalse);
      }

      await expectFullscreenBackAt(
        backgroundScene: testScenes.first,
        activeScene: testScenes.first,
      );

      // Once fullscreen has exited, Back uses the ordinary details stack.
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 500));
      expect(router.routeInformationProvider.value.uri.path, '/scenes');

      // Next/random playback can change the active video behind the overlay.
      await expectFullscreenBackAt(
        backgroundScene: testScenes.first,
        activeScene: testScenes.last,
      );
      await expectFullscreenBackAt(
        backgroundScene: prefixScene,
        activeScene: testScenes.first,
      );
      debugDefaultTargetPlatformOverride = null;
    },
  );

  testWidgets('Integration: Adaptive Navigation (Mobile vs Tablet)', (
    WidgetTester tester,
  ) async {
    final mockRepo = LocalMockGraphQLSceneRepository(testScenes);

    // 1. Test Mobile (NavigationBar)
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(bottom: 24);
    tester.view.viewPadding = const FakeViewPadding(bottom: 24);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(() => tester.view.resetPhysicalSize());

    Future<void> pumpApp() async {
      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [
          sceneRepositoryProvider.overrideWithValue(mockRepo),
          sceneTiktokLayoutProvider.overrideWith(TestSceneTiktokLayout.new),
          sceneGridLayoutProvider.overrideWith(TestSceneGridLayout.new),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final goRouter = ref.watch(routerProvider);
            return MaterialApp.router(
              routerConfig: goRouter,
              theme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
    }

    await pumpApp();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // System navigation padding belongs to the shell bar, not to the sheets
    // opened by its nested feature navigator.
    final barTop = tester.getRect(find.byType(NavigationBar)).top;
    for (final icon in [Icons.sort, Icons.filter_list]) {
      await tester.tap(find.byIcon(icon).first);
      await tester.pumpAndSettle();
      expect(tester.getRect(find.byType(FrostedPanel)).bottom, barTop);
      Navigator.of(tester.element(find.byType(FrostedPanel))).pop();
      await tester.pumpAndSettle();
    }

    // 2. Test Tablet (NavigationRail)
    tester.view.physicalSize = const Size(1200, 800);
    // Re-pump to ensure MediaQuery updates
    await pumpApp();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Integration: Responsive Grid (Mobile vs Tablet)', (
    WidgetTester tester,
  ) async {
    // Ignore overflow errors for this test
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exception is FlutterError &&
          (details.exception as FlutterError).message.contains('overflowed')) {
        return;
      }
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    final mockRepo = LocalMockGraphQLSceneRepository(testScenes);

    Future<void> pumpApp() async {
      await pumpTestWidget(
        tester,
        prefs: prefs,
        overrides: [
          sceneRepositoryProvider.overrideWithValue(mockRepo),
          sceneTiktokLayoutProvider.overrideWith(TestSceneTiktokLayout.new),
          sceneGridLayoutProvider.overrideWith(MockSceneGridLayoutTrue.new),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final goRouter = ref.watch(routerProvider);
            return MaterialApp.router(
              routerConfig: goRouter,
              theme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
            );
          },
        ),
      );
      await tester.pumpAndSettle();
    }

    // 1. Test Mobile (2 columns)
    tester.view.physicalSize = const Size(400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await pumpApp();

    int getCrossAxisCount() {
      final gridFinder = find.byType(GridView);
      if (gridFinder.evaluate().isNotEmpty) {
        final grid = tester.widget<GridView>(gridFinder.first);
        return (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount;
      }
      final masonryFinder = find.byType(MasonryGridView);
      if (masonryFinder.evaluate().isNotEmpty) {
        final masonry = tester.widget<MasonryGridView>(masonryFinder.first);
        return (masonry.gridDelegate
                as SliverSimpleGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount;
      }
      throw StateError('No GridView or MasonryGridView found');
    }

    expect(getCrossAxisCount(), 2);

    // 2. Test Tablet (3 columns)
    tester.view.physicalSize = const Size(1200, 800);
    await pumpApp();

    expect(getCrossAxisCount(), 3);
  });

  testWidgets(
    'Integration: Responsive Grid - Performers (Mobile 3 vs Tablet 5)',
    (WidgetTester tester) async {
      final mockRepo = LocalMockGraphQLSceneRepository([]);
      final mockPerformerRepo = MockGraphQLPerformerRepository()
        ..withData([
          const Performer(
            id: 'p1',
            name: 'Test Performer',
            urls: [],
            birthdate: null,
            aliasList: [],
            favorite: false,
            imagePath: '',
            sceneCount: 0,
            imageCount: 0,
            galleryCount: 0,
            groupCount: 0,
            tagIds: [],
            tagNames: [],
          ),
        ]);

      Future<void> pumpApp() async {
        await pumpTestWidget(
          tester,
          prefs: prefs,

          overrides: [
            sceneRepositoryProvider.overrideWithValue(mockRepo),
            performerRepositoryProvider.overrideWithValue(mockPerformerRepo),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              final goRouter = ref.watch(routerProvider);
              return MaterialApp.router(
                routerConfig: goRouter,
                theme: AppTheme.darkTheme,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          ),
        );
        await tester.pumpAndSettle();
      }

      // Navigate to Performers
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await pumpApp();
      await tester.tap(find.text('Performers'));
      await tester.pumpAndSettle();

      // 1. Test Mobile (3 columns)
      GridView gridView = tester.widget(find.byType(GridView).first);
      expect(
        (gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        3,
      );

      // 2. Test Tablet (5 columns)
      tester.view.physicalSize = const Size(1600, 800);
      await pumpApp();

      gridView = tester.widget(find.byType(GridView).first);
      expect(
        (gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        5,
      );
    },
  );

  testWidgets('Integration: Shell Branch Navigation (Tabs)', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = LocalMockGraphQLSceneRepository(testScenes);
    final mockPerformerRepo = MockGraphQLPerformerRepository()..withData([]);

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
        performerRepositoryProvider.overrideWithValue(mockPerformerRepo),
        sceneTiktokLayoutProvider.overrideWith(TestSceneTiktokLayout.new),
        sceneGridLayoutProvider.overrideWith(TestSceneGridLayout.new),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final goRouter = ref.watch(routerProvider);
          return MaterialApp.router(
            routerConfig: goRouter,
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial load
    expect(find.text('Scenes').last, findsOneWidget);

    // Tap Performers Tab
    await tester.tap(find.text('Performers').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap Studios Tab
    await tester.tap(find.text('Studios').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap Tags Tab
    await tester.tap(find.text('Tags').last, warnIfMissed: false);
    await tester.pumpAndSettle();

    // Tap Galleries Tab
    await tester.tap(find.text('Galleries').last, warnIfMissed: false);
    await tester.pumpAndSettle();
  });

  testWidgets('Integration: Groups tab is hidden by default', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = LocalMockGraphQLSceneRepository(testScenes);
    final mockPerformerRepo = MockGraphQLPerformerRepository()..withData([]);
    final mockGroupRepo = LocalMockGraphQLGroupRepository();
    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
        performerRepositoryProvider.overrideWithValue(mockPerformerRepo),
        groupRepositoryProvider.overrideWithValue(mockGroupRepo),
        sceneTiktokLayoutProvider.overrideWith(TestSceneTiktokLayout.new),
        sceneGridLayoutProvider.overrideWith(TestSceneGridLayout.new),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final goRouter = ref.watch(routerProvider);
          return MaterialApp.router(
            routerConfig: goRouter,
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Groups'), findsNothing);
  });

  testWidgets('Integration: Groups tab appears when enabled', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final mockRepo = LocalMockGraphQLSceneRepository(testScenes);
    final mockPerformerRepo = MockGraphQLPerformerRepository()..withData([]);
    final mockGroupRepo = LocalMockGraphQLGroupRepository();

    await pumpTestWidget(
      tester,
      prefs: prefs,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(mockRepo),
        performerRepositoryProvider.overrideWithValue(mockPerformerRepo),
        groupRepositoryProvider.overrideWithValue(mockGroupRepo),
        sceneTiktokLayoutProvider.overrideWith(TestSceneTiktokLayout.new),
        sceneGridLayoutProvider.overrideWith(TestSceneGridLayout.new),
        navigationTabsProvider.overrideWith(
          () => MockNavigationTabsNotifier([
            const NavigationTab(type: NavigationTabType.scenes),
            const NavigationTab(type: NavigationTabType.performers),
            const NavigationTab(type: NavigationTabType.studios),
            const NavigationTab(type: NavigationTabType.tags),
            const NavigationTab(type: NavigationTabType.galleries),
            const NavigationTab(type: NavigationTabType.groups, visible: true),
          ]),
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final goRouter = ref.watch(routerProvider);
          return MaterialApp.router(
            routerConfig: goRouter,
            theme: AppTheme.darkTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Groups').last, findsOneWidget);
  });
}
