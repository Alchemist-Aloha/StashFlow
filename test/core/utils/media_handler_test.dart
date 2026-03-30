import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/utils/media_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StashMediaHandler handler;

  setUp(() {
    handler = StashMediaHandler();
  });

  group('updateMetadata', () {
    test(
      'updates mediaItem with default values when only required args provided',
      () async {
        handler.updateMetadata(id: '1', title: 'Test Title');

        final mediaItem = await handler.mediaItem.first;

        expect(mediaItem?.id, '1');
        expect(mediaItem?.title, 'Test Title');
        expect(mediaItem?.album, 'Stash');
        expect(mediaItem?.artist, 'Stash');
        expect(mediaItem?.duration, isNull);
        expect(mediaItem?.artUri, isNull);
      },
    );

    test('updates mediaItem with provided values', () async {
      handler.updateMetadata(
        id: '2',
        title: 'Another Title',
        studio: 'Custom Studio',
        thumbnailUri: 'https://example.com/thumb.jpg',
        duration: const Duration(minutes: 5),
      );

      final mediaItem = await handler.mediaItem.first;

      expect(mediaItem?.id, '2');
      expect(mediaItem?.title, 'Another Title');
      expect(mediaItem?.album, 'Custom Studio');
      expect(mediaItem?.artist, 'Custom Studio');
      expect(mediaItem?.duration, const Duration(minutes: 5));
      expect(mediaItem?.artUri, Uri.parse('https://example.com/thumb.jpg'));
    });
  });

  group('updatePlaybackState', () {
    test('updates playbackState when playing', () async {
      handler.updatePlaybackState(
        isPlaying: true,
        position: const Duration(seconds: 10),
        bufferedPosition: const Duration(seconds: 20),
        speed: 1.5,
      );

      final state = await handler.playbackState.first;

      expect(state.playing, isTrue);
      expect(state.processingState, AudioProcessingState.ready);
      expect(state.updatePosition, const Duration(seconds: 10));
      expect(state.bufferedPosition, const Duration(seconds: 20));
      expect(state.speed, 1.5);
      expect(state.controls.contains(MediaControl.pause), isTrue);
      expect(state.controls.contains(MediaControl.play), isFalse);
    });

    test('updates playbackState when paused', () async {
      handler.updatePlaybackState(isPlaying: false);

      final state = await handler.playbackState.first;

      expect(state.playing, isFalse);
      expect(state.processingState, AudioProcessingState.ready);
      expect(state.updatePosition, Duration.zero);
      expect(state.bufferedPosition, Duration.zero);
      expect(state.speed, 1.0);
      expect(state.controls.contains(MediaControl.play), isTrue);
      expect(state.controls.contains(MediaControl.pause), isFalse);
    });
  });

  group('callbacks', () {
    test('play callback is invoked', () async {
      bool called = false;
      handler.onPlayCallback = () async {
        called = true;
      };

      await handler.play();
      expect(called, isTrue);
    });

    test('pause callback is invoked', () async {
      bool called = false;
      handler.onPauseCallback = () async {
        called = true;
      };

      await handler.pause();
      expect(called, isTrue);
    });

    test('stop callback is invoked and updates state', () async {
      bool called = false;
      handler.onStopCallback = () async {
        called = true;
      };

      // Set initial playing state
      handler.updatePlaybackState(isPlaying: true);

      await handler.stop();
      expect(called, isTrue);

      final state = await handler.playbackState.first;
      expect(state.playing, isFalse);
      expect(state.processingState, AudioProcessingState.idle);
    });

    test('seek callback is invoked with correct duration', () async {
      Duration? seekedTo;
      handler.onSeekCallback = (position) async {
        seekedTo = position;
      };

      await handler.seek(const Duration(seconds: 30));
      expect(seekedTo, const Duration(seconds: 30));
    });

    test('skipToNext callback is invoked', () async {
      bool called = false;
      handler.onSkipToNextCallback = () async {
        called = true;
      };

      await handler.skipToNext();
      expect(called, isTrue);
    });

    test('skipToPrevious callback is invoked', () async {
      bool called = false;
      handler.onSkipToPreviousCallback = () async {
        called = true;
      };

      await handler.skipToPrevious();
      expect(called, isTrue);
    });
  });

  group('onTaskRemoved', () {
    test('calls stop and SystemNavigator.pop', () async {
      bool stopCalled = false;
      handler.onStopCallback = () async {
        stopCalled = true;
      };

      bool popCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (message) async {
            if (message.method == 'SystemNavigator.pop') {
              popCalled = true;
            }
            return null;
          });

      await handler.onTaskRemoved();

      expect(stopCalled, isTrue);
      expect(popCalled, isTrue);

      // Clean up mock handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });
  });
}
