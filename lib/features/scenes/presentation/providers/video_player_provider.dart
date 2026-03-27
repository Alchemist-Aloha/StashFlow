import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/entities/scene.dart';
import 'playback_queue_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../../core/utils/pip_mode.dart';
import '../../../../main.dart'; // To access mediaHandler
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/app_log_store.dart';

part 'video_player_provider.g.dart';

/// Represents the global state of the video player.
///
/// This state is shared across the entire application, allowing the mini-player,
/// full-screen player, and scene detail views to stay in sync.
class GlobalPlayerState {
  /// The scene that is currently loaded or playing.
  final Scene? activeScene;

  /// The underlying controller from the `video_player` package.
  final VideoPlayerController? videoPlayerController;

  /// Whether the video is currently playing.
  final bool isPlaying;

  /// Whether the player is currently in full-screen mode.
  final bool isFullScreen;

  /// Whether the player is currently in Picture-in-Picture mode.
  final bool isInPipMode;

  /// MIME type of the current stream.
  final String? streamMimeType;

  /// Display label for the current stream (e.g., "Direct", "Transcoded").
  final String? streamLabel;

  /// Source identifier for the current stream.
  final String? streamSource;

  /// Latency in milliseconds from initialization start to first frame.
  final int? startupLatencyMs;

  /// Whether a network prewarm was attempted for this scene.
  final bool? prewarmAttempted;

  /// Whether the prewarm attempt was successful.
  final bool? prewarmSucceeded;

  /// Latency of the prewarm attempt in milliseconds.
  final int? prewarmLatencyMs;

  /// User preference: whether to automatically play the next scene when current ends.
  final bool autoplayNext;

  /// User preference: whether to show technical overlays on the video.
  final bool showVideoDebugInfo;

  /// User preference: whether to allow double-tap to seek 10s.
  final bool useDoubleTapSeek;

  /// User preference: whether to keep audio playing when the app is backgrounded.
  final bool enableBackgroundPlayback;

  /// User preference: whether to trigger native Android PiP on minimize.
  final bool enableNativePip;

  GlobalPlayerState({
    this.activeScene,
    this.videoPlayerController,
    this.isPlaying = false,
    this.isFullScreen = false,
    this.isInPipMode = false,
    this.streamMimeType,
    this.streamLabel,
    this.streamSource,
    this.startupLatencyMs,
    this.prewarmAttempted,
    this.prewarmSucceeded,
    this.prewarmLatencyMs,
    this.autoplayNext = false,
    this.showVideoDebugInfo = false,
    this.useDoubleTapSeek = true,
    this.enableBackgroundPlayback = false,
    this.enableNativePip = false,
  });

  /// Creates a copy of the state with updated fields.
  /// Use [clearActive] to explicitly reset the active scene and controller.
  GlobalPlayerState copyWith({
    Scene? activeScene,
    VideoPlayerController? videoPlayerController,
    bool? isPlaying,
    bool? isFullScreen,
    bool? isInPipMode,
    String? streamMimeType,
    String? streamLabel,
    String? streamSource,
    int? startupLatencyMs,
    bool? prewarmAttempted,
    bool? prewarmSucceeded,
    int? prewarmLatencyMs,
    bool? autoplayNext,
    bool? showVideoDebugInfo,
    bool? useDoubleTapSeek,
    bool? enableBackgroundPlayback,
    bool? enableNativePip,
    bool clearActive = false,
  }) {
    return GlobalPlayerState(
      activeScene: clearActive ? null : (activeScene ?? this.activeScene),
      videoPlayerController: clearActive
          ? null
          : (videoPlayerController ?? this.videoPlayerController),
      isPlaying: isPlaying ?? this.isPlaying,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      isInPipMode: isInPipMode ?? this.isInPipMode,
      streamMimeType: clearActive
          ? null
          : (streamMimeType ?? this.streamMimeType),
      streamLabel: clearActive ? null : (streamLabel ?? this.streamLabel),
      streamSource: clearActive ? null : (streamSource ?? this.streamSource),
      startupLatencyMs: clearActive
          ? null
          : (startupLatencyMs ?? this.startupLatencyMs),
      prewarmAttempted: clearActive
          ? null
          : (prewarmAttempted ?? this.prewarmAttempted),
      prewarmSucceeded: clearActive
          ? null
          : (prewarmSucceeded ?? this.prewarmSucceeded),
      prewarmLatencyMs: clearActive
          ? null
          : (prewarmLatencyMs ?? this.prewarmLatencyMs),
      autoplayNext: autoplayNext ?? this.autoplayNext,
      showVideoDebugInfo: showVideoDebugInfo ?? this.showVideoDebugInfo,
      useDoubleTapSeek: useDoubleTapSeek ?? this.useDoubleTapSeek,
      enableBackgroundPlayback:
          enableBackgroundPlayback ?? this.enableBackgroundPlayback,
      enableNativePip: enableNativePip ?? this.enableNativePip,
    );
  }
}

