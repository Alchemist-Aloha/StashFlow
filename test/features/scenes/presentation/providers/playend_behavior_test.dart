import 'dart:async';
import 'package:audio_service/audio_service.dart';
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
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
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
        streamResolverProvider.overrideWith(
          () => TestStreamResolver(
            () => pendingResolution?.future ?? Future.value(resolvedChoice),
          ),
        ),
      ],
    );
  });

  tearDown(() {
    playingStream.close();
    positionStream.close();
    durationStream.close();
    completedStream.close();
    container.dispose();
    app.mediaHandler = null;
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

  test('playEndBehavior.stop SHOULD exit full screen', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final scene1 = createTestScene('1');

    await notifier.attachController(scene1, mockPlayer, mockVideoController);
    notifier.setFullScreen(true);

    notifier.setPlayEndBehavior(VideoEndBehavior.stop);
    completedStream.add(true);
    await Future.delayed(Duration.zero);

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
    notifier.setPlayEndBehavior(VideoEndBehavior.next);

    completedStream.add(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(container.read(playbackQueueProvider).currentIndex, 1);
    expect(container.read(playerStateProvider).activeScene?.id, '2');
    expect(container.read(playerStateProvider).isFullScreen, isTrue);
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

// Minimal mock for PlayerState (media_kit)
class PlayerStateData extends Mock implements mk.PlayerState {
  @override
  final bool playing;
  @override
  final Duration position;
  @override
  final Duration duration;
  @override
  final bool buffering;

  PlayerStateData({
    this.playing = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffering = false,
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

class TestStreamResolver extends StreamResolver {
  TestStreamResolver(this.resolve);

  final Future<StreamChoice?> Function() resolve;

  @override
  void build() {}

  @override
  Future<StreamChoice?> resolvePreferredStream(Scene scene) => resolve();
}
