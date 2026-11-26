import 'dart:async';

import 'package:audio_service/audio_service.dart';

/// A bridge between the application's video players and the system media session.
///
/// [StashMediaHandler] uses the `audio_service` package to:
/// 1. Show media notifications on mobile and MPRIS media controls on Linux.
/// 2. Handle remote control events (play, pause, skip, seek) from headphones,
///    Bluetooth devices, and the system UI.
/// 3. Provide metadata (title, studio, duration) to the OS.
class StashMediaHandler extends BaseAudioHandler {
  bool _enabled = true;
  Timer? _idleTimer;
  MediaItem? _heldItem;
  PlaybackState? _heldState;

  /// Whether updates reach the system session; Android's playback notification
  /// and foreground service exist only while this is true.
  ///
  /// While disabled, the latest metadata and state are held and republished
  /// when re-enabled.
  bool get enabled => _enabled;
  set enabled(bool value) {
    if (_enabled == value) return;
    if (!value) {
      _heldItem = mediaItem.value;
      _heldState = playbackState.value;
      _dismissSession();
    }
    _enabled = value;
    if (value) {
      if (_heldItem != null) mediaItem.add(_heldItem);
      if (_heldState != null) _addState(_heldState!);
      _heldItem = null;
      _heldState = null;
    }
  }

  MediaItem? get _currentItem => _enabled ? mediaItem.value : _heldItem;

  void _addState(PlaybackState state) {
    _idleTimer?.cancel();
    playbackState.add(state);
  }

  void _addItem(MediaItem item) =>
      _enabled ? mediaItem.add(item) : _heldItem = item;

  /// Updates the metadata shown in the system media notification.
  void updateMetadata({
    required String id,
    required String title,
    String? studio,
    String? thumbnailUri,
    Duration? duration,
  }) {
    final current = _currentItem;
    final artUri = thumbnailUri != null
        ? Uri.parse(thumbnailUri)
        : current?.id == id
        ? current?.artUri
        : null;
    _addItem(
      MediaItem(
        id: id,
        album: studio ?? 'Stash',
        title: title,
        artist: studio ?? 'Stash',
        duration: duration,
        artUri: artUri,
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
    final next = PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (isPlaying) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processingState,
      playing: isPlaying,
      updatePosition: position ?? Duration.zero,
      bufferedPosition: bufferedPosition ?? Duration.zero,
      speed: speed,
    );
    _enabled ? _addState(next) : _heldState = next;
  }

  /// Updates artwork only when [id] is still the active media item.
  void updateArtwork({required String id, required String thumbnailUri}) {
    final current = _currentItem;
    if (current?.id != id) return;
    _addItem(current!.copyWith(artUri: Uri.parse(thumbnailUri)));
  }

  /// Ends the media session so Android removes its playback notification.
  void dismiss() {
    _heldItem = null;
    _heldState = null;
    _dismissSession();
  }

  void _dismissSession() {
    final wasPlaying = playbackState.value.playing;
    final paused = playbackState.value.copyWith(
      controls: const [],
      systemActions: const {},
      androidCompactActionIndices: const [],
      playing: false,
    );
    final idle = paused.copyWith(processingState: AudioProcessingState.idle);
    mediaItem.add(null);
    if (!wasPlaying) return _addState(idle);
    // Pausing first detaches the foreground notification; cancelling in the
    // same instant races Android's detach, which reposts the notification.
    // shortcut: fixed 500 ms settle time verified on one device; raise it if
    // a stopped notification lingers elsewhere.
    _addState(paused);
    _idleTimer = Timer(
      const Duration(milliseconds: 500),
      () => playbackState.add(idle),
    );
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
