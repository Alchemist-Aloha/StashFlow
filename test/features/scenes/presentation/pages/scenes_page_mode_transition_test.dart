import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_deduplication.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraper.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scenes_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_view_mode.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

class _FakeGraphQLSceneRepository implements GraphQLSceneRepository {
  _FakeGraphQLSceneRepository(this._scenes);

  final List<Scene> _scenes;

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
  }) async => _scenes;

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
    required dynamic scraped,
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

class _TestSceneTiktokLayout extends SceneTiktokLayout {
  @override
  bool build() => true;
}

class _TestPlayerState extends PlayerState {
  int stopCalls = 0;

  @override
  GlobalPlayerState build() {
    return GlobalPlayerState(
      activeScene: _scene,
      isPlaying: true,
      viewMode: PlayerViewMode.tiktok,
      streamSource: 'tiktok-promotion',
    );
  }

  @override
  void stop({bool dismissNotification = true}) {
    stopCalls++;
    state = GlobalPlayerState(
      playEndBehavior: state.playEndBehavior,
      showVideoDebugInfo: state.showVideoDebugInfo,
      useDoubleTapSeek: state.useDoubleTapSeek,
      enableBackgroundPlayback: state.enableBackgroundPlayback,
      enableNativePip: state.enableNativePip,
      videoGravityOrientation: state.videoGravityOrientation,
      defaultSubtitleLanguage: state.defaultSubtitleLanguage,
      subtitleFontSize: state.subtitleFontSize,
      subtitlePositionBottomRatio: state.subtitlePositionBottomRatio,
      subtitleTextAlignment: state.subtitleTextAlignment,
    );
  }
}

final _scene = Scene(
  id: 'scene-1',
  title: 'Feed Scene',
  date: DateTime(2024, 1, 1),
  rating100: null,
  oCounter: 0,
  organized: false,
  interactive: false,
  resumeTime: null,
  playCount: 0,
  playDuration: 0,
  files: const [],
  paths: const ScenePaths(screenshot: null, preview: null, stream: null),
  urls: const [],
  studioId: null,
  studioName: 'Studio',
  studioImagePath: null,
  performerIds: const [],
  performerNames: const [],
  performerImagePaths: const [],
  tagIds: const [],
  tagNames: const [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('switching from feed mode stops promoted feed playback', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final repo = _FakeGraphQLSceneRepository(const []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(repo),
          sceneTiktokLayoutProvider.overrideWith(_TestSceneTiktokLayout.new),
          playerStateProvider.overrideWith(_TestPlayerState.new),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            return MaterialApp.router(
              theme: AppTheme.darkTheme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: GoRouter(
                initialLocation: '/scenes',
                routes: [
                  GoRoute(
                    path: '/scenes',
                    builder: (context, state) => const ScenesPage(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ScenesPage)),
    );
    final playerNotifier =
        container.read(playerStateProvider.notifier) as _TestPlayerState;

    expect(playerNotifier.stopCalls, 0);

    await container.read(sceneTiktokLayoutProvider.notifier).set(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(playerNotifier.stopCalls, 1);
  });
}
