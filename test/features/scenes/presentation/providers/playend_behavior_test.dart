import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';

import 'package:stash_app_flutter/features/scenes/domain/entities/scene.dart';
import 'package:stash_app_flutter/features/scenes/domain/repositories/scene_repository.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';

import 'playend_behavior_test.mocks.dart';

@GenerateMocks([SceneRepository, mk.Player, VideoController])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockSceneRepository mockRepo;
  late MockPlayer mockPlayer;
  late MockVideoController mockVideoController;
  late StreamController<bool> playingStream;
  late StreamController<Duration> positionStream;
  late StreamController<Duration> durationStream;
  late StreamController<bool> completedStream;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();

    mockRepo = MockSceneRepository();
    mockPlayer = MockPlayer();
    mockVideoController = MockVideoController();

    playingStream = StreamController<bool>.broadcast();
    positionStream = StreamController<Duration>.broadcast();
    durationStream = StreamController<Duration>.broadcast();
    completedStream = StreamController<bool>.broadcast();

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
      ],
    );
  });

  tearDown(() {
    playingStream.close();
    positionStream.close();
    durationStream.close();
    completedStream.close();
    container.dispose();
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

  test('playNext should NOT exit full screen', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final scene1 = createTestScene('1');
    
    // Attach initial controller
    await notifier.attachController(scene1, mockPlayer, mockVideoController);
    
    // Set full screen
    notifier.setFullScreen(true);
    expect(container.read(playerStateProvider).isFullScreen, isTrue);

    // Mock playEndBehavior to next
    notifier.setPlayEndBehavior(VideoEndBehavior.next);
    
    // Trigger video finish by emitting to completedStream
    completedStream.add(true);
    
    // Wait for async operations
    await Future.delayed(Duration.zero);
    
    // Verify it DID NOT exit full screen
    expect(container.read(playerStateProvider).isFullScreen, isTrue);
  });

  test('playEndBehavior.stop SHOULD exit full screen', () async {
    final notifier = container.read(playerStateProvider.notifier);
    final scene1 = createTestScene('1');
    
    await notifier.attachController(scene1, mockPlayer, mockVideoController);
    notifier.setFullScreen(true);
    
    notifier.setPlayEndBehavior(VideoEndBehavior.stop);
    completedStream.add(true);
    await Future.delayed(Duration.zero);
    
    expect(container.read(playerStateProvider).isFullScreen, isFalse);
  });
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
  @override
  Stream<List<mk.SubtitleTrack>> get subtitleTracks => const Stream.empty();

  CustomPlayerStream(
    this.playing,
    this.completed,
    this.position,
    this.duration,
  );
}
