import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:dart_cast/dart_cast.dart' as dc;
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stash_app_flutter/core/utils/pip_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/graphql_scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_view_mode.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/data/services/cast_service.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_prewarmer.dart';
import 'package:stash_app_flutter/core/utils/media_handler.dart';
import 'package:stash_app_flutter/main.dart' as app;

import 'playend_behavior_test.mocks.dart';

@GenerateMocks([GraphQLSceneRepository, mk.Player, VideoController])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockGraphQLSceneRepository mockRepo;
  late MockPlayer mockPlayer;
  late MockVideoController mockVideoController;
  late StreamController<bool> playingStream;
  late StreamController<Duration> positionStream;
  late StreamController<Duration> durationStream;
  late StreamController<bool> completedStream;
  StreamChoice? resolvedChoice;
  Completer<StreamChoice?>? pendingResolution;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    mockRepo = MockGraphQLSceneRepository();
    mockPlayer = MockPlayer();
    mockVideoController = MockVideoController();

    playingStream = StreamController<bool>.broadcast();
    positionStream = StreamController<Duration>.broadcast();
    durationStream = StreamController<Duration>.broadcast();
    completedStream = StreamController<bool>.broadcast();
    resolvedChoice = null;
    pendingResolution = null;
    app.mediaHandler = StashMediaHandler();

    final playerStream = CustomPlayerStream(
      playingStream.stream,
      completedStream.stream,
      positionStream.stream,
      durationStream.stream,
    );

    when(mockPlayer.stream).thenReturn(playerStream);
    when(mockPlayer.state).thenReturn(PlayerStateData());
    when(mockVideoController.player).thenReturn(mockPlayer);

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        sceneRepositoryProvider.overrideWithValue(mockRepo),
        streamResolverProvider.overrideWithValue(
          (scene) => pendingResolution?.future ?? Future.value(resolvedChoice),
        ),
        castServiceProvider.overrideWith(_FakeAppCastService.new),
        streamPrewarmerProvider.overrideWith(_RecordingPrewarmer.new),
      ],
    );
  });

  tearDown(() async {
    final closing = [
      playingStream.close(),
      positionStream.close(),
      durationStream.close(),
      completedStream.close(),
    ];
    container.dispose();
    app.mediaHandler = null;
    await Future.wait(closing);
  });

  // Helper to create a Scene
  Scene createTestScene(String id) {
    return Scene(
      id: id,
      title: 'Scene $id',
      date: DateTime.now(),
      rating100: 0,
      oCounter: 0,
      organized: false,
      interactive: false,
      resumeTime: 0,
      playCount: 0,
      playDuration: 0,
      files: [],
      paths: const ScenePaths(screenshot: '', preview: '', stream: ''),
      urls: [],
      studioId: 's1',
      studioName: 'Studio 1',
      studioImagePath: '',
      performerIds: [],
      performerNames: [],
      performerImagePaths: [],
      tagIds: [],
      tagNames: [],
    );
  }

  for (final enterThroughApp in [false, true]) {
    test(
      'Android PiP follows metadata and replacement without repeated updates (app entry: $enterThroughApp)',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        const channel = MethodChannel('stash_app_flutter/pip');
        final calls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              calls.add(call);
              return true;
            });
        addTearDown(() {
          PipMode.isInPipMode.value = false;
          debugDefaultTargetPlatformOverride = null;
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
        });
        final notifier = container.read(playerStateProvider.notifier);
        when(mockPlayer.state).thenReturn(
          PlayerStateData(
            videoParams: const mk.VideoParams(dw: 1080, dh: 1920),
          ),
        );
        await notifier.attachController(
          createTestScene('portrait'),
          mockPlayer,
          mockVideoController,
        );
        if (enterThroughApp) {
          notifier.didChangeAppLifecycleState(AppLifecycleState.paused);
          expect(await notifier.requestEnterPip(), isTrue);
        } else {
          PipMode.isInPipMode.value = true;
        }
        await Future<void>.delayed(Duration.zero);
        expect(
          calls.single.method,
          enterThroughApp
              ? 'enterPictureInPicture'
              : 'updatePictureInPictureAspectRatio',
        );
        expect(calls.single.arguments, {'numerator': 563, 'denominator': 1000});

        positionStream.add(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(calls, hasLength(1));

        final nextPlayer = MockPlayer();
        final nextController = MockVideoController();
        when(nextPlayer.stream).thenReturn(mockPlayer.stream);
        when(nextController.player).thenReturn(nextPlayer);
        when(nextPlayer.state).thenReturn(PlayerStateData());
        await notifier.attachController(
          createTestScene('next'),
          nextPlayer,
          nextController,
        );
        positionStream.add(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(
          calls,
          hasLength(1),
          reason: 'unknown dimensions retain the previous ratio',
        );

        when(nextPlayer.state).thenReturn(
          PlayerStateData(
            videoParams: const mk.VideoParams(dw: 1920, dh: 1080),
          ),
        );
        positionStream.add(Duration.zero);
        await Future<void>.delayed(Duration.zero);
        expect(calls, hasLength(2));
        expect(calls.last.arguments, {'numerator': 1778, 'denominator': 1000});
        expect(container.read(playerStateProvider).isInPipMode, isTrue);
      },
    );
  }

  for (final next in [true, false]) {
    test(
      'queue ${next ? 'next' : 'previous'} prewarms the scene after the new active scene',
      () async {
        final scenes = [for (var i = 1; i <= 4; i++) createTestScene('$i')];
        final queue = container.read(playbackQueueProvider.notifier);
        queue.setSequence(scenes, next ? 0 : 2);
        resolvedChoice = const StreamChoice(
          url: 'https://example.test/stream.mp4',
          mimeType: 'video/mp4',
        );
        final notifier = container.read(playerStateProvider.notifier);
        await notifier.attachController(
          scenes[next ? 0 : 2],
          mockPlayer,
          mockVideoController,
        );
        await Future<void>.delayed(Duration.zero);
        final prewarmer =
            container.read(streamPrewarmerProvider.notifier)
                as _RecordingPrewarmer;
        prewarmer.warmed.clear();
        if (next) {
          expect(await notifier.playNext(), isTrue);
        } else {
          await notifier.playPrevious();
        }
        await Future<void>.delayed(Duration.zero);
        expect(container.read(playerStateProvider).activeScene?.id, '2');
        expect(prewarmer.warmed, ['3']);
      },
    );
  }

  test(
    'same-controller TikTok handoff transfers completion without restarting playback',
    () async {
      final scenes = [createTestScene('1'), createTestScene('2')];
      container.read(playbackQueueProvider.notifier).setSequence(scenes, 0);
      resolvedChoice = const StreamChoice(
        url: 'https://example.test/2.mp4',
        mimeType: 'video/mp4',
      );
      final notifier = container.read(playerStateProvider.notifier);
      await notifier.attachController(
        scenes.first,
        mockPlayer,
        mockVideoController,
        streamSource: 'tiktok-promotion',
      );
      await notifier.attachController(
        scenes.first,
        mockPlayer,
        mockVideoController,
        streamSource: 'tiktok-handoff',
      );
      expect(
        container.read(playerStateProvider).streamSource,
        'tiktok-handoff',
      );
      expect(
        container.read(playerStateProvider).viewMode,
        PlayerViewMode.inline,
      );
      verifyNever(mockPlayer.pause());
      verifyNever(mockPlayer.dispose());
      final navigation = <String>[];
      container.listen(
        playerStateProvider.select((s) => s.navigationReplacementPath),
        (_, path) {
          if (path != null) navigation.add(path);
        },
      );
      notifier.setPlayEndBehavior(VideoEndBehavior.next);
      completedStream.add(true);
      completedStream.add(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(playbackQueueProvider).currentIndex, 1);
      expect(container.read(playerStateProvider).activeScene?.id, '2');
      expect(navigation, ['/scenes/scene/2']);
    },
  );

  for (final presentation in ['feed', 'inline', 'fullscreen', 'pip']) {
    test(
      'promoted TikTok completion belongs to the visible $presentation presentation',
      () async {
        final scenes = [createTestScene('1'), createTestScene('2')];
        container.read(playbackQueueProvider.notifier).setSequence(scenes, 0);
        resolvedChoice = const StreamChoice(
          url: 'https://example.test/2.mp4',
          mimeType: 'video/mp4',
        );
        final notifier = container.read(playerStateProvider.notifier);
        await notifier.attachController(
          scenes.first,
          mockPlayer,
          mockVideoController,
          streamSource: 'tiktok-promotion',
        );
        if (presentation == 'pip') {
          PipMode.isInPipMode.value = true;
          addTearDown(() => PipMode.isInPipMode.value = false);
        } else if (presentation != 'feed') {
          notifier.setViewMode(
            presentation == 'fullscreen'
                ? PlayerViewMode.fullscreen
                : PlayerViewMode.inline,
          );
          if (presentation == 'fullscreen') notifier.setFullScreen(true);
        }
        notifier.setPlayEndBehavior(VideoEndBehavior.next);
        completedStream.add(true);
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(
          container.read(playerStateProvider).activeScene?.id,
          presentation == 'feed' ? '1' : '2',
        );
        expect(
          container.read(playbackQueueProvider).currentIndex,
          presentation == 'feed' ? 0 : 1,
        );
        if (presentation == 'fullscreen') {
          expect(container.read(playerStateProvider).isFullScreen, isTrue);
        }
        if (presentation == 'pip') {
          expect(container.read(playerStateProvider).isInPipMode, isTrue);
        }
      },
    );
  }

  test(
    'stale URL resolutions do not restart prewarming after scene change or stop',
    () async {
      final scenes = [for (var i = 1; i <= 3; i++) createTestScene('$i')];
      container.read(playbackQueueProvider.notifier).setSequence(scenes, 0);
      pendingResolution = Completer<StreamChoice?>();
      final notifier = container.read(playerStateProvider.notifier);
      await notifier.attachController(
        scenes.first,
        mockPlayer,
        mockVideoController,
      );
      await notifier.attachController(
        scenes[1],
        mockPlayer,
        mockVideoController,
      );
      pendingResolution!.complete(
        const StreamChoice(
          url: 'https://example.test/stream.mp4',
          mimeType: 'video/mp4',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      final prewarmer =
          container.read(streamPrewarmerProvider.notifier)
              as _RecordingPrewarmer;
      expect(prewarmer.warmed, ['3']);
      prewarmer.warmed.clear();
      pendingResolution = Completer<StreamChoice?>();
      await notifier.attachController(
        scenes.first,
        mockPlayer,
        mockVideoController,
      );
      notifier.stop();
      pendingResolution!.complete(
        const StreamChoice(
          url: 'https://example.test/stream.mp4',
          mimeType: 'video/mp4',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(prewarmer.warmed, isEmpty);
    },
  );

  for (final next in [true, false]) {
    test(
      'in-flight ${next ? 'next' : 'previous'} commits to its original queue without corrupting a newly selected queue',
      () async {
        final scenes = [for (var i = 1; i <= 3; i++) createTestScene('$i')];
        final queue = container.read(playbackQueueProvider.notifier);
        queue.setSequence(scenes, next ? 0 : 2);
        pendingResolution = Completer<StreamChoice?>();
        final notifier = container.read(playerStateProvider.notifier);
        await notifier.attachController(
          scenes[next ? 0 : 2],
          mockPlayer,
          mockVideoController,
        );
        final navigation = next ? notifier.playNext() : notifier.playPrevious();
        // The same target can be selected from another contextual queue while
        // native startup is pending. Its position need not match the old queue.
        queue.setSequence([scenes[1], scenes.first], 0, queueId: 'other');
        pendingResolution!.complete(
          const StreamChoice(
            url: 'https://example.test/2.mp4',
            mimeType: 'video/mp4',
          ),
        );
        await navigation;
        expect(container.read(playerStateProvider).activeScene?.id, '2');
        expect(queue.state.activeQueueId, 'other');
        expect(queue.state.currentIndex, 0);
        expect(queue.state.queues[PlaybackQueueIds.main]!.currentIndex, 1);
      },
    );
  }

  test(
    'rapid mixed transport commands start only one queue transition',
    () async {
      final scenes = [for (var i = 1; i <= 3; i++) createTestScene('$i')];
      final queue = container.read(playbackQueueProvider.notifier);
      queue.setSequence(scenes, 1);
      pendingResolution = Completer<StreamChoice?>();
      final notifier = container.read(playerStateProvider.notifier);
      await notifier.attachController(
        scenes[1],
        mockPlayer,
        mockVideoController,
      );
      final next = notifier.playNext();
      expect(await notifier.playNext(), isFalse);
      await notifier.playPrevious();
      expect(queue.state.currentIndex, 1);
      expect(container.read(playerStateProvider).activeScene?.id, '2');
      pendingResolution!.complete(
        const StreamChoice(
          url: 'https://example.test/3.mp4',
          mimeType: 'video/mp4',
        ),
      );
      expect(await next, isTrue);
      expect(queue.state.currentIndex, 2);
      expect(container.read(playerStateProvider).activeScene?.id, '3');
    },
  );

  test(
    'PiP takes over an already completed feed frame without losing auto-next',
    () async {
      final scenes = [createTestScene('1'), createTestScene('2')];
      container.read(playbackQueueProvider.notifier).setSequence(scenes, 0);
      resolvedChoice = const StreamChoice(
        url: 'https://example.test/2.mp4',
        mimeType: 'video/mp4',
      );
      when(mockPlayer.state).thenReturn(mk.PlayerState(completed: true));
      final notifier = container.read(playerStateProvider.notifier);
      await notifier.attachController(
        scenes.first,
        mockPlayer,
        mockVideoController,
        streamSource: 'tiktok-promotion',
      );
      notifier.setPlayEndBehavior(VideoEndBehavior.next);
      PipMode.isInPipMode.value = true;
      addTearDown(() => PipMode.isInPipMode.value = false);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(playerStateProvider).activeScene?.id, '2');
      expect(container.read(playerStateProvider).isInPipMode, isTrue);
      expect(container.read(playbackQueueProvider).currentIndex, 1);
    },
  );

  test('background playback off pauses an active player', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final scene = createTestScene('background-off');

    when(mockPlayer.state).thenReturn(PlayerStateData(playing: true));
    await notifier.attachController(scene, mockPlayer, mockVideoController);
    notifier.setEnableBackgroundPlayback(false);

    notifier.didChangeAppLifecycleState(AppLifecycleState.hidden);

    verify(mockPlayer.pause()).called(1);
    expect(container.read(playerStateProvider).isPlaying, isFalse);
  });

  test('playEndBehavior.stop SHOULD exit full screen', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final scene1 = createTestScene('1');

    await notifier.attachController(scene1, mockPlayer, mockVideoController);
    notifier.setFullScreen(true);

    notifier.setPlayEndBehavior(VideoEndBehavior.stop);
    completedStream.add(true);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(playerStateProvider).isFullScreen, isFalse);
    expect(container.read(playerStateProvider).activeScene, isNull);
    expect(
      app.mediaHandler!.playbackState.value.processingState,
      AudioProcessingState.idle,
    );
    expect(app.mediaHandler!.mediaItem.value, isNull);
  });

  test('loop seeks to zero and resumes without stopping', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final scene = createTestScene('1');
    await notifier.attachController(scene, mockPlayer, mockVideoController);
    notifier.setPlayEndBehavior(VideoEndBehavior.loop);

    completedStream.add(true);
    await Future<void>.delayed(Duration.zero);

    verify(mockPlayer.seek(Duration.zero)).called(1);
    verify(mockPlayer.play()).called(1);
    expect(container.read(playerStateProvider).activeScene?.id, '1');
  });

  test('next advances transactionally and preserves full screen', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final queue = container.read(playbackQueueProvider.notifier);
    final scene1 = createTestScene('1');
    final scene2 = createTestScene('2');
    resolvedChoice = const StreamChoice(
      url: 'https://example.test/2.mp4',
      mimeType: 'video/mp4',
    );

    queue.setSequence([scene1, scene2], 0);
    await notifier.attachController(scene1, mockPlayer, mockVideoController);
    notifier.setFullScreen(true);
    notifier.setFeedStartRandom(true);
    notifier.setResumePlayPosition(false);
    notifier.setPlayEndBehavior(VideoEndBehavior.next);

    completedStream.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(container.read(playbackQueueProvider).currentIndex, 1);
    expect(container.read(playerStateProvider).activeScene?.id, '2');
    expect(container.read(playerStateProvider).isFullScreen, isTrue);
    expect(container.read(playerStateProvider).feedStartRandom, isTrue);
    expect(container.read(playerStateProvider).resumePlayPosition, isFalse);
  });

  test('next advances without leaving the mini player', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final queue = container.read(playbackQueueProvider.notifier);
    final scene1 = createTestScene('mini-1');
    final scene2 = createTestScene('mini-2');
    resolvedChoice = const StreamChoice(
      url: 'https://example.test/mini-2.mp4',
      mimeType: 'video/mp4',
    );

    queue.setSequence([scene1, scene2], 0);
    await notifier.attachController(scene1, mockPlayer, mockVideoController);
    notifier.setMiniPlayerVisible(true);
    notifier.setPlayEndBehavior(VideoEndBehavior.next);

    final navigationPaths = <String?>[];
    container.listen<String?>(
      playerStateProvider.select((s) => s.navigationReplacementPath),
      (_, next) => navigationPaths.add(next),
    );

    completedStream.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(container.read(playerStateProvider).activeScene?.id, 'mini-2');
    expect(
      navigationPaths.whereType<String>(),
      isEmpty,
      reason: 'mini player playback must not open the scene details page',
    );
  });

  test('next opens the details page when not in the mini player', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final queue = container.read(playbackQueueProvider.notifier);
    final scene1 = createTestScene('details-1');
    final scene2 = createTestScene('details-2');
    resolvedChoice = const StreamChoice(
      url: 'https://example.test/details-2.mp4',
      mimeType: 'video/mp4',
    );

    queue.setSequence([scene1, scene2], 0);
    await notifier.attachController(scene1, mockPlayer, mockVideoController);
    notifier.setMiniPlayerVisible(false);
    notifier.setPlayEndBehavior(VideoEndBehavior.next);

    final navigationPaths = <String?>[];
    container.listen<String?>(
      playerStateProvider.select((s) => s.navigationReplacementPath),
      (_, next) => navigationPaths.add(next),
    );

    completedStream.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(container.read(playerStateProvider).activeScene?.id, 'details-2');
    expect(
      navigationPaths.whereType<String>(),
      contains('/scenes/scene/details-2'),
    );
  });

  test(
    'details page still navigates when the mini player mounts mid-transition',
    () async {
      final notifier = container.read(playerStateProvider.notifier);
      final queue = container.read(playbackQueueProvider.notifier);
      final scene1 = createTestScene('race-1');
      final scene2 = createTestScene('race-2');
      resolvedChoice = const StreamChoice(
        url: 'https://example.test/race-2.mp4',
        mimeType: 'video/mp4',
      );

      queue.setSequence([scene1, scene2], 0);
      await notifier.attachController(scene1, mockPlayer, mockVideoController);
      // Details page: the mini player is not mounted when playback ends.
      notifier.setMiniPlayerVisible(false);
      notifier.setPlayEndBehavior(VideoEndBehavior.next);

      final navigationPaths = <String?>[];
      container.listen<String?>(
        playerStateProvider.select((s) => s.navigationReplacementPath),
        (_, next) => navigationPaths.add(next),
      );
      // Mimic the shell briefly mounting the mini player once the new scene goes
      // active, before playNext decides whether to replace the route.
      final transientMount = container.listen<String?>(
        playerStateProvider.select((s) => s.activeScene?.id),
        (_, next) {
          if (next == 'race-2') notifier.setMiniPlayerVisible(true);
        },
      );

      completedStream.add(true);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      transientMount.close();

      expect(container.read(playerStateProvider).activeScene?.id, 'race-2');
      expect(
        navigationPaths.whereType<String>(),
        contains('/scenes/scene/race-2'),
      );
    },
  );

  test(
    'remote completion advances and switches the active cast media',
    () async {
      final notifier = container.read(playerStateProvider.notifier);
      final queue = container.read(playbackQueueProvider.notifier);
      final cast =
          container.read(castServiceProvider.notifier) as _FakeAppCastService;
      final scene1 = createTestScene('1');
      final scene2 = createTestScene('2');
      resolvedChoice = const StreamChoice(
        url: 'https://example.test/2.mp4',
        mimeType: 'video/mp4',
      );

      queue.setSequence([scene1, scene2], 0);
      await notifier.attachController(scene1, mockPlayer, mockVideoController);
      notifier.setPlayEndBehavior(VideoEndBehavior.next);
      cast.activate(localWasPlaying: true);

      cast.completeRemoteMedia();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(container.read(playbackQueueProvider).currentIndex, 1);
      expect(container.read(playerStateProvider).activeScene?.id, '2');
      expect(cast.restartCalls, 1);
      expect(cast.lastMedia?.url, 'https://example.test/2.mp4');
      expect(container.read(castServiceProvider).isCasting, isTrue);
    },
  );

  test('cast previous follows the active More From Studio queue', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final queue = container.read(playbackQueueProvider.notifier);
    final cast =
        container.read(castServiceProvider.notifier) as _FakeAppCastService;
    final scene1 = createTestScene('1');
    final scene2 = createTestScene('2');
    resolvedChoice = const StreamChoice(
      url: 'https://example.test/1.mp4',
      mimeType: 'video/mp4',
    );

    queue.setSequence(
      [scene1, scene2],
      1,
      queueId: PlaybackQueueIds.sceneMoreFromStudio(
        sceneId: 'source',
        studioId: 's1',
      ),
    );
    await notifier.attachController(scene2, mockPlayer, mockVideoController);
    cast.activate(localWasPlaying: true);

    await notifier.playPrevious();

    expect(container.read(playbackQueueProvider).currentIndex, 0);
    expect(container.read(playerStateProvider).activeScene?.id, '1');
    expect(cast.restartCalls, 1);
    expect(cast.lastMedia?.url, 'https://example.test/1.mp4');
  });

  test('next stops when the next stream cannot be resolved', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final queue = container.read(playbackQueueProvider.notifier);
    final scene1 = createTestScene('1');
    final scene2 = createTestScene('2');

    queue.setSequence([scene1, scene2], 0);
    await notifier.attachController(scene1, mockPlayer, mockVideoController);
    notifier.setPlayEndBehavior(VideoEndBehavior.next);

    completedStream.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(container.read(playbackQueueProvider).currentIndex, 0);
    expect(container.read(playerStateProvider).activeScene, isNull);
    expect(app.mediaHandler!.mediaItem.value, isNull);
  });

  test('completion does not stop an in-flight queue transition', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final queue = container.read(playbackQueueProvider.notifier);
    final scene1 = createTestScene('1');
    final scene2 = createTestScene('2');
    pendingResolution = Completer<StreamChoice?>();

    queue.setSequence([scene1, scene2], 0);
    await notifier.attachController(scene1, mockPlayer, mockVideoController);
    notifier.setPlayEndBehavior(VideoEndBehavior.next);

    final transition = notifier.playNext();
    completedStream.add(true);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(playerStateProvider).activeScene?.id, '1');

    pendingResolution!.complete(null);
    await transition;
    expect(container.read(playerStateProvider).activeScene?.id, '1');
  });

  test('notification previous command routes to queue playback', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final queue = container.read(playbackQueueProvider.notifier);
    final scene1 = createTestScene('1');
    final scene2 = createTestScene('2');
    resolvedChoice = const StreamChoice(
      url: 'https://example.test/1.mp4',
      mimeType: 'video/mp4',
    );

    queue.setSequence([scene1, scene2], 1);
    await notifier.attachController(scene2, mockPlayer, mockVideoController);

    await app.mediaHandler!.skipToPrevious();

    expect(container.read(playbackQueueProvider).currentIndex, 0);
    expect(container.read(playerStateProvider).activeScene?.id, '1');
  });

  for (final titleCase in [
    (
      title: '',
      path: '/library/File_Name.mp4',
      stream: '',
      expected: 'File Name',
    ),
    (
      title: '   ',
      path: '/library/File_Name.mp4',
      stream: '',
      expected: 'File Name',
    ),
    (
      title: '  Scene Title  ',
      path: '/library/File_Name.mp4',
      stream: '',
      expected: 'Scene Title',
    ),
    (
      title: '',
      path: null,
      stream: 'https://example.test/Stream_Name.mp4',
      expected: 'Stream Name',
    ),
    (title: '', path: null, stream: '', expected: 'Untitled Scene'),
  ]) {
    test(
      'notification keeps display title ${titleCase.expected} after duration refresh (${titleCase.title})',
      () async {
        final notifier = container.read(playerStateProvider.notifier);
        final scene = createTestScene('notification-title').copyWith(
          title: titleCase.title,
          path: titleCase.path,
          paths: ScenePaths(
            screenshot: '',
            preview: '',
            stream: titleCase.stream,
          ),
        );

        await notifier.attachController(scene, mockPlayer, mockVideoController);
        expect(app.mediaHandler!.mediaItem.value?.title, titleCase.expected);

        const duration = Duration(minutes: 2);
        when(mockPlayer.state).thenReturn(PlayerStateData(duration: duration));
        durationStream.add(duration);
        await Future<void>.delayed(Duration.zero);

        expect(app.mediaHandler!.mediaItem.value?.title, titleCase.expected);
        expect(app.mediaHandler!.mediaItem.value?.duration, duration);
      },
    );
  }

  test(
    'notification duration refreshes when the player discovers it',
    () async {
      final notifier = container.read(playerStateProvider.notifier);
      final scene = createTestScene('duration');

      when(
        mockPlayer.state,
      ).thenReturn(PlayerStateData(duration: Duration.zero));
      await notifier.attachController(scene, mockPlayer, mockVideoController);
      expect(app.mediaHandler!.mediaItem.value?.duration, Duration.zero);

      const duration = Duration(minutes: 2);
      when(mockPlayer.state).thenReturn(PlayerStateData(duration: duration));
      durationStream.add(duration);
      await Future<void>.delayed(Duration.zero);

      expect(app.mediaHandler!.mediaItem.value?.duration, duration);
    },
  );

  test(
    'notification seek clamps to duration and publishes the target',
    () async {
      final notifier = container.read(playerStateProvider.notifier);
      final scene = createTestScene('seek');
      const duration = Duration(seconds: 60);

      when(mockPlayer.state).thenReturn(
        PlayerStateData(
          position: const Duration(seconds: 10),
          duration: duration,
        ),
      );
      await notifier.attachController(scene, mockPlayer, mockVideoController);

      await app.mediaHandler!.seek(const Duration(seconds: 120));

      verify(mockPlayer.seek(duration)).called(1);
      verifyNever(mockPlayer.play());
      verifyNever(mockPlayer.pause());
      expect(app.mediaHandler!.playbackState.value.updatePosition, duration);
    },
  );

  test(
    'notification seek restores playback when a playing player pauses',
    () async {
      final notifier = container.read(playerStateProvider.notifier);
      final scene = createTestScene('playing-seek');
      var isPlaying = false;
      const duration = Duration(seconds: 60);

      when(mockPlayer.state).thenAnswer(
        (_) => PlayerStateData(
          playing: isPlaying,
          position: const Duration(seconds: 10),
          duration: duration,
        ),
      );
      when(mockPlayer.seek(any)).thenAnswer((_) async => isPlaying = false);
      when(mockPlayer.play()).thenAnswer((_) async => isPlaying = true);
      await notifier.attachController(scene, mockPlayer, mockVideoController);
      isPlaying = true;

      await app.mediaHandler!.seek(const Duration(seconds: 30));

      verify(mockPlayer.seek(const Duration(seconds: 30))).called(1);
      verify(mockPlayer.play()).called(1);
      verifyNever(mockPlayer.pause());
    },
  );

  test(
    'playNext keeps queue index unchanged when stream resolution fails',
    () async {
      final notifier = container.read(playerStateProvider.notifier);
      final queue = container.read(playbackQueueProvider.notifier);
      final scene1 = createTestScene('1');
      final scene2 = createTestScene('2');

      queue.setSequence([scene1, scene2], 0);
      await notifier.attachController(scene1, mockPlayer, mockVideoController);

      await notifier.playNext();

      expect(container.read(playbackQueueProvider).currentIndex, 0);
      expect(container.read(playerStateProvider).activeScene?.id, '1');
    },
  );

  test(
    'playPrevious keeps queue index unchanged when stream resolution fails',
    () async {
      final notifier = container.read(playerStateProvider.notifier);
      final queue = container.read(playbackQueueProvider.notifier);
      final scene1 = createTestScene('1');
      final scene2 = createTestScene('2');

      queue.setSequence([scene1, scene2], 1);
      await notifier.attachController(scene2, mockPlayer, mockVideoController);

      await notifier.playPrevious();

      expect(container.read(playbackQueueProvider).currentIndex, 1);
      expect(container.read(playerStateProvider).activeScene?.id, '2');
    },
  );
}

