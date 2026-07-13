import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scenes_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_random_navigation_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../../../helpers/test_helpers.dart';

Scene _scene(String id) {
  return Scene(
    id: id,
    title: 'Scene $id',
    date: DateTime(2024, 1, 1),
    rating100: null,
    oCounter: 0,
    organized: false,
    interactive: false,
    resumeTime: 0,
    playCount: 0,
    playDuration: 0,
    files: const [],
    paths: ScenePaths(
      screenshot: null,
      preview: null,
      stream: 'http://example.com/$id.mp4',
    ),
    urls: const [],
    studioId: null,
    studioName: null,
    studioImagePath: null,
    performerIds: const [],
    performerNames: const [],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const [],
  );
}

class _FakeSceneRandomNavigationController
    extends SceneRandomNavigationController {
  _FakeSceneRandomNavigationController(super.ref, this.result);

  final Scene? result;

  @override
  Future<Scene?> getRandomScene({String? excludeSceneId}) async => result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'ScenesPage random button uses shared controller and preserves the main queue',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final listedScene = _scene('listed');
      final randomScene = _scene('backend-random');
      final queuedA = _scene('queue-a');
      final queuedB = _scene('queue-b');
      final repo = MockGraphQLSceneRepository()..withData([listedScene]);

      final router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => const ScenesPage()),
          GoRoute(
            path: '/scenes/scene/:id',
            builder: (context, state) =>
                Text('route:${state.pathParameters['id']}'),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            sceneRepositoryProvider.overrideWithValue(repo),
            sceneRandomNavigationControllerProvider.overrideWith(
              (ref) => _FakeSceneRandomNavigationController(ref, randomScene),
            ),
          ],
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ScenesPage)),
      );
      container.read(playbackQueueProvider.notifier).setSequence([
        queuedA,
        queuedB,
      ], 1);
      final before = container.read(playbackQueueProvider);

      await tester.tap(find.byTooltip('Random scene'));
      await tester.pumpAndSettle();

      final after = container.read(playbackQueueProvider);
      expect(find.text('route:backend-random'), findsOneWidget);
      expect(after.sequence.map((scene) => scene.id).toList(), [
        'queue-a',
        'queue-b',
      ]);
      expect(after.currentIndex, before.currentIndex);
    },
  );

  testWidgets('SceneDetailsPage random button uses the shared controller', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final currentScene = _scene('current');
    final randomScene = _scene('backend-next');
    final repo = MockGraphQLSceneRepository()..withData([currentScene]);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const SceneDetailsPage(sceneId: 'current'),
        ),
        GoRoute(
          path: '/scenes/scene/:id',
          builder: (context, state) =>
              Text('route:${state.pathParameters['id']}'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          sceneRepositoryProvider.overrideWithValue(repo),
          sceneRandomNavigationControllerProvider.overrideWith(
            (ref) => _FakeSceneRandomNavigationController(ref, randomScene),
          ),
        ],
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Random scene'));
    await tester.pumpAndSettle();

    expect(find.text('route:backend-next'), findsOneWidget);
  });
}
