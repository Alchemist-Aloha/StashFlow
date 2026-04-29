import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clock/clock.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import 'playback_queue_provider.dart';
import 'scene_details_provider.dart';
import 'scene_list_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../../core/utils/pip_mode.dart';
import '../../../../main.dart'; // To access mediaHandler
import '../../../../core/data/auth/auth_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/presentation/providers/desktop_settings_provider.dart';
import '../../../../core/presentation/video/app_video_controller.dart';

part 'video_player_provider.g.dart';

/// Represents the global state of the video player.
///
/// This state is shared across the entire application, allowing the mini-player,
/// full-screen player, and scene detail views to stay in sync.
class GlobalPlayerState {
  /// The scene that is currently loaded or playing.
  final Scene? activeScene;

  /// The underlying video controller.
  final AppVideoController? videoPlayerController;

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

  /// Currently selected subtitle language code. null if disabled.
  final String? selectedSubtitleLanguage;

  /// Currently selected subtitle type (e.g., 'vtt', 'srt').
  final String? selectedSubtitleType;

  /// User preference: default subtitle language code. 'none' if disabled.
  final String defaultSubtitleLanguage;

  /// User preference: subtitle font size.
  final double subtitleFontSize;

  /// User preference: subtitle vertical position (0.0 to 1.0 from bottom).
  final double subtitlePositionBottomRatio;

  /// User preference: subtitle text alignment ('left', 'center', 'right').
  final String subtitleTextAlignment;

