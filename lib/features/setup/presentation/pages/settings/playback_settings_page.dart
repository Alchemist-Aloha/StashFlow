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
  static const _showVideoDebugInfoKey = 'show_video_debug_info';
  static const _useDoubleTapSeekKey = 'video_use_double_tap_seek';
  static const _enableBackgroundPlaybackKey = 'video_background_playback';
  static const _enableNativePipKey = 'video_native_pip';

  bool _preferSceneStreams = true;
  bool _autoplayNext = false;
  bool _showVideoDebugInfo = false;
  bool _useDoubleTapSeek = true;
  bool _enableBackgroundPlayback = false;
  bool _enableNativePip = false;
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
    _showVideoDebugInfo = prefs.getBool(_showVideoDebugInfoKey) ?? false;
    _useDoubleTapSeek = prefs.getBool(_useDoubleTapSeekKey) ?? true;
    _enableBackgroundPlayback =
        prefs.getBool(_enableBackgroundPlaybackKey) ?? false;
    _enableNativePip = prefs.getBool(_enableNativePipKey) ?? false;

    setState(() => _loading = false);
  }

  Future<void> _saveToggleSettings() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_preferSceneStreamsKey, _preferSceneStreams);
    await prefs.setBool(_autoplayNextKey, _autoplayNext);
    await prefs.setBool(_showVideoDebugInfoKey, _showVideoDebugInfo);
    await prefs.setBool(_useDoubleTapSeekKey, _useDoubleTapSeek);
    await prefs.setBool(
      _enableBackgroundPlaybackKey,
      _enableBackgroundPlayback,
    );
    await prefs.setBool(_enableNativePipKey, _enableNativePip);

    final playerStateNotifier = ref.read(playerStateProvider.notifier);
    playerStateNotifier.setAutoplayNext(_autoplayNext);
    playerStateNotifier.setShowVideoDebugInfo(_showVideoDebugInfo);
    playerStateNotifier.setUseDoubleTapSeek(_useDoubleTapSeek);
    playerStateNotifier.setEnableBackgroundPlayback(_enableBackgroundPlayback);
    playerStateNotifier.setEnableNativePip(_enableNativePip);
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
                        const Divider(height: AppTheme.spacingLarge),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Show Video Debug Info'),
                          subtitle: const Text(
                            'Display stream source and startup timing overlay on player',
                          ),
                          value: _showVideoDebugInfo,
                          onChanged: (value) async {
                            setState(() => _showVideoDebugInfo = value);
                            await _saveToggleSettings();
                          },
                        ),
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
