import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      title: 'Playback Settings',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SettingsSectionCard(
                    title: 'Playback behavior',
                    subtitle: 'Default playback and background handling',
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Prefer sceneStreams first'),
                          subtitle: const Text(
                            'When off, playback directly uses paths.stream',
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
                          title: const Text('Autoplay Next Scene'),
                          subtitle: const Text(
                            'Automatically play the next scene when current playback ends',
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
                          title: const Text('Background Playback'),
                          subtitle: const Text(
                            'Keep video audio playing when app is backgrounded',
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
                          title: const Text('Native Picture-in-Picture'),
                          subtitle: const Text(
                            'Enable Android PiP button and auto-enter on background',
                          ),
                          value: _enableNativePip,
                          onChanged: (value) async {
                            setState(() => _enableNativePip = value);
                            await _saveToggleSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  SettingsSectionCard(
                    title: 'Subtitle settings',
                    subtitle: 'Automatic loading and appearance',
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
                    title: 'Seek interaction',
                    subtitle: 'Choose how scrubbing works during playback',
                    child: _buildSeekInteractionSelector(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDefaultSubtitleSelector() {
    final languages = [
      ('none', 'None (Disabled)'),
      ('auto', 'Auto (If only one)'),
      ('en', 'English'),
      ('zh', 'Chinese'),
      ('de', 'German'),
      ('fr', 'French'),
      ('es', 'Spanish'),
      ('it', 'Italian'),
      ('ja', 'Japanese'),
      ('ko', 'Korean'),
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Default Subtitle Language'),
      subtitle: const Text('Auto-load if available'),
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
            const Text('Subtitle Font Size'),
            Text(
              '${_subtitleFontSize.round()} px',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
            const Text('Subtitle Vertical Position'),
            Text(
              '${(_subtitlePositionBottomRatio * 100).round()}% from bottom',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
      ('left', 'Left'),
      ('center', 'Center'),
      ('right', 'Right'),
    ];

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Subtitle Text Alignment'),
      subtitle: const Text('Alignment for multiline subtitles'),
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
              ? 'Double-tap left/right to seek 10s'
              : 'Drag the timeline to seek',
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
          segments: const [
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Icons.drag_indicator),
              label: Text('Drag'),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Icons.touch_app_outlined),
              label: Text('Double-tap'),
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
