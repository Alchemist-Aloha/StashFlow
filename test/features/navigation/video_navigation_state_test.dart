import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/navigation/presentation/router.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/presentation/pages/scene_details_page.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_view_mode.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/playlist_floating_panel.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_card.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/tiktok_scenes_view.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../helpers/test_helpers.dart';
import '../../integration_navigation_test.dart' show createTestScene;
import '../scenes/presentation/widgets/native_video_controls_test.dart'
    show FakeVideoController, FakePlayer;
import 'package:media_kit/media_kit.dart' as mk;

class _NavigationDecoder extends FakePlayer {
  @override
  Future<void> play() async {}
  @override
  Future<void> pause() async {}
}

class _NavigationController extends FakeVideoController {
  @override
  mk.Player get player => _NavigationDecoder();
}

// Inject session events without opening a native decoder. Routes, lists, queues,
// fullscreen overlay, and playlist selection remain production widgets/state.
class _NavigationPlayer extends PlayerState {
  _NavigationPlayer(this.scene);
  final Scene scene;

  @override
  GlobalPlayerState build() => GlobalPlayerState(
    activeScene: scene,
    startupLatencyMs: 0,
    videoController: _NavigationController(),
  );

  @override
  Future<void> playScene(
    Scene scene,
    String streamUrl, {
    String? mimeType,
    String? streamLabel,
    String? streamSource,
    Map<String, String>? httpHeaders,
    bool? prewarmAttempted,
    bool? prewarmSucceeded,
    int? prewarmLatencyMs,
    Duration? initialPosition,
    bool force = false,
  }) async => show(scene);

