import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import '../../widgets/settings_page_shell.dart';
import '../../providers/update_provider.dart';

class SupportSettingsPage extends ConsumerWidget {
  const SupportSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsPageShell(
      title: 'Support',
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          Text(
            'Diagnostics and project info',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'Open runtime logs or jump to the repository when you need help.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Update check section
          ref.watch(appUpdateProvider).when(
            data: (updateInfo) {
              if (updateInfo != null && updateInfo.isUpdateAvailable) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SettingsSectionCard(
                      title: 'Update Available',
                      subtitle: 'A newer version is available on GitHub',
                      child: SettingsActionCard(
                        icon: Icons.system_update_rounded,
                        title: 'Update to ${updateInfo.latestVersion}',
                        subtitle:
                            'New features and improvements are waiting for you.',
                        trailing: const Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                        ),
                        onTap: () async {
                          final url = Uri.parse(updateInfo.releaseUrl);
                          try {
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          } catch (_) {}
                        },
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),

          SettingsSectionCard(
            title: 'Diagnostics',
            subtitle: 'Tools for troubleshooting the app',
            child: SettingsActionCard(
              icon: Icons.bug_report_outlined,
              title: 'Debug Log Viewer',
              subtitle: 'Open a live view of in-app logs',
              onTap: () => context.push('/settings/logs'),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          SettingsSectionCard(
            title: 'About',
            subtitle: 'Project and source information',
            child: Column(
              children: [
                ref.watch(appVersionProvider).when(
                  data: (version) => SettingsActionCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    subtitle: 'StashFlow $version',
                    onTap: () {},
                  ),
                  loading: () => SettingsActionCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    subtitle: 'Loading version info...',
                    onTap: () {},
                  ),
                  error: (err, stack) => SettingsActionCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    subtitle: 'Version info unavailable',
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                SettingsActionCard(
                  icon: Icons.code_rounded,
                  title: 'GitHub Repository',
                  subtitle: 'View source code and report issues',
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () async {
                    final url = Uri.parse(
                      'https://github.com/Alchemist-Aloha/StashFlow',
                    );
                    try {
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open GitHub link'),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
