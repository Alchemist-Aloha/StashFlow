import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/presentation/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/l10n_extensions.dart';
import '../../../core/utils/environment.dart' as env;
import 'package:flutter/gestures.dart';
import '../../../core/presentation/providers/desktop_capabilities_provider.dart';
import '../../../core/presentation/providers/keybinds_provider.dart';
import '../../../core/data/graphql/graphql_client.dart';
import '../../scenes/presentation/providers/video_player_provider.dart';
import '../../scenes/presentation/providers/scene_list_provider.dart';
import '../../performers/presentation/providers/performer_list_provider.dart';
import '../../studios/presentation/providers/studio_list_provider.dart';
import '../../tags/presentation/providers/tag_list_provider.dart';
import 'package:shake_gesture/shake_gesture.dart';
import '../../galleries/presentation/providers/gallery_list_provider.dart';
import '../../scenes/presentation/widgets/tiktok_scenes_view.dart';
import '../../setup/presentation/providers/navigation_tabs_provider.dart';
import '../../setup/presentation/providers/gesture_settings_provider.dart';
import '../../setup/presentation/providers/main_page_orientation_provider.dart';
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
  DateTime? _lastHorizontalSwipeTime;
  static const _horizontalSwipeThreshold = Duration(milliseconds: 500);
  bool? _lastAppliedMainPageGravityOrientation;
  bool _wasVideoFullscreen = false;

  bool get _isDesktopPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  List<DeviceOrientation> _mainPageOrientations(bool allowGravity) {
    if (allowGravity) {
      return [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];
    }
    return [DeviceOrientation.portraitUp];
  }

  void _syncMainPageOrientations({
    required bool allowGravity,
    required bool isVideoFullScreen,
  }) {
    if (_isDesktopPlatform || kIsWeb) return;

    if (isVideoFullScreen) {
      _wasVideoFullscreen = true;
      return;
    }

    final shouldApply =
        _wasVideoFullscreen ||
        _lastAppliedMainPageGravityOrientation != allowGravity;
    if (!shouldApply) return;

    _wasVideoFullscreen = false;
    _lastAppliedMainPageGravityOrientation = allowGravity;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        SystemChrome.setPreferredOrientations(
          _mainPageOrientations(allowGravity),
        ),
      );
    });
  }

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
        title: Text(context.l10n.common_update_available),
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
            child: Text(context.l10n.common_later),
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
            child: Text(context.l10n.common_update_now),
          ),
        ],
      ),
    );
  }

  void _checkServerConfiguration() {
    if (env.isTestMode) return;
    final serverUrl = ref.read(serverUrlProvider);
    if (serverUrl.isEmpty && !_dialogShown && mounted) {
      _dialogShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.common_setup_required),
          content: const Text(
            'To get started, you need to configure your Stash server connection details.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/settings/server');
              },
              child: Text(context.l10n.common_configure_now),
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

  String _getTabLabel(NavigationTabType type) {
    switch (type) {
      case NavigationTabType.scenes:
        return context.l10n.nav_scenes;
      case NavigationTabType.performers:
        return context.l10n.nav_performers;
      case NavigationTabType.studios:
        return context.l10n.nav_studios;
      case NavigationTabType.tags:
        return context.l10n.nav_tags;
      case NavigationTabType.galleries:
        return context.l10n.nav_galleries;
    }
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
    final allowMainPageGravityOrientation = ref.watch(
      mainPageGravityOrientationProvider,
    );

    final isVideoFullScreen =
        playerState.isFullScreen ||
        isTiktokFullScreen ||
        currentPath.contains('/fullscreen');
    _syncMainPageOrientations(
      allowGravity: allowMainPageGravityOrientation,
      isVideoFullScreen: isVideoFullScreen,
    );

    // Consider we are in fullscreen if the provider says so, OR if we are on a known fullscreen path.
    // This provides a more immediate UI response during route transitions.
    final isFullscreenPath =
        currentPath.contains('/fullscreen') ||
        currentPath.contains('/image/') ||
        currentPath.contains('/images/') ||
        currentPath.startsWith('/image/') ||
        currentPath.startsWith('/images/');

    final isFullScreen =
        playerState.isFullScreen || isTiktokFullScreen || isFullscreenPath;
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

      // Provide haptic feedback when shake is detected
      HapticFeedback.mediumImpact();

      // IMPORTANT: navigationShell.currentIndex refers to the index in the
      // static branches list in router.dart, which corresponds to NavigationTabType.values.
      // We must NOT use allTabs[currentIndex] because allTabs can be reordered by the user.
      final currentTabType =
          NavigationTabType.values[navigationShell.currentIndex];

      switch (currentTabType) {
        case NavigationTabType.scenes:
          final random = await ref
              .read(sceneListProvider.notifier)
              .getRandomScene();
          if (mounted && context.mounted && random != null) {
            context.push('/scenes/scene/${random.id}');
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
            label: _getTabLabel(t.type),
          ),
        )
        .toList();

    final navigationRailDestinations = visibleTabs
        .map(
          (t) => NavigationRailDestination(
            icon: Icon(t.type.icon),
            label: Text(_getTabLabel(t.type)),
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
            labelType: NavigationRailLabelType.selected,
            useIndicator: true,
            indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            destinations: navigationRailDestinations,
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: bodyContent),
        ],
      );
    }

    if (ref.watch(desktopCapabilitiesProvider)) {
      final Map<ShortcutActivator, VoidCallback> bindings = {};
      final keybinds = ref.watch(keybindsProvider);

      final digitKeys = [
        LogicalKeyboardKey.digit1,
        LogicalKeyboardKey.digit2,
        LogicalKeyboardKey.digit3,
        LogicalKeyboardKey.digit4,
        LogicalKeyboardKey.digit5,
        LogicalKeyboardKey.digit6,
        LogicalKeyboardKey.digit7,
        LogicalKeyboardKey.digit8,
        LogicalKeyboardKey.digit9,
      ];
      for (int i = 0; i < visibleTabs.length && i < digitKeys.length; i++) {
        final index = i;
        bindings[SingleActivator(digitKeys[i])] = () =>
            onDestinationSelected(index);
      }

      // Add back bind
      final backBind = keybinds.binds[KeybindAction.back];
      if (backBind != null) {
        bindings[backBind.toActivator()] = () {
          if (context.canPop()) {
            context.pop();
          }
        };
      }

      bodyContent = CallbackShortcuts(
        bindings: bindings,
        child: Focus(autofocus: true, child: bodyContent),
      );
    }

    final isDesktop = ref.watch(desktopCapabilitiesProvider);

    return PopScope(
      canPop: !context.canPop(),
      child: ShakeGesture(
        onShake: handleShake,
        child: Scaffold(
          body: Listener(
            onPointerSignal: (pointerSignal) {
              if (isDesktop && pointerSignal is PointerScrollEvent) {
                if (pointerSignal.scrollDelta.dx.abs() > 30) {
                  final now = DateTime.now();
                  if (_lastHorizontalSwipeTime == null ||
                      now.difference(_lastHorizontalSwipeTime!) >
                          _horizontalSwipeThreshold) {
                    if (pointerSignal.scrollDelta.dx < -30) {
                      // Swipe Right (negative dx) -> Go Back
                      if (context.canPop()) {
                        _lastHorizontalSwipeTime = now;
                        context.pop();
                      }
                    } else if (pointerSignal.scrollDelta.dx > 30) {
                      // Swipe Left (positive dx) -> Go Forward (if possible)
                      // GoRouter doesn't have a simple goForward,
                      // but we can at least support Back for now as it's most expected.
                    }
                  }
                }
              }
            },
            child: bodyContent,
          ),
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
                          labelBehavior: NavigationDestinationLabelBehavior
                              .alwaysShow,
                          height: 72,
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
