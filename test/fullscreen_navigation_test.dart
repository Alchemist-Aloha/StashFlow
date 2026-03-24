import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/tiktok_scenes_view.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';

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

class MockStreamResolver extends StreamResolver {
  @override
  Future<StreamChoice?> resolvePreferredStream(Scene scene) async {
    return StreamChoice(
      url: scene.paths.stream ?? '',
      mimeType: 'video/mp4',
      label: 'Direct',
    );
  }
}

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
  Future<Scene> getSceneById(String id) async =>
      scenes.firstWhere((s) => s.id == id);

  @override
  Future<void> updateSceneRating(String id, int rating100) async {}
  @override
  Future<void> incrementSceneOCounter(String id) async {}
  @override
  Future<void> incrementScenePlayCount(String id) async {}
}

class MockPerformerRepository implements PerformerRepository {
  @override
  Future<List<Performer>> findPerformers({
    dynamic page,
    dynamic perPage,
    dynamic filter,
    dynamic sort,
    dynamic descending = true,
    dynamic favoritesOnly = false,
    dynamic genders,
  }) async => [];
  @override
  Future<Performer> getPerformerById(String id) => throw UnimplementedError();
  @override
  Future<void> setPerformerFavorite(String id, bool favorite) async {}
}

class MockStudioRepository implements StudioRepository {
  @override
  Future<List<Studio>> findStudios({
    dynamic page,
    dynamic perPage,
    dynamic filter,
    dynamic sort,
    dynamic descending,
    dynamic favoritesOnly = false,
  }) async => [];
  @override
  Future<Studio> getStudioById(String id) => throw UnimplementedError();
  @override
  Future<void> setStudioFavorite(String id, bool favorite) async {}
}

class MockTagRepository implements TagRepository {
  @override
  Future<List<Tag>> findTags({
    dynamic page,
    dynamic perPage,
    dynamic filter,
    dynamic sort,
    dynamic descending,
    dynamic favoritesOnly = false,
  }) async => [];
  @override
  Future<Tag> getTagById(String id) => throw UnimplementedError();
  @override
  Future<void> setTagFavorite(String id, bool favorite) async {}
}

