import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/data/graphql/graphql_client.dart';
import '../../scenes/presentation/providers/video_player_provider.dart';
import '../../scenes/presentation/providers/scene_list_provider.dart';
import '../../scenes/presentation/providers/playback_queue_provider.dart';
import '../../performers/presentation/providers/performer_list_provider.dart';
import '../../studios/presentation/providers/studio_list_provider.dart';
import '../../tags/presentation/providers/tag_list_provider.dart';
import 'dart:math';
import 'package:shake_gesture/shake_gesture.dart';
import '../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../scenes/presentation/widgets/tiktok_scenes_view.dart';
import '../../setup/presentation/providers/navigation_tabs_provider.dart';
import '../../setup/presentation/providers/gesture_settings_provider.dart';
import '../../setup/presentation/providers/update_provider.dart';
import '../../setup/domain/entities/update_info.dart';
import 'widgets/mini_player.dart';

class ShellPage extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  const ShellPage({required this.navigationShell, super.key});

  @override
  ConsumerState<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends ConsumerState<ShellPage> {
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServerConfiguration();
    });
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A new version of StashFlow (${updateInfo.latestVersion}) is available.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Would you like to visit the release page to download it?',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(startupUpdateCheckProvider.notifier).markChecked();
              Navigator.pop(context);
            },
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () async {
              final url = Uri.parse(updateInfo.releaseUrl);
              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              } catch (_) {}
              if (context.mounted) {
                ref.read(startupUpdateCheckProvider.notifier).markChecked();
                Navigator.pop(context);
              }
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  void _checkServerConfiguration() {
    final serverUrl = ref.read(serverUrlProvider);
    if (serverUrl.isEmpty && !_dialogShown && mounted) {
      _dialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Setup Required'),
          content: const Text(
            'To get started, you need to configure your Stash server connection details.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/settings/server');
              },
              child: const Text('Configure Now'),
            ),
          ],
        ),
      );
    }
  }

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
  Widget build(BuildContext context) {
    ref.listen(startupUpdateCheckProvider, (previous, next) {
      next.whenData((updateInfo) {
        if (updateInfo != null && updateInfo.isUpdateAvailable && mounted) {
          _showUpdateDialog(updateInfo);
        }
      });
    });

    final navigationShell = widget.navigationShell;
    final currentPath = GoRouterState.of(context).uri.path;
    final playerState = ref.watch(playerStateProvider);
    final activeSceneId = playerState.activeScene?.id;
    final pathSceneId = _extractSceneIdFromPath(currentPath);
    final isTiktokFullScreen = ref.watch(fullScreenModeProvider);
    final isFullScreen = playerState.isFullScreen || isTiktokFullScreen;
    final isTiktokLayout = ref.watch(sceneTiktokLayoutProvider);
    final isMobile = Responsive.isMobile(context);
    final shakeEnabled = ref.watch(shakeToRandomEnabledProvider);

    final allTabs = ref.watch(navigationTabsProvider);
    final visibleTabs = allTabs.where((t) => t.visible).toList();

    // Map branch index to UI index for the NavigationBar/Rail
    final branchToUiMap = <int, int>{};
    for (var i = 0; i < visibleTabs.length; i++) {
      final branchIndex = visibleTabs[i].type.index;
      branchToUiMap[branchIndex] = i;
    }

    final currentUiIndex = branchToUiMap[navigationShell.currentIndex] ?? 0;

    final onScenesPage = currentPath == '/scenes';

    final hideMiniPlayer =
        (activeSceneId != null &&
            pathSceneId != null &&
            activeSceneId == pathSceneId) ||
        isFullScreen ||
        (isTiktokLayout && onScenesPage);

    void onDestinationSelected(int uiIndex) {
      final tab = visibleTabs[uiIndex];
      final branchIndex = tab.type.index;

      if (branchIndex == navigationShell.currentIndex) {
        switch (tab.type) {
          case NavigationTabType.scenes:
            final isTiktokLayout = ref.read(sceneTiktokLayoutProvider);
            if (!isTiktokLayout) {
              ref.read(sceneScrollControllerProvider.notifier).scrollToTop();
            }
            break;
          case NavigationTabType.performers:
            ref.read(performerScrollControllerProvider.notifier).scrollToTop();
            break;
          case NavigationTabType.studios:
            ref.read(studioScrollControllerProvider.notifier).scrollToTop();
            break;
          case NavigationTabType.tags:
            ref.read(tagScrollControllerProvider.notifier).scrollToTop();
            break;
          case NavigationTabType.galleries:
            ref.read(galleryScrollControllerProvider.notifier).scrollToTop();
            break;
        }
      }
      navigationShell.goBranch(
        branchIndex,
        initialLocation: branchIndex == navigationShell.currentIndex,
      );
    }

    Future<void> handleShake() async {
      if (!shakeEnabled || !mounted) return;

      final currentTab = allTabs[navigationShell.currentIndex];
      switch (currentTab.type) {
        case NavigationTabType.scenes:
          final scenes = ref.read(sceneListProvider).value ?? [];
          if (scenes.isNotEmpty) {
            final index = Random().nextInt(scenes.length);
            ref.read(playbackQueueProvider.notifier).setIndex(index);
            context.push('/scenes/scene/${scenes[index].id}');
          }
          break;
        case NavigationTabType.performers:
          final random = await ref
              .read(performerListProvider.notifier)
              .getRandomPerformer();
          if (mounted && context.mounted && random != null) {
            context.push('/performers/performer/${random.id}');
          }
          break;
        case NavigationTabType.studios:
          final random = await ref
              .read(studioListProvider.notifier)
              .getRandomStudio();
          if (mounted && context.mounted && random != null) {
            context.push('/studios/studio/${random.id}');
          }
          break;
        case NavigationTabType.tags:
          final random = await ref
              .read(tagListProvider.notifier)
              .getRandomTag();
          if (mounted && context.mounted && random != null) {
            context.push('/tags/tag/${random.id}');
          }
          break;
        case NavigationTabType.galleries:
          final random = await ref
              .read(galleryListProvider.notifier)
              .getRandomGallery();
          if (mounted && context.mounted && random != null) {
            context.push('/galleries/gallery/${random.id}');
          }
          break;
      }
    }

    final navigationDestinations = visibleTabs
        .map(
          (t) => NavigationDestination(
            icon: Icon(t.type.icon),
            label: t.type.label,
          ),
        )
        .toList();

    final navigationRailDestinations = visibleTabs
        .map(
          (t) => NavigationRailDestination(
            icon: Icon(t.type.icon),
            label: Text(t.type.label),
          ),
        )
        .toList();

    Widget bodyContent = Column(
      children: [
        Expanded(child: RepaintBoundary(child: navigationShell)),
        if (!hideMiniPlayer) const MiniPlayer(),
      ],
    );

    if (!isMobile && !isFullScreen) {
      bodyContent = Row(
        children: [
          NavigationRail(
            selectedIndex: currentUiIndex,
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
      child: ShakeGesture(
        onShake: handleShake,
        child: Scaffold(
          body: bodyContent,
          bottomNavigationBar: (isFullScreen || !isMobile)
              ? null
              : SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: NavigationBar(
                          selectedIndex: currentUiIndex,
                          destinations: navigationDestinations,
                          onDestinationSelected: onDestinationSelected,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
