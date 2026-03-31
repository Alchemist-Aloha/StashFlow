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

import 'package:stash_app_flutter/features/images/domain/entities/image.dart' as entity;
import 'package:stash_app_flutter/features/images/domain/repositories/image_repository.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';
import 'package:stash_app_flutter/features/galleries/domain/repositories/gallery_repository.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';

import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery_filter.dart';
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
  }) async =>
      [
        Scene.fromJson({
          'id': '1',
          'title': 'Test Scene',
          'date': '2023-01-01',
          'rating100': 80,
          'o_counter': 0,
          'organized': true,
          'interactive': false,
          'resume_time': null,
          'play_count': 0,
          'files': [],
          'paths': {'screenshot': null, 'preview': null, 'stream': null},
          'urls': [],
          'studio_id': null,
          'studio_name': null,
          'studio_image_path': null,
          'performer_ids': [],
          'performer_names': [],
          'performer_image_paths': [],
          'tag_ids': [],
          'tag_names': [],
        })
      ];

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
  }) async =>
      [
        Performer.fromJson({
          'id': '1',
          'name': 'Test Performer',
          'favorite': false,
          'image_path': null,
          'scene_count': 0,
          'urls': [],
          'birthdate': null,
          'ethnicity': null,
          'country': null,
          'eye_color': null,
          'hair_color': null,
          'height_cm': null,
          'measurements': null,
          'fake_tits': null,
          'career_length': null,
          'tattoos': null,
          'piercings': null,
          'alias_list': [],
          'favorite_count': 0,
        })
      ];

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
  }) async =>
      [
        Studio.fromJson({
          'id': '1',
          'name': 'Test Studio',
          'favorite': false,
          'image_path': null,
          'scene_count': 0,
          'image_count': 0,
          'gallery_count': 0,
        })
      ];

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
  }) async =>
      [
        Tag.fromJson({
          'id': '1',
          'name': 'Test Tag',
          'favorite': false,
          'scene_count': 0,
          'image_count': 0,
          'gallery_count': 0,
        })
      ];

  @override
  Future<Tag> getTagById(String id, {bool refresh = false}) =>
      throw UnimplementedError();

  @override
  Future<void> setTagFavorite(String id, bool favorite) async {}
}

class MockImageRepository implements ImageRepository {
  @override
  Future<List<entity.Image>> findImages({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    String? galleryId,
    ImageFilter? imageFilter,
  }) async =>
      [
        entity.Image.fromJson({
          'id': '1',
          'title': 'Test Image',
          'visual_files': [],
          'paths': {'thumbnail': null, 'preview': null, 'image': 'img.jpg'},
          'urls': [],
        })
      ];

  @override
  Future<entity.Image> getImageById(String id, {bool refresh = false}) =>
      throw UnimplementedError();
}

class MockGalleryRepository implements GalleryRepository {
  @override
  Future<List<Gallery>> findGalleries({
    int? page,
    int? perPage,
    String? filter,
    String? sort,
    bool? descending,
    GalleryFilter? galleryFilter,
    String? performerId,
  }) async {
    return [const Gallery(id: '1', title: 'Test Gallery', imageCount: 1)];
  }

  @override
  Future<Gallery> getGalleryById(String id, {bool refresh = false}) =>
      throw UnimplementedError();
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'initial_tab': 0,
      'server_base_url': 'http://localhost:9999',
    });
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
        imageRepositoryProvider.overrideWithValue(MockImageRepository()),
        galleryRepositoryProvider.overrideWithValue(MockGalleryRepository()),
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

    final texts = tester.allWidgets.whereType<Text>().map((t) => t.data).toList();
    print('Rendered texts: $texts');

    // Verify initial route is Scenes
    expect(find.text('Scenes'), findsWidgets);

    // Tap Performers Tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Performers'));
    await tester.pumpAndSettle();
    expect(find.text('Performers'), findsWidgets);

    // Tap Studios Tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Studios'));
    await tester.pumpAndSettle();
    expect(find.text('Studios'), findsWidgets);

    // Tap Tags Tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Tags'));
    await tester.pumpAndSettle();
    expect(find.text('Tags'), findsWidgets);

    // Tap Galleries Tab
    await tester.tap(find.widgetWithText(NavigationDestination, 'Galleries'));
    await tester.pumpAndSettle();
    expect(find.text('Galleries'), findsWidgets);

    // Navigate to Images via top panel button
    await tester.tap(find.byIcon(Icons.image));
    await tester.pumpAndSettle();
    expect(find.text('Images'), findsWidgets);

    // Navigate back to Galleries
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Galleries'), findsWidgets);

    // Tap Settings icon in AppBar (on Galleries page)
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Server'), findsAtLeast(1));
    expect(find.text('Playback'), findsAtLeast(1));

    // Navigate back to Galleries
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Galleries'), findsAtLeast(1));

    // Navigate back to Scenes
    await tester.tap(find.widgetWithText(NavigationDestination, 'Scenes'));
    await tester.pumpAndSettle();
    expect(find.text('Scenes'), findsAtLeast(1));
  });
}
