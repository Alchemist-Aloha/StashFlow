import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';

class StashMediaHandler extends BaseAudioHandler {
  void updateMetadata({
    required String id,
    required String title,
    String? studio,
    String? thumbnailUri,
    Duration? duration,
  }) {
    mediaItem.add(MediaItem(
      id: id,
      album: studio ?? 'Stash',
      title: title,
      artist: studio ?? 'Stash',
      duration: duration,
      artUri: thumbnailUri != null ? Uri.parse(thumbnailUri) : null,
    ));
  }

  void updatePlaybackState({
    required bool isPlaying,
    Duration? position,
    Duration? bufferedPosition,
    double speed = 1.0,
  }) {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: AudioProcessingState.ready,
      playing: isPlaying,
      updatePosition: position ?? Duration.zero,
      bufferedPosition: bufferedPosition ?? Duration.zero,
      speed: speed,
    ));
  }

  // These will be overridden by the provider to link back to the player
  Future<void> Function()? onPlayCallback;
  Future<void> Function()? onPauseCallback;
  Future<void> Function()? onStopCallback;
  Future<void> Function(Duration)? onSeekCallback;
  Future<void> Function()? onSkipToNextCallback;
  Future<void> Function()? onSkipToPreviousCallback;

  @override
  Future<void> play() async => onPlayCallback?.call();

  @override
  Future<void> pause() async => onPauseCallback?.call();

  @override
  Future<void> stop() async {
    await onStopCallback?.call();
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }

  @override
  Future<void> seek(Duration position) async => onSeekCallback?.call(position);

  @override
  Future<void> skipToNext() async => onSkipToNextCallback?.call();

  @override
  Future<void> skipToPrevious() async => onSkipToPreviousCallback?.call();

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    // Signal the OS that the task is finished
    await SystemNavigator.pop();
  }
}
