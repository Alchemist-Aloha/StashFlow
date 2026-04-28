import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';

import '../../widgets/settings_page_shell.dart';

class DeveloperSettingsPage extends ConsumerStatefulWidget {
  const DeveloperSettingsPage({super.key});

  @override
  ConsumerState<DeveloperSettingsPage> createState() =>
      _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends ConsumerState<DeveloperSettingsPage> {
  static const _showVideoDebugInfoKey = 'show_video_debug_info';
  static const _allowWebPasswordLoginKey = 'allow_web_password_login';
  static const _enableProxyAuthModesKey = 'enable_proxy_auth_modes';

  bool _showVideoDebugInfo = false;
  bool _allowWebPasswordLogin = false;
  bool _enableProxyAuthModes = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _showVideoDebugInfo = prefs.getBool(_showVideoDebugInfoKey) ?? false;
      _allowWebPasswordLogin =
          prefs.getBool(_allowWebPasswordLoginKey) ?? false;
      _enableProxyAuthModes = prefs.getBool(_enableProxyAuthModesKey) ?? false;
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
      child: ListView(
        padding: EdgeInsets.all(context.dimensions.spacingMedium),
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
                  title: Text(l10n.settings_develop_proxy_auth),
                  subtitle: Text(l10n.settings_develop_proxy_auth_subtitle),
                  value: _enableProxyAuthModes,
                  onChanged: (value) {
                    setState(() => _enableProxyAuthModes = value);
                    _saveSetting(_enableProxyAuthModesKey, value);
                    ref
                        .read(sharedPreferencesTriggerProvider.notifier)
                        .trigger();
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
          if (kIsWeb) ...[
            SizedBox(height: context.dimensions.spacingLarge),
            SettingsSectionCard(
              title: l10n.settings_develop_web_overrides,
              subtitle: l10n.settings_develop_web_overrides_subtitle,
              child: SwitchListTile(
                title: Text(l10n.settings_develop_web_auth),
                subtitle: Text(l10n.settings_develop_web_auth_subtitle),
                value: _allowWebPasswordLogin,
                onChanged: (value) {
                  setState(() => _allowWebPasswordLogin = value);
                  _saveSetting(_allowWebPasswordLoginKey, value);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