class _RecordingPrewarmer extends StreamPrewarmer {
  final warmed = <String>[];

  @override
  void build() {}

  @override
  Future<void> prewarm(
    Scene scene,
    String url, {
    Map<String, String>? headers,
    int rangeBytes = 2 * 1024 * 1024,
  }) async => warmed.add(scene.id);

  @override
  void cancelAllExcept(Set<String> sceneIds) {}
}

class _FakeAppCastService extends AppCastService {
  final session = _FakeCastSession();
  int restartCalls = 0;
  dc.CastMedia? lastMedia;

  @override
  CastState build() => CastState();

  void activate({bool localWasPlaying = false}) {
    state = state.copyWith(
      activeSession: session,
      isCasting: true,
      localWasPlaying: localWasPlaying,
    );
  }

  void completeRemoteMedia() {
    state = state.copyWith(
      remoteIsPlaying: false,
      completedMediaCount: state.completedMediaCount + 1,
    );
  }

  @override
  Future<void> restartActiveSessionWithMedia(
    dc.CastMedia media, {
    Duration localResumePosition = Duration.zero,
    bool localWasPlaying = false,
  }) async {
    restartCalls++;
    lastMedia = media;
    state = state.copyWith(
      localResumePosition: localResumePosition,
      localWasPlaying: localWasPlaying,
      remotePosition: localResumePosition,
      remoteIsPlaying: true,
    );
  }

