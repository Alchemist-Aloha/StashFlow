import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../../../../../core/presentation/providers/desktop_capabilities_provider.dart';

import '../../widgets/settings_page_shell.dart';

class SettingsHubPage extends ConsumerWidget {
  const SettingsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ref.watch(desktopCapabilitiesProvider);
    final l10n = AppLocalizations.of(context)!;

    return SettingsPageShell(
      title: l10n.settings_title,
      child: SettingsPageBody(
        child: SettingsSectionCard(
          title: l10n.settings_core_section,
          subtitle: l10n.settings_core_subtitle,
          wrapInPanel: false,
          child: SettingsPanelGroup(
            children: [
              SettingsActionCard(
                icon: Icons.dns_rounded,
                title: l10n.settings_server,
                subtitle: l10n.settings_server_subtitle,
                onTap: () => context.push('/settings/server'),
              ),
              SettingsActionCard(
                icon: Icons.play_circle_fill_rounded,
                title: l10n.settings_playback,
                subtitle: l10n.settings_playback_subtitle,
                onTap: () => context.push('/settings/playback'),
              ),
              if (isDesktop)
                SettingsActionCard(
                  icon: Icons.keyboard_rounded,
                  title: l10n.settings_keyboard,
                  subtitle: l10n.settings_keyboard_subtitle,
                  onTap: () => context.push('/settings/keybinds'),
                ),
              SettingsActionCard(
                icon: Icons.palette_rounded,
                title: l10n.settings_appearance,
                subtitle: l10n.settings_appearance_subtitle,
                onTap: () => context.push('/settings/appearance'),
              ),
              SettingsActionCard(
                icon: Icons.dashboard_customize_rounded,
                title: l10n.settings_interface,
                subtitle: l10n.settings_interface_subtitle,
                onTap: () => context.push('/settings/interface'),
              ),
              SettingsActionCard(
                icon: Icons.lock_outline_rounded,
                title: l10n.settings_security_title,
                subtitle: l10n.settings_security_subtitle,
                onTap: () => context.push('/settings/security'),
              ),
              SettingsActionCard(
                icon: Icons.storage_rounded,
                title: l10n.settings_storage,
                subtitle: l10n.settings_storage_subtitle,
                onTap: () => context.push('/settings/storage'),
              ),
              SettingsActionCard(
                icon: Icons.help_outline_rounded,
                title: l10n.settings_support,
                subtitle: l10n.settings_support_subtitle,
                onTap: () => context.push('/settings/support'),
              ),
              SettingsActionCard(
                icon: Icons.developer_mode_rounded,
                title: l10n.settings_develop,
                subtitle: l10n.settings_develop_subtitle,
                onTap: () => context.push('/settings/develop'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
