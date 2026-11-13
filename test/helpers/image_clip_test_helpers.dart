import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:media_kit_video/media_kit_video.dart';
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_session_controller.dart';

class FakeClipPlayer extends Mock implements mk.Player {
  final events = FakeClipStreams();
  bool playing = false;
  int playCalls = 0;
  int pauseCalls = 0;
  int disposeCalls = 0;
  final seeks = <Duration>[];
  mk.PlaylistMode? playlistMode;
  mk.Playable? opened;
  Duration position = const Duration(seconds: 20);
  Duration duration = const Duration(seconds: 100);
  bool updatePositionOnSeek = true;
  Completer<void>? opening;
  Completer<void>? seeking;
  Completer<void>? pausing;
  Error? openError;

  @override
  mk.PlayerStream get stream => events;

  @override
  mk.PlayerState get state => mk.PlayerState(
    playing: playing,
    position: position,
    duration: duration,
    width: 640,
    height: 360,
  );

  @override
  Future<void> setPlaylistMode(mk.PlaylistMode mode) async =>
      playlistMode = mode;

  @override
  Future<void> open(mk.Playable playable, {bool play = true}) async {
    opened = playable;
    if (openError != null) throw openError!;
    await opening?.future;
  }

  @override
  Future<void> play() async {
    playCalls++;
    playing = true;
    events.playingEvents.add(true);
  }

  @override
  Future<void> pause() async {
    pauseCalls++;
    await pausing?.future;
    playing = false;
    events.playingEvents.add(false);
  }

  @override
  Future<void> seek(Duration value) async {
    seeks.add(value);
    await seeking?.future;
    if (updatePositionOnSeek) {
      position = value;
      if (!events.positions.isClosed) events.positions.add(value);
    }
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
    await events.close();
  }
}

class FakeClipStreams extends Fake implements mk.PlayerStream {
  final playingEvents = StreamController<bool>.broadcast();
  final positions = StreamController<Duration>.broadcast();
  final errors = StreamController<String>.broadcast();

  Future<void> close() async {
    await playingEvents.close();
    await positions.close();
    await errors.close();
  }

  @override
  Stream<bool> get playing => playingEvents.stream;
  @override
  Stream<Duration> get position => positions.stream;
  @override
  Stream<String> get error => errors.stream;
  @override
  Stream<Duration> get duration => const Stream.empty();
  @override
  Stream<int> get width => const Stream.empty();
  @override
  Stream<int> get height => const Stream.empty();
  @override
  Stream<List<String>> get subtitle => const Stream.empty();
}

class FakeClipVideoController extends Mock implements VideoController {
  FakeClipVideoController(this.player);

  @override
  final mk.Player player;
  @override
  final notifier = ValueNotifier<PlatformVideoController?>(null);
  @override
  final platform = Completer<PlatformVideoController>()
    ..complete(_FakePlatform());
  @override
  Future<void> get waitUntilFirstFrameRendered async {}
}

class _FakePlatform extends Mock implements PlatformVideoController {}

PlaybackSession fakeClipSession(FakeClipPlayer player) => PlaybackSession(
  player: player,
  controller: FakeClipVideoController(player),
);