void main() {
  late SharedPreferences prefs;
  final mockGraphQLClient = GraphQLClient(
    link: Link.function((request, [forward]) async* {
      yield Response(
        data: <String, dynamic>{
          'sceneStreams': [],
          'findScene': {'sceneStreams': []},
        },
        response: <String, dynamic>{},
      );
    }),
    cache: GraphQLCache(store: InMemoryStore()),
  );

  final testScene = Scene(
    id: '1',
    title: 'Test Scene',
    date: DateTime.now(),
    rating100: 80,
    oCounter: 5,
    organized: true,
    interactive: false,
    resumeTime: null,
    playCount: 10,
    files: [
      const SceneFile(
        format: 'mp4',
        width: 1920,
        height: 1080,
        videoCodec: 'h264',
        audioCodec: 'aac',
        bitRate: 5000,
        duration: 120.0,
        frameRate: 30.0,
      ),
    ],
    paths: const ScenePaths(
      screenshot: 'http://localhost/thumb.jpg',
      preview: 'http://localhost/preview.mp4',
      stream: 'http://localhost/stream.mp4',
    ),
    studioId: null,
    studioName: 'Test Studio',
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );

  final nextScene = Scene(
    id: '2',
    title: 'Next Scene',
    date: DateTime.now().add(const Duration(days: 1)),
    rating100: 90,
    oCounter: 3,
    organized: true,
    interactive: false,
    resumeTime: null,
    playCount: 1,
    files: [
      const SceneFile(
        format: 'mp4',
        width: 1920,
        height: 1080,
        videoCodec: 'h264',
        audioCodec: 'aac',
        bitRate: 5000,
        duration: 100.0,
        frameRate: 30.0,
      ),
    ],
    paths: const ScenePaths(
      screenshot: 'http://localhost/thumb2.jpg',
      preview: 'http://localhost/preview2.mp4',
      stream: 'http://localhost/stream2.mp4',
    ),
    studioId: null,
    studioName: 'Test Studio',
    studioImagePath: null,
    performerIds: [],
    performerNames: [],
    performerImagePaths: [],
    tagIds: [],
    tagNames: [],
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'server_base_url': 'http://localhost',
      'server_api_key': 'test-key',
    });
    prefs = await SharedPreferences.getInstance();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        graphqlClientProvider.overrideWithValue(mockGraphQLClient),
        streamResolverProvider.overrideWith(MockStreamResolver.new),
        sceneRepositoryProvider.overrideWithValue(
          MockSceneRepository([testScene, nextScene]),
        ),
        performerRepositoryProvider.overrideWithValue(
          MockPerformerRepository(),
        ),
        studioRepositoryProvider.overrideWithValue(MockStudioRepository()),
        tagRepositoryProvider.overrideWithValue(MockTagRepository()),
      ],
      child: const MyApp(),
    );
  }

  testWidgets('Robust Fullscreen Navigation: Standard -> Fullscreen -> Back', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 1. Open Scene Details
    await tester.tap(find.text('Test Scene'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Scene Details'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SceneDetailsPage)),
    );

    // 2. Trigger Fullscreen navigation manually to avoid flaky UI tap issues in test environment
    // This directly tests the GoRouter route we added and the FullscreenPlayerPage
    final context = tester.element(find.byType(SceneDetailsPage));
    context.push('/scenes/scene/${testScene.id}/fullscreen');

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 3. Verify we are in Fullscreen
    expect(find.text('Initializing player...'), findsOneWidget);
    expect(container.read(playerStateProvider).isFullScreen, isTrue);

    // 4. Simulate Back Gesture / Pop
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 5. Verify we are back in Scene Details and state is reset
    expect(find.text('Scene Details'), findsOneWidget);
    expect(container.read(playerStateProvider).isFullScreen, isFalse);

    // Final cleanup
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'SceneDetailsPage updates route when playback moves via activeScene null transition',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open initial scene detail
      await tester.tap(find.text('Test Scene'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Scene Details'), findsOneWidget);
      expect(find.text('Test Scene'), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(SceneDetailsPage)),
      );
      final playerNotifier = container.read(playerStateProvider.notifier);

      // Simulate exact transition from provider: current->null->next
      playerNotifier.state = playerNotifier.state.copyWith(
        activeScene: testScene,
      );
      await tester.pump(const Duration(milliseconds: 500));

      playerNotifier.state = playerNotifier.state.copyWith(activeScene: null);
      await tester.pump(const Duration(milliseconds: 500));

      playerNotifier.state = playerNotifier.state.copyWith(
        activeScene: nextScene,
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Next Scene'), findsOneWidget);
      expect(find.text('Test Scene'), findsNothing);
    },
  );

  testWidgets('Robust Fullscreen Navigation: TikTok -> Fullscreen -> Back', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Enable TikTok layout
    await prefs.setBool('scene_tiktok_layout', true);

    await tester.pumpWidget(createTestWidget());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 1. Verify TikTok layout
    expect(find.byType(TiktokScenesView), findsOneWidget);

    // 2. Trigger Fullscreen navigation manually (following the new robust flow)
    final context = tester.element(find.byType(TiktokScenesView));
    context.push('/scenes/scene/${testScene.id}');
    context.push('/scenes/scene/${testScene.id}/fullscreen');

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 3. Verify Fullscreen
    expect(find.text('Initializing player...'), findsOneWidget);

    // 4. Simulate Back (should go to Details)
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // 5. Verify back in Scene Details
    expect(find.text('Scene Details'), findsOneWidget);

    // 6. Simulate Back again (should go to TikTok)
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(TiktokScenesView), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TiktokScenesView)),
    );
    expect(container.read(playerStateProvider).isFullScreen, isFalse);

    // Final cleanup
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
