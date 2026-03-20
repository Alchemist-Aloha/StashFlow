import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/main.dart';

class MockSceneRepository implements SceneRepository {
  List<Scene> scenes;

  MockSceneRepository(this.scenes);

  @override
  Future<List<Scene>> findScenes({
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
    print(
      'MockSceneRepository: findScenes called with filter=$filter, sort=$sort, organized=$organized',
    );
    var result = List<Scene>.from(scenes);

    if (filter != null && filter.isNotEmpty) {
      result = result
          .where((s) => s.title.toLowerCase().contains(filter.toLowerCase()))
          .toList();
    }

    if (organized != null) {
      result = result.where((s) => s.organized == organized).toList();
    }

    if (sceneFilter?.minRating != null) {
      result = result
          .where((s) => (s.rating100 ?? 0) >= sceneFilter!.minRating!)
          .toList();
    }

    // Simple sorting
    if (sort == 'title') {
      result.sort((a, b) => a.title.compareTo(b.title));
    } else if (sort == 'date') {
      result.sort((a, b) => a.date.compareTo(b.date));
    } else if (sort == 'rating') {
      result.sort((a, b) => (a.rating100 ?? 0).compareTo(b.rating100 ?? 0));
    }

    if (descending) {
      result = result.reversed.toList();
    }

    return result;
  }

  @override
  Future<Scene> getSceneById(String id) async {
    return scenes.firstWhere((s) => s.id == id);
  }

  @override
  Future<void> updateSceneRating(String id, int rating100) async {
    final index = scenes.indexWhere((s) => s.id == id);
    if (index != -1) {
      scenes[index] = scenes[index].copyWith(rating100: rating100);
    }
  }

  @override
  Future<void> incrementSceneOCounter(String id) async {
    final index = scenes.indexWhere((s) => s.id == id);
    if (index != -1) {
      scenes[index] = scenes[index].copyWith(
        oCounter: scenes[index].oCounter + 1,
      );
    }
  }

  @override
  Future<void> incrementScenePlayCount(String id) async {
    final index = scenes.indexWhere((s) => s.id == id);
    if (index != -1) {
      scenes[index] = scenes[index].copyWith(
        playCount: scenes[index].playCount + 1,
      );
    }
  }
}

void main() {
  late SharedPreferences prefs;
  late MockSceneRepository repo;

  final testScenes = [
    Scene(
      id: '1',
      title: 'Zebra Scene',
      date: DateTime(2023, 1, 1),
      rating100: 20,
      oCounter: 0,
      organized: false,
      interactive: false,
      resumeTime: null,
      playCount: 0,
      files: [],
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: 'http://test.com/1',
      ),
      studioId: null,
      studioName: null,
      studioImagePath: null,
      performerIds: [],
      performerNames: [],
      performerImagePaths: [],
      tagIds: [],
      tagNames: [],
    ),
    Scene(
      id: '2',
      title: 'Apple Scene',
      date: DateTime(2024, 1, 1),
      rating100: 100,
      oCounter: 5,
      organized: true,
      interactive: false,
      resumeTime: null,
      playCount: 10,
      files: [],
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: 'http://test.com/2',
      ),
      studioId: null,
      studioName: null,
      studioImagePath: null,
      performerIds: [],
      performerNames: [],
      performerImagePaths: [],
      tagIds: [],
      tagNames: [],
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = MockSceneRepository(testScenes);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWithValue(repo),
      ],
      child: const MyApp(),
    );
  }

  testWidgets('Navigation, Sorting, and Filtering Test', (tester) async {
    // Set a much larger window size to fit the bottom sheets
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsOneWidget);

    // Test Sorting
    await tester.tap(find.byIcon(Icons.sort));
    await tester.pump(const Duration(milliseconds: 500));

    // Select Title sort
    await tester.tap(find.text('Title'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.text('Apply Sort'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    // In descending order, Zebra (Z) should be BELOW Apple (A) in Y coordinates
    final zebraPos = tester.getCenter(find.text('Zebra Scene')).dy;
    final applePos = tester.getCenter(find.text('Apple Scene')).dy;
    print('Sorting result: Zebra at $zebraPos, Apple at $applePos');
    expect(zebraPos > applePos, isTrue);

    // Test Filtering (Organized only)
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Organized only'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Apply Filters'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Apple Scene'), findsOneWidget);
    expect(find.text('Zebra Scene'), findsNothing);

    // Navigation to details
    await tester.tap(find.text('Apple Scene'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Scene Details'), findsOneWidget);
    expect(find.text('O: 5'), findsOneWidget);

    // Test O-Counter increment
    await tester.tap(find.text('O: 5'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('O: 6'), findsOneWidget);
  });
}
