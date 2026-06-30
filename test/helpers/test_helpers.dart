import 'package:flutter/material.dart' hide Image;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/widgets/error_state_view.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_repository.dart';
import 'package:stash_app_flutter/features/performers/data/repositories/graphql_performer_repository.dart';
import 'package:stash_app_flutter/features/studios/data/repositories/graphql_studio_repository.dart';
import 'package:stash_app_flutter/features/tags/data/repositories/graphql_tag_repository.dart';
import 'package:stash_app_flutter/features/images/data/repositories/graphql_image_repository.dart';
import 'package:stash_app_flutter/features/groups/data/repositories/graphql_group_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_deduplication.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer_filter.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio_filter.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraper.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_performer.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_scene.dart';
import 'package:stash_app_flutter/core/domain/entities/scraped/scraped_studio.dart';

abstract class MockRepositoryState<T> {
  List<T> data = [];
  bool shouldThrow = false;
  String errorMessage = 'Mock error';

  void setThrow(bool value, {String message = 'Mock error'}) {
    shouldThrow = value;
    errorMessage = message;
  }

  void setData(List<T> value) {
    data = value;
    shouldThrow = false;
  }

  void withData(List<T> value) => setData(value);
  void withEmpty() => setData([]);
  void withError(String message) => setThrow(true, message: message);
}

