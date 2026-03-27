import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraper.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraped_scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scenes_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

class FakeSceneRepository implements SceneRepository {
  final List<Scene> _scenes;

  FakeSceneRepository(this._scenes);

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
    if (filter == null || filter.isEmpty) return _scenes;
    return _scenes
        .where(
          (scene) => scene.title.toLowerCase().contains(filter.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<Scene> getSceneById(String id, {bool refresh = false}) async {
    return _scenes.firstWhere((scene) => scene.id == id);
  }

  @override
  Future<void> updateSceneRating(String id, int rating100) async {}

  @override
  Future<void> incrementSceneOCounter(String id) async {}

  @override
  Future<void> incrementScenePlayCount(String id) async {}

  @override
  Future<List<Scraper>> listScrapers({required List<String> types}) async => [];

  @override
  Future<List<ScrapedScene>> scrapeSingleScene({
    required String scraperId,
    required String sceneId,
  }) async => [];

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
    List<String> queries,
  ) async => {};

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(
    List<String> tags,
  ) async => {};
}

void main() {
  testWidgets('ScenesPage renders and filters with mock repository', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final repo = FakeSceneRepository([
      Scene(
        id: 'scene-1',
        title: 'Alpha Scene',
        details: 'details',
        path: null,
        date: DateTime(2024, 1, 1),
        rating100: 80,
        oCounter: 0,
        organized: true,
        interactive: false,
        resumeTime: null,
        playCount: 1,
        files: const [],
        paths: const ScenePaths(screenshot: null, preview: null, stream: null),
        urls: const [],
        studioId: 'studio-1',
        studioName: 'Studio',
        studioImagePath: null,
        performerIds: const ['p1'],
        performerNames: const ['Performer'],
        performerImagePaths: const [null],
        tagIds: const ['t1'],
        tagNames: const ['Tag'],
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sceneRepositoryProvider.overrideWithValue(repo),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ScenesPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Alpha Scene'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();

    expect(find.text('No items found'), findsOneWidget);
  });
}
