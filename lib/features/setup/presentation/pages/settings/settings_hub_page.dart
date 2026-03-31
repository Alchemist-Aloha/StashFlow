import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsHubPage extends ConsumerWidget {
  const SettingsHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dns),
            title: const Text('Server'),
            subtitle: const Text('Connection and API configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/server'),
          ),
          ListTile(
            leading: const Icon(Icons.play_circle),
            title: const Text('Playback'),
            subtitle: const Text('Player behavior and interactions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/playback'),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Appearance'),
            subtitle: const Text('Theme and colors'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/appearance'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Interface'),
            subtitle: const Text('Navigation and layout defaults'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/interface'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Support'),
            subtitle: const Text('Diagnostics and about'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/support'),
          ),
        ],
      ),
    );
  }
}
