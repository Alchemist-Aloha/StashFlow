import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/main.dart';

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
  Future<Scene> getSceneById(String id) async {
    return _scenes.firstWhere((scene) => scene.id == id);
  }

  @override
  Future<void> updateSceneRating(String id, int rating100) async {}

  @override
  Future<void> incrementSceneOCounter(String id) async {}

  @override
  Future<void> incrementScenePlayCount(String id) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('core flow: browse, search, and play action', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
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
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alpha Scene'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'alpha');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alpha Scene'));
    await tester.pumpAndSettle();
    expect(find.text('Scene Details'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();

    expect(find.text('No stream URL available'), findsOneWidget);
  });
}
