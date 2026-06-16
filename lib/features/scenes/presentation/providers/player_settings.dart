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

  const PlayerSettings({
    this.playEndBehaviorName = 'stop',
    this.showVideoDebugInfo = false,
    this.useDoubleTapSeek = true,
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
  });

  PlayerSettings copyWith({
    String? playEndBehaviorName,
    bool? showVideoDebugInfo,
    bool? useDoubleTapSeek,
    bool? enableBackgroundPlayback,
    bool? enableNativePip,
    bool? videoGravityOrientation,
    bool? useActualSceneVideoInMiniPlayer,
    String? defaultSubtitleLanguage,
    double? subtitleFontSize,
    double? subtitlePositionBottomRatio,
    String? subtitleTextAlignment,
    bool? feedStartRandom,
    bool? resumePlayPosition,
  }) {
    return PlayerSettings(
      playEndBehaviorName: playEndBehaviorName ?? this.playEndBehaviorName,
      showVideoDebugInfo: showVideoDebugInfo ?? this.showVideoDebugInfo,
      useDoubleTapSeek: useDoubleTapSeek ?? this.useDoubleTapSeek,
      enableBackgroundPlayback:
          enableBackgroundPlayback ?? this.enableBackgroundPlayback,
      enableNativePip: enableNativePip ?? this.enableNativePip,
      videoGravityOrientation:
          videoGravityOrientation ?? this.videoGravityOrientation,
      useActualSceneVideoInMiniPlayer:
          useActualSceneVideoInMiniPlayer ??
          this.useActualSceneVideoInMiniPlayer,
      defaultSubtitleLanguage:
          defaultSubtitleLanguage ?? this.defaultSubtitleLanguage,
      subtitleFontSize: subtitleFontSize ?? this.subtitleFontSize,
      subtitlePositionBottomRatio:
          subtitlePositionBottomRatio ?? this.subtitlePositionBottomRatio,
      subtitleTextAlignment:
          subtitleTextAlignment ?? this.subtitleTextAlignment,
      feedStartRandom: feedStartRandom ?? this.feedStartRandom,
      resumePlayPosition: resumePlayPosition ?? this.resumePlayPosition,
    );
  }
}

class PlayerSettingsStore {
  static const autoplayNextKey = 'autoplay_next';
  static const playEndBehaviorKey = 'video_play_end_behavior';
  static const showVideoDebugInfoKey = 'show_video_debug_info';
  static const useDoubleTapSeekKey = 'video_use_double_tap_seek';
  static const enableBackgroundPlaybackKey = 'video_background_playback';
  static const enableNativePipKey = 'video_native_pip';
  static const videoGravityOrientationKey = 'video_gravity_orientation';
  static const useActualSceneVideoInMiniPlayerKey =
      'use_actual_scene_video_in_miniplayer';
  static const defaultSubtitleLanguageKey = 'default_subtitle_language';
  static const subtitleFontSizeKey = 'subtitle_font_size';
  static const subtitlePositionBottomRatioKey =
      'subtitle_position_bottom_ratio';
  static const subtitleTextAlignmentKey = 'subtitle_text_alignment';
  static const feedStartRandomKey = 'feed_start_random';
  static const resumePlayPositionKey = 'video_resume_play_position';

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
      useDoubleTapSeek: prefs.getBool(useDoubleTapSeekKey) ?? true,
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
    );
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