  void show(Scene scene, {bool pip = false}) {
    state = state.copyWith(
      activeScene: scene,
      isInPipMode: pip,
      startupLatencyMs: 0,
    );
  }
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  for (final feed in [false, true]) {
    final mode = feed ? 'feed' : 'grid';
    for (final transition in [
      'details',
      'fullscreen',
      'pip',
      'playlist',
      'random',
      'random-empty',
      'random-single',
      'title-swipe',
      'mixed-components',
      'contextual-next',
      'offscreen-playlist',
    ]) {
      final offscreen = transition == 'offscreen-playlist';
      final destinationIndex = offscreen ? 59 : 2;
      for (final systemBack in [true, false]) {
        final changesScene =
            transition != 'details' &&
            transition != 'random-empty' &&
            transition != 'random-single';
        testWidgets(
          '$mode: $transition → ${systemBack ? 'system' : 'toolbar'} Back preserves return state',
          (tester) async {
            tester.view.physicalSize = const Size(800, 1200);
            tester.view.devicePixelRatio = 1;
            debugDefaultTargetPlatformOverride = TargetPlatform.android;
            const wakeChannel =
                'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';
            final messenger = tester.binding.defaultBinaryMessenger;
            messenger.setMockMethodCallHandler(
              SystemChannels.platform,
              (_) async => null,
            );
            messenger.setMockMessageHandler(
              wakeChannel,
              (_) async => const StandardMessageCodec().encodeMessage([null]),
            );
            addTearDown(() async {
              await tester.pumpWidget(const SizedBox.shrink());
              await tester.pump();
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
              debugDefaultTargetPlatformOverride = null;
              messenger.setMockMethodCallHandler(SystemChannels.platform, null);
              messenger.setMockMessageHandler(wakeChannel, null);
            });

            SharedPreferences.setMockInitialValues({});
            final prefs = await SharedPreferences.getInstance();
            final scenes = [
              for (var i = 0; i < 3; i++)
                createTestScene(id: '$i', title: 'Navigation Scene $i'),
            ];
            if (offscreen) {
              scenes.insertAll(2, [
                for (var i = 3; i < 60; i++)
                  createTestScene(id: '$i', title: 'Navigation Scene $i'),
              ]);
            }
            final repository = MockGraphQLSceneRepository()..withData(scenes);
            final player = _NavigationPlayer(scenes.first);
            var resolvePlayback = false;
            Future<StreamChoice?> resolve(Scene scene) async => resolvePlayback
                ? StreamChoice(
                    url: 'https://example.test/${scene.id}.mp4',
                    mimeType: 'video/mp4',
                  )
                : null;
            late ProviderContainer container;
            late GoRouter router;
            await tester.pumpWidget(
              ProviderScope(
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(prefs),
                  sceneRepositoryProvider.overrideWithValue(repository),
                  playerStateProvider.overrideWith(() => player),
                  streamResolverProvider.overrideWithValue(resolve),
                ],
                child: Consumer(
                  builder: (context, ref, _) {
                    container = ProviderScope.containerOf(context);
                    router = ref.watch(routerProvider);
                    return MaterialApp.router(
                      routerConfig: router,
                      localizationsDelegates:
                          AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                    );
                  },
                ),
              ),
            );
            await _settle(tester);
            // Set through the real preference notifier so this does not depend on
            // preference key spelling or default layout.
            await container.read(sceneTiktokLayoutProvider.notifier).set(feed);
            await container.read(sceneGridLayoutProvider.notifier).set(true);
            await _settle(tester);
            expect(router.state.uri.path, '/scenes');
            expect(
              find.byType(TiktokScenesView),
              feed ? findsOneWidget : findsNothing,
            );
            final queue = container.read(playbackQueueProvider.notifier);
            queue.setIndex(0, queueId: PlaybackQueueIds.main);
            final listBefore = container.read(sceneListProvider).requireValue;
            // The fixture contains one page; returning to its last item may probe
            // the next page. Do not let the mock append the same scenes again.
            repository.findScenesResponses.add([]);
            final feedState = feed
                ? tester.state(find.byType(TiktokScenesView))
                : null;
            double? feedPage() => tester
                .widget<PageView>(find.byType(PageView, skipOffstage: false))
                .controller!
                .page;

            if (feed) {
              router.push('/scenes/scene/0', extra: true);
            } else {
              final card = tester
                  .widgetList<SceneCard>(find.byType(SceneCard))
                  .firstWhere((card) => card.scene.id == '0');
              card.onTap!();
            }
            await _settle(tester);
            expect(router.state.uri.path, '/scenes/scene/0');
            expect(find.byType(SceneDetailsPage), findsOneWidget);
            expect(container.read(playbackQueueProvider).currentIndex, 0);

            Future<void> back() async {
              resolvePlayback = false;
              if (systemBack) {
                await tester.binding.handlePopRoute();
              } else {
                await tester.tap(
                  find.byKey(const Key('inline_video_back_button')),
                );
              }
              await _settle(tester);
            }

            Future<void> swipe(double dx) async {
              resolvePlayback = true;
              await tester.drag(find.byType(SceneSwipeTitle), Offset(dx, 0));
              await _settle(tester);
            }

            if (transition == 'title-swipe' ||
                transition == 'mixed-components') {
              await swipe(-150);
              expect(router.state.uri.path, '/scenes/scene/1');
              expect(container.read(playbackQueueProvider).currentIndex, 1);
              await swipe(150);
              expect(router.state.uri.path, '/scenes/scene/0');
              await swipe(-150);
              if (transition == 'mixed-components') {
                PlaylistFloatingPanel.show(
                  tester.element(find.byType(SceneDetailsPage)),
                );
                await _settle(tester);
                await tester.tap(
                  find.byKey(const ValueKey<String>('playlist_item_2')),
                );
                await _settle(tester);
                expect(router.state.uri.path, '/scenes/scene/2');
                repository.findScenesResponses.insert(0, [scenes[1]]);
                final tooltip = AppLocalizations.of(
                  tester.element(find.byType(SceneDetailsPage)),
                )!.random_scene;
                await tester.tap(find.byTooltip(tooltip).last);
                await _settle(tester);
                expect(router.state.uri.path, '/scenes/scene/1');
              }
              await swipe(-150);
              expect(router.state.uri.path, '/scenes/scene/2');
              expect(container.read(playbackQueueProvider).currentIndex, 2);
              if (feed) expect(feedPage(), 0);
              if (transition == 'mixed-components') {
                await back();
                expect(router.state.uri.path, '/scenes/scene/2');
                await back();
                expect(router.state.uri.path, '/scenes/scene/1');
              }
            } else if (transition == 'contextual-next') {
              const contextualId = 'scene:0:more-from-studio:test';
              queue.setSequence(
                [scenes[0], scenes[2], scenes[1]],
                0,
                queueId: contextualId,
              );
              resolvePlayback = true;
              expect(await player.playNext(), isTrue);
              await _settle(tester);
              expect(router.state.uri.path, '/scenes/scene/2');
              expect(
                container.read(playbackQueueProvider).activeQueueId,
                contextualId,
              );
              expect(container.read(playbackQueueProvider).currentIndex, 1);
              expect(
                container
                    .read(playbackQueueProvider)
                    .queues[PlaybackQueueIds.main]!
                    .currentIndex,
                0,
              );
              await player.playPrevious();
              await _settle(tester);
              expect(router.state.uri.path, '/scenes/scene/0');
              expect(await player.playNext(), isTrue);
              await _settle(tester);
            } else if (transition == 'fullscreen') {
              player.setViewMode(PlayerViewMode.fullscreen);
              player.requestEnterFullscreen();
              await _settle(tester);
              expect(container.read(playerStateProvider).isFullScreen, isTrue);
              player.show(scenes.last);
              queue.findAndSetIndex('2');
              await _settle(tester);
              if (feed) expect(feedPage(), 0);
              await tester.binding.handlePopRoute();
              await _settle(tester);
              expect(container.read(playerStateProvider).isFullScreen, isFalse);
              expect(
                container.read(playerStateProvider).fullscreenPhase,
                FullscreenPhase.inline,
              );
              expect(router.state.uri.path, '/scenes/scene/2');
            } else if (transition == 'pip') {
              // Platform callbacks update the shared presentation; PiP must not pop
              // or replace the details route while the active video changes.
              player.show(scenes.last, pip: true);
              queue.findAndSetIndex('2');
              await _settle(tester);
              expect(router.state.uri.path, '/scenes/scene/0');
              expect(container.read(playerStateProvider).isInPipMode, isTrue);
              if (feed) expect(feedPage(), 0);
              player.show(scenes.last);
              await _settle(tester);
              expect(router.state.uri.path, '/scenes/scene/0');
              expect(container.read(playerStateProvider).isInPipMode, isFalse);
            } else if (transition == 'playlist' || offscreen) {
              PlaylistFloatingPanel.show(
                tester.element(find.byType(SceneDetailsPage)),
              );
              await _settle(tester);
              if (offscreen) {
                await tester.scrollUntilVisible(
                  find.byKey(const ValueKey<String>('playlist_item_2')),
                  300,
                  maxScrolls: 60,
                  scrollable: find
                      .descendant(
                        of: find.byType(PlaylistFloatingPanel),
                        matching: find.byType(Scrollable),
                      )
                      .first,
                );
              }
              await tester.tap(
                find.byKey(const ValueKey<String>('playlist_item_2')),
              );
              await _settle(tester);
              expect(find.byType(PlaylistFloatingPanel), findsNothing);
              expect(router.state.uri.path, '/scenes/scene/2');
              expect(
                tester
                    .widget<SceneDetailsPage>(find.byType(SceneDetailsPage))
                    .autoPlayOnMount,
                isTrue,
              );
              expect(
                container.read(playbackQueueProvider).currentIndex,
                destinationIndex,
              );
              player.show(scenes.last);
            } else if (transition.startsWith('random')) {
              final callsBefore = repository.findSceneCalls.length;
              repository.findScenesResponses.insertAll(0, [
                for (var attempt = 0; attempt < 3; attempt++)
                  transition == 'random-empty'
                      ? <Scene>[]
                      : [
                          transition == 'random-single'
                              ? scenes.first
                              : scenes.last,
                        ],
              ]);
              final detailsContext = tester.element(
                find.byType(SceneDetailsPage),
              );
              final tooltip = AppLocalizations.of(detailsContext)!.random_scene;
              await tester.tap(find.byTooltip(tooltip).last);
              await _settle(tester);
              expect(
                router.state.uri.path,
                changesScene ? '/scenes/scene/2' : '/scenes/scene/0',
              );
              final randomCalls = repository.findSceneCalls
                  .skip(callsBefore)
                  .toList();
              expect(randomCalls.length, changesScene ? 1 : 3);
              expect(
                randomCalls.every((call) => call.sort == 'random'),
                isTrue,
              );
              expect(
                container.read(sceneListRandomReturnProvider),
                changesScene,
              );
              // Random selection must not rewrite the originating playlist.
              expect(container.read(playbackQueueProvider).currentIndex, 0);
              if (changesScene) {
                player.show(scenes.last);
              } else {
                expect(
                  find.text(
                    AppLocalizations.of(detailsContext)!.scenes_no_random,
                  ),
                  findsOneWidget,
                );
              }
              repository.findScenesResponses
                ..clear()
                ..add([]);
            }

            // Playlist and random push a second details route, not a new list.
            if (transition == 'playlist' ||
                transition == 'random' ||
                offscreen) {
              await back();
              expect(router.state.uri.path, '/scenes/scene/0');
            }
            await back();
            expect(router.state.uri.path, '/scenes');
            expect(find.byType(SceneDetailsPage), findsNothing);
            expect(
              container.read(sceneListProvider).requireValue,
              orderedEquals(listBefore),
            );
            final retained = container.read(playbackQueueProvider);
            final contextual = transition == 'contextual-next';
            expect(
              retained.activeQueueId,
              contextual && !feed
                  ? 'scene:0:more-from-studio:test'
                  : PlaybackQueueIds.main,
            );
            expect(
              retained.sequence.map((scene) => scene.id),
              contextual && !feed
                  ? ['0', '2', '1']
                  : scenes.map((scene) => scene.id),
            );
            if (contextual) {
              expect(
                retained.queues['scene:0:more-from-studio:test']!.currentIndex,
                1,
              );
            }
            expect(container.read(playerStateProvider).isFullScreen, isFalse);
            expect(container.read(playerStateProvider).isInPipMode, isFalse);
            expect(
              container.read(playerStateProvider).activeScene?.id,
              changesScene ? '2' : '0',
            );
            expect(
              container.read(playerStateProvider).isPlaying,
              isFalse,
              reason: 'return navigation must not resume user-paused playback',
            );
            if (feed) {
              expect(
                tester.state(find.byType(TiktokScenesView)),
                same(feedState),
              );
              expect(feedPage(), changesScene ? destinationIndex : 0);
              expect(
                retained.currentIndex,
                changesScene ? destinationIndex : 0,
              );
            } else {
              final focused = tester
                  .widgetList<SceneCard>(find.byType(SceneCard))
                  .where((card) => card.focusNode?.hasFocus ?? false);
              expect(
                focused.single.scene.id,
                !changesScene || transition == 'random' ? '0' : '2',
              );
              expect(
                retained.currentIndex,
                contextual
                    ? 1
                    : !changesScene || transition == 'random'
                    ? 0
                    : destinationIndex,
              );
            }
            if (offscreen && !feed) {
              final target = find.byKey(const ValueKey('scene_card_2'));
              expect(target, findsOneWidget);
              final rect = tester.getRect(target);
              expect(rect.bottom, greaterThan(0));
              expect(rect.top, lessThan(tester.view.physicalSize.height));
            }
            expect(tester.takeException(), isNull);
            debugDefaultTargetPlatformOverride = null;
          },
        );
      }
    }
  }
}