/// A centralized notifier managing the global video player lifecycle.
///
/// This class handles:
/// - Controller initialization and disposal.
/// - Synchronization with system media controls (MediaSession).
/// - Handling transitions between scenes (Play Next).
/// - Managing UI-related playback settings (PiP, Fullscreen).
@riverpod
class PlayerState extends _$PlayerState {
  static const _autoplayNextKey = 'autoplay_next';
  static const _showVideoDebugInfoKey = 'show_video_debug_info';
  static const _useDoubleTapSeekKey = 'video_use_double_tap_seek';
  static const _enableBackgroundPlaybackKey = 'video_background_playback';
  static const _enableNativePipKey = 'video_native_pip';

  /// Internal reference used during disposal to ensure we clean up the right controller.
  VideoPlayerController? _videoControllerRef;

  /// Tracking ID to avoid redundant logging of the first frame for the same scene.
  String? _firstFrameLoggedSceneId;

  /// Mutex-like flag to prevent overlapping "Play Next" transitions,
  /// especially when triggered by multiple listeners (e.g. video finish + UI button).
  bool _isTransitioning = false;

  /// Whether the current controller was "borrowed" (e.g. from TikTok view)
  /// and should not be disposed by this provider when stopping/switching.
  bool _isUsingBorrowedController = false;

  @override
  GlobalPlayerState build() {
    // Keep player state alive across route transitions to avoid restarting media.
    ref.keepAlive();

    ref.onDispose(() {
      PipMode.isInPipMode.removeListener(_onPipModeChanged);
      unawaited(_disposeControllers());
    });

    PipMode.isInPipMode.addListener(_onPipModeChanged);

    // Link system media controls to our provider
    mediaHandler?.onPlayCallback = () async => togglePlayPause();
    mediaHandler?.onPauseCallback = () async => togglePlayPause();
    mediaHandler?.onStopCallback = () async => stop();
    mediaHandler?.onSeekCallback = (pos) async =>
        state.videoPlayerController?.seekTo(pos);
    mediaHandler?.onSkipToNextCallback = () async {
      AppLogStore.instance.add(
        'PlayerState mediaHandler.onSkipToNextCallback',
        source: 'player_provider',
      );
      return playNext();
    };

    final prefs = ref.read(sharedPreferencesProvider);
    return GlobalPlayerState(
      autoplayNext: prefs.getBool(_autoplayNextKey) ?? false,
      showVideoDebugInfo: prefs.getBool(_showVideoDebugInfoKey) ?? false,
      useDoubleTapSeek: prefs.getBool(_useDoubleTapSeekKey) ?? true,
      enableBackgroundPlayback:
          prefs.getBool(_enableBackgroundPlaybackKey) ?? false,
      enableNativePip: prefs.getBool(_enableNativePipKey) ?? false,
      isInPipMode: PipMode.isInPipMode.value,
    );
  }

  void _onPipModeChanged() {
    state = state.copyWith(isInPipMode: PipMode.isInPipMode.value);
  }

  void setAutoplayNext(bool value) {
    state = state.copyWith(autoplayNext: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_autoplayNextKey, value);
  }

  void setShowVideoDebugInfo(bool value) {
    state = state.copyWith(showVideoDebugInfo: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_showVideoDebugInfoKey, value);
  }

  void setUseDoubleTapSeek(bool value) {
    state = state.copyWith(useDoubleTapSeek: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_useDoubleTapSeekKey, value);
  }

