import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

import '../../widgets/settings_page_shell.dart';

class SettingsHubPage extends ConsumerWidget {
  const SettingsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsPageShell(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          Text(
            'Customize StashFlow',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Tune playback, appearance, layout, and support tools from one place.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          SettingsSectionCard(
            title: 'Core settings',
            subtitle: 'Most-used configuration pages',
            child: Column(
              children: [
                SettingsActionCard(
                  icon: Icons.dns_rounded,
                  title: 'Server',
                  subtitle: 'Connection and API configuration',
                  onTap: () => context.push('/settings/server'),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SettingsActionCard(
                  icon: Icons.play_circle_fill_rounded,
                  title: 'Playback',
                  subtitle: 'Player behavior and interactions',
                  onTap: () => context.push('/settings/playback'),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SettingsActionCard(
                  icon: Icons.palette_rounded,
                  title: 'Appearance',
                  subtitle: 'Theme and colors',
                  onTap: () => context.push('/settings/appearance'),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SettingsActionCard(
                  icon: Icons.dashboard_customize_rounded,
                  title: 'Interface',
                  subtitle: 'Navigation and layout defaults',
                  onTap: () => context.push('/settings/interface'),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SettingsActionCard(
                  icon: Icons.help_outline_rounded,
                  title: 'Support',
                  subtitle: 'Diagnostics and about',
                  onTap: () => context.push('/settings/support'),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SettingsActionCard(
                  icon: Icons.developer_mode_rounded,
                  title: 'Develop',
                  subtitle: 'Advanced tools and overrides',
                  onTap: () => context.push('/settings/develop'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