  @override
  Future<void> stopCasting() async {
    state = state.copyWith(
      isCasting: false,
      clearActiveSession: true,
      clearLocalHandoff: true,
    );
  }
}

class _FakeCastSession extends dc.CastSession {
  _FakeCastSession()
    : super(
        dc.CastDevice(
          id: 'fake',
          name: 'Fake Cast',
          protocol: dc.CastProtocol.chromecast,
          address: InternetAddress.loopbackIPv4,
          port: 8009,
        ),
      );

  @override
  Future<void> connect() async {}
  @override
  Future<void> disconnect() async {}
  @override
  Future<void> loadMedia(dc.CastMedia media) async {}
  @override
  Future<void> pause() async {}
  @override
  Future<void> play() async {}
  @override
  Future<void> seek(Duration position) async {}
  @override
  Future<void> setSubtitle(dc.CastSubtitle? subtitle) async {}
  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> stop() async {}
}

// Minimal mock for PlayerState (media_kit)
class PlayerStateData extends Mock implements mk.PlayerState {
  @override
  final bool playing;
  @override
  final Duration position;
  @override
  final Duration duration;
  @override
  final Duration buffer;
  @override
  final double rate;
  @override
  final bool buffering;
  @override
  final mk.VideoParams videoParams;

  PlayerStateData({
    this.playing = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffer = Duration.zero,
    this.rate = 1.0,
    this.buffering = false,
    this.videoParams = const mk.VideoParams(),
  });
}

// Minimal mock for PlayerStream (media_kit)
class CustomPlayerStream extends Mock implements mk.PlayerStream {
  @override
  final Stream<bool> playing;
  @override
  final Stream<bool> completed;
  @override
  final Stream<Duration> position;
  @override
  final Stream<Duration> duration;

  @override
  Stream<Duration> get buffer => const Stream.empty();
  @override
  Stream<double> get volume => const Stream.empty();
  @override
  Stream<double> get rate => const Stream.empty();
  @override
  Stream<mk.Playlist> get playlist => const Stream.empty();
  @override
  Stream<bool> get buffering => const Stream.empty();
  @override
  Stream<mk.AudioParams> get audioParams => const Stream.empty();
  @override
  Stream<mk.VideoParams> get videoParams => const Stream.empty();
  @override
  Stream<int?> get width => const Stream.empty();
  @override
  Stream<int?> get height => const Stream.empty();
  @override
  Stream<String> get error => const Stream.empty();
  Stream<List<mk.SubtitleTrack>> get subtitleTracks => const Stream.empty();

  CustomPlayerStream(
    this.playing,
    this.completed,
    this.position,
    this.duration,
  );
}
