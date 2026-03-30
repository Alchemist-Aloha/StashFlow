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

import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/performers/domain/repositories/performer_repository.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';

import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/studios/domain/repositories/studio_repository.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_list_provider.dart';

import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/tags/domain/repositories/tag_repository.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';

import 'package:stash_app_flutter/main.dart';

class MockSceneRepository implements SceneRepository {
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
  }) async => [];

  @override
  Future<Scene> getSceneById(String id, {bool refresh = false}) =>
      throw UnimplementedError();

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

class MockPerformerRepository implements PerformerRepository {
  @override
  Future<List<Performer>> findPerformers({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool descending = true,
    bool favoritesOnly = false,
    List<String>? genders,
  }) async => [];

  @override
  Future<Performer> getPerformerById(String id, {bool refresh = false}) =>
      throw UnimplementedError();

  @override
  Future<void> setPerformerFavorite(String id, bool favorite) async {}
}

class MockStudioRepository implements StudioRepository {
  @override
  Future<List<Studio>> findStudios({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    bool favoritesOnly = false,
  }) async => [];

  @override
  Future<Studio> getStudioById(String id, {bool refresh = false}) =>
      throw UnimplementedError();

  @override
  Future<void> setStudioFavorite(String id, bool favorite) async {}
}

class MockTagRepository implements TagRepository {
  @override
  Future<List<Tag>> findTags({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    bool favoritesOnly = false,
  }) async => [];

  @override
  Future<Tag> getTagById(String id, {bool refresh = false}) =>
      throw UnimplementedError();

  @override
  Future<void> setTagFavorite(String id, bool favorite) async {}
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sceneRepositoryProvider.overrideWithValue(MockSceneRepository()),
        performerRepositoryProvider.overrideWithValue(
          MockPerformerRepository(),
        ),
        studioRepositoryProvider.overrideWithValue(MockStudioRepository()),
        tagRepositoryProvider.overrideWithValue(MockTagRepository()),
      ],
      child: const MyApp(),
    );
  }

  testWidgets('UI Navigation thoroughly tests bottom tabs routing', (
    WidgetTester tester,
  ) async {
    // Use mobile width to ensure NavigationBar is used
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify initial route is Scenes
    expect(find.text('Scenes').first, findsWidgets);

    // Tap Performers Tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Performers'));
    await tester.pumpAndSettle();
    expect(find.text('Performers').first, findsWidgets);

    // Tap Studios Tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Studios'));
    await tester.pumpAndSettle();
    expect(find.text('Studios').first, findsWidgets);

    // Tap Tags Tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Tags'));
    await tester.pumpAndSettle();
    expect(find.text('Tags').first, findsWidgets);

    // Tap Settings Tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Settings'));
    await tester.pumpAndSettle();
    // Verification that we are on Settings Hub page
    expect(find.text('Server'), findsWidgets);
    expect(find.text('Playback'), findsWidgets);

    // Navigate back to Scenes
    await tester.tap(find.widgetWithText(NavigationDestination, 'Scenes'));
    await tester.pumpAndSettle();
    expect(find.text('Scenes').first, findsWidgets);
  });
}
