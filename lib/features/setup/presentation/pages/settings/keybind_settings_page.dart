import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';

import '../../../../../core/presentation/providers/keybinds_provider.dart';
import '../../../../../core/presentation/theme/app_theme.dart';
import '../../widgets/settings_page_shell.dart';

class KeybindSettingsPage extends ConsumerWidget {
  const KeybindSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keybinds = ref.watch(keybindsProvider);

    return SettingsPageShell(
      title: context.l10n.settings_keyboard_title,
      child: SettingsPageBody(
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionCard(
              title: context.l10n.settings_keyboard_title,
              subtitle: context.l10n.settings_keyboard_subtitle,
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _confirmReset(context, ref),
                  icon: Icon(
                    Icons.restore,
                    size: 24 * context.dimensions.fontSizeFactor,
                  ),
                  label: Text(context.l10n.settings_keyboard_reset_defaults),
                ),
              ),
            ),
            for (final shortcutContext in KeybindContext.values)
              _buildSection(context, ref, keybinds, shortcutContext),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    Keybinds keybinds,
    KeybindContext shortcutContext,
  ) {
    final actions = KeybindAction.values
        .where((action) => action.context == shortcutContext)
        .toList();

    return SettingsSectionCard(
      title: _sectionLabel(context, shortcutContext),
      child: SettingsPanelGroup(
        children: [
          for (final action in actions)
            _buildActionTile(context, ref, action, keybinds.binds[action]),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    WidgetRef ref,
    KeybindAction action,
    Keybind? bind,
  ) {
    final description = _actionDescription(context, action);
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.dimensions.spacingSmall,
      ),
      title: Text(
        _actionLabel(context, action),
        style: context.textTheme.bodyMedium?.copyWith(
          fontSize: context.fontSizes.body,
        ),
      ),
      subtitle: description == null
          ? null
          : Text(
              description,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: context.fontSizes.small,
              ),
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 180 * context.dimensions.fontSizeFactor,
            child: OutlinedButton(
              onPressed: () => _capture(context, ref, action),
              child: Text(
                bind?.label ?? context.l10n.settings_keyboard_not_bound,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(width: context.dimensions.spacingSmall),
          IconButton(
            tooltip: context.l10n.settings_keyboard_unbind,
            onPressed: bind == null
                ? null
                : () => ref.read(keybindsProvider.notifier).unbind(action),
            icon: const Icon(Icons.link_off_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _capture(
    BuildContext context,
    WidgetRef ref,
    KeybindAction action,
  ) async {
    final result = await showDialog<Keybind>(
      context: context,
      builder: (context) =>
          _KeyCaptureDialog(actionLabel: _actionLabel(context, action)),
    );
    if (result == null || !context.mounted) return;

    final displaced = await ref
        .read(keybindsProvider.notifier)
        .setBind(action, result);
    if (!context.mounted || displaced.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.settings_keyboard_conflict_moved(
            displaced.map((action) => _actionLabel(context, action)).join(', '),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.settings_keyboard_reset_confirm_title),
        content: Text(context.l10n.settings_keyboard_reset_confirm_body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.common_reset),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(keybindsProvider.notifier).resetToDefaults();
    }
  }

  String _sectionLabel(BuildContext context, KeybindContext shortcutContext) =>
      switch (shortcutContext) {
        KeybindContext.global => context.l10n.settings_keyboard_global_section,
        KeybindContext.video => context.l10n.settings_keyboard_video_section,
        KeybindContext.image => context.l10n.settings_keyboard_image_section,
      };

  String _actionLabel(BuildContext context, KeybindAction action) {
    final l10n = context.l10n;
    return switch (action) {
      KeybindAction.playPause => '${l10n.common_play} / ${l10n.common_pause}',
      KeybindAction.seekForward => l10n.settings_keyboard_seek_forward_5_desc,
      KeybindAction.seekBackward => l10n.settings_keyboard_seek_backward_5_desc,
      KeybindAction.seekForwardLarge =>
        l10n.settings_keyboard_seek_forward_10_desc,
      KeybindAction.seekBackwardLarge =>
        l10n.settings_keyboard_seek_backward_10_desc,
      KeybindAction.volumeUp => l10n.settings_keyboard_volume_up,
      KeybindAction.volumeDown => l10n.settings_keyboard_volume_down,
      KeybindAction.toggleMute => l10n.settings_keyboard_toggle_mute,
      KeybindAction.toggleFullscreen =>
        l10n.settings_keyboard_toggle_fullscreen,
      KeybindAction.togglePip => l10n.common_pip,
      KeybindAction.nextScene => l10n.settings_keyboard_next_scene,
      KeybindAction.previousScene => l10n.settings_keyboard_prev_scene,
      KeybindAction.speedUp => l10n.settings_keyboard_increase_speed,
      KeybindAction.speedDown => l10n.settings_keyboard_decrease_speed,
      KeybindAction.resetSpeed => l10n.settings_keyboard_reset_speed,
      KeybindAction.closePlayer => l10n.settings_keyboard_close_player,
      KeybindAction.nextImage => l10n.settings_keyboard_next_image,
      KeybindAction.previousImage => l10n.settings_keyboard_prev_image,
      KeybindAction.back => l10n.settings_keyboard_go_back,
      KeybindAction.nextTab => l10n.settings_keyboard_next_tab,
      KeybindAction.previousTab => l10n.settings_keyboard_previous_tab,
      KeybindAction.tab1 => l10n.settings_keyboard_tab_number(1),
      KeybindAction.tab2 => l10n.settings_keyboard_tab_number(2),
      KeybindAction.tab3 => l10n.settings_keyboard_tab_number(3),
      KeybindAction.tab4 => l10n.settings_keyboard_tab_number(4),
      KeybindAction.tab5 => l10n.settings_keyboard_tab_number(5),
      KeybindAction.tab6 => l10n.settings_keyboard_tab_number(6),
      KeybindAction.tab7 => l10n.settings_keyboard_tab_number(7),
      KeybindAction.tab8 => l10n.settings_keyboard_tab_number(8),
      KeybindAction.tab9 => l10n.settings_keyboard_tab_number(9),
      KeybindAction.firstImage => l10n.settings_keyboard_first_image,
      KeybindAction.lastImage => l10n.settings_keyboard_last_image,
      KeybindAction.closeImage => l10n.settings_keyboard_close_image,
    };
  }

  String? _actionDescription(BuildContext context, KeybindAction action) =>
      switch (action) {
        KeybindAction.playPause =>
          context.l10n.settings_keyboard_play_pause_desc,
        _ => null,
      };
}

class _KeyCaptureDialog extends StatefulWidget {
  const _KeyCaptureDialog({required this.actionLabel});

  final String actionLabel;

  @override
  State<_KeyCaptureDialog> createState() => _KeyCaptureDialogState();
}

class _KeyCaptureDialogState extends State<_KeyCaptureDialog> {
  Keybind? _captured;
  String? _error;

  bool _isModifier(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.controlLeft ||
      key == LogicalKeyboardKey.controlRight ||
      key == LogicalKeyboardKey.shiftLeft ||
      key == LogicalKeyboardKey.shiftRight ||
      key == LogicalKeyboardKey.altLeft ||
      key == LogicalKeyboardKey.altRight ||
      key == LogicalKeyboardKey.metaLeft ||
      key == LogicalKeyboardKey.metaRight;

  bool _isReserved(Keybind bind) {
    final browserModifier = bind.control || bind.meta;
    return (browserModifier &&
            (bind.key == LogicalKeyboardKey.keyR ||
                bind.key == LogicalKeyboardKey.keyL ||
                bind.key == LogicalKeyboardKey.keyT ||
                bind.key == LogicalKeyboardKey.keyW ||
                bind.key == LogicalKeyboardKey.keyN ||
                bind.key == LogicalKeyboardKey.keyP ||
                bind.key == LogicalKeyboardKey.keyF)) ||
        (bind.meta &&
            (bind.key == LogicalKeyboardKey.keyQ ||
                bind.key == LogicalKeyboardKey.keyM)) ||
        (bind.alt && bind.key == LogicalKeyboardKey.f4) ||
        bind.key == LogicalKeyboardKey.f5;
  }

  KeyEventResult _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
      return KeyEventResult.handled;
    }
    if (_isModifier(key)) return KeyEventResult.handled;
    if (key == LogicalKeyboardKey.tab &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isAltPressed &&
        !HardwareKeyboard.instance.isMetaPressed) {
      setState(() {
        _captured = null;
        _error = context.l10n.settings_keyboard_tab_reserved;
      });
      return KeyEventResult.handled;
    }

    final bind = Keybind(
      key,
      control: HardwareKeyboard.instance.isControlPressed,
      shift: HardwareKeyboard.instance.isShiftPressed,
      alt: HardwareKeyboard.instance.isAltPressed,
      meta: HardwareKeyboard.instance.isMetaPressed,
    );
    final reserved = _isReserved(bind);
    setState(() {
      _captured = reserved ? null : bind;
      _error = reserved ? context.l10n.settings_keyboard_reserved : null;
    });
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.settings_keybind_assign_shortcut),
          Text(widget.actionLabel, style: context.textTheme.bodyMedium),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.settings_keybind_press_any),
          SizedBox(height: context.dimensions.spacingLarge),
          Focus(
            autofocus: true,
            onKeyEvent: (_, event) => _onKeyEvent(event),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.dimensions.spacingLarge,
                vertical: context.dimensions.spacingMedium,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Text(
                _captured?.label ?? context.l10n.settings_keyboard_not_bound,
                style: context.textTheme.displaySmall?.copyWith(
                  fontSize: context.fontSizes.display,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            SizedBox(height: context.dimensions.spacingMedium),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.common_cancel),
        ),
        FilledButton(
          onPressed: _captured == null
              ? null
              : () => Navigator.pop(context, _captured),
          child: Text(context.l10n.common_save),
        ),
      ],
    );
  }
}
