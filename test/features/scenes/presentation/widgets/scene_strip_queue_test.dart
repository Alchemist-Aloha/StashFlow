import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';

Scene _scene(String id, String title) {
  return Scene(
    id: id,
    title: title,
    date: DateTime(2024, 1, 1),
    rating100: 0,
    oCounter: 0,
    organized: true,
    interactive: false,
    resumeTime: null,
    playCount: 0,
    playDuration: 0,
    files: const [],
    paths: const ScenePaths(screenshot: null, preview: null, stream: null),
    urls: const [],
    studioId: 'studio-1',
    studioName: 'Studio',
    studioImagePath: null,
    performerIds: const [],
    performerNames: const [],
    performerImagePaths: const [],
    tagIds: const [],
    tagNames: const [],
  );
}

void main() {
  testWidgets(
    'SceneStrip activates a contextual queue for its displayed list',
    (tester) async {
      final mainScene = _scene('main-1', 'Main Scene');
      final relatedOne = _scene('related-1', 'Related One');
      final relatedTwo = _scene('related-2', 'Related Two');
      final selected = <String>[];
      SharedPreferences.setMockInitialValues({
        'server_base_url': 'http://localhost:9999',
      });
      final prefs = await SharedPreferences.getInstance();

      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  container = ProviderScope.containerOf(context);
                  return SceneStrip(
                    scenes: [relatedOne, relatedTwo],
                    queueId: 'scene:main-1:more-from-studio:studio-1',
                    onTap: (scene) => selected.add(scene.id),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      container
          .read(playbackQueueProvider.notifier)
          .setSequence([mainScene], 0, queueId: PlaybackQueueIds.main);

      await tester.tap(find.byType(SceneCard).at(1));
      await tester.pump();

      expect(selected, ['related-2']);
      final state = container.read(playbackQueueProvider);
      expect(state.sequence.map((scene) => scene.id), [
        'related-1',
        'related-2',
      ]);
      expect(state.currentIndex, 1);

      container
          .read(playbackQueueProvider.notifier)
          .setIndex(0, queueId: PlaybackQueueIds.main);

      final mainState = container.read(playbackQueueProvider);
      expect(mainState.sequence.map((scene) => scene.id), ['main-1']);
      expect(mainState.currentIndex, 0);
    },
  );
}
