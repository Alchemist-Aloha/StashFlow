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
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/main.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_media_provider.dart';
import 'helpers/test_helpers.dart';

class MockSceneRepository implements SceneRepository {
  final List<Scene> scenes;
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
  }) async => scenes;

  @override
  Future<Scene> getSceneById(String id, {bool refresh = false}) async =>
      scenes.firstWhere((s) => s.id == id);

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
  testWidgets('Video Playback Startup Test', (tester) async {
    // Set a larger window size to avoid hit test issues
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    SharedPreferences.setMockInitialValues({
      'prefer_scene_streams': false,
      'server_base_url': 'http://localhost:9999',
    });
    final prefs = await SharedPreferences.getInstance();

    final testScene = Scene(
      id: 'play-1',
      title: 'Play Scene',
      date: DateTime(2024, 1, 1),
      rating100: 0,
      oCounter: 0,
      organized: true,
      interactive: false,
      resumeTime: null,
      playCount: 0,
      files: [],
      paths: const ScenePaths(
        screenshot: null,
        preview: null,
        stream: 'http://test.com/stream.mp4',
      ),
      urls: [],
      studioId: null,
      studioName: null,
      studioImagePath: null,
      performerIds: [],
      performerNames: [],
      performerImagePaths: [],
      tagIds: [],
      tagNames: [],
    );

    final repo = MockSceneRepository([testScene]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(repo),
          studioMediaProvider.overrideWith((ref, id) => const []),
          streamResolverProvider.overrideWith(MockStreamResolver.new),
          mediaHeadersProvider.overrideWithValue(const {}),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Navigate to details
    await tester.tap(find.text('Play Scene'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify we are on details page
    expect(find.text('Scene Details'), findsOneWidget);

    // Find the play button in the video player overlay if not auto-started
    if (find.byIcon(Icons.play_arrow).first.evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.play_arrow).first);
      await tester.pump();
    }
  });
}
