import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/utils/app_log_store.dart';

import '../../widgets/settings_page_shell.dart';

class DeveloperSettingsPage extends ConsumerStatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  ConsumerState<DeveloperSettingsPage> createState() =>
      _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends ConsumerState<DeveloperSettingsPage> {
  static const _showVideoDebugInfoKey = 'show_video_debug_info';
  static const _enableDebugLoggingKey = 'enable_debug_logging';

  bool _showVideoDebugInfo = false;
  bool _enableDebugLogging = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _showVideoDebugInfo = prefs.getBool(_showVideoDebugInfoKey) ?? false;
      _enableDebugLogging = prefs.getBool(_enableDebugLoggingKey) ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsPageShell(
      title: l10n.settings_develop_title,
      child: SettingsPageBody(
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionCard(
              title: l10n.settings_develop_diagnostics,
              subtitle: l10n.settings_develop_diagnostics_subtitle,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.settings_develop_video_debug),
                    subtitle: Text(l10n.settings_develop_video_debug_subtitle),
                    value: _showVideoDebugInfo,
                    onChanged: (value) {
                      setState(() => _showVideoDebugInfo = value);
                      _saveSetting(_showVideoDebugInfoKey, value);
                      ref
                          .read(playerStateProvider.notifier)
                          .setShowVideoDebugInfo(value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.settings_develop_enable_logging),
                    subtitle: Text(
                      l10n.settings_develop_enable_logging_subtitle,
                    ),
                    value: _enableDebugLogging,
                    onChanged: (value) {
                      setState(() => _enableDebugLogging = value);
                      _saveSetting(_enableDebugLoggingKey, value);
                      AppLogStore.instance.isEnabled = value;
                    },
                  ),
                  const Divider(height: 1),
                  SettingsActionCard(
                    icon: Icons.bug_report_outlined,
                    title: l10n.settings_develop_log_viewer,
                    subtitle: l10n.settings_develop_log_viewer_subtitle,
                    onTap: () => context.push('/settings/logs'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
