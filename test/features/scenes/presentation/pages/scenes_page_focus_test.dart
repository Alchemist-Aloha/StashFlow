import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scenes_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';

import '../../../../helpers/test_helpers.dart';

class _FocusPlayerState extends PlayerState {
  @override
  GlobalPlayerState build() => GlobalPlayerState();

  void setActiveScene(Scene scene) {
    state = state.copyWith(activeScene: scene);
  }
}

Scene _scene(int index) => Scene(
  id: '$index',
  title: 'Scene $index',
  date: DateTime(2024, 1, 1),
  rating100: null,
  oCounter: 0,
  organized: false,
  interactive: false,
  resumeTime: 0,
  playCount: 0,
  playDuration: 0,
  files: const [],
  paths: const ScenePaths(screenshot: null, preview: null, stream: null),
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

void main() {
  Future<void> pumpFocusFlow(
    WidgetTester tester, {
    required bool randomReturn,
  }) async {
    final scenes = List.generate(40, _scene);
    final repository = MockGraphQLSceneRepository()..withData(scenes);
    await pumpTestWidget(
      tester,
      overrides: [
        sceneRepositoryProvider.overrideWithValue(repository),
        playerStateProvider.overrideWith(_FocusPlayerState.new),
      ],
      child: const ScenesPage(),
      routes: [
        GoRoute(
          path: '/scenes/scene/:id',
          builder: (context, state) => Consumer(
            builder: (context, ref, child) {
              ref.watch(playerStateProvider);
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    key: const Key('return_to_scene_list'),
                    onPressed: () {
                      final playerState =
                          ref.read(playerStateProvider.notifier)
                              as _FocusPlayerState;
                      playerState.setActiveScene(scenes[30]);
                      if (randomReturn) {
                        ref
                            .read(playbackQueueProvider.notifier)
                            .setIndex(20, queueId: PlaybackQueueIds.main);
                        ref
                            .read(sceneListRandomReturnProvider.notifier)
                            .markRandom();
                      }
                      context.pop();
                    },
                    child: const Text('Back'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SceneCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('return_to_scene_list')));
    await tester.pumpAndSettle();

    final expectedId = randomReturn ? '20' : '30';
    final focusedCard = find.byWidgetPredicate(
      (widget) => widget is SceneCard && widget.scene.id == expectedId,
    );
    expect(focusedCard, findsOneWidget);
    expect(tester.widget<SceneCard>(focusedCard).focusNode?.hasFocus, isTrue);
    expect(
      Scrollable.of(tester.element(focusedCard)).position.pixels,
      greaterThan(0),
    );
  }

  testWidgets('returning from details focuses the last played scene', (
    tester,
  ) async {
    await pumpFocusFlow(tester, randomReturn: false);
  });

  testWidgets('returning from random details focuses the playlist item', (
    tester,
  ) async {
    await pumpFocusFlow(tester, randomReturn: true);
  });
}
