import 'package:flutter/material.dart' hide Image;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/widgets/error_state_view.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/performers/domain/repositories/performer_repository.dart';
import 'package:stash_app_flutter/features/studios/domain/repositories/studio_repository.dart';
import 'package:stash_app_flutter/features/tags/domain/repositories/tag_repository.dart';
import 'package:stash_app_flutter/features/images/domain/repositories/image_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer_filter.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio_filter.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraped_scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraper.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

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
  }

  void withData(List<T> value) => setData(value);
  void withEmpty() => setData([]);
  void withError(String message) => setThrow(true, message: message);
}

class MockSceneRepository extends MockRepositoryState<Scene>
    implements SceneRepository {
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
    return data;
  }

  @override
  Future<Scene> getSceneById(String id, {bool refresh = false}) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((s) => s.id == id);
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
    return [];
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
}

class MockPerformerRepository extends MockRepositoryState<Performer>
    implements PerformerRepository {
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

class MockStudioRepository extends MockRepositoryState<Studio>
    implements StudioRepository {
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

class MockTagRepository extends MockRepositoryState<Tag>
    implements TagRepository {
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

class MockImageRepository extends MockRepositoryState<Image>
    implements ImageRepository {
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
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: child,
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
