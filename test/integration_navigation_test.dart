import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/navigation/presentation/router.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'helpers/test_helpers.dart';

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
    files: [],
    paths: const ScenePaths(screenshot: null, preview: null, stream: null),
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
  Future<Scene> getSceneById(String id) async {
    return scenes.firstWhere((s) => s.id == id);
  }

  @override
  Future<void> updateSceneRating(String id, int rating100) async {}
  @override
  Future<void> incrementSceneOCounter(String id) async {}
  @override
  Future<void> incrementScenePlayCount(String id) async {}
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

void main() {
  final testScenes = [
    createTestScene(id: '1', title: 'Apple Scene', organized: true),
    createTestScene(id: '2', title: 'Zebra Scene', organized: false),
  ];

  testWidgets('Integration: Scenes List -> Search -> Sort -> Filter', (
    WidgetTester tester,
  ) async {
    // Increase surface size for integration tests
    tester.view.physicalSize = const Size(1200, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockRepo = LocalMockSceneRepository(testScenes);

    await pumpTestWidget(
      tester,
      wrapWithApp: false,
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
          );
        },
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    // Verify initial list
    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsOneWidget);

    // Test Search
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'Apple');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsNothing);

    // Clear Search
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsOneWidget);

    // Test Sorting (Title Descending)
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pump(const Duration(seconds: 2));

    final titleSort = find.text('Title');
    await tester.scrollUntilVisible(titleSort, 200.0, scrollable: find.byType(Scrollable).last);
    await tester.tap(titleSort);
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Descending'));
    await tester.pump(const Duration(milliseconds: 500));

    final applySort = find.text('Apply Sort');
    await tester.scrollUntilVisible(applySort, 200.0, scrollable: find.byType(Scrollable).last);
    await tester.tap(applySort);
    await tester.pump(const Duration(seconds: 1));

    // Re-verify positions
    final zebraPos = tester.getCenter(find.text('Zebra Scene')).dy;
    final applePos = tester.getCenter(find.text('Apple Scene')).dy;
    expect(zebraPos < applePos, isTrue);

    // Test Filtering (Organized only)
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pump(const Duration(seconds: 2));

    final organizedOnly = find.text('Organized only');
    await tester.scrollUntilVisible(organizedOnly, 200.0, scrollable: find.byType(Scrollable).last);
    await tester.tap(organizedOnly);
    await tester.pump(const Duration(milliseconds: 500));

    final applyFilters = find.text('Apply Filters');
    await tester.scrollUntilVisible(applyFilters, 200.0, scrollable: find.byType(Scrollable).last);
    await tester.tap(applyFilters);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsNothing);
  });

  testWidgets('Integration: Navigation to Details and back', (
    WidgetTester tester,
  ) async {
    // Increase surface size for integration tests
    tester.view.physicalSize = const Size(1200, 5000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockRepo = LocalMockSceneRepository(testScenes);

    await pumpTestWidget(
      tester,
      wrapWithApp: false,
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
          );
        },
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Apple Scene'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Apple Scene'), findsAtLeast(1));

    if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.arrow_back));
    } else if (find.byType(BackButton).evaluate().isNotEmpty) {
      await tester.tap(find.byType(BackButton));
    }

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Zebra Scene'), findsOneWidget);
  });

  testWidgets('Integration: Adaptive Navigation (Mobile vs Tablet)', (
    WidgetTester tester,
  ) async {
    final mockRepo = LocalMockSceneRepository(testScenes);

    // 1. Test Mobile (NavigationBar)
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;

    await pumpTestWidget(
      tester,
      wrapWithApp: false,
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
          );
        },
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);

    // 2. Test Tablet (NavigationRail)
    tester.view.physicalSize = const Size(1200, 800);
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
