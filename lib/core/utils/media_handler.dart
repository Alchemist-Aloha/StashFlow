import 'package:audio_service/audio_service.dart';

/// A bridge between the application's video players and the system media session.
///
/// [StashMediaHandler] uses the `audio_service` package to:
/// 1. Show media notifications on the lock screen and notification shade.
/// 2. Handle remote control events (play, pause, skip, seek) from headphones,
///    Bluetooth devices, and the system UI.
/// 3. Provide metadata (title, studio, duration) to the OS.
class StashMediaHandler extends BaseAudioHandler {
  /// Updates the metadata shown in the system media notification.
  void updateMetadata({
    required String id,
    required String title,
    String? studio,
    String? thumbnailUri,
    Duration? duration,
  }) {
    mediaItem.add(
      MediaItem(
        id: id,
        album: studio ?? 'Stash',
        title: title,
        artist: studio ?? 'Stash',
        duration: duration,
        artUri: thumbnailUri != null ? Uri.parse(thumbnailUri) : null,
      ),
    );
  }

  /// Updates the playback state (playing/paused, position) in the system media session.
  void updatePlaybackState({
    required bool isPlaying,
    Duration? position,
    Duration? bufferedPosition,
    double speed = 1.0,
    AudioProcessingState processingState = AudioProcessingState.ready,
  }) {
    playbackState.add(
      PlaybackState(
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
        processingState: processingState,
        playing: isPlaying,
        updatePosition: position ?? Duration.zero,
        bufferedPosition: bufferedPosition ?? Duration.zero,
        speed: speed,
      ),
    );
  }

  /// Updates artwork only when [id] is still the active media item.
  void updateArtwork({required String id, required String thumbnailUri}) {
    final current = mediaItem.value;
    if (current?.id != id) return;
    mediaItem.add(current!.copyWith(artUri: Uri.parse(thumbnailUri)));
  }

  /// Ends the media session so Android removes its playback notification.
  void dismiss() {
    playbackState.add(
      playbackState.value.copyWith(
        controls: const [],
        systemActions: const {},
        androidCompactActionIndices: const [],
        playing: false,
        processingState: AudioProcessingState.idle,
      ),
    );
    mediaItem.add(null);
  }

  /// Callback for toggling play state. Linked to the active player provider.
  Future<void> Function()? onPlayCallback;

  /// Callback for pausing playback.
  Future<void> Function()? onPauseCallback;

  /// Callback for stopping playback.
  Future<void> Function()? onStopCallback;

  /// Callback for seeking to a specific position.
  Future<void> Function(Duration)? onSeekCallback;

  /// Callback for skipping to the next item in the queue.
  Future<void> Function()? onSkipToNextCallback;

  /// Callback for skipping to the previous item.
  Future<void> Function()? onSkipToPreviousCallback;

  @override
  Future<void> play() async => onPlayCallback?.call();

  @override
  Future<void> pause() async => onPauseCallback?.call();

  @override
  Future<void> stop() async {
    await onStopCallback?.call();
    dismiss();
  }

  @override
  Future<void> seek(Duration position) async => onSeekCallback?.call(position);

  @override
  Future<void> skipToNext() async => onSkipToNextCallback?.call();

  @override
  Future<void> skipToPrevious() async => onSkipToPreviousCallback?.call();

  @override
  Future<void> onTaskRemoved() => stop();
}
