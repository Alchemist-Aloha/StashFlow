import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/mini_player.dart';

class ShellPage extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final hideMiniPlayer = currentPath.startsWith('/scene/');
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          if (!hideMiniPlayer) const MiniPlayer(),
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
          ],
        ),
      ),
    );
  }
}
