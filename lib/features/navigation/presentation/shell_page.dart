import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/mini_player.dart';

class ShellPage extends StatelessWidget {
  final Widget child;
  const ShellPage({required this.child, super.key});

  int _selectedIndexForPath(String path) {
    if (path.startsWith('/settings')) return 4;
    if (path.startsWith('/explore')) return 1;
    if (path.startsWith('/subscriptions')) return 2;
    if (path.startsWith('/library')) return 3;
    return 0;
  }

  String _routeForIndex(int index) {
    switch (index) {
      case 4:
        return '/settings';
      case 0:
      case 1:
      case 2:
      case 3:
      default:
        return '/scenes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndexForPath(currentPath),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.subscriptions), label: 'Subscriptions'),
          NavigationDestination(icon: Icon(Icons.video_library), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onDestinationSelected: (index) {
          context.go(_routeForIndex(index));
        },
      ),
    );
  }
}
