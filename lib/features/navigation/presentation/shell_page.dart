import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../scenes/presentation/providers/video_player_provider.dart';
import '../../scenes/presentation/providers/scene_list_provider.dart';
import '../../scenes/presentation/widgets/tiktok_scenes_view.dart';
import 'widgets/mini_player.dart';

class ShellPage extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const ShellPage({required this.navigationShell, super.key});

  String? _extractSceneIdFromPath(String path) {
    if (path.startsWith('/scenes/scene/')) {
      final segments = Uri.parse(path).pathSegments;
      return segments.length >= 3 ? segments[2] : null;
    }
    if (path.startsWith('/scene/')) {
      final segments = Uri.parse(path).pathSegments;
      return segments.length >= 2 ? segments[1] : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    final playerState = ref.watch(playerStateProvider);
    final activeSceneId = playerState.activeScene?.id;
    final pathSceneId = _extractSceneIdFromPath(currentPath);
    final isTiktokFullScreen = ref.watch(fullScreenModeProvider);
    final isFullScreen = playerState.isFullScreen || isTiktokFullScreen;
    final isTiktokLayout = ref.watch(sceneTiktokLayoutProvider);
    
    final onScenesPage = currentPath == '/scenes';
    
    final hideMiniPlayer =
        (activeSceneId != null &&
        pathSceneId != null &&
        activeSceneId == pathSceneId) || 
        isFullScreen ||
        (isTiktokLayout && onScenesPage);

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: navigationShell),
          if (!hideMiniPlayer) const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: isFullScreen ? null : SafeArea(
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
