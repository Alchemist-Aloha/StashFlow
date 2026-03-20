import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/mini_player.dart';

class ShellPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const ShellPage({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isDetailPage = currentPath.contains('/scene/') ||
        currentPath.contains('/performer/') ||
        currentPath.contains('/studio/') ||
        currentPath.contains('/tag/') ||
        currentPath.contains('/gallery/') ||
        currentPath.contains('/group/');

    final hideMiniPlayer = currentPath.startsWith('/scene/');

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: navigationShell),
          if (!hideMiniPlayer && !isDetailPage) const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: isDetailPage
          ? null
          : SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: NavigationBar(
                      selectedIndex: navigationShell.currentIndex,
                      destinations: const [
                        NavigationDestination(
                          icon: Icon(Icons.video_library),
                          label: 'Scenes',
                        ),
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
                        navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
