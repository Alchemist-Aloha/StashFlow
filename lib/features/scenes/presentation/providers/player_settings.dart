import 'package:flutter/foundation.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerSettings {
  final String playEndBehaviorName;
  final bool showVideoDebugInfo;
  final bool useDoubleTapSeek;
  final bool enableBackgroundPlayback;
  final bool enableNativePip;
  final bool videoGravityOrientation;
  final bool useActualSceneVideoInMiniPlayer;
  final String defaultSubtitleLanguage;
  final double subtitleFontSize;
  final double subtitlePositionBottomRatio;
  final String subtitleTextAlignment;
  final bool feedStartRandom;
  final bool resumePlayPosition;

  /// mpv video output override, or `default` for media-kit's platform default.
  final String mpvVo;

  /// mpv hardware decoder override; `no` explicitly uses software decoding.
  final String mpvHwdec;

  const PlayerSettings({
    this.playEndBehaviorName = 'stop',
    this.showVideoDebugInfo = false,
    this.useDoubleTapSeek = false,
    this.enableBackgroundPlayback = false,
    this.enableNativePip = false,
    this.videoGravityOrientation = true,
    this.useActualSceneVideoInMiniPlayer = true,
    this.defaultSubtitleLanguage = 'none',
    this.subtitleFontSize = 18.0,
    this.subtitlePositionBottomRatio = 0.15,
    this.subtitleTextAlignment = 'center',
    this.feedStartRandom = false,
    this.resumePlayPosition = true,
    this.mpvVo = 'default',
    this.mpvHwdec = 'default',
  });
}

class PlayerSettingsStore {
  static const autoplayNextKey = 'autoplay_next';
  static const playEndBehaviorKey = 'video_play_end_behavior';
  static const showVideoDebugInfoKey = 'show_video_debug_info';
  static const useDoubleTapSeekKey = 'video_use_double_tap_seek';
  static const enableBackgroundPlaybackKey = 'video_background_playback';
  static const enableNativePipKey = 'video_native_pip';
  static const videoGravityOrientationKey = 'video_gravity_orientation';

  /// Opens explicit scene playback navigation in the fullscreen player.
  static const enterFullscreenOnNavigationKey =
      'video_enter_fullscreen_on_navigation';
  static const useActualSceneVideoInMiniPlayerKey =
      'use_actual_scene_video_in_miniplayer';
  static const defaultSubtitleLanguageKey = 'default_subtitle_language';
  static const subtitleFontSizeKey = 'subtitle_font_size';
  static const subtitlePositionBottomRatioKey =
      'subtitle_position_bottom_ratio';
  static const subtitleTextAlignmentKey = 'subtitle_text_alignment';
  static const feedStartRandomKey = 'feed_start_random';
  static const resumePlayPositionKey = 'video_resume_play_position';

  /// Persisted mpv output choice, also included in config backups.
  static const mpvVoKey = 'video_mpv_vo';

  /// Persisted mpv decoder choice, also included in config backups.
  static const mpvHwdecKey = 'video_mpv_hwdec';

  /// Output drivers compatible with media-kit's embedded video surfaces.
  static const mpvVoValues = {'default', 'gpu', 'mediacodec_embed', 'libmpv'};

  /// Supported decoder choices; platform-specific entries are filtered below.
  static const mpvHwdecValues = {
    'default',
    'no',
    'auto',
    'auto-safe',
    'auto-copy',
    'mediacodec',
    'mediacodec-copy',
  };

  /// Outputs that can render inside the app on [platform].
  static Set<String> supportedMpvVoValues(TargetPlatform platform) =>
      platform == TargetPlatform.android
      ? const {'default', 'gpu', 'mediacodec_embed'}
      : const {'default', 'libmpv'};

  /// Decoder modes available for selection on [platform].
  static Set<String> supportedMpvHwdecValues(TargetPlatform platform) =>
      platform == TargetPlatform.android
      ? mpvHwdecValues
      : const {'default', 'no', 'auto', 'auto-safe', 'auto-copy'};

  final SharedPreferences prefs;

  const PlayerSettingsStore(this.prefs);