  void setEnableBackgroundPlayback(bool value) {
    state = state.copyWith(enableBackgroundPlayback: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_enableBackgroundPlaybackKey, value);
  }

  void setEnableNativePip(bool value) {
    state = state.copyWith(enableNativePip: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_enableNativePipKey, value);
  }

  void setPrewarmResult({
    required bool attempted,
    required bool succeeded,
    int? latencyMs,
  }) {
    state = state.copyWith(
      prewarmAttempted: attempted,
      prewarmSucceeded: succeeded,
      prewarmLatencyMs: latencyMs,
    );
  }

  void setFullScreen(bool value) {
    AppLogStore.instance.add(
      'PlayerState setFullScreen: $value',
      source: 'player_provider',
    );
    state = state.copyWith(isFullScreen: value);
  }

  Future<void> playScene(
    Scene scene,
    String streamUrl, {
    String? mimeType,
    String? streamLabel,
    String? streamSource,
    Map<String, String>? httpHeaders,
    bool? prewarmAttempted,
    bool? prewarmSucceeded,
    int? prewarmLatencyMs,
    Duration? initialPosition,
  }) async {
    final allowBackgroundPlayback = state.enableBackgroundPlayback;

    AppLogStore.instance.add(
      'provider playScene begin scene=${scene.id} source=${streamSource ?? '-'} mime=${mimeType ?? '-'} initialPos=${initialPosition?.inMilliseconds}ms',
      source: 'player_provider',
    );

    if (state.activeScene?.id == scene.id &&
        state.videoPlayerController != null) {
      _videoControllerRef ??= state.videoPlayerController;
      if (initialPosition != null) {
        await state.videoPlayerController?.seekTo(initialPosition);
      }
      state.videoPlayerController?.play();
      AppLogStore.instance.add(
        'provider playScene replay-active scene=${scene.id}',
        source: 'player_provider',
      );
      state = state.copyWith(
        isPlaying: true,
        streamMimeType: mimeType,
        streamLabel: streamLabel,
        streamSource: streamSource,
        prewarmAttempted: prewarmAttempted,
        prewarmSucceeded: prewarmSucceeded,
        prewarmLatencyMs: prewarmLatencyMs,
      );
      return;
    }

    // Detach the currently rendered player widget before disposing native players.
    if (state.activeScene != null) {
      state = state.copyWith(clearActive: true, isPlaying: false);
    }

    // Stop current
    await _disposeControllers();
    _isUsingBorrowedController = false;
    if (!ref.mounted) return;

    final stopwatch = Stopwatch()..start();
    final videoController = VideoPlayerController.networkUrl(
      Uri.parse(streamUrl),
      httpHeaders: httpHeaders ?? const <String, String>{},
      videoPlayerOptions: VideoPlayerOptions(
        allowBackgroundPlayback: allowBackgroundPlayback,
      ),
    );
    _videoControllerRef = videoController;
    _firstFrameLoggedSceneId = null;

    state = state.copyWith(
      activeScene: scene,
      videoPlayerController: videoController,
      isPlaying: false,
      streamMimeType: mimeType,
      streamLabel: streamLabel,
      streamSource: streamSource,
      startupLatencyMs: null,
      prewarmAttempted: prewarmAttempted,
      prewarmSucceeded: prewarmSucceeded,
      prewarmLatencyMs: prewarmLatencyMs,
    );

    try {
      await videoController.initialize();
      if (!ref.mounted) {
        await _disposeControllers();
        return;
      }

      if (initialPosition != null) {
        await videoController.seekTo(initialPosition);
      }

      stopwatch.stop();
      final initializeElapsedMs = stopwatch.elapsedMilliseconds;
      AppLogStore.instance.add(
        'provider initialize done scene=${scene.id} elapsed=${initializeElapsedMs}ms duration=${videoController.value.duration.inMilliseconds}ms size=${videoController.value.size.width.toStringAsFixed(0)}x${videoController.value.size.height.toStringAsFixed(0)}',
        source: 'player_provider',
      );

      state = state.copyWith(
        isPlaying: true,
        startupLatencyMs: initializeElapsedMs,
      );

      mediaHandler?.updateMetadata(
        id: scene.id,
        title: scene.title,
        studio: scene.studioName,
        thumbnailUri: scene.paths.screenshot,
        duration: videoController.value.duration,
      );

      AppLogStore.instance.add(
        'provider ready scene=${scene.id} startup=${initializeElapsedMs}ms',
        source: 'player_provider',
      );

      if (!isTestMode) {
        unawaited(WakelockPlus.enable());
      }

      videoController.addListener(_videoListener);
      unawaited(videoController.play());
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      AppLogStore.instance.add(
        'provider initialize error scene=${scene.id} error=$e',
        source: 'player_provider',
      );
      if (ref.mounted) {
        stop();
      } else {
        await _disposeControllers();
      }
    }
  }

