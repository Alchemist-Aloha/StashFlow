import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_kit/media_kit.dart' as mk;
import 'package:mockito/mockito.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_session_controller.dart';

import 'playend_behavior_test.mocks.dart';

void main() {
  group('PlaybackSessionController', () {
    late MockPlayer player1;
    late MockPlayer player2;
    late MockVideoController controller1;
    late MockVideoController controller2;
    late StreamController<bool> playing1;
    late StreamController<Duration> position1;
    late StreamController<Duration> duration1;
    late StreamController<bool> completed1;
    late StreamController<String> error1;
    late StreamController<bool> playing2;
    late StreamController<Duration> position2;
    late StreamController<Duration> duration2;
    late StreamController<bool> completed2;
    late StreamController<String> error2;

    setUp(() {
      player1 = MockPlayer();
      player2 = MockPlayer();
      controller1 = MockVideoController();
      controller2 = MockVideoController();

      playing1 = StreamController<bool>.broadcast();
      position1 = StreamController<Duration>.broadcast();
      duration1 = StreamController<Duration>.broadcast();
      completed1 = StreamController<bool>.broadcast();
      error1 = StreamController<String>.broadcast();
      playing2 = StreamController<bool>.broadcast();
      position2 = StreamController<Duration>.broadcast();
      duration2 = StreamController<Duration>.broadcast();
      completed2 = StreamController<bool>.broadcast();
      error2 = StreamController<String>.broadcast();

      when(player1.stream).thenReturn(
        _CustomPlayerStream(
          playing1.stream,
          completed1.stream,
          position1.stream,
          duration1.stream,
          error1.stream,
        ),
      );
      when(player2.stream).thenReturn(
        _CustomPlayerStream(
          playing2.stream,
          completed2.stream,
          position2.stream,
          duration2.stream,
          error2.stream,
        ),
      );
      when(controller1.player).thenReturn(player1);
      when(controller2.player).thenReturn(player2);
    });

    tearDown(() async {
      await playing1.close();
      await position1.close();
      await duration1.close();
      await completed1.close();
      await error1.close();
      await playing2.close();
      await position2.close();
      await duration2.close();
      await completed2.close();
      await error2.close();
    });

    test('bindPlayerStreams forwards tick and completed callbacks', () async {
      final sessionController = PlaybackSessionController(
        createPlayer: () => player1,
        createVideoController: (_) => controller1,
      );
      var ticks = 0;
      var completed = 0;

      await sessionController.bindPlayerStreams(
        player1,
        onTick: () => ticks++,
        onCompleted: () => completed++,
        onError: (_) {},
      );

      playing1.add(true);
      completed1.add(true);
      await Future<void>.delayed(Duration.zero);

      expect(ticks, 1);
      expect(completed, 1);
    });

    test('completed callback fires once per false-to-true edge', () async {
      final sessionController = PlaybackSessionController(
        createPlayer: () => player1,
        createVideoController: (_) => controller1,
      );
      var completed = 0;

      await sessionController.bindPlayerStreams(
        player1,
        onTick: () {},
        onCompleted: () => completed++,
        onError: (_) {},
      );

      completed1.add(true);
      completed1.add(true);
      await Future<void>.delayed(Duration.zero);
      expect(completed, 1);

      completed1.add(false);
      completed1.add(true);
      await Future<void>.delayed(Duration.zero);
      expect(completed, 2);
    });

    test('rebinding cancels previous subscriptions', () async {
      final sessionController = PlaybackSessionController(
        createPlayer: () => player1,
        createVideoController: (_) => controller1,
      );
      var ticks = 0;

      await sessionController.bindPlayerStreams(
        player1,
        onTick: () => ticks++,
        onCompleted: () {},
        onError: (_) {},
      );
      await sessionController.bindPlayerStreams(
        player2,
        onTick: () => ticks++,
        onCompleted: () {},
        onError: (_) {},
      );

      playing1.add(true);
      playing2.add(true);
      await Future<void>.delayed(Duration.zero);

      expect(ticks, 1);
    });

    test('disposeSession skips dispose for borrowed controller', () async {
      final sessionController = PlaybackSessionController(
        createPlayer: () => player1,
        createVideoController: (_) => controller1,
      );
      sessionController.adoptBorrowedSession(player1, controller1);

      await sessionController.disposeSession(isTestMode: false, log: (_) {});

      verifyNever(player1.dispose());
    });

    test('startup recovery warms the stream and retries once', () async {
      final recovery = PlaybackStartupRecovery();
      final starts = <int>[];
      final slowStarts = <int>[];
      final retries = <int>[];

      final result = await recovery.run<String>(
        start: (attempt) {
          starts.add(attempt);
          if (attempt == 0) return Completer<String>().future;
          return Future.value('ready');
        },
        onSlowStartup: (attempt) async => slowStarts.add(attempt),
        onRetry: (attempt, error) async => retries.add(attempt),
        isCurrent: () => true,
        slowStartupDelay: const Duration(milliseconds: 1),
        retryTimeout: const Duration(milliseconds: 10),
      );

      expect(result, 'ready');
      expect(starts, [0, 1]);
      expect(slowStarts, [0]);
      expect(retries, [0]);
    });
  });
}

class _CustomPlayerStream extends Mock implements mk.PlayerStream {
  @override
  final Stream<bool> playing;
  @override
  final Stream<bool> completed;
  @override
  final Stream<Duration> position;
  @override
  final Stream<Duration> duration;
  @override
  final Stream<String> error;

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
  Stream<double> get bufferingPercentage => const Stream.empty();
  @override
  Stream<double> get pitch => const Stream.empty();
  @override
  Stream<mk.PlaylistMode> get playlistMode => const Stream.empty();
  @override
  Stream<bool> get shuffle => const Stream.empty();
  @override
  Stream<mk.AudioParams> get audioParams => const Stream.empty();
  @override
  Stream<mk.VideoParams> get videoParams => const Stream.empty();
  @override
  Stream<int?> get width => const Stream.empty();
  @override
  Stream<int?> get height => const Stream.empty();
  @override
  Stream<mk.Track> get track => const Stream.empty();
  @override
  Stream<mk.Tracks> get tracks => const Stream.empty();
  @override
  Stream<List<String>> get subtitle => const Stream.empty();
  @override
  Stream<mk.PlayerLog> get log => const Stream.empty();
  @override
  Stream<double?> get audioBitrate => const Stream.empty();
  @override
  Stream<mk.AudioDevice> get audioDevice => const Stream.empty();
  @override
  Stream<List<mk.AudioDevice>> get audioDevices => const Stream.empty();

  _CustomPlayerStream(
    this.playing,
    this.completed,
    this.position,
    this.duration,
    this.error,
  );
}
