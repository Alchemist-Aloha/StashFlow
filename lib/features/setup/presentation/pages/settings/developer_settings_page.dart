import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/data/preferences/shared_preferences_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';

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

  bool _showVideoDebugInfo = false;
  bool _allowWebPasswordLogin = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _showVideoDebugInfo = prefs.getBool(_showVideoDebugInfoKey) ?? false;
      _allowWebPasswordLogin = prefs.getBool(_allowWebPasswordLoginKey) ?? false;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageShell(
      title: 'Develop',
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          SettingsSectionCard(
            title: 'Diagnostic Tools',
            subtitle: 'Troubleshooting and performance',
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Show Video Debug Info'),
                  subtitle: const Text(
                    'Display technical playback details as an overlay on the video player.',
                  ),
                  value: _showVideoDebugInfo,
                  onChanged: (value) {
                    setState(() => _showVideoDebugInfo = value);
                    _saveSetting(_showVideoDebugInfoKey, value);
                    ref.read(playerStateProvider.notifier).setShowVideoDebugInfo(value);
                  },
                ),
                const Divider(height: 1),
                SettingsActionCard(
                  icon: Icons.bug_report_outlined,
                  title: 'Debug Log Viewer',
                  subtitle: 'Open a live view of in-app logs.',
                  onTap: () => context.push('/settings/logs'),
                ),
              ],
            ),
          ),
          if (kIsWeb) ...[
            const SizedBox(height: AppTheme.spacingLarge),
            SettingsSectionCard(
              title: 'Web Overrides',
              subtitle: 'Advanced flags for web platform',
              child: SwitchListTile(
                title: const Text('Allow Password Login on Web'),
                subtitle: const Text(
                  'Overrides the native-only restriction and forces the Username + Password auth method to be visible on Flutter Web.',
                ),
                value: _allowWebPasswordLogin,
                onChanged: (value) {
                  setState(() => _allowWebPasswordLogin = value);
                  _saveSetting(_allowWebPasswordLoginKey, value);
                },
              ),
            ),
          ]
        ],
      ),
    );
  }
}