class MockGraphQLSceneRepository extends MockRepositoryState<Scene>
    implements GraphQLSceneRepository {
  String? deletedSceneId;
  bool? deletedSceneDeleteFile;
  bool? deletedSceneDeleteGenerated;
  final List<String> deletedSceneMarkerIds = [];
  final List<
    ({
      String sceneId,
      String title,
      double seconds,
      double? endSeconds,
      String? primaryTagId,
      List<String> tagIds,
    })
  >
  createdSceneMarkers = [];
  final List<bool> getSceneByIdRefreshValues = [];
  List<SceneDuplicateGroup> duplicateGroups = [];
  int missingPhashCount = 0;
  int? lastDuplicateDistance;
  double? lastDuplicateDurationDiff;
  int duplicateFetchCount = 0;
  int? lastFindScenesPage;
  int? lastFindScenesPerPage;
  String? lastFindScenesFilter;
  String? lastFindScenesSort;
  bool? lastFindScenesDescending;
  SceneFilter? lastFindScenesSceneFilter;
  final List<
    ({
      int? page,
      int? perPage,
      String? filter,
      String? sort,
      bool descending,
      bool? organized,
      SceneFilter? sceneFilter,
    })
  >
  findSceneCalls = [];
  final List<List<Scene>> findScenesResponses = [];
  final List<({String? sceneId, String? stashBoxEndpoint, String? scraperId})>
  scrapeSceneCalls = [];
  final Map<String, List<ScrapedScene>> scrapedScenesBySceneId = {};
  final List<
    ({
      String sceneId,
      ScrapedScene scraped,
      bool mergeValues,
      bool organized,
      List<String>? performerIds,
      List<String>? tagIds,
      String? studioId,
    })
  >
  savedScrapedScenes = [];

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
    if (shouldThrow) throw Exception(errorMessage);
    lastFindScenesPage = page;
    lastFindScenesPerPage = perPage;
    lastFindScenesFilter = filter;
    lastFindScenesSort = sort;
    lastFindScenesDescending = descending;
    lastFindScenesSceneFilter = sceneFilter;
    findSceneCalls.add((
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort,
      descending: descending,
      organized: organized,
      sceneFilter: sceneFilter,
    ));
    if (findScenesResponses.isNotEmpty) {
      return findScenesResponses.removeAt(0);
    }
    return data;
  }

  @override
  Future<Scene> getSceneById(String id, {bool refresh = false}) async {
    if (shouldThrow) throw Exception(errorMessage);
    getSceneByIdRefreshValues.add(refresh);
    return data.firstWhere((s) => s.id == id);
  }

  @override
  Future<SceneMarker> createSceneMarker({
    required String sceneId,
    required String title,
    double seconds = 0,
    double? endSeconds,
    String? primaryTagId,
    List<String> tagIds = const [],
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    createdSceneMarkers.add((
      sceneId: sceneId,
      title: title,
      seconds: seconds,
      endSeconds: endSeconds,
      primaryTagId: primaryTagId,
      tagIds: tagIds,
    ));
    return SceneMarker(
      id: 'marker-${createdSceneMarkers.length}',
      title: title,
      seconds: seconds,
      endSeconds: endSeconds,
      screenshot: null,
      preview: null,
      stream: null,
      primaryTagId: primaryTagId,
      primaryTagName: null,
      tagIds: tagIds,
      tagNames: const [],
    );
  }

  @override
  Future<void> deleteSceneMarker(String markerId) async {
    if (shouldThrow) throw Exception(errorMessage);
    deletedSceneMarkerIds.add(markerId);
  }

  @override
  Future<List<Scraper>> listScrapers({required List<String> types}) async {
    if (shouldThrow) throw Exception(errorMessage);
    return [];
  }

  @override
  Future<List<ScrapedScene>> scrapeSingleScene({
    String? scraperId,
    String? stashBoxEndpoint,
    String? sceneId,
    String? query,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    scrapeSceneCalls.add((
      sceneId: sceneId,
      stashBoxEndpoint: stashBoxEndpoint,
      scraperId: scraperId,
    ));
    return scrapedScenesBySceneId[sceneId] ?? [];
  }

  @override
  Future<ScrapedScene?> scrapeSceneURL(String url) async {
    if (shouldThrow) throw Exception(errorMessage);
    return null;
  }

  @override
  Future<void> generatePhash(String sceneId) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<void> saveScrapedScene({
    required String sceneId,
    required ScrapedScene scraped,
    bool mergeValues = false,
    List<String>? performerIds,
    List<String>? tagIds,
    String? studioId,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    savedScrapedScenes.add((
      sceneId: sceneId,
      scraped: scraped,
      mergeValues: mergeValues,
      organized: true,
      performerIds: performerIds,
      tagIds: tagIds,
      studioId: studioId,
    ));
    data = [
      for (final scene in data)
        if (scene.id == sceneId) scene.copyWith(organized: true) else scene,
    ];
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findPerformerCandidates(
    List<String> performers,
  ) async {
    if (shouldThrow) throw Exception(errorMessage);
    return {};
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(
    List<String> tags,
  ) async {
    if (shouldThrow) throw Exception(errorMessage);
    return {};
  }

  @override
  Future<void> updateSceneRating(String id, int rating100) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<void> incrementSceneOCounter(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<void> incrementScenePlayCount(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<void> saveSceneActivity(
    String id, {
    double? resumeTime,
    double? playDuration,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<void> deleteScene(
    String id, {
    required bool deleteFile,
    bool deleteGenerated = true,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    deletedSceneId = id;
    deletedSceneDeleteFile = deleteFile;
    deletedSceneDeleteGenerated = deleteGenerated;
    data.removeWhere((scene) => scene.id == id);
  }

  @override
  Future<List<SceneDuplicateGroup>> findDuplicateScenes({
    int distance = 0,
    double durationDiff = 1,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    duplicateFetchCount += 1;
    lastDuplicateDistance = distance;
    lastDuplicateDurationDiff = durationDiff;
    return duplicateGroups;
  }

  @override
  Future<int> countScenesMissingPhash() async {
    if (shouldThrow) throw Exception(errorMessage);
    return missingPhashCount;
  }
}

class MockGraphQLPerformerRepository extends MockRepositoryState<Performer>
    implements GraphQLPerformerRepository {
  @override
  Future<List<Performer>> findPerformers({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    PerformerFilter? performerFilter,
    bool favoritesOnly = false,
    List<String>? genders,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data;
  }

  @override
  Future<Performer> getPerformerById(String id, {bool refresh = false}) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((p) => p.id == id);
  }

  @override
  Future<void> setPerformerFavorite(String id, bool favorite) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<List<ScrapedPerformer>> scrapePerformer({
    String? scraperId,
    String? stashBoxEndpoint,
    String? performerId,
    String? query,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return [];
  }

  @override
  Future<ScrapedPerformer?> scrapePerformerURL(String url) async {
    if (shouldThrow) throw Exception(errorMessage);
    return null;
  }

  @override
  Future<void> updatePerformer({
    required String id,
    required Map<String, dynamic> input,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
  }
}

class MockGraphQLStudioRepository extends MockRepositoryState<Studio>
    implements GraphQLStudioRepository {
  @override
  Future<List<Studio>> findStudios({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    StudioFilter? studioFilter,
    bool favoritesOnly = false,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data;
  }

  @override
  Future<Studio> getStudioById(String id, {bool refresh = false}) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((s) => s.id == id);
  }

  @override
  Future<void> setStudioFavorite(String id, bool favorite) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<List<ScrapedStudio>> scrapeStudio({
    String? scraperId,
    String? stashBoxEndpoint,
    String? studioId,
    String? query,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return [];
  }

  @override
  Future<ScrapedStudio?> scrapeStudioURL(String url) async {
    if (shouldThrow) throw Exception(errorMessage);
    return null;
  }

  @override
  Future<void> updateStudio({
    required String id,
    required Map<String, dynamic> input,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
  }
}

class MockGraphQLTagRepository extends MockRepositoryState<Tag>
    implements GraphQLTagRepository {
  @override
  Future<List<Tag>> findTags({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    bool favoritesOnly = false,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data;
  }

  @override
  Future<Tag> getTagById(String id, {bool refresh = false}) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((t) => t.id == id);
  }

  @override
  Future<void> setTagFavorite(String id, bool favorite) async {
    if (shouldThrow) throw Exception(errorMessage);
  }
}

class MockGraphQLGroupRepository extends MockRepositoryState<Group>
    implements GraphQLGroupRepository {
  @override
  Future<List<Group>> findGroups({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    GroupFilter? groupFilter,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data;
  }

  @override
  Future<Group> getGroupById(String id, {bool refresh = false}) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((g) => g.id == id);
  }
}

class MockGraphQLImageRepository extends MockRepositoryState<Image>
    implements GraphQLImageRepository {
  final List<
    ({
      int? page,
      int? perPage,
      String? filter,
      String? sort,
      bool? descending,
      String? galleryId,
      ImageFilter? imageFilter,
    })
  >
  findImageCalls = [];

  @override
  Future<List<Image>> findImages({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    String? galleryId,
    ImageFilter? imageFilter,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    findImageCalls.add((
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort,
      descending: descending,
      galleryId: galleryId,
      imageFilter: imageFilter,
    ));
    return data;
  }

  @override
  Future<Image> getImageById(String id, {bool refresh = false}) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((i) => i.id == id);
  }

  @override
  Future<void> updateImageRating(String id, int rating100) async {
    if (shouldThrow) throw Exception(errorMessage);
  }
}

Future<void> pumpTestWidget(
  WidgetTester tester, {
  SharedPreferences? prefs,
  required Widget child,
  List<dynamic> overrides = const [],
}) async {
  if (prefs == null) {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  }
  PackageInfo.setMockInitialValues(
    appName: 'StashFlow',
    packageName: 'io.github.alchemistaloha.stashflow',
    version: '1.10.0',
    buildNumber: '1',
    buildSignature: '',
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ...overrides,
      ],
      child: MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: GoRouter(
          routes: [GoRoute(path: '/', builder: (context, state) => child)],
        ),
      ),
    ),
  );
}

extension CommonFindersExtension on CommonFinders {
  Finder errorView({String? message}) {
    if (message != null) {
      return find.descendant(
        of: find.byType(ErrorStateView),
        matching: find.textContaining(message),
      );
    }
    return find.byType(ErrorStateView);
  }

  Finder retryButton() => find.descendant(
    of: find.byType(ErrorStateView),
    matching: find.byType(FilledButton),
  );
}
