import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import '../../widgets/settings_page_shell.dart';

class PlaybackSettingsPage extends ConsumerStatefulWidget {
  const PlaybackSettingsPage({super.key});

  @override
  ConsumerState<PlaybackSettingsPage> createState() =>
      _PlaybackSettingsPageState();
}

class _PlaybackSettingsPageState extends ConsumerState<PlaybackSettingsPage> {
  static const _preferSceneStreamsKey = 'prefer_scene_streams';
  static const _autoplayNextKey = 'autoplay_next';
  static const _useDoubleTapSeekKey = 'video_use_double_tap_seek';
  static const _enableBackgroundPlaybackKey = 'video_background_playback';
  static const _enableNativePipKey = 'video_native_pip';
  static const _videoGravityOrientationKey = 'video_gravity_orientation';
  static const _defaultSubtitleLanguageKey = 'default_subtitle_language';
  static const _subtitleFontSizeKey = 'subtitle_font_size';
  static const _subtitlePositionBottomRatioKey =
      'subtitle_position_bottom_ratio';
  static const _subtitleTextAlignmentKey = 'subtitle_text_alignment';

  bool _preferSceneStreams = true;
  bool _autoplayNext = false;
  bool _useDoubleTapSeek = true;
  bool _enableBackgroundPlayback = false;
  bool _enableNativePip = false;
  bool _videoGravityOrientation = true;
  String _defaultSubtitleLanguage = 'none';
  double _subtitleFontSize = 18.0;
  double _subtitlePositionBottomRatio = 0.15;
  String _subtitleTextAlignment = 'center';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = ref.read(sharedPreferencesProvider);
    _preferSceneStreams = prefs.getBool(_preferSceneStreamsKey) ?? true;
    _autoplayNext = prefs.getBool(_autoplayNextKey) ?? false;
    _useDoubleTapSeek = prefs.getBool(_useDoubleTapSeekKey) ?? true;
    _enableBackgroundPlayback =
        prefs.getBool(_enableBackgroundPlaybackKey) ?? false;
    _enableNativePip = prefs.getBool(_enableNativePipKey) ?? false;
    _videoGravityOrientation =
        prefs.getBool(_videoGravityOrientationKey) ?? true;
    _defaultSubtitleLanguage =
        prefs.getString(_defaultSubtitleLanguageKey) ?? 'none';
    _subtitleFontSize = prefs.getDouble(_subtitleFontSizeKey) ?? 18.0;
    _subtitlePositionBottomRatio =
        prefs.getDouble(_subtitlePositionBottomRatioKey) ?? 0.15;
    _subtitleTextAlignment =
        prefs.getString(_subtitleTextAlignmentKey) ?? 'center';