  PlayerSettings load() {
    final autoplayNext = prefs.getBool(autoplayNextKey) ?? false;
    final endBehaviorStr = prefs.getString(playEndBehaviorKey);
    String playEndBehaviorName;
    if (endBehaviorStr != null) {
      playEndBehaviorName = endBehaviorStr;
    } else {
      playEndBehaviorName = autoplayNext ? 'next' : 'stop';
    }

    return PlayerSettings(
      playEndBehaviorName: playEndBehaviorName,
      showVideoDebugInfo: prefs.getBool(showVideoDebugInfoKey) ?? false,
      useDoubleTapSeek: prefs.getBool(useDoubleTapSeekKey) ?? false,
      enableBackgroundPlayback:
          prefs.getBool(enableBackgroundPlaybackKey) ?? false,
      enableNativePip: prefs.getBool(enableNativePipKey) ?? false,
      videoGravityOrientation:
          prefs.getBool(videoGravityOrientationKey) ?? true,
      useActualSceneVideoInMiniPlayer:
          prefs.getBool(useActualSceneVideoInMiniPlayerKey) ?? true,
      defaultSubtitleLanguage:
          prefs.getString(defaultSubtitleLanguageKey) ?? 'none',
      subtitleFontSize: prefs.getDouble(subtitleFontSizeKey) ?? 18.0,
      subtitlePositionBottomRatio:
          prefs.getDouble(subtitlePositionBottomRatioKey) ?? 0.15,
      subtitleTextAlignment:
          prefs.getString(subtitleTextAlignmentKey) ?? 'center',
      feedStartRandom: prefs.getBool(feedStartRandomKey) ?? false,
      resumePlayPosition: prefs.getBool(resumePlayPositionKey) ?? true,
      mpvVo: _loadMpvChoice(mpvVoKey, mpvVoValues),
      mpvHwdec: _loadMpvChoice(mpvHwdecKey, mpvHwdecValues),
    );
  }

  String _loadMpvChoice(String key, Set<String> allowed) {
    final value = prefs.get(key);
    return value is String && allowed.contains(value) ? value : 'default';
  }

  /// Reads current preferences for each new controller, without caching them.
  /// Unsupported imported choices fall back to the platform default. Decoder
  /// choice takes precedence over an incompatible direct MediaCodec output.
  VideoControllerConfiguration loadVideoConfiguration({
    TargetPlatform? platform,
    bool isWeb = kIsWeb,
  }) {
    if (isWeb) return const VideoControllerConfiguration();
    platform ??= defaultTargetPlatform;
    var vo = _loadMpvChoice(mpvVoKey, supportedMpvVoValues(platform));
    final hwdec = _loadMpvChoice(
      mpvHwdecKey,
      supportedMpvHwdecValues(platform),
    );
    if (vo == 'mediacodec_embed' && hwdec != 'mediacodec') {
      vo = 'default';
    }
    return VideoControllerConfiguration(
      vo: vo == 'default' ? null : vo,
      hwdec: hwdec == 'default' ? null : hwdec,
    );
  }

  /// Saves a compatible output/decoder pair selected by the playback settings.
  Future<void> saveMpvConfiguration({
    required String vo,
    required String hwdec,
  }) async {
    if (!mpvVoValues.contains(vo) ||
        !mpvHwdecValues.contains(hwdec) ||
        (vo == 'mediacodec_embed' && hwdec != 'mediacodec')) {
      throw ArgumentError('Invalid mpv output/decoder combination');
    }
    await prefs.setString(mpvVoKey, vo);
    await prefs.setString(mpvHwdecKey, hwdec);
  }

  Future<void> savePlayEndBehaviorName(String behaviorName) async {
    await prefs.setString(playEndBehaviorKey, behaviorName);
    await prefs.setBool(autoplayNextKey, behaviorName == 'next');
  }

  Future<void> saveShowVideoDebugInfo(bool value) =>
      prefs.setBool(showVideoDebugInfoKey, value);

  Future<void> saveUseDoubleTapSeek(bool value) =>
      prefs.setBool(useDoubleTapSeekKey, value);

  Future<void> saveEnableBackgroundPlayback(bool value) =>
      prefs.setBool(enableBackgroundPlaybackKey, value);

  Future<void> saveEnableNativePip(bool value) =>
      prefs.setBool(enableNativePipKey, value);

  Future<void> saveVideoGravityOrientation(bool value) =>
      prefs.setBool(videoGravityOrientationKey, value);

  Future<void> saveUseActualSceneVideoInMiniPlayer(bool value) =>
      prefs.setBool(useActualSceneVideoInMiniPlayerKey, value);

  Future<void> saveDefaultSubtitleLanguage(String value) =>
      prefs.setString(defaultSubtitleLanguageKey, value);

  Future<void> saveSubtitleFontSize(double value) =>
      prefs.setDouble(subtitleFontSizeKey, value);

  Future<void> saveSubtitlePositionBottomRatio(double value) =>
      prefs.setDouble(subtitlePositionBottomRatioKey, value);

  Future<void> saveSubtitleTextAlignment(String value) =>
      prefs.setString(subtitleTextAlignmentKey, value);

  Future<void> saveFeedStartRandom(bool value) =>
      prefs.setBool(feedStartRandomKey, value);

  Future<void> saveResumePlayPosition(bool value) =>
      prefs.setBool(resumePlayPositionKey, value);
}
