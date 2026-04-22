import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraper.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scenes_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'helpers/test_helpers.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';

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

    await pumpTestWidget(
      tester,
      overrides: [sceneRepositoryProvider.overrideWithValue(repo)],
      child: const ScenesPage(),
    );

    await tester.pumpAndSettle();
    expect(find.text('Alpha Scene'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(ScenesPage)))!;
    expect(find.text(l10n.common_no_items), findsOneWidget);
  });
}
