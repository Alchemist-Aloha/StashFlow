import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/navigation/presentation/router.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraper.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'helpers/test_helpers.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';

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

class LocalMockSceneRepository implements SceneRepository {
  final List<Scene> scenes;
  LocalMockSceneRepository(this.scenes);

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

    final mockRepo = LocalMockSceneRepository(testScenes);

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

    final mockRepo = LocalMockSceneRepository(testScenes);

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

    if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.arrow_back));
    } else if (find.byType(BackButton).evaluate().isNotEmpty) {
      await tester.tap(find.byType(BackButton));
    }

    await tester.pumpAndSettle();
    expect(find.text('Zebra Scene'), findsOneWidget);
  });

  testWidgets('Integration: Adaptive Navigation (Mobile vs Tablet)', (
    WidgetTester tester,
  ) async {
    final mockRepo = LocalMockSceneRepository(testScenes);

    // 1. Test Mobile (NavigationBar)
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
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

    final mockRepo = LocalMockSceneRepository(testScenes);

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
      final mockRepo = LocalMockSceneRepository([]);
      final mockPerformerRepo = MockPerformerRepository()
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
}
