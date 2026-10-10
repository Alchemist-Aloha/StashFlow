import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_view_mode.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import '../../../../helpers/test_helpers.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/tiktok_scenes_view.dart';

class _FeedPlayer extends Mock implements mk.Player {
  bool playing = true;
  int pauseCalls = 0;
  int playCalls = 0;
  mk.PlaylistMode mode = mk.PlaylistMode.none;

  @override
  mk.PlayerState get state =>
      mk.PlayerState(playing: playing, playlistMode: mode);
  @override
  Future<void> pause() async {
    pauseCalls++;
    playing = false;
  }

  @override
  Future<void> play() async {
    playCalls++;
    playing = true;
  }

  @override
  Future<void> setPlaylistMode(mk.PlaylistMode value) async {
    mode = value;
  }
}

class _FeedController extends Fake implements VideoController {
  _FeedController(this.player);
  @override
  final mk.Player player;
}

class _FeedScene extends Fake implements Scene {
  _FeedScene(this.id);
  @override
  final String id;
  @override
  int get rating100 => 0;
}

class _UiFeedScene extends _FeedScene {
  _UiFeedScene([super.id = 'feed-ui']);
  @override
  String get title => 'Feed title';
  @override
  String? get path => null;
  @override
  ScenePaths get paths =>
      const ScenePaths(screenshot: null, preview: null, stream: null);
  @override
  String? get studioName => null;
  @override
  DateTime get date => DateTime(2024, 1, 1);
}

class _UiFeedStream extends Fake implements mk.PlayerStream {
  @override
  Stream<bool> get playing => const Stream.empty();
  @override
  Stream<int> get width => const Stream.empty();
  @override
  Stream<int> get height => const Stream.empty();
  @override
  Stream<Duration> get position => const Stream.empty();
  @override
  Stream<List<String>> get subtitle => const Stream.empty();
}

class _UiFeedPlayer extends _FeedPlayer {
  @override
  mk.PlayerStream get stream => _UiFeedStream();
  @override
  mk.PlayerState get state => mk.PlayerState(
    playing: playing,
    width: 1920,
    height: 1080,
    playlist: mk.Playlist([mk.Media('https://example.test/feed.mp4')]),
  );
}

class _UiFeedController extends _FeedController {
  _UiFeedController(super.player);
  final _notifier = ValueNotifier<PlatformVideoController?>(null);
  @override
  ValueNotifier<PlatformVideoController?> get notifier => _notifier;
}

class _FeedScenes extends SceneList {
  _FeedScenes(this.scenes);
  final List<Scene> scenes;
  @override
  FutureOr<List<Scene>> build() => scenes;

  @override
  Future<void> fetchNextPage() async {}
}

class _FeedState extends PlayerState {
  _FeedState(this.scene);
  final Scene scene;
  @override
  VideoController? get currentVideoController => null;
  @override
  GlobalPlayerState build() => GlobalPlayerState(
    activeScene: scene,
    viewMode: PlayerViewMode.tiktok,
    streamSource: 'tiktok-promotion',
    startupLatencyMs: 0,
  );
  void show(
    Scene target, {
    bool pip = false,
    bool ready = true,
    PlayerViewMode mode = PlayerViewMode.tiktok,
  }) {
    state = GlobalPlayerState(
      activeScene: target,
      viewMode: mode,
      streamSource: 'autoplay-next',
      isInPipMode: pip,
      startupLatencyMs: ready ? 0 : null,
    );
  }
}