    setState(() => _loading = false);
  }

  Future<void> _saveToggleSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_preferSceneStreamsKey, _preferSceneStreams);
    await prefs.setBool(_autoplayNextKey, _autoplayNext);
    await prefs.setBool(_useDoubleTapSeekKey, _useDoubleTapSeek);
    await prefs.setBool(
      _enableBackgroundPlaybackKey,
      _enableBackgroundPlayback,
    );
    await prefs.setBool(_enableNativePipKey, _enableNativePip);
    await prefs.setBool(
      _videoGravityOrientationKey,
      _videoGravityOrientation,
    );
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

    final playerStateNotifier = ref.read(playerStateProvider.notifier);
    playerStateNotifier.setAutoplayNext(_autoplayNext);
    playerStateNotifier.setUseDoubleTapSeek(_useDoubleTapSeek);
    playerStateNotifier.setEnableBackgroundPlayback(_enableBackgroundPlayback);
    playerStateNotifier.setEnableNativePip(_enableNativePip);
    playerStateNotifier.setVideoGravityOrientation(_videoGravityOrientation);
    playerStateNotifier.setDefaultSubtitleLanguage(_defaultSubtitleLanguage);
    playerStateNotifier.setSubtitleFontSize(_subtitleFontSize);
    playerStateNotifier.setSubtitlePositionBottomRatio(
      _subtitlePositionBottomRatio,
    );
    playerStateNotifier.setSubtitleTextAlignment(_subtitleTextAlignment);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageShell(
      title: context.l10n.settings_playback_title,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
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
                            context.l10n.settings_playback_prefer_streams,
                          ),
                          subtitle: Text(
                            context
                                .l10n
                                .settings_playback_prefer_streams_subtitle,
                          ),
                          value: _preferSceneStreams,
                          onChanged: (value) async {
                            setState(() => _preferSceneStreams = value);
                            await _saveToggleSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.l10n.settings_playback_autoplay),
                          subtitle: Text(
                            context.l10n.settings_playback_autoplay_subtitle,
                          ),
                          value: _autoplayNext,
                          onChanged: (value) async {
                            setState(() => _autoplayNext = value);
                            await _saveToggleSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            context.l10n.settings_playback_background,
                          ),
                          subtitle: Text(
                            context.l10n.settings_playback_background_subtitle,
                          ),
                          value: _enableBackgroundPlayback,
                          onChanged: (value) async {
                            setState(() => _enableBackgroundPlayback = value);
                            await _saveToggleSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(context.l10n.settings_playback_pip),
                          subtitle: Text(
                            context.l10n.settings_playback_pip_subtitle,
                          ),
                          value: _enableNativePip,
                          onChanged: (value) async {
                            setState(() => _enableNativePip = value);
                            await _saveToggleSettings();
                          },
                        ),
                        const Divider(height: AppTheme.spacingLarge),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: context.l10n.settings_playback_subtitles,
                    subtitle: context.l10n.settings_playback_subtitles_subtitle,
                    child: Column(
                      children: [
                        _buildDefaultSubtitleSelector(),
                        const Divider(height: AppTheme.spacingLarge),
                        _buildSubtitleSizeSlider(),
                        const Divider(height: AppTheme.spacingLarge),
                        _buildSubtitlePositionSlider(),
                        const Divider(height: AppTheme.spacingLarge),
                        _buildSubtitleAlignmentSelector(),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: context.l10n.settings_playback_seek,
                    subtitle: context.l10n.settings_playback_seek_subtitle,
                    child: _buildSeekInteractionSelector(),
                  ),
                ],
              ),
            ),
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(context.l10n.settings_playback_subtitle_lang),
      subtitle: Text(context.l10n.settings_playback_subtitle_lang_subtitle),
      trailing: DropdownButton<String>(
        value: _defaultSubtitleLanguage,
        onChanged: (value) async {
          if (value != null) {
            setState(() => _defaultSubtitleLanguage = value);
            await _saveToggleSettings();
          }
        },
        items: languages
            .map((l) => DropdownMenuItem(value: l.$1, child: Text(l.$2)))
            .toList(),
      ),
    );
  }

  Widget _buildSubtitleSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.settings_playback_subtitle_size),
            Text(
              '${_subtitleFontSize.round()} px',
              style: TextStyle(
                fontSize: context.fontSizes.regular,
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
            Text(context.l10n.settings_playback_subtitle_pos),
            Text(
              context.l10n.settings_playback_subtitle_pos_desc(
                (_subtitlePositionBottomRatio * 100).round().toString(),
              ),
              style: TextStyle(
                fontSize: context.fontSizes.regular,
                fontWeight: FontWeight.bold,
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(context.l10n.settings_playback_subtitle_align),
      subtitle: Text(context.l10n.settings_playback_subtitle_align_subtitle),
      trailing: DropdownButton<String>(
        value: _subtitleTextAlignment,
        onChanged: (value) async {
          if (value != null) {
            setState(() => _subtitleTextAlignment = value);
            await _saveToggleSettings();
          }
        },
        items: alignments
            .map((a) => DropdownMenuItem(value: a.$1, child: Text(a.$2)))
            .toList(),
      ),
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
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
        final trailingWidget = SegmentedButton<bool>(
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          segments: [
            ButtonSegment<bool>(
              value: false,
              icon: const Icon(Icons.drag_indicator),
              label: Text(context.l10n.settings_playback_seek_drag_label),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: const Icon(Icons.touch_app_outlined),
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
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                subtitleWidget,
                const SizedBox(height: 12),
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
