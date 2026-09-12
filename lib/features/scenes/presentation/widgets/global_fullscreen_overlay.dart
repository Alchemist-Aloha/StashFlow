import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../providers/video_player_provider.dart';
import '../providers/player_view_mode.dart';
import '../providers/scene_list_provider.dart';
import 'player_surface.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/desktop_fullscreen.dart';
import '../../../../core/utils/responsive.dart';
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  bool _isVisible = false;
  bool _isAnimating = false;
  Future<void> _orientationSync = Future<void>.value();
  List<DeviceOrientation>? _lastFullscreenOrientations;

  bool _wasPlayingBeforeExit = false;
  VideoController? _currentListenedController;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    unawaited(_queueOrientationSync());
  }

  void _onControllerUpdate() {
    if (_isVisible && _currentListenedController != null) {
      _wasPlayingBeforeExit = _currentListenedController!.player.state.playing;
    }
  }

  bool get _usesDesktopFullscreen =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<void> _queueOrientationSync() {
    _orientationSync = _orientationSync.then((_) async {
      try {
        await _syncFullscreenOrientation();
      } catch (error, stackTrace) {
        AppLogStore.instance.add(
          'GlobalFullscreenOverlay: error syncing fullscreen orientation: '
          '$error\n$stackTrace',
          source: 'GlobalFullscreenOverlay',
        );
      }
    });
    return _orientationSync;
  }

  Future<void> _syncFullscreenOrientation() async {
    if (!mounted || kIsWeb || _usesDesktopFullscreen) return;

    final phase = ref.read(playerStateProvider).fullscreenPhase;
    if (phase != FullscreenPhase.entering &&
        phase != FullscreenPhase.fullscreen) {
      return;
    }

    final view = View.maybeOf(context);
    if (view == null) return;

    final state = ref.read(playerStateProvider);
    final isPhone =
        view.display.size.shortestSide / view.display.devicePixelRatio <
        Responsive.mobileBreakpoint;
    double? aspectRatio;

    final controllerWidth = state.videoController?.player.state.width;
    final controllerHeight = state.videoController?.player.state.height;
    if (controllerWidth != null &&
        controllerHeight != null &&
        controllerWidth > 0 &&
        controllerHeight > 0) {
      aspectRatio = controllerWidth / controllerHeight;
    } else if (state.videoWidth != null &&
        state.videoHeight != null &&
        state.videoWidth! > 0 &&
        state.videoHeight! > 0) {
      aspectRatio = state.videoWidth! / state.videoHeight!;
    } else {
      final file = state.activeScene?.files.firstOrNull;
      if (file?.width != null &&
          file?.height != null &&
          file!.width! > 0 &&
          file.height! > 0) {
        aspectRatio = file.width! / file.height!;
      }
    }

    // Keep the current axis on phones until media dimensions are known.
    if (isPhone && aspectRatio == null) return;

    final allowGravity = state.videoGravityOrientation;
    final useLandscape = !isPhone || aspectRatio! > 1.0;
    final orientations = useLandscape
        ? allowGravity
              ? [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ]
              : [DeviceOrientation.landscapeLeft]
        : allowGravity
        ? [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]
        : [DeviceOrientation.portraitUp];

    if (listEquals(orientations, _lastFullscreenOrientations)) return;

    await SystemChrome.setPreferredOrientations(orientations);
    if (mounted) {
      final currentPhase = ref.read(playerStateProvider).fullscreenPhase;
      if (currentPhase == FullscreenPhase.entering ||
          currentPhase == FullscreenPhase.fullscreen) {
        _lastFullscreenOrientations = orientations;
      }
    }
  }

  void _onFullScreenChanged(bool isFullScreen) {
    if (!mounted) return;

    if (isFullScreen && _isVisible) {
      unawaited(_queueOrientationSync());
    } else if (isFullScreen) {
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
      unawaited(_completeExitFullScreen());
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

      if (_usesDesktopFullscreen) {
        await DesktopFullscreen.instance.enter();

        if (wasPlaying && defaultTargetPlatform == TargetPlatform.windows) {
          if (controller != null && !controller.player.state.playing) {
            unawaited(controller.player.play());
          }
        }
      } else {
        await _queueOrientationSync();

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

  Future<void> _completeExitFullScreen() async {
    try {
      await _exitFullScreen();
      if (!mounted) return;

      await _animationController.reverse();
      if (!mounted) return;

      setState(() {
        _isVisible = false;
        _isAnimating = false;
      });
      ref.read(playerStateProvider.notifier).markFullscreenExited();
    } catch (error, stackTrace) {
      AppLogStore.instance.add(
        'GlobalFullscreenOverlay: error exiting fullscreen: '
        '$error\n$stackTrace',
        source: 'GlobalFullscreenOverlay',
      );
      if (!mounted) return;
      setState(() => _isAnimating = false);
      ref.read(playerStateProvider.notifier).markFullscreenExitFailed();
      return;
    }

    await _resumePlaybackAfterExit();
  }

  Future<void> _exitFullScreen() async {
    AppLogStore.instance.add(
      'GlobalFullscreenOverlay: _exitFullScreen',
      source: 'GlobalFullscreenOverlay',
    );

    await _orientationSync;
    _lastFullscreenOrientations = null;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (_usesDesktopFullscreen) {
      await DesktopFullscreen.instance.exit();
    } else {
      final allowMainPageGravityOrientation = ref.read(
        mainPageGravityOrientationProvider,
      );
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
    }
  }

  Future<void> _resumePlaybackAfterExit() async {
    final controller = ref.read(playerStateProvider).videoController;
    if (!_wasPlayingBeforeExit || controller == null) return;

    try {
      if (kIsWeb) {
        Future.delayed(const Duration(milliseconds: 350), () {
          if (!controller.player.state.playing) {
            unawaited(
              controller.player.play().catchError((
                Object error,
                StackTrace stack,
              ) {
                AppLogStore.instance.add(
                  'GlobalFullscreenOverlay: error resuming playback after '
                  'fullscreen exit: $error\n$stack',
                  source: 'GlobalFullscreenOverlay',
                );
              }),
            );
          }
        });
      } else if (defaultTargetPlatform == TargetPlatform.windows &&
          !controller.player.state.playing) {
        await controller.player.play();
      }
    } catch (error, stackTrace) {
      AppLogStore.instance.add(
        'GlobalFullscreenOverlay: error resuming playback after fullscreen '
        'exit: $error\n$stackTrace',
        source: 'GlobalFullscreenOverlay',
      );
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
        .read(sceneListProvider.notifier)
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
    ref.listen(
      playerStateProvider.select((state) {
        final file = state.activeScene?.files.firstOrNull;
        return (
          sceneId: state.activeScene?.id,
          controller: state.videoController,
          width: state.videoWidth,
          height: state.videoHeight,
          fileWidth: file?.width,
          fileHeight: file?.height,
          gravity: state.videoGravityOrientation,
        );
      }),
      (_, _) => unawaited(_queueOrientationSync()),
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
