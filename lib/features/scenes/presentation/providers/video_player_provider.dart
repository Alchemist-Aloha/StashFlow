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
  final bool autoplayNext;
  final bool showVideoDebugInfo;
  final bool useDoubleTapSeek;

  GlobalPlayerState({
    this.activeScene,
    this.videoPlayerController,
    this.chewieController,
    this.isPlaying = false,
    this.streamMimeType,
    this.streamLabel,
    this.streamSource,
    this.startupLatencyMs,
    this.autoplayNext = false,
    this.showVideoDebugInfo = false,
    this.useDoubleTapSeek = true,
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
    bool? autoplayNext,
    bool? showVideoDebugInfo,
    bool? useDoubleTapSeek,
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
      autoplayNext: autoplayNext ?? this.autoplayNext,
      showVideoDebugInfo: showVideoDebugInfo ?? this.showVideoDebugInfo,
      useDoubleTapSeek: useDoubleTapSeek ?? this.useDoubleTapSeek,
    );
  }
}

@riverpod
class PlayerState extends _$PlayerState {
  static const _autoplayNextKey = 'autoplay_next';
  static const _showVideoDebugInfoKey = 'show_video_debug_info';
  static const _useDoubleTapSeekKey = 'video_use_double_tap_seek';

  @override
  GlobalPlayerState build() {
    ref.onDispose(() {
      _disposeControllers();
    });

    final prefs = ref.read(sharedPreferencesProvider);
    return GlobalPlayerState(
      autoplayNext: prefs.getBool(_autoplayNextKey) ?? false,
      showVideoDebugInfo: prefs.getBool(_showVideoDebugInfoKey) ?? false,
      useDoubleTapSeek: prefs.getBool(_useDoubleTapSeekKey) ?? true,
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
      ),
      placeholder: Container(color: Colors.black),
    );

    existingChewie?.dispose();
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
  }) async {
    if (state.activeScene?.id == scene.id &&
        state.videoPlayerController != null) {
      state.videoPlayerController?.play();
      state = state.copyWith(
        isPlaying: true,
        streamMimeType: mimeType,
        streamLabel: streamLabel,
        streamSource: streamSource,
      );
      return;
    }

    // Stop current
    await _disposeControllers();

    final stopwatch = Stopwatch()..start();
    final videoController = VideoPlayerController.networkUrl(
      Uri.parse(streamUrl),
      httpHeaders: httpHeaders ?? const <String, String>{},
    );

    state = state.copyWith(
      activeScene: scene,
      videoPlayerController: videoController,
      isPlaying: false,
      streamMimeType: mimeType,
      streamLabel: streamLabel,
      streamSource: streamSource,
      startupLatencyMs: null,
    );

    try {
      await videoController.initialize();
      stopwatch.stop();

      final initializedAspectRatio = videoController.value.aspectRatio;
      final metadataAspectRatio = _sceneAspectRatio(scene);
      final resolvedAspectRatio =
          (initializedAspectRatio.isFinite && initializedAspectRatio > 0)
          ? initializedAspectRatio
          : (metadataAspectRatio ?? (16 / 9));

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: true,
        looping: false,
        aspectRatio: resolvedAspectRatio,
        allowFullScreen: true,
        customControls: ScrubChewieControls(
          useDoubleTapSeek: state.useDoubleTapSeek,
        ),
        placeholder: Container(color: Colors.black),
      );

      state = state.copyWith(
        chewieController: chewieController,
        isPlaying: true,
        startupLatencyMs: stopwatch.elapsedMilliseconds,
      );

      unawaited(WakelockPlus.enable());

      videoController.addListener(_videoListener);
    } catch (e) {
      debugPrint('Error initializing video player: $e');
      stop();
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
    controller.seekTo(target);
  }

  void stop() {
    _disposeControllers();
    unawaited(WakelockPlus.disable());
    state = GlobalPlayerState(
      autoplayNext: state.autoplayNext,
      showVideoDebugInfo: state.showVideoDebugInfo,
      useDoubleTapSeek: state.useDoubleTapSeek,
    );
  }

  Future<void> _disposeControllers() async {
    state.videoPlayerController?.removeListener(_videoListener);
    state.chewieController?.dispose();
    await state.videoPlayerController?.dispose();
    await WakelockPlus.disable();
  }

  void _videoListener() {
    final controller = state.videoPlayerController;
    if (controller != null) {
      if (controller.value.isPlaying != state.isPlaying) {
        state = state.copyWith(isPlaying: controller.value.isPlaying);
        unawaited(
          controller.value.isPlaying
              ? WakelockPlus.enable()
              : WakelockPlus.disable(),
        );
      }

      // Check if finished
      if (controller.value.position >= controller.value.duration &&
          controller.value.duration > Duration.zero &&
          !controller.value.isPlaying) {
        _handleVideoFinished();
      }
    }
  }

  void _handleVideoFinished() {
    if (state.autoplayNext) {
      playNext();
    }
  }

  Future<void> playNext() async {
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
