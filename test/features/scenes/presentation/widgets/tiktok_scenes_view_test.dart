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
