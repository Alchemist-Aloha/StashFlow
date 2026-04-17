import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/presentation/providers/keybinds_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import '../../../../../core/presentation/theme/app_theme.dart';
import '../../widgets/settings_page_shell.dart';

class KeybindSettingsPage extends ConsumerWidget {
  const KeybindSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keybinds = ref.watch(keybindsProvider);

    return SettingsPageShell(
      title: context.l10n.settings_keyboard_title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.settings_keyboard_subtitle,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      ref.read(keybindsProvider.notifier).resetToDefaults(),
                  icon: const Icon(Icons.restore),
                  label: Text(context.l10n.settings_keyboard_reset_defaults),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: KeybindAction.values.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final action = KeybindAction.values[index];
                final bind = keybinds.binds[action];
                return ListTile(
                  title: Text(_getActionLabel(action)),
                  subtitle: Text(_getActionDescription(action)),
                  trailing: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => _showCaptureDialog(context, ref, action),
                    child: Text(bind?.label ?? context.l10n.settings_keyboard_not_bound),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getActionLabel(KeybindAction action) {
    switch (action) {
      case KeybindAction.playPause:
        return 'Play / Pause';
      case KeybindAction.seekForward:
        return 'Seek Forward (Small)';
      case KeybindAction.seekBackward:
        return 'Seek Backward (Small)';
      case KeybindAction.seekForwardLarge:
        return 'Seek Forward (Large)';
      case KeybindAction.seekBackwardLarge:
        return 'Seek Backward (Large)';
      case KeybindAction.volumeUp:
        return 'Volume Up';
      case KeybindAction.volumeDown:
        return 'Volume Down';
      case KeybindAction.toggleMute:
        return 'Toggle Mute';
      case KeybindAction.toggleFullscreen:
        return 'Toggle Fullscreen';
      case KeybindAction.togglePip:
        return 'Toggle Picture-in-Picture';
      case KeybindAction.nextScene:
        return 'Next Scene';
      case KeybindAction.previousScene:
        return 'Previous Scene';
      case KeybindAction.speedUp:
        return 'Increase Playback Speed';
      case KeybindAction.speedDown:
        return 'Decrease Playback Speed';
      case KeybindAction.resetSpeed:
        return 'Reset Playback Speed';
      case KeybindAction.closePlayer:
        return 'Close Player';
      case KeybindAction.nextImage:
        return 'Next Image';
      case KeybindAction.previousImage:
        return 'Previous Image';
      case KeybindAction.back:
        return 'Go Back';
    }
  }

  String _getActionDescription(KeybindAction action) {
    switch (action) {
      case KeybindAction.playPause:
        return 'Toggle between playing and pausing video';
      case KeybindAction.seekForward:
        return 'Jump forward by 5 seconds';
      case KeybindAction.seekBackward:
        return 'Jump backward by 5 seconds';
      case KeybindAction.seekForwardLarge:
        return 'Jump forward by 10 seconds';
      case KeybindAction.seekBackwardLarge:
        return 'Jump backward by 10 seconds';
      case KeybindAction.volumeUp:
        return 'Increase volume by 5%';
      case KeybindAction.volumeDown:
        return 'Decrease volume by 5%';
      case KeybindAction.toggleMute:
        return 'Silence or restore audio';
      case KeybindAction.toggleFullscreen:
        return 'Expand to entire screen or exit';
      case KeybindAction.togglePip:
        return 'Toggle floating mini-player (Android only)';
      case KeybindAction.nextScene:
        return 'Play the next scene in the queue';
      case KeybindAction.previousScene:
        return 'Play the previous scene in the queue';
      case KeybindAction.speedUp:
        return 'Increase playback speed by 0.25x';
      case KeybindAction.speedDown:
        return 'Decrease playback speed by 0.25x';
      case KeybindAction.resetSpeed:
        return 'Restore playback speed to 1.0x';
      case KeybindAction.closePlayer:
        return 'Stop playback and close video viewer';
      case KeybindAction.nextImage:
        return 'Navigate to the next image';
      case KeybindAction.previousImage:
        return 'Navigate to the previous image';
      case KeybindAction.back:
        return 'Navigate back to the previous page';
    }
  }

  void _showCaptureDialog(
    BuildContext context,
    WidgetRef ref,
    KeybindAction action,
  ) {
    showDialog(
      context: context,
      builder: (context) => _KeyCaptureDialog(action: action),
    ).then((result) {
      if (result is Keybind) {
        ref.read(keybindsProvider.notifier).setBind(action, result);
      }
    });
  }
}

class _KeyCaptureDialog extends StatefulWidget {
  final KeybindAction action;
  const _KeyCaptureDialog({required this.action});

  @override
  State<_KeyCaptureDialog> createState() => _KeyCaptureDialogState();
}

class _KeyCaptureDialogState extends State<_KeyCaptureDialog> {
  Keybind? _captured;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Shortcut'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Press any key combination...'),
          const SizedBox(height: 24),
          Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent) {
                final key = event.logicalKey;
                // Ignore modifier-only presses
                if (key == LogicalKeyboardKey.controlLeft ||
                    key == LogicalKeyboardKey.controlRight ||
                    key == LogicalKeyboardKey.shiftLeft ||
                    key == LogicalKeyboardKey.shiftRight ||
                    key == LogicalKeyboardKey.altLeft ||
                    key == LogicalKeyboardKey.altRight ||
                    key == LogicalKeyboardKey.metaLeft ||
                    key == LogicalKeyboardKey.metaRight) {
                  return KeyEventResult.ignored;
                }

                setState(() {
                  _captured = Keybind(
                    key,
                    control: HardwareKeyboard.instance.isControlPressed,
                    shift: HardwareKeyboard.instance.isShiftPressed,
                    alt: HardwareKeyboard.instance.isAltPressed,
                    meta: HardwareKeyboard.instance.isMetaPressed,
                  );
                });
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _captured?.label ?? context.l10n.settings_keyboard_not_bound,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.common_cancel),
        ),
        FilledButton(
          onPressed: _captured != null
              ? () => Navigator.pop(context, _captured)
              : null,
          child: Text(context.l10n.common_save),
        ),
      ],
    );
  }
}
