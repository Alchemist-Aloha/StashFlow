import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/responsive.dart';
import '../../scenes/presentation/providers/video_player_provider.dart';
import '../../scenes/presentation/providers/scene_list_provider.dart';
import '../../performers/presentation/providers/performer_list_provider.dart';
import '../../studios/presentation/providers/studio_list_provider.dart';
import '../../tags/presentation/providers/tag_list_provider.dart';
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
    final isMobile = Responsive.isMobile(context);
    
    final onScenesPage = currentPath == '/scenes';
    
    final hideMiniPlayer =
        (activeSceneId != null &&
        pathSceneId != null &&
        activeSceneId == pathSceneId) || 
        isFullScreen ||
        (isTiktokLayout && onScenesPage);

    void onDestinationSelected(int index) {
      if (index == navigationShell.currentIndex) {
        switch (index) {
          case 0:
            final isTiktokLayout = ref.read(sceneTiktokLayoutProvider);
            if (!isTiktokLayout) {
              ref.read(sceneScrollControllerProvider.notifier).scrollToTop();
            }
            break;
          case 1:
            ref.read(performerScrollControllerProvider.notifier).scrollToTop();
            break;
          case 2:
            ref.read(studioScrollControllerProvider.notifier).scrollToTop();
            break;
          case 3:
            ref.read(tagScrollControllerProvider.notifier).scrollToTop();
            break;
        }
      }
      navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );
    }

    final navigationDestinations = const [
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
    ];

    final navigationRailDestinations = const [
      NavigationRailDestination(
        icon: Icon(Icons.video_library),
        label: Text('Scenes'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.people),
        label: Text('Performers'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.business),
        label: Text('Studios'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.local_offer),
        label: Text('Tags'),
      ),
      NavigationRailDestination(
        icon: Icon(Icons.settings),
        label: Text('Settings'),
      ),
    ];

    Widget bodyContent = Column(
      children: [
        Expanded(child: navigationShell),
        if (!hideMiniPlayer) const MiniPlayer(),
      ],
    );

    if (!isMobile && !isFullScreen) {
      bodyContent = Row(
        children: [
          NavigationRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            destinations: navigationRailDestinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: bodyContent),
        ],
      );
    }

    return PopScope(
      canPop: !context.canPop(),
      child: Scaffold(
        body: bodyContent,
        bottomNavigationBar: (isFullScreen || !isMobile) ? null : SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  destinations: navigationDestinations,
                  onDestinationSelected: onDestinationSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
