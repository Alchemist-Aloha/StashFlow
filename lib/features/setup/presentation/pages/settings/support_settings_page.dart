import 'package:flutter/material.dart';
import '../../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import '../../widgets/settings_page_shell.dart';
import '../../providers/update_provider.dart';

class SupportSettingsPage extends ConsumerWidget {
  const SupportSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SettingsPageShell(
      title: l10n.settings_support_title,
      child: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          Text(
            l10n.settings_support_diagnostics,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settings_support_diagnostics_subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLarge),

          // Update check section
          ref
              .watch(appUpdateProvider)
              .when(
                data: (updateInfo) {
                  if (updateInfo != null && updateInfo.isUpdateAvailable) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingsSectionCard(
                          title: l10n.settings_support_update_available,
                          subtitle:
                              l10n.settings_support_update_available_subtitle,
                          child: SettingsActionCard(
                            icon: Icons.system_update_rounded,
                            title: l10n.settings_support_update_to(
                              updateInfo.latestVersion,
                            ),
                            subtitle: l10n.settings_support_update_to_subtitle,
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
            title: l10n.settings_support_about,
            subtitle: l10n.settings_support_about_subtitle,
            child: Column(
              children: [
                ref
                    .watch(appVersionProvider)
                    .when(
                      data: (version) => SettingsActionCard(
                        icon: Icons.info_outline_rounded,
                        title: l10n.settings_support_version,
                        subtitle: '${l10n.appTitle} $version',
                        onTap: () async {
                          final url = Uri.parse('https://github.com/Alchemist-Aloha/StashFlow/releases');
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
                      loading: () => SettingsActionCard(
                        icon: Icons.info_outline_rounded,
                        title: l10n.settings_support_version,
                        subtitle: l10n.settings_support_version_loading,
                        onTap: () {},
                      ),
                      error: (err, stack) => SettingsActionCard(
                        icon: Icons.info_outline_rounded,
                        title: l10n.settings_support_version,
                        subtitle: l10n.settings_support_version_unavailable,
                        onTap: () {},
                      ),
                    ),
                const SizedBox(height: AppTheme.spacingSmall),
                SettingsActionCard(
                  icon: Icons.code_rounded,
                  title: l10n.settings_support_github,
                  subtitle: l10n.settings_support_github_subtitle,
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
                            SnackBar(
                              content: Text(l10n.settings_support_github_error),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.l10n.common_error(e.toString()),
                            ),
                          ),
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
