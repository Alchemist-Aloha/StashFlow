import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clock/clock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/entities/scene.dart';
import 'playback_queue_provider.dart';
import 'scene_details_provider.dart';
import 'scene_list_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../data/repositories/stream_prewarmer.dart';
import 'playback_activity_tracker.dart';
import 'playback_session_controller.dart';
import 'player_settings.dart';
import '../../../../core/utils/pip_mode.dart';
import '../../../../main.dart'; // To access mediaHandler
import '../../../../core/data/auth/auth_provider.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/preferences/shared_preferences_provider.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/presentation/providers/desktop_settings_provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

part 'video_player_provider.g.dart';

enum VideoEndBehavior { stop, loop, next }

enum PlayerViewMode { inline, fullscreen, tiktok }

class NavigationAction {
  final String path;
  final bool isReplacement;
  NavigationAction(this.path, {this.isReplacement = false});
}

class NavigationIntent {
  final List<NavigationAction> actions;
  NavigationIntent(this.actions);
}

/// Represents the global state of the video player.
///
/// This state is shared across the entire application, allowing the mini-player,
/// full-screen player, and scene detail views to stay in sync.
class GlobalPlayerState {
  /// The scene that is currently loaded or playing.
  final Scene? activeScene;

  /// The underlying Player.
  final Player? player;

  /// The underlying VideoController.
  final VideoController? videoController;

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

  /// Whether the player is currently buffering.
  final bool isBuffering;

  /// The width of the video track.
  final int? videoWidth;

  /// The height of the video track.
  final int? videoHeight;

  /// Latency in milliseconds from initialization start to first frame.
  final int? startupLatencyMs;

  /// Whether a network prewarm was attempted for this scene.
  final bool? prewarmAttempted;

  /// Whether the prewarm attempt was successful.
  final bool? prewarmSucceeded;

  /// Latency of the prewarm attempt in milliseconds.
  final int? prewarmLatencyMs;

  /// User preference: how to behave when current playback ends.
  final VideoEndBehavior playEndBehavior;

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

  /// User preference: whether to start feed playback from a random position.
  final bool feedStartRandom;

  /// User preference: whether to resume playback from the last saved position.
  final bool resumePlayPosition;

  /// Current UI context where the video is being viewed.
  final PlayerViewMode viewMode;

  /// Flag to ignore redundant triggers during navigation.
  final bool isTransitioning;

  /// Intent for coordinated navigation triggered by player state changes.
  final NavigationIntent? navigationIntent;

  GlobalPlayerState({
    this.activeScene,
    this.player,
    this.videoController,
    this.isPlaying = false,
    this.isFullScreen = false,
    this.isInPipMode = false,
    this.streamMimeType,
    this.streamLabel,
    this.streamSource,
    this.isBuffering = false,
    this.videoWidth,
    this.videoHeight,
    this.startupLatencyMs,
    this.prewarmAttempted,
    this.prewarmSucceeded,
    this.prewarmLatencyMs,
    this.playEndBehavior = VideoEndBehavior.stop,
    this.showVideoDebugInfo = false,
    this.useDoubleTapSeek = true,
    this.enableBackgroundPlayback = false,
    this.enableNativePip = false,
    this.videoGravityOrientation = true,
    this.feedStartRandom = false,
    this.resumePlayPosition = true,
    this.selectedSubtitleLanguage,
    this.selectedSubtitleType,
    this.defaultSubtitleLanguage = 'none',
    this.subtitleFontSize = 18.0,
    this.subtitlePositionBottomRatio = 0.15,
    this.subtitleTextAlignment = 'center',
    this.viewMode = PlayerViewMode.inline,
    this.isTransitioning = false,
    this.navigationIntent,
  });

  /// User preference: whether to automatically play the next scene when current ends.
  /// (Deprecated: Use [playEndBehavior] instead)
  bool get autoplayNext => playEndBehavior == VideoEndBehavior.next;

