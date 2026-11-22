import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/utils/l10n_extensions.dart';

import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_settings.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';

import '../../widgets/settings_page_shell.dart';
import '../../widgets/local_caption_settings_section.dart';

/// Persistent playback preferences, including native mpv output and decoding.
class PlaybackSettingsPage extends ConsumerStatefulWidget {
  const PlaybackSettingsPage({super.key});

  @override
  ConsumerState<PlaybackSettingsPage> createState() =>
      _PlaybackSettingsPageState();
}

class _PlaybackSettingsPageState extends ConsumerState<PlaybackSettingsPage> {
  static const _playEndBehaviorKey = 'video_play_end_behavior';
  static const _useDoubleTapSeekKey = 'video_use_double_tap_seek';
  static const _enableBackgroundPlaybackKey = 'video_background_playback';
  static const _videoGravityOrientationKey = 'video_gravity_orientation';
  static const _defaultSubtitleLanguageKey = 'default_subtitle_language';
  static const _subtitleFontSizeKey = 'subtitle_font_size';
  static const _subtitlePositionBottomRatioKey =
      'subtitle_position_bottom_ratio';
  static const _subtitleTextAlignmentKey = 'subtitle_text_alignment';
  static const _feedStartRandomKey = 'feed_start_random';
  static const _resumePlayPositionKey = 'video_resume_play_position';

  VideoEndBehavior _playEndBehavior = VideoEndBehavior.stop;
  bool _useDoubleTapSeek = false;
  int _controlsAutoHideSeconds = 2;
  bool _enableBackgroundPlayback = true;
  bool _respectAudioFocus = true;
  bool _systemMediaControls = true;
  bool _autoPip = true;
  bool _videoGravityOrientation = true;
  String _defaultSubtitleLanguage = 'none';
  String _defaultStreamSource = 'direct';
  String _defaultStreamResolution = 'ORIGINAL';
  double _subtitleFontSize = 18.0;
  double _subtitlePositionBottomRatio = 0.15;
  String _subtitleTextAlignment = 'center';
  bool _loading = true;
  bool _enterFullscreenOnNavigation = false;
  bool _feedStartRandom = false;
  bool _resumePlayPosition = true;
  String _mpvVo = 'default';
  String _mpvHwdec = 'default';
  final _mpvConfController = TextEditingController();
  final _mpvOptions = <String, String>{};
  String? _mpvConfError;

  @override
  void dispose() {
    _mpvConfController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final prefs = ref.read(sharedPreferencesProvider);
    final endBehaviorStr = prefs.getString(_playEndBehaviorKey);
    if (endBehaviorStr != null) {
      _playEndBehavior = VideoEndBehavior.values.firstWhere(
        (e) => e.name == endBehaviorStr,
        orElse: () => VideoEndBehavior.stop,
      );
    } else {
      // Migrate from autoplayNext
      final autoplayNext = prefs.getBool('autoplay_next') ?? true;
      _playEndBehavior = autoplayNext
          ? VideoEndBehavior.next
          : VideoEndBehavior.stop;
    }

    _useDoubleTapSeek = prefs.getBool(_useDoubleTapSeekKey) ?? false;
    _controlsAutoHideSeconds = PlayerSettingsStore(prefs)
        .load()
        .controlsAutoHideSeconds;
    _enableBackgroundPlayback =
        prefs.getBool(_enableBackgroundPlaybackKey) ?? true;
    _respectAudioFocus = PlayerSettingsStore(prefs).load().respectAudioFocus;
    _systemMediaControls =
        prefs.getBool(PlayerSettingsStore.systemMediaControlsKey) ?? true;
    _autoPip = prefs.getBool(PlayerSettingsStore.autoPipKey) ?? true;
    _videoGravityOrientation =
        prefs.getBool(_videoGravityOrientationKey) ?? true;
    _defaultStreamSource = prefs.getString(defaultStreamSourceKey) ?? 'direct';
    _defaultStreamResolution =
        prefs.getString(defaultStreamResolutionKey) ?? 'ORIGINAL';
    _defaultSubtitleLanguage =
        prefs.getString(_defaultSubtitleLanguageKey) ?? 'none';
    _subtitleFontSize = prefs.getDouble(_subtitleFontSizeKey) ?? 18.0;
    _subtitlePositionBottomRatio =
        prefs.getDouble(_subtitlePositionBottomRatioKey) ?? 0.15;
    _subtitleTextAlignment =
        prefs.getString(_subtitleTextAlignmentKey) ?? 'center';
    _enterFullscreenOnNavigation =
        prefs.getBool(PlayerSettingsStore.enterFullscreenOnNavigationKey) ??
        false;
    _feedStartRandom = prefs.getBool(_feedStartRandomKey) ?? false;
    _resumePlayPosition = prefs.getBool(_resumePlayPositionKey) ?? true;
    final videoConfiguration = PlayerSettingsStore(prefs)
        .loadVideoConfiguration();
    _mpvVo = !videoConfiguration.enableHardwareAcceleration
        ? 'libmpv-software'
        : videoConfiguration.vo ?? 'default';
    _mpvHwdec = videoConfiguration.hwdec ?? 'default';
    final store = PlayerSettingsStore(prefs);
    for (final option in PlayerSettingsStore.mpvChoices.keys) {
      _mpvOptions[option] = store.loadMpvOption(option);
    }
    _mpvConfController.text = store.mpvConf;

    setState(() => _loading = false);
  }

