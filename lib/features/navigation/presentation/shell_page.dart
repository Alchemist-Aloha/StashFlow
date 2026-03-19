import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../scenes/presentation/providers/scene_list_provider.dart';
import 'widgets/mini_player.dart';

class ShellPage extends ConsumerWidget {
  final Widget child;
  const ShellPage({required this.child, super.key});

  int _selectedIndexForPath(String path) {
    if (path.startsWith('/settings')) return 4;
    if (path.startsWith('/performers')) return 1;
    if (path.startsWith('/studios')) return 2;
    if (path.startsWith('/tags')) return 3;
    return 0;
  }

  String _routeForIndex(int index) {
    switch (index) {
      case 0:
        return '/scenes';
      case 1:
        return '/performers';
      case 2:
        return '/studios';
      case 3:
        return '/tags';
      case 4:
        return '/settings';
      default:
        return '/scenes';
    }
  }

  Future<void> _surpriseMe(BuildContext context, WidgetRef ref) async {
    final randomScene = await ref
        .read(sceneListProvider.notifier)
        .getRandomScene();
    if (!context.mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No scenes available for Surprise Me yet'),
        ),
      );
      return;
    }

    context.push('/scene/${randomScene.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: NavigationBar(
                selectedIndex: _selectedIndexForPath(currentPath),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(
                    icon: Icon(Icons.people),
                    label: 'Performers',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.business),
                    label: 'Studios',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.local_offer),
                    label: 'Tags',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
                onDestinationSelected: (index) {
                  context.go(_routeForIndex(index));
                },
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              onSelected: (value) {
                if (value == 'surprise') {
                  _surpriseMe(context, ref);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'surprise',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.casino_outlined),
                    title: Text('Surprise Me'),
                  ),
                ),
              ],
              child: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.more_vert),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