  /// Creates a copy of the state with updated fields.
  /// Use [clearActive] to explicitly reset the active scene and controller.
  GlobalPlayerState copyWith({
    Scene? activeScene,
    Player? player,
    VideoController? videoController,
    bool? isPlaying,
    bool? isFullScreen,
    bool? isInPipMode,
    String? streamMimeType,
    String? streamLabel,
    String? streamSource,
    bool? isBuffering,
    int? videoWidth,
    int? videoHeight,
    int? startupLatencyMs,
    bool? prewarmAttempted,
    bool? prewarmSucceeded,
    int? prewarmLatencyMs,
    VideoEndBehavior? playEndBehavior,
    bool? autoplayNext,
    bool? showVideoDebugInfo,
    bool? useDoubleTapSeek,
    bool? enableBackgroundPlayback,
    bool? enableNativePip,
    bool? videoGravityOrientation,
    bool? feedStartRandom,
    bool? resumePlayPosition,
    String? selectedSubtitleLanguage,
    String? selectedSubtitleType,
    String? defaultSubtitleLanguage,
    double? subtitleFontSize,
    double? subtitlePositionBottomRatio,
    String? subtitleTextAlignment,
    PlayerViewMode? viewMode,
    bool? isTransitioning,
    NavigationIntent? navigationIntent,
    bool clearActive = false,
    bool clearSubtitle = false,
    bool clearNavigation = false,
  }) {
    return GlobalPlayerState(
      activeScene: clearActive ? null : (activeScene ?? this.activeScene),
      player: clearActive ? null : (player ?? this.player),
      videoController: clearActive
          ? null
          : (videoController ?? this.videoController),
      isPlaying: isPlaying ?? this.isPlaying,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      isInPipMode: isInPipMode ?? this.isInPipMode,
      streamMimeType: clearActive
          ? null
          : (streamMimeType ?? this.streamMimeType),
      streamLabel: clearActive ? null : (streamLabel ?? this.streamLabel),
      streamSource: clearActive ? null : (streamSource ?? this.streamSource),
      isBuffering: isBuffering ?? this.isBuffering,
      videoWidth: clearActive ? null : (videoWidth ?? this.videoWidth),
      videoHeight: clearActive ? null : (videoHeight ?? this.videoHeight),
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
      playEndBehavior:
          playEndBehavior ??
          (autoplayNext != null
              ? (autoplayNext ? VideoEndBehavior.next : VideoEndBehavior.stop)
              : this.playEndBehavior),
      showVideoDebugInfo: showVideoDebugInfo ?? this.showVideoDebugInfo,
      useDoubleTapSeek: useDoubleTapSeek ?? this.useDoubleTapSeek,
      enableBackgroundPlayback:
          enableBackgroundPlayback ?? this.enableBackgroundPlayback,
      enableNativePip: enableNativePip ?? this.enableNativePip,
      videoGravityOrientation:
          videoGravityOrientation ?? this.videoGravityOrientation,
      feedStartRandom: feedStartRandom ?? this.feedStartRandom,
      resumePlayPosition: resumePlayPosition ?? this.resumePlayPosition,
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
      viewMode: viewMode ?? this.viewMode,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      navigationIntent: clearNavigation
          ? null
          : (navigationIntent ?? this.navigationIntent),
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
  PlayerSettingsStore get _settingsStore =>
      PlayerSettingsStore(ref.read(sharedPreferencesProvider));

  /// Internal reference used during disposal to ensure we clean up the right scene activity.
  Scene? _activeSceneRef;

  /// Tracking ID to avoid redundant logging of the first frame for the same scene.
  String? _firstFrameLoggedSceneId;

  /// Mutex-like flag to prevent overlapping "Play Next" transitions,
  /// especially when triggered by multiple listeners (e.g. video finish + UI button).
  bool _isTransitioning = false;

  /// Internal flag to track playback state changes across listener fires.
  bool? _lastIsPlaying;

  /// Internal flag to track the last position reported to the media handler.
  Duration? _lastMediaHandlerPosition;

  /// Internal flag to track the last speed reported to the media handler.
  double? _lastSpeed;

  late final PlaybackActivityTracker _activityTracker;
  late final PlaybackSessionController _sessionController;

  @override
  GlobalPlayerState build() {
    // Keep player state alive across route transitions to avoid restarting media.
    ref.keepAlive();

    // Ensure MediaKit is initialized before any Player instances are created.
    // This is called here instead of main() to improve initial app startup performance.
    MediaKit.ensureInitialized();
    _sessionController = PlaybackSessionController();

    _activityTracker = PlaybackActivityTracker(
      now: () => clock.now(),
      isMounted: () => ref.mounted,
      incrementPlayCount: (sceneId) =>
          ref.read(sceneRepositoryProvider).incrementScenePlayCount(sceneId),
      saveSceneActivity: (sceneId, resumeTime, playDuration) => ref
          .read(sceneRepositoryProvider)
          .saveSceneActivity(
            sceneId,
            resumeTime: resumeTime,
            playDuration: playDuration,
          ),
      refreshSceneDetails: (sceneId) {
        if (!ref.mounted) return;
        unawaited(ref.read(sceneDetailsProvider(sceneId).notifier).refresh());
      },
      log: (message) {
        AppLogStore.instance.add(message, source: 'player_provider');
      },
    );
    ref.onDispose(() {
      PipMode.isInPipMode.removeListener(_onPipModeChanged);
      _activityTracker.dispose();

      unawaited(
        _disposeControllers(
          scene: _activeSceneRef,
          controller: _sessionController.controller,
        ),
      );
    });

    PipMode.isInPipMode.addListener(_onPipModeChanged);

    // Link system media controls to our provider
    mediaHandler?.onPlayCallback = () async => togglePlayPause();
    mediaHandler?.onPauseCallback = () async => togglePlayPause();
    mediaHandler?.onStopCallback = () async => stop();
    mediaHandler?.onSeekCallback = (pos) async => state.player?.seek(pos);
    mediaHandler?.onSkipToNextCallback = () async {
      AppLogStore.instance.add(
        'PlayerState mediaHandler.onSkipToNextCallback',
        source: 'player_provider',
      );
      return playNext();
    };

    final loadedSettings = _settingsStore.load();
    final playEndBehavior = VideoEndBehavior.values.firstWhere(
      (e) => e.name == loadedSettings.playEndBehaviorName,
      orElse: () => VideoEndBehavior.stop,
    );

    return GlobalPlayerState(
      playEndBehavior: playEndBehavior,
      showVideoDebugInfo: loadedSettings.showVideoDebugInfo,
      useDoubleTapSeek: loadedSettings.useDoubleTapSeek,
      enableBackgroundPlayback: loadedSettings.enableBackgroundPlayback,
      enableNativePip: loadedSettings.enableNativePip,
      videoGravityOrientation: loadedSettings.videoGravityOrientation,
      isInPipMode: PipMode.isInPipMode.value,
      defaultSubtitleLanguage: loadedSettings.defaultSubtitleLanguage,
      subtitleFontSize: loadedSettings.subtitleFontSize,
      subtitlePositionBottomRatio: loadedSettings.subtitlePositionBottomRatio,
      subtitleTextAlignment: loadedSettings.subtitleTextAlignment,
      feedStartRandom: loadedSettings.feedStartRandom,
      resumePlayPosition: loadedSettings.resumePlayPosition,
    );
  }

  void _onPipModeChanged() {
    state = state.copyWith(isInPipMode: PipMode.isInPipMode.value);
  }

  void setAutoplayNext(bool value) {
    setPlayEndBehavior(value ? VideoEndBehavior.next : VideoEndBehavior.stop);
  }

  void setPlayEndBehavior(VideoEndBehavior behavior) {
    state = state.copyWith(playEndBehavior: behavior);
    unawaited(_settingsStore.savePlayEndBehaviorName(behavior.name));
  }

  void setShowVideoDebugInfo(bool value) {
    state = state.copyWith(showVideoDebugInfo: value);
    unawaited(_settingsStore.saveShowVideoDebugInfo(value));
  }

  void setUseDoubleTapSeek(bool value) {
    state = state.copyWith(useDoubleTapSeek: value);
    unawaited(_settingsStore.saveUseDoubleTapSeek(value));
  }

  void setEnableBackgroundPlayback(bool value) {
    state = state.copyWith(enableBackgroundPlayback: value);
    unawaited(_settingsStore.saveEnableBackgroundPlayback(value));
  }

  void setEnableNativePip(bool value) {
    state = state.copyWith(enableNativePip: value);
    unawaited(_settingsStore.saveEnableNativePip(value));
  }

  void setVideoGravityOrientation(bool value) {
    state = state.copyWith(videoGravityOrientation: value);
    unawaited(_settingsStore.saveVideoGravityOrientation(value));
  }

  void setFeedStartRandom(bool value) {
    state = state.copyWith(feedStartRandom: value);
    unawaited(_settingsStore.saveFeedStartRandom(value));
  }

  void setResumePlayPosition(bool value) {
    state = state.copyWith(resumePlayPosition: value);
    unawaited(_settingsStore.saveResumePlayPosition(value));
  }

  void setDefaultSubtitleLanguage(String value) {
    state = state.copyWith(defaultSubtitleLanguage: value);
    unawaited(_settingsStore.saveDefaultSubtitleLanguage(value));
  }

  void setSubtitleFontSize(double value) {
    state = state.copyWith(subtitleFontSize: value);
    unawaited(_settingsStore.saveSubtitleFontSize(value));
  }

  void setSubtitlePositionBottomRatio(double value) {
    state = state.copyWith(subtitlePositionBottomRatio: value);
    unawaited(_settingsStore.saveSubtitlePositionBottomRatio(value));
  }

  void setSubtitleTextAlignment(String value) {
    state = state.copyWith(subtitleTextAlignment: value);
    unawaited(_settingsStore.saveSubtitleTextAlignment(value));
  }

  Future<void> setSubtitle(String? languageCode, {String? captionType}) async {
    if (!ref.mounted) return;
    final scene = state.activeScene;
    if (scene == null || state.player == null) return;
    AppLogStore.instance.add(
      'PlayerState setSubtitle: $languageCode (type=$captionType)',
      source: 'player_provider',
    );
    // 1. Update the UI state first
    final isNone = languageCode == null || languageCode == 'none';
    state = state.copyWith(
      selectedSubtitleLanguage: isNone ? 'none' : languageCode,
      selectedSubtitleType: captionType,
    );

    // 2. Switch the track dynamically
    final player = state.player!;

    if (isNone) {
      // Disable subtitles
      await player.setSubtitleTrack(SubtitleTrack.no());
    } else {
      // Find the track that matches your languageCode
      // Note: You might need to map languageCode to the actual Track ID
      // available in player.state.tracks.subtitle
      try {
        final availableTracks = player.state.tracks.subtitle;
        final targetTrack = availableTracks.firstWhere(
          (t) => t.language == languageCode || t.title == languageCode,
          orElse: () => SubtitleTrack.auto(),
        );

        await player.setSubtitleTrack(targetTrack);
      } catch (e) {
        AppLogStore.instance.add('Failed to switch track: $e');
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

  void setViewMode(PlayerViewMode mode) {
    AppLogStore.instance.add(
      'PlayerState setViewMode: $mode',
      source: 'player_provider',
    );
    state = state.copyWith(viewMode: mode);
  }

  /// Synchronizes the background navigation to match the currently active scene.
  /// This is called when exiting fullscreen to ensure the user lands on the
  /// correct details page.
  void syncBackgroundToActiveScene(BuildContext context) {
    final activeSceneId = state.activeScene?.id;
    if (activeSceneId == null) return;

    final router = GoRouter.of(context);
    final currentPath = router.routeInformationProvider.value.uri.path;

    // If we are not already on the details page for this scene
    if (!currentPath.contains('/scenes/scene/$activeSceneId')) {
      AppLogStore.instance.add(
        'PlayerState: syncing background to scene $activeSceneId',
        source: 'player_provider',
      );
      router.pushReplacement('/scenes/scene/$activeSceneId');
    }
  }

  void _navigate(List<NavigationAction> actions) {
    state = state.copyWith(navigationIntent: NavigationIntent(actions));
    // Immediately clear intent so it's not re-processed on next state update
    Future.microtask(() {
      if (ref.mounted) state = state.copyWith(clearNavigation: true);
    });
  }

  Future<void> setVolume(double volume) async {
    await ref.read(desktopSettingsProvider.notifier).setVolume(volume);
    final desktopSettings = ref.read(desktopSettingsProvider);
    final player = state.player;
    if (player != null) {
      await player.setVolume(
        desktopSettings.isMuted ? 0 : desktopSettings.volume * 100.0,
      );
    }
  }

  Future<void> toggleMute() async {
    await ref.read(desktopSettingsProvider.notifier).toggleMute();
    final desktopSettings = ref.read(desktopSettingsProvider);
    final player = state.player;
    if (player != null) {
      await player.setVolume(
        desktopSettings.isMuted ? 0 : desktopSettings.volume * 100.0,
      );
    }
  }

  /// Proactively resolve and warm the stream URLs for the next several scenes
  /// in the playback queue to ensure near-instant startup when navigating.
  void _prewarmQueue() {
    final queue = ref.read(playbackQueueProvider);
    final currentIndex = queue.currentIndex;
    final sequence = queue.sequence;

    if (currentIndex == -1 || sequence.isEmpty) return;

    // Keep prewarming conservative: one next-scene probe preserves quick
    // sequential navigation without competing heavily with active playback.
    const windowSize = 1;
    final startIndex = currentIndex + 1;
    final endIndex = (currentIndex + 1 + windowSize).clamp(0, sequence.length);

    final nextScenes = <Scene>[];
    for (int i = startIndex; i < endIndex; i++) {
      nextScenes.add(sequence[i]);
    }

    final prewarmer = ref.read(streamPrewarmerProvider.notifier);
    final resolver = ref.read(streamResolverProvider.notifier);
    final mediaHeaders = ref.read(mediaPlaybackHeadersProvider);

    // Cancel any active prewarms for scenes that are no longer in our current "next N" window.
    final nextSceneIds = nextScenes.map((s) => s.id).toSet();
    prewarmer.cancelAllExcept(nextSceneIds);

    for (final scene in nextScenes) {
      unawaited(() async {
        // Resolve URL (hits cache if already resolved)
        final choice = await resolver.resolvePreferredStream(scene);
        if (choice != null) {
          // Perform network-level prewarming
          await prewarmer.prewarm(scene, choice.url, headers: mediaHeaders);
        }
      }());
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
      await _activityTracker.stop(
        sceneId: state.activeScene?.id,
        resumePositionProvider: () =>
            state.player?.state.position ?? Duration.zero,
      );
      _activityTracker.resetForSceneChange();
    }

    // ...
    // Later in playScene, when creating the controller:
    String? subtitleUrl;
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

      final apiKey = ref.read(serverApiKeyProvider);
      subtitleUrl = appendApiKey(captionUrl, apiKey);

      AppLogStore.instance.add(
        'provider playScene: subtitle url=$subtitleUrl lang=$lang type=$type',
        source: 'player_provider',
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

      final uri = Uri.tryParse(effectiveStreamUrl);
      String maskedUrl = effectiveStreamUrl;
      if (uri != null && uri.userInfo.isNotEmpty) {
        maskedUrl = uri.replace(userInfo: '***:***').toString();
      } else if (uri != null && uri.queryParameters.containsKey('apikey')) {
        final params = Map<String, String>.from(uri.queryParameters);
        params['apikey'] = '***';
        maskedUrl = uri.replace(queryParameters: params).toString();
      }

      AppLogStore.instance.add(
        'provider playScene: web effective url=$maskedUrl',
        source: 'player_provider',
      );
    }

    if (state.player != null) {
      await _disposeControllers();
    }

    final session = _sessionController.createOwnedSession();
    final player = session.player;
    final videoController = session.controller;
    _activeSceneRef = scene;
    _firstFrameLoggedSceneId = null;
    _lastIsPlaying = null;

    final stopwatch = Stopwatch()..start();

    AppLogStore.instance.add(
      'PlayerState playScene: updating state.activeScene to ${scene.id}',
      source: 'player_provider',
    );

    state = GlobalPlayerState(
      activeScene: scene,
      player: player,
      videoController: videoController,
      isPlaying: false,
      isFullScreen:
          state.isFullScreen, // Preserve fullscreen state across scenes
      isInPipMode: state.isInPipMode, // Preserve PiP state across scenes
      viewMode: state.viewMode, // Preserve UI context
      streamMimeType: mimeType,
      streamLabel: streamLabel,
      streamSource: streamSource,
      startupLatencyMs: null,
      prewarmAttempted: prewarmAttempted,
      prewarmSucceeded: prewarmSucceeded,
      prewarmLatencyMs: prewarmLatencyMs,
      playEndBehavior: state.playEndBehavior,
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
      await player.open(
        Media(
          effectiveStreamUrl,
          httpHeaders: httpHeaders ?? const <String, String>{},
          start: initialPosition,
        ),
        play: false,
      );

      if (subtitleUrl != null && subtitleUrl.isNotEmpty) {
        await player.setSubtitleTrack(SubtitleTrack.uri(subtitleUrl));
      } else {
        await player.setSubtitleTrack(SubtitleTrack.no());
      }

      if (!ref.mounted) {
        await _disposeControllers();
        return;
      }

      stopwatch.stop();
      final initializeElapsedMs = stopwatch.elapsedMilliseconds;
      AppLogStore.instance.add(
        'provider initialize done scene=${scene.id} elapsed=${initializeElapsedMs}ms duration=${player.state.duration.inMilliseconds}ms size=${player.state.width ?? 0}x${player.state.height ?? 0}',
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
        duration: player.state.duration,
      );

      AppLogStore.instance.add(
        'provider ready scene=${scene.id} startup=${initializeElapsedMs}ms',
        source: 'player_provider',
      );

      if (!isTestMode) {
        unawaited(WakelockPlus.enable());
      }

      final desktopSettings = ref.read(desktopSettingsProvider);
      await player.setVolume(
        desktopSettings.isMuted ? 0 : desktopSettings.volume * 100.0,
      );

      await _sessionController.bindPlayerStreams(
        player,
        onTick: _videoListener,
        onCompleted: _handleVideoFinished,
        onError: (error) {
          AppLogStore.instance.add(
            'provider player error scene=${scene.id} error=$error',
            source: 'player_provider',
          );
        },
      );
      unawaited(player.play());

      // Prepare for the next scene in the queue
      _prewarmQueue();
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
    Player player,
    VideoController controller, {
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
        state.player == player &&
        state.videoController == controller) {
      return;
    }

    // Stop current, but don't dispose the one we are about to attach!
    if (state.activeScene != null &&
        (state.player != player || state.videoController != controller)) {
      await _disposeControllers();
    }

    // Reset activity tracking state for the new scene
    if (state.activeScene?.id != scene.id) {
      _activityTracker.resetForSceneChange();
    }

    _activeSceneRef = scene;
    _firstFrameLoggedSceneId = null;
    _lastIsPlaying = null;
    _sessionController.adoptBorrowedSession(player, controller);

    final isTiktokHandoff =
        streamSource == 'tiktok-handoff' || streamSource == 'tiktok-promotion';

    state = state.copyWith(
      activeScene: scene,
      player: player,
      videoController: controller,
      isPlaying: player.state.playing,
      isFullScreen: state.isFullScreen, // Preserve fullscreen
      isInPipMode: state.isInPipMode, // Preserve PiP
      viewMode: isTiktokHandoff ? PlayerViewMode.tiktok : state.viewMode,
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
      duration: player.state.duration,
    );

    if (!isTestMode) {
      unawaited(WakelockPlus.enable());
    }

    final desktopSettings = ref.read(desktopSettingsProvider);
    unawaited(
      player.setVolume(
        desktopSettings.isMuted ? 0 : desktopSettings.volume * 100.0,
      ),
    );

    await _sessionController.bindPlayerStreams(
      player,
      onTick: _videoListener,
      onCompleted: _handleVideoFinished,
      onError: (error) {
        AppLogStore.instance.add(
          'provider player error scene=${scene.id} error=$error',
          source: 'player_provider',
        );
      },
    );

    if (player.state.playing) {
      _activityTracker.start(
        sceneId: scene.id,
        resumePositionProvider: () => player.state.position,
      );
    }

    // Prepare for the next scene in the queue
    _prewarmQueue();
  }

  void togglePlayPause() {
    final player = state.player;
    if (player != null) {
      if (player.state.playing) {
        player.pause();
        state = state.copyWith(isPlaying: false);
        if (!isTestMode) {
          unawaited(WakelockPlus.disable());
        }
      } else {
        player.play();
        state = state.copyWith(isPlaying: true);
        if (!isTestMode) {
          unawaited(WakelockPlus.enable());
        }
      }
    }
  }

  void seekRelative(Duration delta) {
    final player = state.player;
    if (player == null) return;

    final current = player.state.position;
    final duration = player.state.duration;
    var target = current + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    player.seek(target);
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
      playEndBehavior: state.playEndBehavior,
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
    Player? player,
    VideoController? controller,
  }) async {
    final effectiveSceneId =
        scene?.id ??
        _activeSceneRef?.id ??
        (ref.mounted ? state.activeScene?.id : null);
    final effectivePlayer =
        player ??
        _sessionController.player ??
        (ref.mounted ? state.player : null);
    await _activityTracker.stop(
      sceneId: effectiveSceneId,
      resumePositionProvider: () =>
          effectivePlayer?.state.position ?? Duration.zero,
    );

    await _sessionController.disposeSession(
      isTestMode: isTestMode,
      fallbackPlayer: player ?? (ref.mounted ? state.player : null),
      log: (message) {
        AppLogStore.instance.add(message, source: 'player_provider');
      },
    );

    if (!isTestMode) {
      await WakelockPlus.disable();
    }
  }

  void _videoListener() {
    if (!ref.mounted) return;

    final player = state.player;
    if (player != null) {
      final activeSceneId = state.activeScene?.id;
      final isInitialized = player.state.width != null;
      if (activeSceneId != null &&
          _firstFrameLoggedSceneId != activeSceneId &&
          isInitialized &&
          player.state.position > Duration.zero) {
        _firstFrameLoggedSceneId = activeSceneId;
        AppLogStore.instance.add(
          'provider first-frame scene=$activeSceneId position=${player.state.position.inMilliseconds}ms buffered=${player.state.buffer.inMilliseconds}ms',
          source: 'player_provider',
        );
      }

      final isPlayingNow = player.state.playing;
      final isBufferingNow = player.state.buffering;
      final currentWidth = player.state.width;
      final currentHeight = player.state.height;
      final currentPosition = player.state.position;
      final currentSpeed = player.state.rate;
      final currentBuffered = player.state.buffer;

      final playingChanged = isPlayingNow != _lastIsPlaying;
      final bufferingChanged = isBufferingNow != state.isBuffering;
      final speedChanged = currentSpeed != (_lastSpeed ?? 1.0);

      if (playingChanged ||
          bufferingChanged ||
          speedChanged ||
          currentWidth != state.videoWidth ||
          currentHeight != state.videoHeight) {
        final wasPlaying = _lastIsPlaying ?? false;
        _lastIsPlaying = isPlayingNow;
        _lastSpeed = currentSpeed;

        state = state.copyWith(
          isPlaying: isPlayingNow,
          isBuffering: isBufferingNow,
          videoWidth: currentWidth,
          videoHeight: currentHeight,
        );

        if (isPlayingNow && !wasPlaying) {
          if (state.activeScene != null) {
            _activityTracker.start(
              sceneId: state.activeScene!.id,
              resumePositionProvider: () => player.state.position,
            );
          }
        } else if (!isPlayingNow && wasPlaying) {
          unawaited(
            _activityTracker.stop(
              sceneId: state.activeScene?.id,
              resumePositionProvider: () => player.state.position,
            ),
          );
        }

        if (!isTestMode) {
          unawaited(
            isPlayingNow ? WakelockPlus.enable() : WakelockPlus.disable(),
          );
        }
      }

      // Only update media handler if state changed or if position drifted significantly
      // (audio_service increments position automatically, so we only need to sync periodically)
      final shouldUpdateMediaHandler =
          playingChanged ||
          bufferingChanged ||
          speedChanged ||
          _lastMediaHandlerPosition == null ||
          (currentPosition - _lastMediaHandlerPosition!).abs().inMilliseconds >
              1000;

      if (shouldUpdateMediaHandler) {
        _lastMediaHandlerPosition = currentPosition;
        mediaHandler?.updatePlaybackState(
          isPlaying: isPlayingNow,
          position: currentPosition,
          bufferedPosition: currentBuffered,
          speed: currentSpeed,
        );
      }
    }
  }

  void _handleVideoFinished() {
    AppLogStore.instance.add(
      'PlayerState _handleVideoFinished: active=${state.activeScene?.id} behavior=${state.playEndBehavior}',
      source: 'player_provider',
    );

    switch (state.playEndBehavior) {
      case VideoEndBehavior.stop:
        if (state.isFullScreen) {
          setFullScreen(false);
        }
        break;
      case VideoEndBehavior.loop:
        state.player?.seek(Duration.zero);
        state.player?.play();
        break;
      case VideoEndBehavior.next:
        if (state.streamSource == 'tiktok-promotion') {
          // TikTok view handles its own "next" behavior by scrolling the PageView.
          // We don't want to call playNext() here because it would create a new player.
          AppLogStore.instance.add(
            'PlayerState _handleVideoFinished: TikTok promotion detected, skipping playNext()',
            source: 'player_provider',
          );
          break;
        }

        // Do NOT exit full screen when moving to the next video,
        // so the next video also starts in full screen.
        playNext();
        break;
    }
  }

  Future<void> playNext() async {
    AppLogStore.instance.add(
      'PlayerState playNext: CALLED, _isTransitioning=$_isTransitioning, activeScene=${state.activeScene?.id}',
      source: 'player_provider',
    );
    if (!ref.mounted) {
      AppLogStore.instance.add(
        'PlayerState playNext: ref not mounted, returning',
        source: 'player_provider',
      );
      return;
    }
    if (_isTransitioning) {
      AppLogStore.instance.add(
        'PlayerState playNext: already transitioning, skipping',
        source: 'player_provider',
      );
      return;
    }

    _isTransitioning = true;
    try {
      final queueNotifier = ref.read(playbackQueueProvider.notifier);

      // Ensure queue is synced
      if (queueNotifier.state.currentIndex == -1 &&
          state.activeScene?.id != null) {
        queueNotifier.findAndSetIndex(state.activeScene!.id);
      }

      final nextScene = queueNotifier.getNextScene();

      if (nextScene != null) {
        // Trigger navigation synchronization so background details match active scene
        // Skip for TikTok mode as it handles its own navigation via PageView
        if (state.viewMode != PlayerViewMode.tiktok) {
          _navigate([
            NavigationAction(
              '/scenes/scene/${nextScene.id}',
              isReplacement: true,
            ),
          ]);
        }

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
        }
      }
    } finally {
      _isTransitioning = false;
    }
  }

  Future<void> playPrevious() async {
    AppLogStore.instance.add(
      'PlayerState playPrevious: CALLED, _isTransitioning=$_isTransitioning, activeScene=${state.activeScene?.id}',
      source: 'player_provider',
    );
    if (!ref.mounted || _isTransitioning) return;

    _isTransitioning = true;
    try {
      final queueNotifier = ref.read(playbackQueueProvider.notifier);

      // Ensure queue is synced
      if (queueNotifier.state.currentIndex == -1 &&
          state.activeScene?.id != null) {
        queueNotifier.findAndSetIndex(state.activeScene!.id);
      }

      final prevScene = queueNotifier.getPreviousScene();

      if (prevScene != null) {
        // Trigger navigation synchronization
        // Skip for TikTok mode as it handles its own navigation via PageView
        if (state.viewMode != PlayerViewMode.tiktok) {
          _navigate([
            NavigationAction(
              '/scenes/scene/${prevScene.id}',
              isReplacement: true,
            ),
          ]);
        }

        queueNotifier.playPrevious(); // Decrement index in queue

        final resolver = ref.read(streamResolverProvider.notifier);
        final choice = await resolver.resolvePreferredStream(prevScene);

        if (choice != null) {
          final mediaHeaders = ref.read(mediaPlaybackHeadersProvider);
          await playScene(
            prevScene,
            choice.url,
            mimeType: choice.mimeType,
            streamLabel: choice.label,
            streamSource: 'autoplay-prev',
            httpHeaders: mediaHeaders,
          );
        }
      }
    } finally {
      _isTransitioning = false;
    }
  }
}
