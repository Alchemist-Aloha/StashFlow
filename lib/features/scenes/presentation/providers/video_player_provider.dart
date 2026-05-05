import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:clock/clock.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../domain/entities/scene.dart';
import '../../domain/repositories/scene_repository.dart';
import 'playback_queue_provider.dart';
import 'scene_details_provider.dart';
import 'scene_list_provider.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../data/repositories/stream_prewarmer.dart';
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

class NavigationIntent {
  final String path;
  final bool isReplacement;
  NavigationIntent(this.path, {this.isReplacement = false});
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
      navigationIntent:
          clearNavigation ? null : (navigationIntent ?? this.navigationIntent),
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
  static const _playEndBehaviorKey = 'video_play_end_behavior';
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

  /// Internal reference used during disposal to ensure we clean up the right player.
  Player? _playerRef;

  /// Internal reference used during disposal to ensure we clean up the right controller.
  VideoController? _videoControllerRef;

  /// Subscriptions to the player's event streams.
  final List<StreamSubscription> _subscriptions = [];

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

    // Ensure MediaKit is initialized before any Player instances are created.
    // This is called here instead of main() to improve initial app startup performance.
    MediaKit.ensureInitialized();

    final repository = ref.read(sceneRepositoryProvider);
    ref.onDispose(() {
      PipMode.isInPipMode.removeListener(_onPipModeChanged);

      unawaited(
        _disposeControllers(
          scene: _activeSceneRef,
          controller: _videoControllerRef,
          repository: repository,
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

    final prefs = ref.read(sharedPreferencesProvider);

    // Initial load of preferences
    final autoplayNext = prefs.getBool(_autoplayNextKey) ?? false;
    final endBehaviorStr = prefs.getString(_playEndBehaviorKey);
    VideoEndBehavior playEndBehavior;
    if (endBehaviorStr != null) {
      playEndBehavior = VideoEndBehavior.values.firstWhere(
        (e) => e.name == endBehaviorStr,
        orElse: () => VideoEndBehavior.stop,
      );
    } else {
      // Migrate from autoplayNext
      playEndBehavior = autoplayNext
          ? VideoEndBehavior.next
          : VideoEndBehavior.stop;
    }

    return GlobalPlayerState(
      playEndBehavior: playEndBehavior,
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
    setPlayEndBehavior(value ? VideoEndBehavior.next : VideoEndBehavior.stop);
  }

  void setPlayEndBehavior(VideoEndBehavior behavior) {
    state = state.copyWith(playEndBehavior: behavior);
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_playEndBehaviorKey, behavior.name);
    // Sync legacy key
    prefs.setBool(_autoplayNextKey, behavior == VideoEndBehavior.next);
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

  void _setTransitioning(bool value) {
    state = state.copyWith(isTransitioning: value);
  }

  void _navigate(String path, {bool replacement = false}) {
    state = state.copyWith(
      navigationIntent: NavigationIntent(path, isReplacement: replacement),
    );
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

    // Window size: how many scenes ahead to prewarm.
    // 3 is a good balance between responsiveness and resource usage.
    const windowSize = 3;
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
      await _stopActivityTracking();
      _playCountIncremented = false;
      _accumulatedDuration = 0;
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
    }

    if (state.player != null) {
      await _disposeControllers();
    }

    final player = Player();
    final videoController = VideoController(player);

    _playerRef = player;
    _videoControllerRef = videoController;
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

      if (initialPosition != null) {
        await player.seek(initialPosition);
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

      _subscriptions.add(player.stream.playing.listen((_) => _videoListener()));
      _subscriptions.add(
        player.stream.position.listen((_) => _videoListener()),
      );
      _subscriptions.add(
        player.stream.duration.listen((_) => _videoListener()),
      );
      _subscriptions.add(
        player.stream.completed.listen((completed) {
          if (completed) {
            _handleVideoFinished();
          }
        }),
      );
      _subscriptions.add(
        player.stream.buffering.listen((_) => _videoListener()),
      );
      _subscriptions.add(player.stream.width.listen((_) => _videoListener()));
      _subscriptions.add(player.stream.height.listen((_) => _videoListener()));
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
      _playCountIncremented = false;
      _accumulatedDuration = 0;
    }

    _playerRef = player;
    _videoControllerRef = controller;
    _activeSceneRef = scene;
    _firstFrameLoggedSceneId = null;
    _isUsingBorrowedController = true;
    _lastIsPlaying = null;

    final isTiktokHandoff = streamSource == 'tiktok-handoff' || streamSource == 'tiktok-promotion';

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

    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();

    _subscriptions.add(player.stream.playing.listen((_) => _videoListener()));
    _subscriptions.add(player.stream.position.listen((_) => _videoListener()));
    _subscriptions.add(player.stream.duration.listen((_) => _videoListener()));
    _subscriptions.add(
      player.stream.completed.listen((completed) {
        if (completed) {
          _handleVideoFinished();
        }
      }),
    );
    _subscriptions.add(player.stream.buffering.listen((_) => _videoListener()));
    _subscriptions.add(player.stream.width.listen((_) => _videoListener()));
    _subscriptions.add(player.stream.height.listen((_) => _videoListener()));

    if (player.state.playing) {
      _startActivityTracking();
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
    SceneRepository? repository,
  }) async {
    // Save final activity before disposing
    await _stopActivityTracking(
      scene: scene,
      player: player,
      repository: repository,
    );

    if (isTestMode) {
      _playerRef = null;
      _videoControllerRef = null;
      _isUsingBorrowedController = false;
      return;
    }

    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();

    final prevPlayer =
        _playerRef ?? player ?? (ref.mounted ? state.player : null);

    _playerRef = null;
    _videoControllerRef = null;

    if (prevPlayer != null) {
      if (_isUsingBorrowedController) {
        AppLogStore.instance.add(
          'provider skipping dispose of borrowed controller',
          source: 'player_provider',
        );
        _isUsingBorrowedController = false;
      } else {
        await prevPlayer.dispose();
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
            unawaited(
              ref.read(sceneDetailsProvider(scene.id).notifier).refresh(),
            );
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
    Player? player,
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
      await _saveActivity(scene: scene, player: player, repository: repository);
    }
  }

  Future<void> _saveActivity({
    Scene? scene,
    Player? player,
    SceneRepository? repository,
  }) async {
    final effectiveScene = scene ?? (ref.mounted ? state.activeScene : null);
    final effectivePlayer = player ?? (ref.mounted ? state.player : null);
    final effectiveRepo =
        repository ?? (ref.mounted ? ref.read(sceneRepositoryProvider) : null);

    if (effectiveScene == null ||
        effectivePlayer == null ||
        effectiveRepo == null) {
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

    if (durationToSave < 0.1 &&
        effectivePlayer.state.position == Duration.zero) {
      return;
    }

    final resumeTime = effectivePlayer.state.position.inMilliseconds / 1000.0;
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
        unawaited(
          ref.read(sceneDetailsProvider(effectiveScene.id).notifier).refresh(),
        );
      }
    } catch (e) {
      debugPrint('Failed to save scene activity: $e');
      // On failure, we might want to put the duration back into the accumulator
      // but let's keep it simple for now to avoid complexity.
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

      if (isPlayingNow != _lastIsPlaying ||
          isBufferingNow != state.isBuffering ||
          currentWidth != state.videoWidth ||
          currentHeight != state.videoHeight) {
        final wasPlaying = _lastIsPlaying ?? false;
        _lastIsPlaying = isPlayingNow;

        state = state.copyWith(
          isPlaying: isPlayingNow,
          isBuffering: isBufferingNow,
          videoWidth: currentWidth,
          videoHeight: currentHeight,
        );

        if (isPlayingNow && !wasPlaying) {
          _startActivityTracking();
        } else if (!isPlayingNow && wasPlaying) {
          _stopActivityTracking();
        }

        if (!isTestMode) {
          unawaited(
            isPlayingNow ? WakelockPlus.enable() : WakelockPlus.disable(),
          );
        }
      }

      mediaHandler?.updatePlaybackState(
        isPlaying: isPlayingNow,
        position: player.state.position,
        bufferedPosition: player.state.buffer,
        speed: player.state.rate,
      );
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

        final nextScene = ref.read(playbackQueueProvider.notifier).getNextScene();
        if (nextScene != null) {
          if (state.viewMode == PlayerViewMode.fullscreen) {
            // Sequence: replace current fullscreen with new details, then push new fullscreen.
            // This ensures the "Back" button lands on the current scene's details.
            _navigate('/scenes/scene/${nextScene.id}', replacement: true);
            _navigate('/scenes/fullscreen/${nextScene.id}');
          } else if (state.viewMode == PlayerViewMode.inline) {
            _navigate('/scenes/scene/${nextScene.id}', replacement: true);
          }
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
      AppLogStore.instance.add(
        'PlayerState playNext: currentActive=${state.activeScene?.id}',
        source: 'player_provider',
      );

      final queueNotifier = ref.read(playbackQueueProvider.notifier);
      final queueState = queueNotifier.state;

      AppLogStore.instance.add(
        'PlayerState playNext: queue state - currentIndex=${queueState.currentIndex}, sequenceLength=${queueState.sequence.length}',
        source: 'player_provider',
      );

      // If the playback queue hasn't been synchronized with the currently
      // active scene (index == -1), try to recover by finding the active
      // scene in the existing sequence. This helps when `setSequence` was
      // called with -1 to preserve an external index but the queue hasn't
      // been initialized for this session.
      if (queueNotifier.state.currentIndex == -1 &&
          state.activeScene?.id != null) {
        AppLogStore.instance.add(
          'PlayerState playNext: queue index unset (-1), attempting to find active scene in sequence=${state.activeScene?.id}',
          source: 'player_provider',
        );
        queueNotifier.findAndSetIndex(state.activeScene!.id);

        AppLogStore.instance.add(
          'PlayerState playNext: after findAndSetIndex, new index=${queueNotifier.state.currentIndex}',
          source: 'player_provider',
        );
      }

      final nextScene = queueNotifier.getNextScene();

      AppLogStore.instance.add(
        'PlayerState playNext: getNextScene returned ${nextScene?.id}, currentIndex=${queueNotifier.state.currentIndex}, sequenceLength=${queueNotifier.state.sequence.length}',
        source: 'player_provider',
      );

      if (nextScene != null) {
        AppLogStore.instance.add(
          'PlayerState playNext: moving from ${state.activeScene?.id} to ${nextScene.id}',
          source: 'player_provider',
        );
        queueNotifier.playNext(); // Increment index in queue

        AppLogStore.instance.add(
          'PlayerState playNext: queue.playNext() called, new index=${queueNotifier.state.currentIndex}',
          source: 'player_provider',
        );

        final resolver = ref.read(streamResolverProvider.notifier);
        final choice = await resolver.resolvePreferredStream(nextScene);

        AppLogStore.instance.add(
          'PlayerState playNext: stream resolved for ${nextScene.id}, choice=${choice?.label}',
          source: 'player_provider',
        );

        if (choice != null) {
          final mediaHeaders = ref.read(mediaPlaybackHeadersProvider);
          AppLogStore.instance.add(
            'PlayerState playNext: calling playScene() for ${nextScene.id} with streamSource=autoplay-next',
            source: 'player_provider',
          );
          await playScene(
            nextScene,
            choice.url,
            mimeType: choice.mimeType,
            streamLabel: choice.label,
            streamSource: 'autoplay-next',
            httpHeaders: mediaHeaders,
          );
          AppLogStore.instance.add(
            'PlayerState playNext: playScene() completed for ${nextScene.id}',
            source: 'player_provider',
          );
        } else {
          AppLogStore.instance.add(
            'PlayerState playNext: failed to resolve stream for ${nextScene.id}',
            source: 'player_provider',
          );
        }
      } else {
        AppLogStore.instance.add(
          'PlayerState playNext: no next scene found, currentIndex=${queueNotifier.state.currentIndex}, sequenceLength=${queueNotifier.state.sequence.length}',
          source: 'player_provider',
        );
      }
    } finally {
      _isTransitioning = false;
      AppLogStore.instance.add(
        'PlayerState playNext: DONE, _isTransitioning=false',
        source: 'player_provider',
      );
    }
  }
}