  /// User preference: whether to allow gravity-controlled orientation rotation in fullscreen.
  final bool videoGravityOrientation;

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
    this.videoGravityOrientation = true,
    this.selectedSubtitleLanguage,
    this.selectedSubtitleType,
    this.defaultSubtitleLanguage = 'none',
    this.subtitleFontSize = 18.0,
    this.subtitlePositionBottomRatio = 0.15,
    this.subtitleTextAlignment = 'center',
  });

  /// Creates a copy of the state with updated fields.
  /// Use [clearActive] to explicitly reset the active scene and controller.
  GlobalPlayerState copyWith({
    Scene? activeScene,
    AppVideoController? videoPlayerController,
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
    bool? videoGravityOrientation,
    String? selectedSubtitleLanguage,
    String? selectedSubtitleType,
    String? defaultSubtitleLanguage,
    double? subtitleFontSize,
    double? subtitlePositionBottomRatio,
    String? subtitleTextAlignment,
    bool clearActive = false,
    bool clearSubtitle = false,
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
      videoGravityOrientation:
          videoGravityOrientation ?? this.videoGravityOrientation,
      selectedSubtitleLanguage: clearSubtitle
          ? null
          : (selectedSubtitleLanguage ?? this.selectedSubtitleLanguage),
      selectedSubtitleType: clearSubtitle
          ? null
          : (selectedSubtitleType ?? this.selectedSubtitleType),
      defaultSubtitleLanguage:
          defaultSubtitleLanguage ?? this.defaultSubtitleLanguage,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      subtitlePositionBottomRatio:
          subtitlePositionBottomRatio ?? this.subtitlePositionBottomRatio,
      subtitleTextAlignment:
          subtitleTextAlignment ?? this.subtitleTextAlignment,
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
  static const _videoGravityOrientationKey = 'video_gravity_orientation';
  static const _defaultSubtitleLanguageKey = 'default_subtitle_language';
  static const _subtitleFontSizeKey = 'subtitle_font_size';
  static const _subtitlePositionBottomRatioKey =
      'subtitle_position_bottom_ratio';
  static const _subtitleTextAlignmentKey = 'subtitle_text_alignment';

  /// Internal reference used during disposal to ensure we clean up the right controller.
  AppVideoController? _videoControllerRef;

  /// Internal reference used during disposal to ensure we clean up the right scene activity.
  Scene? _activeSceneRef;

  /// Tracking ID to avoid redundant logging of the first frame for the same scene.
  String? _firstFrameLoggedSceneId;

  /// Mutex-like flag to prevent overlapping "Play Next" transitions,
  /// especially when triggered by multiple listeners (e.g. video finish + UI button).
  bool _isTransitioning = false;

  /// Whether the current controller was "borrowed" (e.g. from TikTok view)
  /// and should not be disposed by this provider when stopping/switching.
  bool _isUsingBorrowedController = false;

  /// Internal flag to track playback state changes across listener fires.
  bool? _lastIsPlaying;

  // Activity tracking state
  Timer? _playCountTimer;
  bool _playCountIncremented = false;
  DateTime? _playStartTime;
  double _accumulatedDuration = 0;
  Timer? _periodicSaveTimer;

  @override
  GlobalPlayerState build() {
    // Keep player state alive across route transitions to avoid restarting media.
    ref.keepAlive();

    final repository = ref.read(sceneRepositoryProvider);
    ref.onDispose(() {
      PipMode.isInPipMode.removeListener(_onPipModeChanged);
      
      unawaited(_disposeControllers(
        scene: _activeSceneRef,
        controller: _videoControllerRef,
        repository: repository,
      ));
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
      videoGravityOrientation:
          prefs.getBool(_videoGravityOrientationKey) ?? true,
      isInPipMode: PipMode.isInPipMode.value,
      defaultSubtitleLanguage:
          prefs.getString(_defaultSubtitleLanguageKey) ?? 'none',
      subtitleFontSize: prefs.getDouble(_subtitleFontSizeKey) ?? 18.0,
      subtitlePositionBottomRatio:
          prefs.getDouble(_subtitlePositionBottomRatioKey) ?? 0.15,
      subtitleTextAlignment:
          prefs.getString(_subtitleTextAlignmentKey) ?? 'center',
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

  void setVideoGravityOrientation(bool value) {
    state = state.copyWith(videoGravityOrientation: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_videoGravityOrientationKey, value);
  }

  void setDefaultSubtitleLanguage(String value) {
    state = state.copyWith(defaultSubtitleLanguage: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_defaultSubtitleLanguageKey, value);
  }

  void setSubtitleFontSize(double value) {
    state = state.copyWith(subtitleFontSize: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setDouble(_subtitleFontSizeKey, value);
  }

  void setSubtitlePositionBottomRatio(double value) {
    state = state.copyWith(subtitlePositionBottomRatio: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setDouble(_subtitlePositionBottomRatioKey, value);
  }

  void setSubtitleTextAlignment(String value) {
    state = state.copyWith(subtitleTextAlignment: value);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_subtitleTextAlignmentKey, value);
  }

  Future<void> setSubtitle(String? languageCode, {String? captionType}) async {
    if (!ref.mounted) return;
    final scene = state.activeScene;
    if (scene == null) return;

    if (state.selectedSubtitleLanguage == languageCode &&
        state.selectedSubtitleType == captionType) {
      return;
    }

    AppLogStore.instance.add(
      'PlayerState setSubtitle: $languageCode (type=$captionType)',
      source: 'player_provider',
    );

    // If we're disabling subtitles, we set it to 'none' to distinguish from
    // the null (unselected) state which triggers default auto-selection.
    if (languageCode == null || languageCode == 'none') {
      state = state.copyWith(
        selectedSubtitleLanguage: 'none',
        selectedSubtitleType: null,
      );
    } else {
      state = state.copyWith(
        selectedSubtitleLanguage: languageCode,
        selectedSubtitleType: captionType,
      );
    }

    // Reload the current scene to apply subtitle change
    final controller = state.videoPlayerController;
    if (controller != null) {
      final currentPosition = controller.value.position;
      final isPlaying = controller.value.isPlaying;
      final streamUrl = controller.dataSource;

      // We re-run playScene which will handle creating a new controller with the correct subtitle.
      // We pass the current state fields to preserve them.
      await playScene(
        scene,
        streamUrl,
        mimeType: state.streamMimeType,
        streamLabel: state.streamLabel,
        streamSource: state.streamSource,
        httpHeaders: ref.read(mediaPlaybackHeadersProvider),
        prewarmAttempted: state.prewarmAttempted,
        prewarmSucceeded: state.prewarmSucceeded,
        prewarmLatencyMs: state.prewarmLatencyMs,
        initialPosition: currentPosition,
        force: true,
      );

      if (!isPlaying) {
        state.videoPlayerController?.pause();
      }
    }
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

  Future<void> setVolume(double volume) async {
    await ref.read(desktopSettingsProvider.notifier).setVolume(volume);
    final desktopSettings = ref.read(desktopSettingsProvider);
    final controller = state.videoPlayerController;
    if (controller != null) {
      await controller.setVolume(
        desktopSettings.isMuted ? 0 : desktopSettings.volume,
      );
    }
  }

  Future<void> toggleMute() async {
    await ref.read(desktopSettingsProvider.notifier).toggleMute();
    final desktopSettings = ref.read(desktopSettingsProvider);
    final controller = state.videoPlayerController;
    if (controller != null) {
      await controller.setVolume(
        desktopSettings.isMuted ? 0 : desktopSettings.volume,
      );
    }
  }

  /// Proactively resolve the stream URL for the next scene in the queue
  /// and store it in the StreamResolver cache.
  void _prewarmNext() {
    final queue = ref.read(playbackQueueProvider);
    final nextIndex = queue.currentIndex + 1;
    if (nextIndex < queue.sequence.length) {
      final nextScene = queue.sequence[nextIndex];
      AppLogStore.instance.add(
        'PlayerState prewarming next scene=${nextScene.id} at index=$nextIndex',
        source: 'player_provider',
      );
      // Fire and forget resolution into cache
      unawaited(
        ref
            .read(streamResolverProvider.notifier)
            .resolvePreferredStream(nextScene),
      );
    }
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
    bool force = false,
  }) async {
    final allowBackgroundPlayback = state.enableBackgroundPlayback;

    AppLogStore.instance.add(
      'provider playScene begin scene=${scene.id} source=${streamSource ?? '-'} mime=${mimeType ?? '-'} initialPos=${initialPosition?.inMilliseconds}ms force=$force',
      source: 'player_provider',
    );

    // Automatic caption loading logic
    final hasCaptionPath = scene.paths.caption?.trim().isNotEmpty ?? false;
    final hasVttPath = scene.paths.vtt?.trim().isNotEmpty ?? false;
    final hasSubtitleSource = hasCaptionPath || hasVttPath;
    String? autoLang;
    String? autoType;

    // If we haven't manually selected a subtitle for this session yet
    if (!force && state.selectedSubtitleLanguage == null) {
      final defaultLang = state.defaultSubtitleLanguage;
      if (defaultLang == 'auto') {
        // 'auto' mode: select if and only if exactly one subtitle is available
        if (scene.captions.length == 1) {
          autoLang = scene.captions.first.languageCode;
          autoType = scene.captions.first.captionType;
        }
      } else if (defaultLang != 'none') {
        // 1. Try matching default language
        final matches = scene.captions.where(
          (c) => c.languageCode.toLowerCase() == defaultLang.toLowerCase(),
        );
        if (matches.isNotEmpty) {
          autoLang = matches.first.languageCode;
          autoType = matches.first.captionType;
        }
      }
    }

    // Represent "subtitles disabled" explicitly as 'none' for consistent UI
    // selection state in subtitle menus.
    if (!force &&
        state.selectedSubtitleLanguage == null &&
        state.defaultSubtitleLanguage == 'none') {
      autoLang = 'none';
      autoType = null;
    }

    final effectiveSubtitleLanguage =
        autoLang ?? state.selectedSubtitleLanguage;
    final effectiveSubtitleType = autoType ?? state.selectedSubtitleType;

    // Reset activity tracking state for the new scene
    if (!force && state.activeScene?.id != scene.id) {
      await _stopActivityTracking();
      _playCountIncremented = false;
      _accumulatedDuration = 0;
    }

    // ...
    // Later in playScene, when creating the controller:
    Future<vp.ClosedCaptionFile>? closedCaptionFile;
    if (effectiveSubtitleLanguage != null &&
        effectiveSubtitleLanguage != 'none' &&
        hasSubtitleSource) {
      final lang = effectiveSubtitleLanguage;
      final type = effectiveSubtitleType;
      late final String captionUrl;
      if (hasCaptionPath) {
        final baseCaptionUrl = scene.paths.caption!.trim();
        final uri = Uri.parse(baseCaptionUrl);
        final queryParams = Map<String, dynamic>.from(uri.queryParameters);
        if (lang.isNotEmpty) {
          queryParams['lang'] = lang;
        }
        if (type != null && type.isNotEmpty) {
          queryParams['type'] = type;
        }
        captionUrl = uri.replace(queryParameters: queryParams).toString();
      } else {
        // For unnamed subtitle sources, use vtt path directly.
        captionUrl = scene.paths.vtt!.trim();
      }

      AppLogStore.instance.add(
        'provider playScene: loading subtitles lang=$lang type=$type final=$captionUrl',
        source: 'player_provider',
      );

      closedCaptionFile = _loadSubtitles(
        captionUrl,
        fallbackVttUrl: hasVttPath ? scene.paths.vtt!.trim() : null,
      );
    } else if (effectiveSubtitleLanguage != null) {
      AppLogStore.instance.add(
        'provider playScene: language selected but no subtitle source path is available',
        source: 'player_provider',
      );
    }

    var effectiveStreamUrl = streamUrl;
    if (kIsWeb) {
      final authState = ref.read(authProvider);
      final apiKey = ref.read(serverApiKeyProvider);
      final serverUrl = ref.read(serverUrlProvider);
      effectiveStreamUrl = applyWebMediaAuthFallback(
        url: streamUrl,
        authMode: authState.mode,
        apiKey: apiKey,
        username: authState.username,
        password: authState.password,
        graphqlEndpoint: Uri.tryParse(serverUrl),
      );
    }

    if (state.videoPlayerController != null) {
      await _disposeControllers();
    }

    final videoController = VideoPlayerControllerAdapter.networkUrl(
      Uri.parse(effectiveStreamUrl),
      httpHeaders: httpHeaders ?? const <String, String>{},
      closedCaptionFile: closedCaptionFile,
      allowBackgroundPlayback: allowBackgroundPlayback,
      mixWithOthers: true,
    );
    _videoControllerRef = videoController;
    _activeSceneRef = scene;
    _firstFrameLoggedSceneId = null;
    _lastIsPlaying = null;

    final stopwatch = Stopwatch()..start();

    state = GlobalPlayerState(
      activeScene: scene,
      videoPlayerController: videoController,
      isPlaying: false,
      isFullScreen:
          state.isFullScreen, // Preserve fullscreen state across scenes
      isInPipMode: state.isInPipMode, // Preserve PiP state across scenes
      streamMimeType: mimeType,
      streamLabel: streamLabel,
      streamSource: streamSource,
      startupLatencyMs: null,
      prewarmAttempted: prewarmAttempted,
      prewarmSucceeded: prewarmSucceeded,
      prewarmLatencyMs: prewarmLatencyMs,
      autoplayNext: state.autoplayNext,
      showVideoDebugInfo: state.showVideoDebugInfo,
      useDoubleTapSeek: state.useDoubleTapSeek,
      enableBackgroundPlayback: state.enableBackgroundPlayback,
      enableNativePip: state.enableNativePip,
      videoGravityOrientation: state.videoGravityOrientation,
      selectedSubtitleLanguage: effectiveSubtitleLanguage,
      selectedSubtitleType: effectiveSubtitleType,
      defaultSubtitleLanguage: state.defaultSubtitleLanguage,
      subtitleFontSize: state.subtitleFontSize,
      subtitlePositionBottomRatio: state.subtitlePositionBottomRatio,
      subtitleTextAlignment: state.subtitleTextAlignment,
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
        thumbnailUri: appendApiKey(
          scene.paths.screenshot ?? '',
          ref.read(serverApiKeyProvider),
        ),
        duration: videoController.value.duration,
      );

      AppLogStore.instance.add(
        'provider ready scene=${scene.id} startup=${initializeElapsedMs}ms',
        source: 'player_provider',
      );

      if (!isTestMode) {
        unawaited(WakelockPlus.enable());
      }

      final desktopSettings = ref.read(desktopSettingsProvider);
      await videoController.setVolume(
        desktopSettings.isMuted ? 0 : desktopSettings.volume,
      );

      videoController.addListener(_videoListener);
      unawaited(videoController.play());

      // Prepare for the next scene in the queue
      _prewarmNext();
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

  /// Takes over an existing [AppVideoController] for a given [Scene].
  ///
  /// This is used for seamless handoff from TikTok view to immersive views.
  Future<void> attachController(
    Scene scene,
    AppVideoController controller, {
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

    // Reset activity tracking state for the new scene
    if (state.activeScene?.id != scene.id) {
      _playCountIncremented = false;
      _accumulatedDuration = 0;
    }

    _videoControllerRef = controller;
    _activeSceneRef = scene;
    _firstFrameLoggedSceneId = null;
    _isUsingBorrowedController = true;
    _lastIsPlaying = null;

    state = state.copyWith(
      activeScene: scene,
      videoPlayerController: controller,
      isPlaying: controller.value.isPlaying,
      isFullScreen: state.isFullScreen, // Preserve fullscreen
      isInPipMode: state.isInPipMode, // Preserve PiP
      streamMimeType: streamMimeType,
      streamLabel: streamLabel,
      streamSource: streamSource,
      startupLatencyMs: 0, // Attached, no initialization latency to report
    );

    mediaHandler?.updateMetadata(
      id: scene.id,
      title: scene.title,
      studio: scene.studioName,
      thumbnailUri: appendApiKey(
        scene.paths.screenshot ?? '',
        ref.read(serverApiKeyProvider),
      ),
      duration: controller.value.duration,
    );

    if (!isTestMode) {
      unawaited(WakelockPlus.enable());
    }

    final desktopSettings = ref.read(desktopSettingsProvider);
    unawaited(
      controller.setVolume(
        desktopSettings.isMuted ? 0 : desktopSettings.volume,
      ),
    );

    controller.removeListener(_videoListener);
    controller.addListener(_videoListener);

    if (controller.value.isPlaying) {
      _startActivityTracking();
    }

    // Prepare for the next scene in the queue
    _prewarmNext();
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
    _activeSceneRef = null;
    _lastIsPlaying = null;
    if (!ref.mounted) return;

    state = GlobalPlayerState(
      autoplayNext: state.autoplayNext,
      showVideoDebugInfo: state.showVideoDebugInfo,
      useDoubleTapSeek: state.useDoubleTapSeek,
      enableBackgroundPlayback: state.enableBackgroundPlayback,
      enableNativePip: state.enableNativePip,
      videoGravityOrientation: state.videoGravityOrientation,
      defaultSubtitleLanguage: state.defaultSubtitleLanguage,
      subtitleFontSize: state.subtitleFontSize,
      subtitlePositionBottomRatio: state.subtitlePositionBottomRatio,
      subtitleTextAlignment: state.subtitleTextAlignment,
    );
  }

  Future<void> _disposeControllers({
    Scene? scene,
    AppVideoController? controller,
    SceneRepository? repository,
  }) async {
    // Save final activity before disposing
    await _stopActivityTracking(
      scene: scene,
      controller: controller,
      repository: repository,
    );

    if (isTestMode) {
      _videoControllerRef = null;
      _isUsingBorrowedController = false;
      return;
    }

    final videoController =
        _videoControllerRef ??
        controller ??
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

  void _startActivityTracking() {
    if (!ref.mounted) return;
    final scene = state.activeScene;
    if (scene == null) return;

    if (_playStartTime != null) return; // Already tracking

    AppLogStore.instance.add(
      'PlayerState _startActivityTracking for scene=${scene.id}',
      source: 'player_provider',
    );

    // 1. Play count timer (5 seconds)
    if (!_playCountIncremented) {
      _playCountTimer?.cancel();
      _playCountTimer = Timer(const Duration(seconds: 5), () async {
        if (!ref.mounted || _playCountIncremented) return;
        try {
          await ref
              .read(sceneRepositoryProvider)
              .incrementScenePlayCount(scene.id);
          _playCountIncremented = true;
          if (ref.mounted) {
            unawaited(ref.read(sceneDetailsProvider(scene.id).notifier).refresh());
          }
          AppLogStore.instance.add(
            'PlayerState play count incremented for scene=${scene.id}',
            source: 'player_provider',
          );
        } catch (e) {
          debugPrint('Failed to increment play count: $e');
        }
      });
    }

    // 2. Duration tracking
    _playStartTime = clock.now();

    // 3. Periodic save timer (30 seconds)
    _periodicSaveTimer?.cancel();
    _periodicSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _saveActivity();
    });
  }

  Future<void> _stopActivityTracking({
    Scene? scene,
    AppVideoController? controller,
    SceneRepository? repository,
  }) async {
    _playCountTimer?.cancel();
    _playCountTimer = null;
    _periodicSaveTimer?.cancel();
    _periodicSaveTimer = null;

    if (_playStartTime != null) {
      final now = clock.now();
      _accumulatedDuration +=
          now.difference(_playStartTime!).inMilliseconds / 1000.0;
      _playStartTime = null;
    }

    if (_accumulatedDuration > 0) {
      await _saveActivity(
        scene: scene,
        controller: controller,
        repository: repository,
      );
    }
  }

  Future<void> _saveActivity({
    Scene? scene,
    AppVideoController? controller,
    SceneRepository? repository,
  }) async {
    final effectiveScene = scene ?? (ref.mounted ? state.activeScene : null);
    final effectiveController =
        controller ?? (ref.mounted ? state.videoPlayerController : null);
    final effectiveRepo = repository ?? (ref.mounted ? ref.read(sceneRepositoryProvider) : null);

    if (effectiveScene == null || effectiveController == null || effectiveRepo == null) {
      return;
    }

    // Calculate current duration if still playing
    double durationToSave = _accumulatedDuration;
    if (_playStartTime != null) {
      final now = clock.now();
      durationToSave += now.difference(_playStartTime!).inMilliseconds / 1000.0;
      // Reset start time to current so we don't double count in next save
      _playStartTime = now;
    }

    if (durationToSave < 0.1 && effectiveController.value.position == Duration.zero) {
      return;
    }

    final resumeTime = effectiveController.value.position.inMilliseconds / 1000.0;
    _accumulatedDuration = 0;

    AppLogStore.instance.add(
      'PlayerState _saveActivity scene=${effectiveScene.id} duration=${durationToSave.toStringAsFixed(1)}s resume=${resumeTime.toStringAsFixed(1)}s',
      source: 'player_provider',
    );

    try {
      await effectiveRepo.saveSceneActivity(
        effectiveScene.id,
        resumeTime: resumeTime,
        playDuration: durationToSave,
      );
      if (ref.mounted) {
        unawaited(ref.read(sceneDetailsProvider(effectiveScene.id).notifier).refresh());
      }
    } catch (e) {
      debugPrint('Failed to save scene activity: $e');
      // On failure, we might want to put the duration back into the accumulator
      // but let's keep it simple for now to avoid complexity.
    }
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

      if (controller.value.isPlaying != _lastIsPlaying) {
        final wasPlaying = _lastIsPlaying ?? false;
        final isPlayingNow = controller.value.isPlaying;
        _lastIsPlaying = isPlayingNow;

        state = state.copyWith(isPlaying: isPlayingNow);

        if (isPlayingNow) {
          _startActivityTracking();
        } else if (wasPlaying) {
          _stopActivityTracking();
        }

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

  Future<vp.ClosedCaptionFile> _loadSubtitles(
    String url, {
    String? fallbackVttUrl,
  }) async {
    final apiKey = ref.read(serverApiKeyProvider);
    final headers = ref.read(mediaPlaybackHeadersProvider);
    final authenticatedUrl = appendApiKey(url, apiKey);

    AppLogStore.instance.add(
      'PlayerState _loadSubtitles: downloading $authenticatedUrl',
      source: 'player_provider',
    );

    try {
      final requestHeaders = {...headers, 'Accept': 'text/vtt, */*'};

      var response = await http.get(
        Uri.parse(authenticatedUrl),
        headers: requestHeaders,
      );

      AppLogStore.instance.add(
        'PlayerState _loadSubtitles: status=${response.statusCode} len=${response.bodyBytes.length} type=${response.headers['content-type']}',
        source: 'player_provider',
      );

      // Fallback 1: If lang=00 returned empty, try without lang parameter
      if (response.statusCode == 200 &&
          response.bodyBytes.isEmpty &&
          authenticatedUrl.contains('lang=00')) {
        final uri = Uri.parse(authenticatedUrl);
        final params = Map<String, String>.from(uri.queryParameters);
        params.remove('lang');
        final fallbackUrl = uri.replace(queryParameters: params).toString();

        AppLogStore.instance.add(
          'PlayerState _loadSubtitles: empty response for lang=00, trying fallback: $fallbackUrl',
          source: 'player_provider',
        );
        response = await http.get(
          Uri.parse(fallbackUrl),
          headers: requestHeaders,
        );

        AppLogStore.instance.add(
          'PlayerState _loadSubtitles fallback: status=${response.statusCode} len=${response.bodyBytes.length}',
          source: 'player_provider',
        );
      }

      // Fallback 2: If still empty and we have a vtt path, try that
      if (response.statusCode == 200 &&
          response.bodyBytes.isEmpty &&
          fallbackVttUrl != null &&
          fallbackVttUrl != url) {
        final authFallbackVtt = appendApiKey(fallbackVttUrl, apiKey);
        AppLogStore.instance.add(
          'PlayerState _loadSubtitles: empty response, trying vtt fallback: $authFallbackVtt',
          source: 'player_provider',
        );
        response = await http.get(
          Uri.parse(authFallbackVtt),
          headers: requestHeaders,
        );
        AppLogStore.instance.add(
          'PlayerState _loadSubtitles vtt fallback: status=${response.statusCode} len=${response.bodyBytes.length}',
          source: 'player_provider',
        );
      }

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        if (bytes.isEmpty) {
          AppLogStore.instance.add(
            'PlayerState _loadSubtitles: received empty body bytes',
            source: 'player_provider',
          );
          return vp.WebVTTCaptionFile('');
        }

        // Use utf8.decode with allowMalformed: true to be resilient
        var content = utf8.decode(bytes, allowMalformed: true);

        if (content.trim().isEmpty) {
          AppLogStore.instance.add(
            'PlayerState _loadSubtitles: received only whitespace',
            source: 'player_provider',
          );
          return vp.WebVTTCaptionFile('');
        }

        // Filter out thumbnail/storyboard lines (e.g. sprite.jpg#xywh=...)
        content = _filterSubtitleContent(content);

        final preview = content.length > 100
            ? content.substring(0, 100).replaceAll('\n', ' ')
            : content.replaceAll('\n', ' ');

        AppLogStore.instance.add(
          'PlayerState _loadSubtitles: success, length=${content.length}, preview="$preview"',
          source: 'player_provider',
        );

        final isVtt = content.contains('WEBVTT');
        // SRT often starts with 1 and a newline, or has --> but not WEBVTT
        final isSrt = !isVtt && content.contains('-->');

        vp.ClosedCaptionFile captionFile;
        if (isSrt) {
          AppLogStore.instance.add(
            'PlayerState _loadSubtitles: detected SRT format',
            source: 'player_provider',
          );
          captionFile = vp.SubRipCaptionFile(content);
        } else {
          AppLogStore.instance.add(
            'PlayerState _loadSubtitles: detected VTT format',
            source: 'player_provider',
          );
          captionFile = vp.WebVTTCaptionFile(content);
        }

        AppLogStore.instance.add(
          'PlayerState _loadSubtitles: parsed ${captionFile.captions.length} captions',
          source: 'player_provider',
        );

        return captionFile;
      } else {
        throw Exception('Failed to load subtitles: ${response.statusCode}');
      }
    } catch (e) {
      AppLogStore.instance.add(
        'PlayerState _loadSubtitles error: $e',
        source: 'player_provider',
      );
      // Return empty file on error to avoid breaking playback
      return vp.WebVTTCaptionFile('');
    }
  }

  /// Filters out common storyboard/thumbnail lines (like sprite.jpg#xywh=...)
  /// from VTT/SRT content to prevent them from being rendered as text captions.
  String _filterSubtitleContent(String content) {
    if (!content.contains('#xywh')) return content;

    final lines = content.split('\n');
    final filteredLines = lines.where((line) {
      final trimmed = line.trim();
      // Filter out lines containing the storyboard fragment identifier.
      // These are typically of the form: "thumbnail.jpg#xywh=0,0,160,90"
      if (trimmed.contains('#xywh')) return false;
      return true;
    });

    return filteredLines.join('\n');
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
          final mediaHeaders = ref.read(mediaPlaybackHeadersProvider);
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
