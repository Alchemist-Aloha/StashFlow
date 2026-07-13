import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

import '../providers/video_player_provider.dart';
import '../providers/fullscreen_controller.dart';
import '../providers/scene_random_navigation_provider.dart';
import 'player_surface.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/web_helpers.dart';
import '../../../setup/presentation/providers/main_page_orientation_provider.dart';
import '../../../../core/utils/l10n_extensions.dart';

class GlobalFullscreenOverlay extends ConsumerStatefulWidget {
  const GlobalFullscreenOverlay({super.key});

  @override
  ConsumerState<GlobalFullscreenOverlay> createState() =>
      _GlobalFullscreenOverlayState();
}

class _GlobalFullscreenOverlayState
    extends ConsumerState<GlobalFullscreenOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  bool _isVisible = false;
  bool _isAnimating = false;

  bool _wasMaximizedBeforeFullscreen = false;
  bool _wasPlayingBeforeExit = false;
  VideoController? _currentListenedController;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut,
          ),
        );

    // Check initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final phase = ref.read(
        playerStateProvider.select((s) => s.fullscreenPhase),
      );
      if (phase == FullscreenPhase.entering ||
          phase == FullscreenPhase.fullscreen) {
        _onFullScreenChanged(true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void _onControllerUpdate() {
    if (_isVisible && _currentListenedController != null) {
      _wasPlayingBeforeExit = _currentListenedController!.player.state.playing;
    }
  }

  void _onFullScreenChanged(bool isFullScreen) {
    if (!mounted) return;

    if (isFullScreen && !_isVisible) {
      AppLogStore.instance.add(
        'GlobalFullscreenOverlay: showing overlay',
        source: 'GlobalFullscreenOverlay',
      );
      setState(() {
        _isVisible = true;
        _isAnimating = true;
      });
      _animationController.forward().then((_) {
        if (mounted) setState(() => _isAnimating = false);
      });
      _enterFullScreen().then((_) {
        if (mounted) {
          ref.read(playerStateProvider.notifier).markFullscreenEntered();
        }
      });
    } else if (!isFullScreen && _isVisible) {
      AppLogStore.instance.add(
        'GlobalFullscreenOverlay: hiding overlay',
        source: 'GlobalFullscreenOverlay',
      );
      setState(() => _isAnimating = true);
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
            _isAnimating = false;
          });
        }
      });
      _exitFullScreen();
      ref.read(playerStateProvider.notifier).markFullscreenExited();
    }
  }

  Future<void> _enterFullScreen() async {
    final playerState = ref.read(playerStateProvider);
    final controller = playerState.videoController;
    final wasPlaying = playerState.player?.state.playing ?? false;

    AppLogStore.instance.add(
      'GlobalFullscreenOverlay: _enterFullScreen: controller=${controller != null} wasPlaying=$wasPlaying',
      source: 'GlobalFullscreenOverlay',
    );

    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.linux ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        _wasMaximizedBeforeFullscreen = await windowManager.isMaximized();

        if (_wasMaximizedBeforeFullscreen) {
          await windowManager.unmaximize();
        }

        await windowManager.setFullScreen(true);

        if (!await windowManager.isFullScreen()) {
          await windowManager.setFullScreen(true);
        }

        if (wasPlaying && defaultTargetPlatform == TargetPlatform.windows) {
          if (controller != null && !controller.player.state.playing) {
            unawaited(controller.player.play());
          }
        }
      } else {
        final playerState = ref.read(playerStateProvider);
        final width = controller?.player.state.width;
        final height = controller?.player.state.height;
        final aspectRatio = (width != null && height != null && height > 0)
            ? width / height
            : 16 / 9;
        final allowGravity = playerState.videoGravityOrientation;

        List<DeviceOrientation> orientations;
        if (aspectRatio > 1.0) {
          orientations = allowGravity
              ? [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]
              : [DeviceOrientation.landscapeLeft];
        } else {
          orientations = allowGravity
              ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
              : [DeviceOrientation.portraitUp];
        }

        await SystemChrome.setPreferredOrientations(orientations);

        if (wasPlaying && kIsWeb) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (controller != null && !controller.player.state.playing) {
              unawaited(controller.player.play());
            }
          });
        }
      }
    } catch (e) {
      AppLogStore.instance.add(
        'GlobalFullscreenOverlay: error entering fullscreen: $e',
        source: 'GlobalFullscreenOverlay',
      );
    }
  }

  void _exitFullScreen() {
    final controller = ref.read(playerStateProvider).videoController;
    final wasPlaying = _wasPlayingBeforeExit;

    AppLogStore.instance.add(
      'GlobalFullscreenOverlay: _exitFullScreen: wasPlayingBeforeExit=$wasPlaying',
      source: 'GlobalFullscreenOverlay',
    );

    unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      unawaited(() async {
        await windowManager.setFullScreen(false);

        if (_wasMaximizedBeforeFullscreen) {
          await windowManager.maximize();
          _wasMaximizedBeforeFullscreen = false;
        }

        if (wasPlaying &&
            (kIsWeb || defaultTargetPlatform == TargetPlatform.windows)) {
          if (controller != null && !controller.player.state.playing) {
            await controller.player.play();
          }
        }
      }());
    } else {
      final allowMainPageGravityOrientation = ref.read(
        mainPageGravityOrientationProvider,
      );
      unawaited(() async {
        await SystemChrome.setPreferredOrientations(
          allowMainPageGravityOrientation
              ? [
                  DeviceOrientation.portraitUp,
                  DeviceOrientation.portraitDown,
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]
              : [DeviceOrientation.portraitUp],
        );

        if (wasPlaying && kIsWeb) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (controller != null && !controller.player.state.playing) {
              unawaited(controller.player.play());
            }
          });
        }
      }());
    }
  }

  Future<void> _toggleFullScreen() async {
    if (!mounted) return;

    if (kIsWeb) {
      unawaited(exitWebFullScreen());
    }

    final notifier = ref.read(playerStateProvider.notifier);

    // Synchronize background to active scene before exiting
    notifier.syncBackgroundToActiveScene(context);

    // Trigger the hide animation and state change
    notifier.requestExitFullscreen();
  }

  Future<void> _openRandomScene(String currentSceneId) async {
    final randomScene = await ref
        .read(sceneRandomNavigationControllerProvider)
        .getRandomScene(excludeSceneId: currentSceneId);
    if (!mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.scenes_no_random)));
      return;
    }

    GoRouter.of(context).push('/scenes/scene/${randomScene.id}', extra: true);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<FullscreenPhase>(
      playerStateProvider.select((s) => s.fullscreenPhase),
      (previous, next) {
        final shouldShow =
            next == FullscreenPhase.entering ||
            next == FullscreenPhase.fullscreen;
        _onFullScreenChanged(shouldShow);
      },
    );

    final bool showOverlay = _isVisible || _isAnimating;

    // Avoid eagerly initializing cast discovery/session infrastructure
    // while overlay is hidden; this keeps app startup lighter.
    if (!showOverlay) {
      return const IgnorePointer(
        ignoring: true,
        child: Visibility(
          visible: false,
          maintainState: false,
          child: SizedBox.shrink(),
        ),
      );
    }

    final playerState = ref.watch(playerStateProvider);
    final scene = playerState.activeScene;
    final controller = playerState.videoController;

    if (controller != _currentListenedController) {
      if (_currentListenedController != null) {
        for (final sub in _subscriptions) {
          sub.cancel();
        }
        _subscriptions.clear();
      }
      _currentListenedController = controller;
      if (controller != null) {
        _subscriptions.add(
          controller.player.stream.playing.listen((_) => _onControllerUpdate()),
        );
      }
      if (controller != null && _isVisible) {
        _wasPlayingBeforeExit = controller.player.state.playing;
      }
    }

    Widget content;
    if (scene == null || controller == null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              context.l10n.initializing_player,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    } else {
      content = PlayerSurface(
        scene: scene,
        controller: controller,
        onFullScreenToggle: _toggleFullScreen,
        onRandomScene: () => _openRandomScene(scene.id),
        fit: BoxFit.contain,
        squareFit: BoxFit.fill,
      );
    }

    return IgnorePointer(
      ignoring: false,
      child: Visibility(
        visible: true,
        maintainState: false,
        child: SlideTransition(
          key: const ValueKey('global_fullscreen_overlay_slide'),
          position: _offsetAnimation,
          child: Material(color: Colors.black, child: content),
        ),
      ),
    );
  }
}
