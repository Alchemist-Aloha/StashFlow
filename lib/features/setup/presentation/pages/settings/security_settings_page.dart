import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/app_lock_settings_provider.dart';
import '../../widgets/settings_page_shell.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';


class SecuritySettingsPage extends ConsumerWidget {
  const SecuritySettingsPage({super.key});

  static const _backgroundTimeoutOptions = <int>[0, 5, 10, 30, 60, 120, 300];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appLockSettingsProvider);
    final notifier = ref.read(appLockSettingsProvider.notifier);

    return SettingsPageShell(
      title: context.l10n.settings_security,
      child: ListView(
        padding: EdgeInsets.all(context.dimensions.spacingLarge),
        children: [
          SettingsSectionCard(
            title: context.l10n.settings_security_app_lock,
            subtitle: context.l10n.settings_security_app_lock_subtitle,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.security_passcode),
                  subtitle: Text(
                    settings.hasPasscode ? context.l10n.settings_security_configured : context.l10n.settings_security_not_configured,
                  ),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: () async {
                          final passcode = await _showPasscodeDialog(context);
                          if (passcode == null) return;
                          await notifier.setPasscode(passcode);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(context.l10n.security_passcode_saved)),
                            );
                          }
                        },
                        child: Text(settings.hasPasscode ? 'Change' : 'Set'),
                      ),
                      if (settings.hasPasscode)
                        TextButton(
                          onPressed: () async {
                            await notifier.clearPasscode();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.l10n.security_passcode_removed),
                                ),
                              );
                            }
                          },
                          child: Text(context.l10n.common_remove),
                        ),
                    ],
                  ),
                ),
                Divider(height: context.dimensions.spacingLarge),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.settings_security_enable_app_lock),
                  subtitle: Text(
                    context.l10n.settings_security_require_passcode_subtitle,
                  ),
                  value: settings.enabled && settings.hasPasscode,
                  onChanged: (value) async {
                    if (value && !settings.hasPasscode) {
                      final passcode = await _showPasscodeDialog(context);
                      if (passcode == null) return;
                      await notifier.setPasscode(passcode);
                    }
                    await notifier.setEnabled(value);
                  },
                ),
                Divider(height: context.dimensions.spacingLarge),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.settings_security_lock_on_app_launch),
                  subtitle: Text(
                    context.l10n.settings_security_lock_on_launch_subtitle,
                  ),
                  value: settings.lockOnLaunch,
                  onChanged: settings.enabled && settings.hasPasscode
                      ? (value) => notifier.setLockOnLaunch(value)
                      : null,
                ),
                Divider(height: context.dimensions.spacingLarge),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.settings_security_background_lock_timer),
                  subtitle: Text(
                    context.l10n.settings_security_background_timer_subtitle,
                  ),
                  trailing: DropdownButton<int>(
                    value: settings.backgroundLockSeconds,
                    onChanged: settings.enabled && settings.hasPasscode
                        ? (value) {
                            if (value != null) {
                              notifier.setBackgroundLockSeconds(value);
                            }
                          }
                        : null,
                    items: _backgroundTimeoutOptions
                        .map(
                          (seconds) => DropdownMenuItem<int>(
                            value: seconds,
                            child: Text(_formatTimeout(seconds)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTimeout(int seconds) {
    if (seconds == 0) return 'Immediately';
    if (seconds < 60) return '$seconds sec';
    if (seconds % 60 == 0) return '${seconds ~/ 60} min';
    return '${seconds}s';
  }

  static Future<String?> _showPasscodeDialog(BuildContext context) async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    String? error;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(context.l10n.settings_security_set_passcode),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 8,
                    decoration: InputDecoration(
                      labelText: context.l10n.settings_security_passcode_hint,
                    ),
                  ),
                  TextField(
                    controller: confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 8,
                    decoration: InputDecoration(labelText: context.l10n.settings_security_confirm_passcode),
                  ),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(context.l10n.common_cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final passcode = controller.text.trim();
                    final confirm = confirmController.text.trim();
                    final numeric = RegExp(r'^\d{4,8}$');
                    if (!numeric.hasMatch(passcode)) {
                      setState(
                        () => error = 'Use only digits, with length 4-8.',
                      );
                      return;
                    }
                    if (passcode != confirm) {
                      setState(() => error = 'Passcodes do not match.');
                      return;
                    }
                    Navigator.of(dialogContext).pop(passcode);
                  },
                  child: Text(context.l10n.common_save),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    confirmController.dispose();
    return result;
  }
}