  /// Takes over an existing [VideoPlayerController] for a given [Scene].
  ///
  /// This is used for seamless handoff from TikTok view to immersive views.
  Future<void> attachController(
    Scene scene,
    VideoPlayerController controller, {
    String? streamMimeType,
    String? streamLabel,
    String? streamSource,
  }) async {
    if (!ref.mounted) return;

    AppLogStore.instance.add(
      'provider attachController scene=${scene.id} source=${streamSource ?? '-'}',
      source: 'player_provider',
    );

    // If already active, just reuse
    if (state.activeScene?.id == scene.id &&
        state.videoPlayerController == controller) {
      return;
    }

    // Stop current, but don't dispose the one we are about to attach!
    if (state.activeScene != null &&
        state.videoPlayerController != controller) {
      await _disposeControllers();
    }

    _videoControllerRef = controller;
    _firstFrameLoggedSceneId = null;
    _isUsingBorrowedController = true;

    state = state.copyWith(
      activeScene: scene,
      videoPlayerController: controller,
      isPlaying: controller.value.isPlaying,
      streamMimeType: streamMimeType,
      streamLabel: streamLabel,
      streamSource: streamSource,
      startupLatencyMs: 0, // Attached, no initialization latency to report
    );

    mediaHandler?.updateMetadata(
      id: scene.id,
      title: scene.title,
      studio: scene.studioName,
      thumbnailUri: scene.paths.screenshot,
      duration: controller.value.duration,
    );

    if (!isTestMode) {
      unawaited(WakelockPlus.enable());
    }

    controller.removeListener(_videoListener);
    controller.addListener(_videoListener);
  }