  Future<void> _saveToggleSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_playEndBehaviorKey, _playEndBehavior.name);
    await prefs.setBool(_useDoubleTapSeekKey, _useDoubleTapSeek);
    await PlayerSettingsStore(prefs)
        .saveControlsAutoHideSeconds(_controlsAutoHideSeconds);
    await prefs.setBool(
      _enableBackgroundPlaybackKey,
      _enableBackgroundPlayback,
    );
    await prefs.setBool(_videoGravityOrientationKey, _videoGravityOrientation);
    await prefs.setString(
      _defaultSubtitleLanguageKey,
      _defaultSubtitleLanguage,
    );
    await prefs.setDouble(_subtitleFontSizeKey, _subtitleFontSize);
    await prefs.setDouble(
      _subtitlePositionBottomRatioKey,
      _subtitlePositionBottomRatio,
    );
    await prefs.setString(_subtitleTextAlignmentKey, _subtitleTextAlignment);
    await prefs.setBool(
      PlayerSettingsStore.enterFullscreenOnNavigationKey,
      _enterFullscreenOnNavigation,
    );
    await prefs.setBool(_feedStartRandomKey, _feedStartRandom);
    await prefs.setBool(_resumePlayPositionKey, _resumePlayPosition);

    final playerStateNotifier = ref.read(playerStateProvider.notifier);
    playerStateNotifier.setPlayEndBehavior(_playEndBehavior);
    playerStateNotifier.setUseDoubleTapSeek(_useDoubleTapSeek);
    playerStateNotifier.setControlsAutoHideSeconds(_controlsAutoHideSeconds);
    playerStateNotifier.setEnableBackgroundPlayback(_enableBackgroundPlayback);
    playerStateNotifier.setRespectAudioFocus(_respectAudioFocus);
    playerStateNotifier.setVideoGravityOrientation(_videoGravityOrientation);
    playerStateNotifier.setDefaultSubtitleLanguage(_defaultSubtitleLanguage);
    playerStateNotifier.setSubtitleFontSize(_subtitleFontSize);
    playerStateNotifier.setSubtitlePositionBottomRatio(
      _subtitlePositionBottomRatio,
    );
    playerStateNotifier.setSubtitleTextAlignment(_subtitleTextAlignment);
    playerStateNotifier.setFeedStartRandom(_feedStartRandom);
    playerStateNotifier.setResumePlayPosition(_resumePlayPosition);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageShell(
      title: context.l10n.settings_playback_title,
      child: _loading
          ? const SettingsLoadingState()
          : SettingsPageBody(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionCard(
                    title: context.l10n.settings_playback_behavior,
                    subtitle: context.l10n.settings_playback_behavior_subtitle,
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.settings_playback_feed_random,
                          ),
                          subtitle: Text(
                            context.l10n.settings_playback_feed_random_subtitle,
                          ),
                          value: _feedStartRandom,
                          onChanged: (value) async {
                            setState(() => _feedStartRandom = value);
                            await _saveToggleSettings();
                          },
                        ),
                        Divider(height: context.dimensions.spacingLarge),
                        _buildEndBehaviorSelector(),
                        Divider(height: context.dimensions.spacingLarge),
                        _buildChoiceSelector(
                          title: context.l10n.settings_playback_stream_source,
                          description: context
                              .l10n
                              .settings_playback_stream_source_subtitle,
                          value: _defaultStreamSource,
                          choices: [
                            for (final kind in streamSourceKinds)
                              (
                                kind,
                                kind == 'direct'
                                    ? context.l10n.player_stream_direct
                                    : kind.toUpperCase(),
                              ),
                          ],
                          onChanged: (value) async {
                            setState(() => _defaultStreamSource = value);
                            await ref
                                .read(sharedPreferencesProvider)
                                .setString(defaultStreamSourceKey, value);
                          },
                        ),
                        // Direct plays the file as-is, so resolution only applies to transcodes.
                        if (_defaultStreamSource != 'direct') ...[
                          Divider(height: context.dimensions.spacingLarge),
                          _buildChoiceSelector(
                            title: context
                                .l10n
                                .settings_playback_stream_resolution,
                            description: context
                                .l10n
                                .settings_playback_stream_resolution_subtitle,
                            value: _defaultStreamResolution,
                            choices: [
                              for (final MapEntry(key: res, value: height)
                                  in streamResolutionHeights.entries)
                                (
                                  res,
                                  height == null
                                      ? context.l10n.player_stream_original
                                      : height == 2160
                                      ? '4K'
                                      : '${height}p',
                                ),
                            ],
                            onChanged: (value) async {
                              setState(() => _defaultStreamResolution = value);
                              await ref
                                  .read(sharedPreferencesProvider)
                                  .setString(defaultStreamResolutionKey, value);
                            },
                          ),
                        ],
                        Divider(height: context.dimensions.spacingLarge),
                        _buildControlsAutoHideSlider(),
                        Divider(height: context.dimensions.spacingLarge),
                        ListTile(
                          key: const Key('player_controls_layout_tile'),
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.settings_playback_controls_layout,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_playback_controls_layout_subtitle,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            size: 24 * context.dimensions.fontSizeFactor,
                          ),
                          onTap: () => unawaited(
                            context.push('/settings/playback/controls'),
                          ),
                        ),
                        if (PlayerSettingsStore
                            .backgroundPlaybackConfigurable) ...[
                          Divider(height: context.dimensions.spacingLarge),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              context.l10n.settings_playback_background,
                            ),
                            subtitle: Text(
                              context
                                  .l10n
                                  .settings_playback_background_subtitle,
                            ),
                            value: _enableBackgroundPlayback,
                            onChanged: (value) async {
                              setState(() => _enableBackgroundPlayback = value);
                              await _saveToggleSettings();
                            },
                          ),
                        ],
                        // These Android options only apply with background playback.
                        if (!kIsWeb &&
                            defaultTargetPlatform == TargetPlatform.android &&
                            _enableBackgroundPlayback) ...[
                          Divider(height: context.dimensions.spacingLarge),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              context.l10n.settings_playback_audio_focus,
                            ),
                            subtitle: Text(
                              context
                                  .l10n
                                  .settings_playback_audio_focus_subtitle,
                            ),
                            value: _respectAudioFocus,
                            onChanged: (value) async {
                              setState(() => _respectAudioFocus = value);
                              await _saveToggleSettings();
                            },
                          ),
                          Divider(height: context.dimensions.spacingLarge),
                          SwitchListTile.adaptive(
                            key: const Key('settings_auto_pip'),
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              context.l10n.settings_playback_auto_pip,
                            ),
                            subtitle: Text(
                              context.l10n.settings_playback_auto_pip_subtitle,
                            ),
                            value: _autoPip,
                            onChanged: (value) {
                              setState(() => _autoPip = value);
                              ref
                                  .read(playerStateProvider.notifier)
                                  .setAutoPip(value);
                            },
                          ),
                          Divider(height: context.dimensions.spacingLarge),
                          SwitchListTile.adaptive(
                            key: const Key('settings_system_media_controls'),
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              context.l10n.settings_playback_system_controls,
                            ),
                            subtitle: Text(
                              context
                                  .l10n
                                  .settings_playback_system_controls_subtitle,
                            ),
                            value: _systemMediaControls,
                            onChanged: (value) async {
                              setState(() => _systemMediaControls = value);
                              await ref
                                  .read(sharedPreferencesProvider)
                                  .setBool(
                                    PlayerSettingsStore.systemMediaControlsKey,
                                    value,
                                  );
                              ref
                                  .read(playerStateProvider.notifier)
                                  .syncSystemMediaControls();
                            },
                          ),
                        ],
                        Divider(height: context.dimensions.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.settings_playback_open_fullscreen,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_playback_open_fullscreen_subtitle,
                          ),
                          value: _enterFullscreenOnNavigation,
                          onChanged: (value) async {
                            setState(
                              () => _enterFullscreenOnNavigation = value,
                            );
                            await _saveToggleSettings();
                          },
                        ),
                        Divider(height: context.dimensions.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.settings_playback_gravity_orientation,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_playback_gravity_orientation_subtitle,
                          ),
                          value: _videoGravityOrientation,
                          onChanged: (value) async {
                            setState(() => _videoGravityOrientation = value);
                            await _saveToggleSettings();
                          },
                        ),
                        Divider(height: context.dimensions.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.settings_playback_resume_position,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_playback_resume_position_subtitle,
                          ),
                          value: _resumePlayPosition,
                          onChanged: (value) async {
                            setState(() => _resumePlayPosition = value);
                            await _saveToggleSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.dimensions.spacingLarge),
                  SettingsSectionCard(
                    title: context.l10n.settings_playback_subtitles,
                    subtitle: context.l10n.settings_playback_subtitles_subtitle,
                    child: Column(
                      children: [
                        _buildDefaultSubtitleSelector(),
                        Divider(height: context.dimensions.spacingLarge),
                        _buildSubtitleSizeSlider(),
                        Divider(height: context.dimensions.spacingLarge),
                        _buildSubtitlePositionSlider(),
                        Divider(height: context.dimensions.spacingLarge),
                        _buildSubtitleAlignmentSelector(),
                      ],
                    ),
                  ),
                  SizedBox(height: context.dimensions.spacingLarge),
                  const LocalCaptionSettingsSection(),
                  SizedBox(height: context.dimensions.spacingLarge),
                  SettingsSectionCard(
                    title: context.l10n.settings_playback_seek,
                    subtitle: context.l10n.settings_playback_seek_subtitle,
                    child: _buildSeekInteractionSelector(),
                  ),
                  if (!kIsWeb) ...[
                    SizedBox(height: context.dimensions.spacingLarge),
                    _buildMpvSettings(),
                    SizedBox(height: context.dimensions.spacingLarge),
                    _buildMpvRenderingSettings(),
                    SizedBox(height: context.dimensions.spacingLarge),
                    _buildMpvConfSettings(),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildMpvSettings() {
    final l10n = context.l10n;
    final labels = {
      'default': l10n.settings_playback_mpv_default,
      'no': l10n.settings_playback_mpv_software,
      'auto': l10n.settings_playback_mpv_auto,
      'auto-safe': l10n.settings_playback_mpv_auto_safe,
      'auto-copy': l10n.settings_playback_mpv_auto_copy,
      'gpu': l10n.settings_playback_mpv_gpu,
      'gpu-next': l10n.settings_playback_mpv_gpu_next,
      'libmpv': l10n.settings_playback_mpv_libmpv,
      'libmpv-software': l10n.settings_playback_mpv_libmpv_software,
      'vaapi': l10n.settings_playback_mpv_vaapi,
      'vaapi-copy': l10n.settings_playback_mpv_vaapi_copy,
      'nvdec': l10n.settings_playback_mpv_nvdec,
      'nvdec-copy': l10n.settings_playback_mpv_nvdec_copy,
      'vdpau-copy': l10n.settings_playback_mpv_vdpau_copy,
      'mediacodec_embed': l10n.settings_playback_mpv_embed,
      'mediacodec': l10n.settings_playback_mpv_mediacodec,
      'mediacodec-copy': l10n.settings_playback_mpv_mediacodec_copy,
    };
    return SettingsSectionCard(
      title: l10n.settings_playback_mpv_title,
      subtitle: l10n.settings_playback_mpv_subtitle,
      child: Column(
        children: [
          _buildChoiceSelector(
            title: l10n.settings_playback_mpv_vo,
            description: defaultTargetPlatform == TargetPlatform.android
                ? l10n.settings_playback_mpv_embed_help
                : defaultTargetPlatform == TargetPlatform.linux
                ? l10n.settings_playback_mpv_linux_help
                : null,
            value: _mpvVo,
            choices: [
              for (final value in PlayerSettingsStore.supportedMpvVoValues(
                defaultTargetPlatform,
              ))
                (value, labels[value]!),
            ],
            onChanged: (value) => _saveMpvSettings(vo: value),
          ),
          Divider(height: context.dimensions.spacingLarge),
          _buildChoiceSelector(
            title: l10n.settings_playback_mpv_hwdec,
            value: _mpvHwdec,
            choices: [
              for (final value in PlayerSettingsStore.supportedMpvHwdecValues(
                defaultTargetPlatform,
              ))
                (value, labels[value]!),
            ],
            onChanged: (value) => _saveMpvSettings(hwdec: value),
          ),
        ],
      ),
    );
  }

  Widget _buildMpvRenderingSettings() {
    final l10n = context.l10n;
    final titles = {
      'interpolation': l10n.settings_playback_mpv_interpolation,
      'video-sync': l10n.settings_playback_mpv_sync,
      'tscale': l10n.settings_playback_mpv_tscale,
      'scale': l10n.settings_playback_mpv_scale,
      'dscale': l10n.settings_playback_mpv_dscale,
      'cscale': l10n.settings_playback_mpv_cscale,
      'deband': l10n.settings_playback_mpv_deband,
    };
    return SettingsSectionCard(
      title: l10n.settings_playback_mpv_rendering,
      subtitle: l10n.settings_playback_mpv_rendering_help,
      child: Column(
        children: [
          for (final entry in PlayerSettingsStore.mpvChoices.entries) ...[
            if (entry.key != 'interpolation')
              Divider(height: context.dimensions.spacingLarge),
            _buildChoiceSelector(
              title: titles[entry.key]!,
              value: _mpvOptions[entry.key]!,
              choices: [
                for (final value in entry.value)
                  (
                    value,
                    switch (value) {
                      'default' => l10n.settings_playback_mpv_default,
                      'yes' => l10n.settings_playback_mpv_enabled,
                      'no' => l10n.settings_playback_mpv_disabled,
                      _ => value,
                    },
                  ),
              ],
              onChanged: (value) async {
                await PlayerSettingsStore(ref.read(sharedPreferencesProvider))
                    .saveMpvOption(entry.key, value);
                if (mounted) setState(() => _mpvOptions[entry.key] = value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMpvConfSettings() {
    final l10n = context.l10n;
    return SettingsSectionCard(
      title: l10n.settings_playback_mpv_conf,
      subtitle: l10n.settings_playback_mpv_conf_help,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _mpvConfController,
            minLines: 5,
            maxLines: 12,
            maxLength: 16384,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(
              labelText: l10n.settings_playback_mpv_conf,
              hintText: 'interpolation=yes\nvideo-sync=display-resample\ntscale=oversample',
              errorText: _mpvConfError,
            ),
          ),
          SizedBox(height: context.dimensions.spacingSmall),
          Text(
            PlayerSettingsStore.customMpvOptions.join(', '),
            style: context.textTheme.bodySmall,
          ),
          SizedBox(height: context.dimensions.spacingMedium),
          FilledButton(
            onPressed: () async {
              final store = PlayerSettingsStore(
                ref.read(sharedPreferencesProvider),
              );
              if (!PlayerSettingsStore.isValidMpvConf(
                _mpvConfController.text,
              )) {
                setState(
                  () => _mpvConfError = l10n.settings_playback_mpv_conf_invalid,
                );
                return;
              }
              await store.saveMpvConf(_mpvConfController.text);
              if (!mounted) return;
              setState(() => _mpvConfError = null);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settings_playback_mpv_conf_saved)),
              );
            },
            child: Text(l10n.common_save),
          ),
        ],
      ),
    );
  }

  Future<void> _saveMpvSettings({String? vo, String? hwdec}) async {
    var nextVo = vo ?? _mpvVo;
    var nextHwdec = hwdec ?? _mpvHwdec;
    if (vo == 'mediacodec_embed') nextHwdec = 'mediacodec';
    if (nextVo == 'mediacodec_embed' && nextHwdec != 'mediacodec') {
      nextVo = 'default';
    }
    await PlayerSettingsStore(ref.read(sharedPreferencesProvider))
        .saveMpvConfiguration(vo: nextVo, hwdec: nextHwdec);
    if (!mounted) return;
    setState(() {
      _mpvVo = nextVo;
      _mpvHwdec = nextHwdec;
    });
  }

  Widget _buildChoiceSelector<T>({
    required String title,
    String? description,
    required T value,
    required List<(T, String)> choices,
    required Future<void> Function(T) onChanged,
  }) {
    final label = choices
        .firstWhere((choice) => choice.$1 == value, orElse: () => choices.first)
        .$2;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(description == null ? label : '$label\n$description'),
      trailing: Icon(
        Icons.chevron_right,
        size: 24 * context.dimensions.fontSizeFactor,
      ),
      onTap: () async {
        final selected = await showModalBottomSheet<T>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          showDragHandle: true,
          builder: (sheetContext) => SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(sheetContext.dimensions.spacingMedium),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: sheetContext.textTheme.titleLarge),
                  if (description != null) Text(description),
                  SizedBox(height: sheetContext.dimensions.spacingSmall),
                  for (final choice in choices)
                    ListTile(
                      title: Text(choice.$2),
                      selected: choice.$1 == value,
                      trailing: choice.$1 == value
                          ? Icon(
                              Icons.check,
                              size: 24 * sheetContext.dimensions.fontSizeFactor,
                            )
                          : null,
                      onTap: () => Navigator.pop(sheetContext, choice.$1),
                    ),
                ],
              ),
            ),
          ),
        );
        if (selected != null && mounted) await onChanged(selected);
      },
    );
  }

  Widget _buildEndBehaviorSelector() {
    final behaviors = [
      (VideoEndBehavior.stop, context.l10n.settings_playback_end_behavior_stop),
      (VideoEndBehavior.loop, context.l10n.settings_playback_end_behavior_loop),
      (VideoEndBehavior.next, context.l10n.settings_playback_end_behavior_next),
    ];

    return _buildChoiceSelector(
      title: context.l10n.settings_playback_end_behavior,
      description: context.l10n.settings_playback_end_behavior_subtitle,
      value: _playEndBehavior,
      choices: behaviors,
      onChanged: (value) async {
        setState(() => _playEndBehavior = value);
        await _saveToggleSettings();
      },
    );
  }

  Widget _buildControlsAutoHideSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(context.l10n.settings_playback_controls_auto_hide),
            ),
            SizedBox(width: context.dimensions.spacingSmall),
            Text(
              context.l10n.duration_seconds_format(
                _controlsAutoHideSeconds.toString(),
              ),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          context.l10n.settings_playback_controls_auto_hide_subtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Slider(
          min: PlayerSettingsStore.minControlsAutoHideSeconds.toDouble(),
          max: PlayerSettingsStore.maxControlsAutoHideSeconds.toDouble(),
          divisions:
              PlayerSettingsStore.maxControlsAutoHideSeconds -
              PlayerSettingsStore.minControlsAutoHideSeconds,
          value: _controlsAutoHideSeconds.toDouble(),
          label: context.l10n.duration_seconds_format(
            _controlsAutoHideSeconds.toString(),
          ),
          onChanged: (value) {
            setState(() => _controlsAutoHideSeconds = value.round());
          },
          onChangeEnd: (value) async {
            await _saveToggleSettings();
          },
        ),
      ],
    );
  }

  Widget _buildDefaultSubtitleSelector() {
    final languages = [
      ('none', context.l10n.settings_playback_subtitle_lang_none_disabled),
      ('auto', context.l10n.settings_playback_subtitle_lang_auto_if_only_one),
      ('en', context.l10n.settings_playback_subtitle_lang_english),
      ('zh', context.l10n.settings_playback_subtitle_lang_chinese),
      ('de', context.l10n.settings_playback_subtitle_lang_german),
      ('fr', context.l10n.settings_playback_subtitle_lang_french),
      ('es', context.l10n.settings_playback_subtitle_lang_spanish),
      ('it', context.l10n.settings_playback_subtitle_lang_italian),
      ('ja', context.l10n.settings_playback_subtitle_lang_japanese),
      ('ko', context.l10n.settings_playback_subtitle_lang_korean),
    ];

    return _buildChoiceSelector(
      title: context.l10n.settings_playback_subtitle_lang,
      description: context.l10n.settings_playback_subtitle_lang_subtitle,
      value: _defaultSubtitleLanguage,
      choices: languages,
      onChanged: (value) async {
        setState(() => _defaultSubtitleLanguage = value);
        await _saveToggleSettings();
      },
    );
  }

  Widget _buildSubtitleSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(context.l10n.settings_playback_subtitle_size)),
            SizedBox(width: context.dimensions.spacingSmall),
            Text(
              '${_subtitleFontSize.round()} px',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          min: 12,
          max: 32,
          divisions: 20,
          value: _subtitleFontSize,
          onChanged: (value) {
            setState(() => _subtitleFontSize = value);
          },
          onChangeEnd: (value) async {
            await _saveToggleSettings();
          },
        ),
      ],
    );
  }

  Widget _buildSubtitlePositionSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text(context.l10n.settings_playback_subtitle_pos)),
            SizedBox(width: context.dimensions.spacingSmall),
            Expanded(
              child: Text(
                context.l10n.settings_playback_subtitle_pos_desc(
                  (_subtitlePositionBottomRatio * 100).round().toString(),
                ),
                textAlign: TextAlign.end,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Slider(
          min: 0.05,
          max: 0.40,
          divisions: 35,
          value: _subtitlePositionBottomRatio,
          onChanged: (value) {
            setState(() => _subtitlePositionBottomRatio = value);
          },
          onChangeEnd: (value) async {
            await _saveToggleSettings();
          },
        ),
      ],
    );
  }

  Widget _buildSubtitleAlignmentSelector() {
    final alignments = [
      ('left', context.l10n.settings_playback_subtitle_align_left),
      ('center', context.l10n.settings_playback_subtitle_align_center),
      ('right', context.l10n.settings_playback_subtitle_align_right),
    ];

    return _buildChoiceSelector(
      title: context.l10n.settings_playback_subtitle_align,
      description: context.l10n.settings_playback_subtitle_align_subtitle,
      value: _subtitleTextAlignment,
      choices: alignments,
      onChanged: (value) async {
        setState(() => _subtitleTextAlignment = value);
        await _saveToggleSettings();
      },
    );
  }

  Widget _buildSeekInteractionSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 450;
        final subtitleWidget = Text(
          _useDoubleTapSeek
              ? context.l10n.settings_playback_seek_double_tap
              : context.l10n.settings_playback_seek_drag,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
        final trailingWidget = SegmentedButton<bool>(
          showSelectedIcon: false,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: WidgetStateProperty.all(
              EdgeInsets.symmetric(
                horizontal: context.dimensions.spacingSmall,
                vertical: context.dimensions.spacingSmall / 2,
              ),
            ),
          ),
          segments: [
            ButtonSegment<bool>(
              value: false,
              icon: Icon(
                Icons.drag_indicator,
                size: 24 * context.dimensions.fontSizeFactor,
              ),
              label: Text(context.l10n.settings_playback_seek_drag_label),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: Icon(
                Icons.touch_app_outlined,
                size: 24 * context.dimensions.fontSizeFactor,
              ),
              label: Text(context.l10n.settings_playback_seek_double_tap_label),
            ),
          ],
          selected: {_useDoubleTapSeek},
          onSelectionChanged: (selection) async {
            setState(() => _useDoubleTapSeek = selection.first);
            await _saveToggleSettings();
          },
        );

        if (isNarrow) {
          return Padding(
            padding: EdgeInsets.only(
              top: 4 * context.dimensions.fontSizeFactor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                subtitleWidget,
                SizedBox(height: context.dimensions.spacingMedium),
                SizedBox(width: double.infinity, child: trailingWidget),
              ],
            ),
          );
        }

        return ListTile(
          contentPadding: EdgeInsets.zero,
          subtitle: subtitleWidget,
          trailing: trailingWidget,
        );
      },
    );
  }
}
