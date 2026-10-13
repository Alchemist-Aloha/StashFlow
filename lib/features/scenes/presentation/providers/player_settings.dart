import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerSettings {
  final String playEndBehaviorName;
  final bool showVideoDebugInfo;
  final bool useDoubleTapSeek;
  final int controlsAutoHideSeconds;
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

  /// Output preference, or `default` for media-kit's platform default.
  /// `libmpv-software` uses the libmpv software render API, not a separate VO.
  final String mpvVo;

  /// mpv hardware decoder override; `no` explicitly uses software decoding.
  final String mpvHwdec;

  const PlayerSettings({
    this.playEndBehaviorName = 'stop',
    this.showVideoDebugInfo = false,
    this.useDoubleTapSeek = false,
    this.controlsAutoHideSeconds = 2,
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
  static const controlsAutoHideSecondsKey = 'video_controls_auto_hide_seconds';
  static const minControlsAutoHideSeconds = 1;
  static const maxControlsAutoHideSeconds = 10;

  static bool isValidControlsAutoHideSeconds(int value) =>
      value >= minControlsAutoHideSeconds &&
      value <= maxControlsAutoHideSeconds;
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
  static const mpvVoValues = {
    'default',
    'gpu',
    'gpu-next',
    'mediacodec_embed',
    'libmpv',
    'libmpv-software',
  };

  /// Runtime rendering choices shared by settings and configuration backups.
  static const mpvChoices = {
    'interpolation': {'default', 'yes', 'no'},
    'video-sync': {
      'default',
      'audio',
      'display-resample',
      'display-resample-vdrop',
      'display-vdrop',
      'display-desync',
    },
    'tscale': {
      'default',
      'oversample',
      'linear',
      'mitchell',
      'catmull_rom',
      'sinc',
    },
    'scale': {'default', 'bilinear', 'bicubic', 'lanczos', 'ewa_lanczossharp'},
    'dscale': {'default', 'bilinear', 'bicubic', 'lanczos', 'mitchell'},
    'cscale': {'default', 'bilinear', 'bicubic', 'lanczos', 'ewa_lanczossharp'},
    'deband': {'default', 'yes', 'no'},
  };
  static String mpvOptionKey(String option) => 'video_mpv_$option';
  static const mpvConfKey = 'video_mpv_conf';

  // Only playback tuning: imported configs cannot load files/scripts or replace
  // the app's surface, authentication, navigation, or player lifecycle.
  static const customMpvOptions = {
    'interpolation',
    'video-sync',
    'tscale',
    'scale',
    'dscale',
    'cscale',
    'deband',
    'interpolation-threshold',
    'tscale-radius',
    'tscale-clamp',
    'tscale-blur',
    'scale-antiring',
    'dscale-antiring',
    'cscale-antiring',
    'scale-radius',
    'dscale-radius',
    'cscale-radius',
    'correct-downscaling',
    'linear-downscaling',
    'linear-upscaling',
    'sigmoid-upscaling',
    'deband-iterations',
    'deband-threshold',
    'deband-range',
    'deband-grain',
    'dither-depth',
    'dither',
    'temporal-dither',
    'gamma',
    'brightness',
    'contrast',
    'saturation',
    'hue',
    'tone-mapping',
    'tone-mapping-param',
    'hdr-compute-peak',
    'target-prim',
    'target-trc',
    'target-peak',
    'gamut-mapping-mode',
    'video-output-levels',
    'audio-delay',
    'audio-normalize-downmix',
    'audio-pitch-correction',
    'demuxer-max-bytes',
    'demuxer-max-back-bytes',
    'cache',
    'cache-secs',
  };

  /// Parses a flat mpv.conf subset. Duplicate options use the last value.
  /// Profiles, includes, scripts and app-owned options are intentionally rejected.
  static Map<String, String> parseMpvConf(String text) {
    if (text.length > 16384) throw const FormatException('Config too long');
    final options = <String, String>{};
    final lines = text.split('\n');
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index].trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      final separator = line.indexOf('=');
      final key = (separator < 0 ? line : line.substring(0, separator)).trim();
      var value = separator < 0 ? 'yes' : line.substring(separator + 1).trim();
      if (value.length >= 2 &&
          ((value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'")))) {
        value = value.substring(1, value.length - 1);
      }
      if (!customMpvOptions.contains(key) ||
          value.isEmpty ||
          value.contains('\u0000')) {
        throw FormatException('${index + 1}');
      }
      options[key] = value;
    }
    return options;
  }

  static bool isValidMpvConf(String text) {
    try {
      parseMpvConf(text);
      return true;
    } on FormatException {
      return false;
    }
  }

  String loadMpvOption(String option) =>
      _loadMpvChoice(mpvOptionKey(option), mpvChoices[option]!);

  String get mpvConf {
    final value = prefs.get(mpvConfKey);
    return value is String && isValidMpvConf(value) ? value : '';
  }

  Future<void> saveMpvOption(String option, String value) async {
    if (!(mpvChoices[option]?.contains(value) ?? false)) {
      throw ArgumentError.value(value, option);
    }
    await prefs.setString(mpvOptionKey(option), value);
  }

  Future<void> saveMpvConf(String text) async {
    parseMpvConf(text);
    await prefs.setString(mpvConfKey, text);
  }

  /// Effective runtime options; custom entries override selectors. Interpolation
  /// supplies display synchronization unless explicitly overridden.
  Map<String, String> loadMpvProperties({
    TargetPlatform? platform,
    bool isWeb = kIsWeb,
  }) {
    if (isWeb) return {};
    final result = <String, String>{
      for (final option in mpvChoices.keys)
        if (loadMpvOption(option) != 'default') option: loadMpvOption(option),
      ...parseMpvConf(mpvConf),
    };
    if (result['interpolation'] == 'yes') {
      result.putIfAbsent('video-sync', () => 'display-resample');
    }
    final configuration = loadVideoConfiguration(platform: platform);
    if (configuration.vo == 'mediacodec_embed' ||
        !configuration.enableHardwareAcceleration) {
      result.removeWhere(
        (key, _) =>
            !key.startsWith('audio-') &&
            !key.startsWith('demuxer-') &&
            key != 'cache' &&
            key != 'cache-secs',
      );
    }
    return result;
  }

  /// Apply once after attaching a new controller and before opening media.
  Future<void> applyMpvProperties(Player player) async {
    final options = loadMpvProperties();
    if (options.isEmpty) return;
    final native = player.platform;
    if (native is! NativePlayer) return;
    for (final entry in options.entries) {
      await native.setProperty(entry.key, entry.value);
    }
  }

  /// Supported decoder choices; platform-specific entries are filtered below.
  static const mpvHwdecValues = {
    'default',
    'no',
    'auto',
    'auto-safe',
    'auto-copy',
    'mediacodec',
    'mediacodec-copy',
    'vaapi',
    'vaapi-copy',
    'nvdec',
    'nvdec-copy',
    'vdpau-copy',
  };

  /// Outputs that can render inside the app on [platform].
  static Set<String> supportedMpvVoValues(TargetPlatform platform) =>
      switch (platform) {
        TargetPlatform.android => const {
          'default',
          'gpu',
          'gpu-next',
          'mediacodec_embed',
        },
        TargetPlatform.linux => const {'default', 'libmpv', 'libmpv-software'},
        _ => const {'default', 'libmpv'},
      };

  /// Decoder modes available for selection on [platform].
  static Set<String> supportedMpvHwdecValues(TargetPlatform platform) => {
    'default',
    'no',
    'auto',
    'auto-safe',
    'auto-copy',
    if (platform == TargetPlatform.android) ...{
      'mediacodec',
      'mediacodec-copy',
    },
    if (platform == TargetPlatform.linux) ...{
      'vaapi',
      'vaapi-copy',
      'nvdec',
      'nvdec-copy',
      'vdpau-copy',
    },
  };

  final SharedPreferences prefs;

  const PlayerSettingsStore(this.prefs);

  PlayerSettings load() {
    final autoplayNext = prefs.getBool(autoplayNextKey) ?? false;
    final controlsAutoHideValue = prefs.get(controlsAutoHideSecondsKey);
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
      controlsAutoHideSeconds:
          controlsAutoHideValue is int &&
              isValidControlsAutoHideSeconds(controlsAutoHideValue)
          ? controlsAutoHideValue
          : 2,
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
      vo: vo == 'default' ? null : (vo == 'libmpv-software' ? 'libmpv' : vo),
      hwdec: hwdec == 'default' ? null : hwdec,
      enableHardwareAcceleration: vo != 'libmpv-software',
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

  Future<void> saveControlsAutoHideSeconds(int value) {
    if (!isValidControlsAutoHideSeconds(value)) {
      throw ArgumentError.value(value, 'value');
    }
    return prefs.setInt(controlsAutoHideSecondsKey, value);
  }

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