  void togglePlayPause() {
    final controller = state.videoPlayerController;
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
        state = state.copyWith(isPlaying: false);
        if (!isTestMode) {
          unawaited(WakelockPlus.disable());
        }
      } else {
        controller.play();
        state = state.copyWith(isPlaying: true);
        if (!isTestMode) {
          unawaited(WakelockPlus.enable());
        }
      }
    }
  }

  void seekRelative(Duration delta) {
    final controller = state.videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;

    final current = controller.value.position;
    final duration = controller.value.duration;
    var target = current + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    controller.seekTo(target);
  }

  void stop() {
    unawaited(_disposeControllers());
    if (!isTestMode) {
      unawaited(WakelockPlus.disable());
    }
    if (!ref.mounted) return;

    state = GlobalPlayerState(
      autoplayNext: state.autoplayNext,
      showVideoDebugInfo: state.showVideoDebugInfo,
      useDoubleTapSeek: state.useDoubleTapSeek,
      enableBackgroundPlayback: state.enableBackgroundPlayback,
      enableNativePip: state.enableNativePip,
    );
  }

  Future<void> _disposeControllers() async {
    if (isTestMode) {
      _videoControllerRef = null;
      _isUsingBorrowedController = false;
      return;
    }

    final videoController =
        _videoControllerRef ??
        (ref.mounted ? state.videoPlayerController : null);
    _videoControllerRef = null;

    if (videoController != null) {
      videoController.removeListener(_videoListener);

      if (_isUsingBorrowedController) {
        AppLogStore.instance.add(
          'provider skipping dispose of borrowed controller',
          source: 'player_provider',
        );
        _isUsingBorrowedController = false;
      } else {
        await videoController.dispose();
      }
    }

    await WakelockPlus.disable();
  }

  void _videoListener() {
    if (!ref.mounted) return;

    final controller = state.videoPlayerController;
    if (controller != null) {
      final activeSceneId = state.activeScene?.id;
      if (activeSceneId != null &&
          _firstFrameLoggedSceneId != activeSceneId &&
          controller.value.isInitialized &&
          controller.value.position > Duration.zero) {
        _firstFrameLoggedSceneId = activeSceneId;
        AppLogStore.instance.add(
          'provider first-frame scene=$activeSceneId position=${controller.value.position.inMilliseconds}ms buffered=${controller.value.buffered.length}',
          source: 'player_provider',
        );
      }

      if (controller.value.isPlaying != state.isPlaying) {
        state = state.copyWith(isPlaying: controller.value.isPlaying);
        if (!isTestMode) {
          unawaited(
            controller.value.isPlaying
                ? WakelockPlus.enable()
                : WakelockPlus.disable(),
          );
        }
      }

      mediaHandler?.updatePlaybackState(
        isPlaying: controller.value.isPlaying,
        position: controller.value.position,
        bufferedPosition: controller.value.buffered.isNotEmpty
            ? controller.value.buffered.last.end
            : Duration.zero,
        speed: controller.value.playbackSpeed,
      );

      // Check if finished
      if (controller.value.position >= controller.value.duration &&
          controller.value.duration > Duration.zero &&
          !controller.value.isPlaying) {
        _handleVideoFinished();
      }
    }
  }

  void _handleVideoFinished() {
    AppLogStore.instance.add(
      'PlayerState _handleVideoFinished: active=${state.activeScene?.id} autoplay=${state.autoplayNext}',
      source: 'player_provider',
    );
    if (state.isFullScreen) {
      setFullScreen(false);
    }
    if (state.autoplayNext) {
      playNext();
    }
  }

  Future<void> playNext() async {
    if (!ref.mounted) return;
    if (_isTransitioning) {
      AppLogStore.instance.add(
        'PlayerState playNext: already transitioning, skipping',
        source: 'player_provider',
      );
      return;
    }

    _isTransitioning = true;
    try {
      AppLogStore.instance.add(
        'PlayerState playNext: currentActive=${state.activeScene?.id}',
        source: 'player_provider',
      );

      final queueNotifier = ref.read(playbackQueueProvider.notifier);
      // If the playback queue hasn't been synchronized with the currently
      // active scene (index == -1), try to recover by finding the active
      // scene in the existing sequence. This helps when `setSequence` was
      // called with -1 to preserve an external index but the queue hasn't
      // been initialized for this session.
      if (queueNotifier.state.currentIndex == -1 &&
          state.activeScene?.id != null) {
        AppLogStore.instance.add(
          'PlayerState playNext: queue index unset, attempting to find active scene in sequence=${state.activeScene?.id}',
          source: 'player_provider',
        );
        queueNotifier.findAndSetIndex(state.activeScene!.id);
      }
      final nextScene = queueNotifier.getNextScene();

      AppLogStore.instance.add(
        'PlayerState playNext: nextSceneFound=${nextScene?.id}',
        source: 'player_provider',
      );

      if (nextScene != null) {
        AppLogStore.instance.add(
          'PlayerState playNext: moving to ${nextScene.id}',
          source: 'player_provider',
        );
        queueNotifier.playNext(); // Increment index in queue
        final resolver = ref.read(streamResolverProvider.notifier);
        final choice = await resolver.resolvePreferredStream(nextScene);
        if (choice != null) {
          final mediaHeaders = ref.read(mediaHeadersProvider);
          await playScene(
            nextScene,
            choice.url,
            mimeType: choice.mimeType,
            streamLabel: choice.label,
            streamSource: 'autoplay-next',
            httpHeaders: mediaHeaders,
          );
        } else {
          AppLogStore.instance.add(
            'PlayerState playNext: failed to resolve stream for ${nextScene.id}',
            source: 'player_provider',
          );
        }
      } else {
        AppLogStore.instance.add(
          'PlayerState playNext: no next scene found',
          source: 'player_provider',
        );
      }
    } finally {
      _isTransitioning = false;
    }
  }
}
