import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/player_controls_layout.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/settings_page_shell.dart';

/// Lets users show, order, and place the player's utility buttons.
class PlayerControlsCustomizationPage extends ConsumerStatefulWidget {
  const PlayerControlsCustomizationPage({super.key});

  @override
  ConsumerState<PlayerControlsCustomizationPage> createState() =>
      _PlayerControlsCustomizationPageState();
}

class _PlayerControlsCustomizationPageState
    extends ConsumerState<PlayerControlsCustomizationPage> {
  bool _fullscreen = false;

  static String _describe(BuildContext context, PlayerControlButton button) =>
      switch (button) {
        PlayerControlButton.stream => context.l10n.player_stream_source,
        PlayerControlButton.subtitles => context.l10n.common_select_subtitle,
        PlayerControlButton.speed => context.l10n.common_playback_speed,
        PlayerControlButton.volume => context.l10n.player_control_volume,
        PlayerControlButton.cast => context.l10n.cast_cast,
        PlayerControlButton.pip => context.l10n.common_pip,
        PlayerControlButton.fullscreen => context.l10n.common_toggle_fullscreen,
        PlayerControlButton.playlist => context.l10n.player_control_playlist,
        PlayerControlButton.random => context.l10n.random_scene,
      };

  @override
  Widget build(BuildContext context) {
    final provider = playerControlsLayoutProvider(_fullscreen);
    final items = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    final iconSize = 24 * context.dimensions.fontSizeFactor;
    final handleSize = context.dimensions.buttonHeight.clamp(
      48.0,
      double.infinity,
    );

    return SettingsPageShell(
      title: context.l10n.settings_playback_controls_layout,
      child: SettingsPageBody(
        scrollable: false,
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionCard(
              wrapInPanel: false,
              title: context.l10n.settings_playback_controls_layout,
              subtitle: context.l10n.settings_playback_controls_layout_subtitle,
              child: const SizedBox.shrink(),
            ),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(
                          context.l10n.settings_playback_controls_inline,
                        ),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(
                          context.l10n.settings_playback_controls_fullscreen,
                        ),
                      ),
                    ],
                    selected: {_fullscreen},
                    onSelectionChanged: (value) =>
                        setState(() => _fullscreen = value.single),
                  ),
                ),
                SizedBox(width: context.dimensions.spacingSmall),
                TextButton(
                  onPressed: () => unawaited(notifier.reset()),
                  child: Text(context.l10n.common_reset),
                ),
              ],
            ),
            SizedBox(height: context.dimensions.spacingMedium),
            Expanded(
              child: SettingsPanelCard(
                child: ReorderableListView(
                  buildDefaultDragHandles: false,
                  onReorderItem: (oldIndex, newIndex) =>
                      unawaited(notifier.reorder(oldIndex, newIndex)),
                  children: [
                    for (var index = 0; index < items.length; index++)
                      _buildTile(
                        context,
                        notifier,
                        items[index],
                        index,
                        iconSize,
                        handleSize,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    PlayerControlsLayoutNotifier notifier,
    PlayerControlItem item,
    int index,
    double iconSize,
    double handleSize,
  ) {
    final label = _describe(context, item.button);
    // A plain row, not ListTile: ListTile clips a two-line body at large scales.
    return Padding(
      key: ValueKey(item.button),
      padding: EdgeInsets.symmetric(
        vertical: context.dimensions.spacingSmall / 2,
      ),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: SizedBox(
              width: handleSize,
              height: handleSize,
              child: Icon(Icons.drag_handle, size: iconSize),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textTheme.bodyLarge),
                SizedBox(height: context.dimensions.spacingSmall / 2),
                SegmentedButton<PlayerControlPlacement>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: PlayerControlPlacement.bottom,
                      icon: const Icon(Icons.vertical_align_bottom_rounded),
                      tooltip: context.l10n.settings_playback_controls_bottom,
                    ),
                    ButtonSegment(
                      value: PlayerControlPlacement.topRight,
                      icon: const Icon(Icons.north_east_rounded),
                      tooltip:
                          context.l10n.settings_playback_controls_top_right,
                    ),
                  ],
                  selected: {item.placement},
                  onSelectionChanged: item.visible
                      ? (value) => unawaited(
                          notifier.update(
                            item.copyWith(placement: value.single),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: item.visible,
            onChanged: (value) =>
                unawaited(notifier.update(item.copyWith(visible: value))),
          ),
        ],
      ),
    );
  }
}
