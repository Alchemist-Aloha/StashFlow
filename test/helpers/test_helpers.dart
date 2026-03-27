import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraper.dart';
import 'package:stash_app_flutter/features/scenes/domain/models/scraped_scene.dart';

import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/domain/repositories/performer_repository.dart';

import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/studios/domain/repositories/studio_repository.dart';

import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/tags/domain/repositories/tag_repository.dart';

import 'package:stash_app_flutter/core/presentation/widgets/error_state_view.dart';

import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_media_provider.dart';

/// Base class for manual mock repositories with common state control
class MockRepositoryState<T> {
  List<T> data = [];
  bool shouldThrow = false;
  String errorMessage = 'Something went wrong';

  void withData(List<T> data) {
    this.data = data;
    shouldThrow = false;
  }

  void withEmpty() {
    data = [];
    shouldThrow = false;
  }

  void withError(String message) {
    errorMessage = message;
    shouldThrow = true;
  }
}

class MockStreamResolver extends StreamResolver {
  @override
  void build() {}

  @override
  Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
    if (scene.paths.stream != null) {
      return StreamChoice(url: scene.paths.stream!, mimeType: 'video/mp4');
    }
    return null;
  }
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
  Future<Scene> getSceneById(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((s) => s.id == id);
  }

  @override
  Future<void> updateSceneRating(String id, int rating100) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<void> incrementSceneOCounter(String id) async {}

  @override
  Future<void> incrementScenePlayCount(String id) async {}

  @override
  Future<List<Scraper>> listScrapers({required List<String> types}) async {
    if (shouldThrow) throw Exception(errorMessage);
    return [];
  }

  @override
  Future<List<ScrapedScene>> scrapeSingleScene({
    required String scraperId,
    required String sceneId,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return [];
  }

  @override
  Future<void> saveScrapedScene({
    required String sceneId,
    required ScrapedScene scraped,
    bool mergeValues = false,
    List<String>? performerIds,
    List<String>? tagIds,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findPerformerCandidates(
    List<String> queries,
  ) async {
    return {};
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> findTagCandidates(
    List<String> tags,
  ) async {
    return {};
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
    bool favoritesOnly = false,
    List<String>? genders,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data;
  }

  @override
  Future<Performer> getPerformerById(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((p) => p.id == id);
  }

  @override
  Future<void> setPerformerFavorite(String id, bool favorite) async {
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
    bool favoritesOnly = false,
  }) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data;
  }

  @override
  Future<Studio> getStudioById(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((s) => s.id == id);
  }

  @override
  Future<void> setStudioFavorite(String id, bool favorite) async {
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
  Future<Tag> getTagById(String id) async {
    if (shouldThrow) throw Exception(errorMessage);
    return data.firstWhere((t) => t.id == id);
  }

  @override
  Future<void> setTagFavorite(String id, bool favorite) async {
    if (shouldThrow) throw Exception(errorMessage);
  }
}

/// Helper to pump a widget with all necessary providers and theme
Future<void> pumpTestWidget(
  WidgetTester tester, {
  required Widget child,
  List<dynamic> overrides = const [],
  SharedPreferences? prefs,
  bool wrapWithApp = true,
}) async {
  if (prefs == null) {
    SharedPreferences.setMockInitialValues({
      'server_base_url': 'http://localhost:9999',
    });
  }
  final finalPrefs = prefs ?? await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(finalPrefs),
        studioMediaProvider.overrideWith((ref, id) => const []),
        streamResolverProvider.overrideWith(MockStreamResolver.new),
        mediaHeadersProvider.overrideWithValue(const {}),
        ...overrides,
      ],
      child: wrapWithApp
          ? MaterialApp(theme: AppTheme.darkTheme, home: child)
          : child,
    ),
  );
}

/// Extension for common finders
extension CommonFindersX on CommonFinders {
  Finder loadingSpinner() => byType(CircularProgressIndicator);

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