void main() {
  testWidgets(
    'feed resynchronizes navigation after PiP/fullscreen and waits for startup',
    (tester) async {
      const wakeChannel =
          'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMessageHandler(
        wakeChannel,
        (_) async => const StandardMessageCodec().encodeMessage([null]),
      );
      messenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (_) async => null,
      );
      final scenes = [
        for (final id in ['first', 'middle', 'last']) _FeedScene(id),
      ];
      final player = _FeedState(scenes.first);
      await pumpTestWidget(
        tester,
        child: const Text('start'),
        overrides: [
          sceneListProvider.overrideWith(() => _FeedScenes(scenes)),
          playerStateProvider.overrideWith(() => player),
          streamResolverProvider.overrideWithValue((_) async => null),
        ],
        routes: [
          GoRoute(path: '/scenes', builder: (_, _) => const TiktokScenesView()),
        ],
      );
      final startContext = tester.element(find.text('start'));
      ProviderScope.containerOf(
        startContext,
      ).read(playbackQueueProvider.notifier).setSequence(scenes, 0);
      final router = GoRouter.of(startContext);
      router.go('/scenes');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(TiktokScenesView)),
      );
      expect(
        container.read(sceneListProvider).hasValue,
        isTrue,
        reason: '${container.read(sceneListProvider)}',
      );
      double? page() =>
          tester.widget<PageView>(find.byType(PageView)).controller!.page;
      expect(page(), 0);
      player.show(scenes.last, pip: true);
      await tester.pump();
      await tester.pump();
      expect(page(), 0, reason: 'the hidden feed must not navigate during PiP');
      player.show(scenes.last);
      await tester.pump();
      await tester.pump();
      expect(page(), 2);
      expect(container.read(playbackQueueProvider).currentIndex, 2);
      player.show(scenes[1], mode: PlayerViewMode.fullscreen);
      await tester.pump();
      await tester.pump();
      expect(page(), 2, reason: 'fullscreen owns navigation');
      player.show(scenes[1], ready: false);
      await tester.pump();
      await tester.pump();
      expect(
        page(),
        2,
        reason: 'do not replace an opening global session with a feed preload',
      );
      player.show(scenes[1]);
      await tester.pump();
      await tester.pump();
      expect(page(), 1);
      expect(container.read(playbackQueueProvider).currentIndex, 1);
      router.go('/');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      messenger.setMockMessageHandler(wakeChannel, null);
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    },
  );
  testWidgets('system Back returns the retained feed to the playing scene', (
    tester,
  ) async {
    const wakeChannel =
        'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle';
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler(
      wakeChannel,
      (_) async => const StandardMessageCodec().encodeMessage([null]),
    );
    messenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (_) async => null,
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      messenger.setMockMessageHandler(wakeChannel, null);
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });
    Future<void> settle() async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    }

    final scenes = [
      for (final id in ['first', 'middle', 'last']) _FeedScene(id),
    ];
    final player = _FeedState(scenes.first);
    await pumpTestWidget(
      tester,
      child: const Text('start'),
      overrides: [
        sceneListProvider.overrideWith(() => _FeedScenes(scenes)),
        playerStateProvider.overrideWith(() => player),
        streamResolverProvider.overrideWithValue((_) async => null),
      ],
      routes: [
        GoRoute(
          path: '/scenes',
          builder: (_, _) => const TiktokScenesView(),
          routes: [
            GoRoute(
              path: 'scene/:id',
              builder: (context, route) => Consumer(
                builder: (context, ref, _) {
                  final global = ref.watch(playerStateProvider);
                  final fullscreen =
                      global.viewMode == PlayerViewMode.fullscreen;
                  return PopScope(
                    canPop: !fullscreen,
                    onPopInvokedWithResult: (didPop, _) {
                      if (didPop || !fullscreen) return;
                      // Match details' fullscreen Back handling: exit and
                      // synchronize the details route to the active scene.
                      player.show(
                        global.activeScene!,
                        mode: PlayerViewMode.inline,
                      );
                      GoRouter.of(
                        context,
                      ).go('/scenes/scene/${global.activeScene!.id}');
                    },
                    child: Scaffold(
                      appBar: AppBar(
                        leading: BackButton(
                          onPressed: () => GoRouter.of(context).pop(),
                        ),
                      ),
                      body: Text('details ${route.pathParameters['id']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
    final context = tester.element(find.text('start'));
    final container = ProviderScope.containerOf(context);
    container.read(playbackQueueProvider.notifier).setSequence(scenes, 0);
    final router = GoRouter.of(context);
    router.go('/scenes');
    await settle();
    final feedState = tester.state(find.byType(TiktokScenesView));
    double? page() => tester
        .widget<PageView>(find.byType(PageView, skipOffstage: false))
        .controller!
        .page;
    expect(page(), 0);
    router.go('/scenes/scene/first');
    player.show(scenes.first, mode: PlayerViewMode.fullscreen);
    await settle();
    player.show(scenes.last, mode: PlayerViewMode.fullscreen);
    await settle();
    expect(
      page(),
      0,
      reason: 'the covered feed must not follow fullscreen navigation',
    );
    await tester.binding.handlePopRoute();
    await settle();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/scenes/scene/last',
    );
    expect(page(), 0);
    // No player-state change accompanies this second system Back.
    await tester.binding.handlePopRoute();
    await settle();
    expect(router.routeInformationProvider.value.uri.path, '/scenes');
    expect(tester.state(find.byType(TiktokScenesView)), same(feedState));
    expect(page(), 2);
    expect(container.read(playbackQueueProvider).currentIndex, 2);

    for (final systemBack in [true, false]) {
      player.show(scenes.first, mode: PlayerViewMode.inline);
      await settle();
      expect(page(), 0);
      unawaited(router.push('/scenes/scene/first'));
      await settle();
      player.show(scenes.last, mode: PlayerViewMode.inline);
      unawaited(router.pushReplacement('/scenes/scene/last'));
      await settle();
      expect(router.state.uri.path, '/scenes/scene/last');
      expect(page(), 0, reason: 'details owns playback until Back');
      if (systemBack) {
        await tester.binding.handlePopRoute();
      } else {
        await tester.tap(find.byType(BackButton));
      }
      await settle();
      expect(router.state.uri.path, '/scenes');
      expect(tester.state(find.byType(TiktokScenesView)), same(feedState));
      expect(
        page(),
        2,
        reason: 'details next → ${systemBack ? 'system' : 'button'} Back',
      );
      expect(container.read(playbackQueueProvider).currentIndex, 2);
    }
  });

  test(
    'feed navigation pauses all inactive players in both directions and at the last item',
    () {
      final players = {
        for (final id in ['first', 'middle', 'last']) id: _FeedPlayer(),
      };
      final controllers = {
        for (final entry in players.entries)
          entry.key: _FeedController(entry.value),
      };
      for (final current in ['first', 'middle', 'last', 'middle', 'first']) {
        syncTiktokPlayback(controllers, current, VideoEndBehavior.next);
        expect(
          players.entries
              .where((entry) => entry.value.playing)
              .map((entry) => entry.key),
          [current],
        );
      }
      expect(players['first']!.pauseCalls, 1);
      expect(players['last']!.pauseCalls, 2);
    },
  );

  test('unloaded next feed item still pauses the previous video', () {
    final previous = _FeedPlayer();
    syncTiktokPlayback(
      {'previous': _FeedController(previous)},
      'loading',
      VideoEndBehavior.next,
    );
    expect(previous.playing, isFalse);
    expect(previous.pauseCalls, 1);
  });

  test('feed loop policy applies to the active controller only', () {
    final current = _FeedPlayer()..playing = false;
    final other = _FeedPlayer();
    final controllers = {
      'current': _FeedController(current),
      'other': _FeedController(other),
    };
    syncTiktokPlayback(controllers, 'current', VideoEndBehavior.loop);
    expect(current.mode, mk.PlaylistMode.loop);
    expect(current.playCalls, 1);
    expect(other.mode, mk.PlaylistMode.none);
    expect(other.playing, isFalse);
    current.playing = false;
    syncTiktokPlayback(
      controllers,
      'current',
      VideoEndBehavior.next,
      playCurrent: false,
    );
    expect(
      current.playing,
      isFalse,
      reason: 'a handoff must not resume user-paused playback',
    );
    expect(current.mode, mk.PlaylistMode.none);
    expect(current.playCalls, 1);
  });
  group('FullScreenMode', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is false', () {
      final isFullScreen = container.read(fullScreenModeProvider);
      expect(isFullScreen, isFalse);
    });

    test('toggle changes state', () {
      final isFullScreenInitial = container.read(fullScreenModeProvider);
      expect(isFullScreenInitial, isFalse);

      container.read(fullScreenModeProvider.notifier).toggle();
      final isFullScreenAfterToggle = container.read(fullScreenModeProvider);
      expect(isFullScreenAfterToggle, isTrue);

      container.read(fullScreenModeProvider.notifier).toggle();
      final isFullScreenAfterSecondToggle = container.read(
        fullScreenModeProvider,
      );
      expect(isFullScreenAfterSecondToggle, isFalse);
    });

    test('set updates state to specific value', () {
      final isFullScreenInitial = container.read(fullScreenModeProvider);
      expect(isFullScreenInitial, isFalse);

      container.read(fullScreenModeProvider.notifier).set(true);
      final isFullScreenAfterSetTrue = container.read(fullScreenModeProvider);
      expect(isFullScreenAfterSetTrue, isTrue);

      container.read(fullScreenModeProvider.notifier).set(false);
      final isFullScreenAfterSetFalse = container.read(fullScreenModeProvider);
      expect(isFullScreenAfterSetFalse, isFalse);
    });
  });

  testWidgets('title hides feed UI and video restores it before play/pause', (
    tester,
  ) async {
    var scene = _UiFeedScene();
    var showFeedUi = true;
    late StateSetter rebuild;
    final player = _UiFeedPlayer()..playing = false;
    final controller = _UiFeedController(player);
    await pumpTestWidget(
      tester,
      overrides: [playerStateProvider.overrideWith(() => _FeedState(scene))],
      child: StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return Scaffold(
            body: TiktokSceneItem(
              scene: scene,
              controller: controller,
              useHero: false,
              showFeedUi: showFeedUi,
              onFeedUiVisibilityChanged: (visible) =>
                  setState(() => showFeedUi = visible),
            ),
          );
        },
      ),
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      controller.notifier.dispose();
    });
    await tester.pump(const Duration(milliseconds: 500));
    final video = find.byKey(const ValueKey('feed_video_touch_area'));
    player.playing = true;
    await tester.tap(find.text('Feed title'));
    await tester.pump();
    expect(find.text('Feed title'), findsNothing);
    expect(find.byType(FeedActionMenu), findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(player.pauseCalls, 0, reason: 'title must not pause the video');
    rebuild(() => scene = _UiFeedScene('next-feed-ui'));
    await tester.pump();
    expect(
      find.text('Feed title'),
      findsNothing,
      reason: 'scene changes preserve manual visibility',
    );
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('Feed title'), findsNothing);
    await tester.tap(video);
    await tester.pump();
    expect(find.text('Feed title'), findsOneWidget);
    expect(find.byType(FeedActionMenu), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(
      player.pauseCalls,
      0,
      reason: 'revealing UI takes priority over pause',
    );
    await tester.pump(const Duration(seconds: 10));
    expect(
      find.text('Feed title'),
      findsOneWidget,
      reason: 'no auto-hide timer',
    );
    await tester.tap(video);
    await tester.pump();
    expect(player.pauseCalls, 1);
    expect(player.playing, isFalse);
    await tester.tap(find.text('Feed title'));
    await tester.pump();
    await tester.tap(video);
    await tester.pump();
    expect(
      player.playCalls,
      0,
      reason: 'revealing UI must also preserve paused playback',
    );
    await tester.tap(video);
    await tester.pump();
    expect(player.playCalls, 1);
    expect(player.playing, isTrue);
  });

  testWidgets('feed action chevron expands and collapses actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeedActionMenu(
            actions: [
              IconButton(
                key: const Key('sort_action'),
                onPressed: () {},
                icon: const Icon(Icons.sort),
              ),
              IconButton(
                key: const Key('filter_action'),
                onPressed: () {},
                icon: const Icon(Icons.filter_list),
              ),
              IconButton(
                key: const Key('preset_action'),
                onPressed: () {},
                icon: const Icon(Icons.bookmarks_outlined),
              ),
              IconButton(
                key: const Key('marker_action'),
                onPressed: () {},
                icon: const Icon(Icons.sell_outlined),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('sort_action')), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('feed_actions_toggle')));
    await tester.pump();

    expect(find.byKey(const Key('sort_action')), findsOneWidget);
    expect(find.byKey(const Key('filter_action')), findsOneWidget);
    expect(find.byKey(const Key('preset_action')), findsOneWidget);
    expect(find.byKey(const Key('marker_action')), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

    await tester.tap(find.byKey(const Key('feed_actions_toggle')));
    await tester.pump();

    expect(find.byKey(const Key('sort_action')), findsNothing);
  });
}
