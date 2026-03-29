import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

class SupportSettingsPage extends ConsumerWidget {
  const SupportSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingSmall),
        children: [
          _buildSectionHeader(context, 'Diagnostics'),
          ListTile(
            leading: const Icon(Icons.bug_report_outlined),
            title: const Text('Debug Log Viewer'),
            subtitle: const Text('Open a live view of in-app logs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/logs'),
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          _buildSectionHeader(context, 'About'),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('GitHub Repository'),
            subtitle: const Text('View source code and report issues'),
            trailing: const Icon(Icons.open_in_new, size: 20),
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: AppTheme.spacingSmall, top: AppTheme.spacingSmall),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
