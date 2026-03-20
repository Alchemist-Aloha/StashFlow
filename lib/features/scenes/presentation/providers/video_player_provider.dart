import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/entities/scene.dart';
import 'playback_queue_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import '../widgets/scrub_chewie_controls.dart';

part 'video_player_provider.g.dart';

class GlobalPlayerState {
  final Scene? activeScene;
  final VideoPlayerController? videoPlayerController;
  final ChewieController? chewieController;
  final bool isPlaying;
  final String? streamMimeType;
  final String? streamLabel;
  final String? streamSource;
  final int? startupLatencyMs;
  final bool? prewarmAttempted;
  final bool? prewarmSucceeded;
  final int? prewarmLatencyMs;
  final bool autoplayNext;
  final bool showVideoDebugInfo;
  final bool useDoubleTapSeek;
  final bool enableBackgroundPlayback;
  final bool enableNativePip;

  GlobalPlayerState({
    this.activeScene,
    this.videoPlayerController,
    this.chewieController,
    this.isPlaying = false,
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

  GlobalPlayerState copyWith({
    Scene? activeScene,
    VideoPlayerController? videoPlayerController,
    ChewieController? chewieController,
    bool? isPlaying,
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
      chewieController: clearActive
          ? null
          : (chewieController ?? this.chewieController),
      isPlaying: isPlaying ?? this.isPlaying,
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

@riverpod
class PlayerState extends _$PlayerState {
  static const _autoplayNextKey = 'autoplay_next';
  static const _showVideoDebugInfoKey = 'show_video_debug_info';
  static const _useDoubleTapSeekKey = 'video_use_double_tap_seek';
  static const _enableBackgroundPlaybackKey = 'video_background_playback';
  static const _enableNativePipKey = 'video_native_pip';

  VideoPlayerController? _videoControllerRef;
  ChewieController? _chewieControllerRef;
  String? _firstFrameLoggedSceneId;
  String? _completedSceneId;

  @override
  GlobalPlayerState build() {
    // Keep player state alive across route transitions to avoid restarting media.
    ref.keepAlive();

    ref.onDispose(() {
      unawaited(_disposeControllers());
    });

    final prefs = ref.read(sharedPreferencesProvider);
    return GlobalPlayerState(
      autoplayNext: prefs.getBool(_autoplayNextKey) ?? false,
      showVideoDebugInfo: prefs.getBool(_showVideoDebugInfoKey) ?? false,
      useDoubleTapSeek: prefs.getBool(_useDoubleTapSeekKey) ?? true,
      enableBackgroundPlayback:
          prefs.getBool(_enableBackgroundPlaybackKey) ?? false,
      enableNativePip: prefs.getBool(_enableNativePipKey) ?? false,
    );
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
    _rebuildChewieControls();
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
    _rebuildChewieControls();
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

  void _rebuildChewieControls() {
    final videoController = state.videoPlayerController;
    if (videoController == null || !videoController.value.isInitialized) {
      return;
    }

    final existingChewie = state.chewieController;
    final scene = state.activeScene;
    final initializedAspectRatio = videoController.value.aspectRatio;
    final metadataAspectRatio = scene == null ? null : _sceneAspectRatio(scene);
    final resolvedAspectRatio =
        (initializedAspectRatio.isFinite && initializedAspectRatio > 0)
        ? initializedAspectRatio
        : (metadataAspectRatio ?? (16 / 9));

    final newChewie = ChewieController(
      videoPlayerController: videoController,
      autoPlay: videoController.value.isPlaying,
      looping: false,
      aspectRatio: resolvedAspectRatio,
      allowFullScreen: true,
      customControls: ScrubChewieControls(
        useDoubleTapSeek: state.useDoubleTapSeek,
        enableNativePip: state.enableNativePip,
      ),
      placeholder: Container(color: Colors.black),
    );

    existingChewie?.dispose();
    _chewieControllerRef = newChewie;
    state = state.copyWith(chewieController: newChewie);
  }

  double? _sceneAspectRatio(Scene scene) {
    if (scene.files.isEmpty) return null;
    final file = scene.files.first;
    final width = file.width;
    final height = file.height;
    if (width == null || height == null || width <= 0 || height <= 0) {
      return null;
    }
    return width / height;
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
  }) async {
    final allowBackgroundPlayback = state.enableBackgroundPlayback;
    final useDoubleTapSeek = state.useDoubleTapSeek;
    final enableNativePip = state.enableNativePip;

    AppLogStore.instance.add(
      'provider playScene begin scene=${scene.id} source=${streamSource ?? '-'} mime=${mimeType ?? '-'}',
      source: 'player_provider',
    );

    if (state.activeScene?.id == scene.id &&
        state.videoPlayerController != null) {
      _videoControllerRef ??= state.videoPlayerController;
      state.videoPlayerController?.play();
      _completedSceneId = null;
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
    _completedSceneId = null;

    state = state.copyWith(
      activeScene: scene,
      videoPlayerController: videoController,
      chewieController: null,
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
      stopwatch.stop();
      final initializeElapsedMs = stopwatch.elapsedMilliseconds;
      AppLogStore.instance.add(
        'provider initialize done scene=${scene.id} elapsed=${initializeElapsedMs}ms duration=${videoController.value.duration.inMilliseconds}ms size=${videoController.value.size.width.toStringAsFixed(0)}x${videoController.value.size.height.toStringAsFixed(0)}',
        source: 'player_provider',
      );

      final initializedAspectRatio = videoController.value.aspectRatio;
      final metadataAspectRatio = _sceneAspectRatio(scene);
      final resolvedAspectRatio =
          (initializedAspectRatio.isFinite && initializedAspectRatio > 0)
          ? initializedAspectRatio
          : (metadataAspectRatio ?? (16 / 9));

      final chewieBuildStopwatch = Stopwatch()..start();
      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: resolvedAspectRatio,
        allowFullScreen: true,
        customControls: ScrubChewieControls(
          useDoubleTapSeek: useDoubleTapSeek,
          enableNativePip: enableNativePip,
        ),
        placeholder: Container(color: Colors.black),
      );
      _chewieControllerRef = chewieController;
      chewieBuildStopwatch.stop();

      state = state.copyWith(
        chewieController: chewieController,
        isPlaying: true,
        startupLatencyMs: initializeElapsedMs,
      );

      AppLogStore.instance.add(
        'provider chewie ready scene=${scene.id} chewieBuild=${chewieBuildStopwatch.elapsedMilliseconds}ms startup=${initializeElapsedMs}ms',
        source: 'player_provider',
      );

      unawaited(WakelockPlus.enable());

      videoController.addListener(_videoListener);
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

  void togglePlayPause() {
    final controller = state.videoPlayerController;
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
        state = state.copyWith(isPlaying: false);
        unawaited(WakelockPlus.disable());
      } else {
        controller.play();
        _completedSceneId = null;
        state = state.copyWith(isPlaying: true);
        unawaited(WakelockPlus.enable());
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
    if (target < duration) {
      _completedSceneId = null;
    }
    controller.seekTo(target);
  }

  void stop() {
    unawaited(_disposeControllers());
    unawaited(WakelockPlus.disable());
    _completedSceneId = null;
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
    final videoController =
        _videoControllerRef ??
        (ref.mounted ? state.videoPlayerController : null);
    final chewieController =
        _chewieControllerRef ?? (ref.mounted ? state.chewieController : null);
    _videoControllerRef = null;
    _chewieControllerRef = null;
    _completedSceneId = null;

    videoController?.removeListener(_videoListener);
    chewieController?.dispose();
    await videoController?.dispose();
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
        if (controller.value.isPlaying) {
          _completedSceneId = null;
        }
        state = state.copyWith(isPlaying: controller.value.isPlaying);
        unawaited(
          controller.value.isPlaying
              ? WakelockPlus.enable()
              : WakelockPlus.disable(),
        );
      }

      final duration = controller.value.duration;
      if (duration > Duration.zero && activeSceneId != null) {
        final completionThreshold =
            duration - const Duration(milliseconds: 200);
        final atEnd =
            controller.value.position >=
            (completionThreshold > Duration.zero
                ? completionThreshold
                : Duration.zero);

        if (atEnd && !controller.value.isPlaying) {
          if (_completedSceneId != activeSceneId) {
            _completedSceneId = activeSceneId;
            _handleVideoFinished();
          }
        } else if (!atEnd && _completedSceneId == activeSceneId) {
          _completedSceneId = null;
        }
      }
    }
  }

  void _handleVideoFinished() {
    if (state.autoplayNext) {
      playNext();
    }
  }

  Future<void> playNext() async {
    if (!ref.mounted) return;

    final nextScene = ref.read(playbackQueueProvider.notifier).getNextScene();
    if (nextScene != null) {
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
      }
    }
  }
}
