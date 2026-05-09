import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:window_manager/window_manager.dart';

import '../providers/video_player_provider.dart';
import 'native_video_controls.dart';
import 'transformable_video_surface.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/utils/web_helpers.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/services/cast_service.dart';
import '../../../setup/presentation/providers/main_page_orientation_provider.dart';

TextAlign _subtitleTextAlign(String setting) {
  switch (setting) {
    case 'left':
      return TextAlign.left;
    case 'right':
      return TextAlign.right;
    case 'center':
    default:
      return TextAlign.center;
  }
}

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

  // Timer to debounce the buffering spinner.
  Timer? _bufferingDisplayTimer;
  bool _showBufferingSpinner = false;

  final ValueNotifier<Matrix4> _transformationNotifier = ValueNotifier(
    Matrix4.identity(),
  );
  double _lastScale = 1.0;
  double _lastRotation = 0.0;

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
      final isFullScreen = ref.read(
        playerStateProvider.select((s) => s.isFullScreen),
      );
      if (isFullScreen) {
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

  void _onScaleStart(ScaleStartDetails details) {
    _lastScale = 1.0;
    _lastRotation = 0.0;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount < 2) return;

    final double deltaScale = details.scale / _lastScale;
    final double deltaRotation = details.rotation - _lastRotation;
    final Offset focalPoint = details.localFocalPoint;

    final Matrix4 matrix = Matrix4.identity()
      ..translateByVector3(Vector3(focalPoint.dx, focalPoint.dy, 0))
      ..rotateZ(deltaRotation)
      ..scaleByVector3(Vector3(deltaScale, deltaScale, 1.0))
      ..translateByVector3(Vector3(-focalPoint.dx, -focalPoint.dy, 0))
      ..translateByVector3(
        Vector3(details.focalPointDelta.dx, details.focalPointDelta.dy, 0),
      );

    _transformationNotifier.value = matrix * _transformationNotifier.value;
    _lastScale = details.scale;
    _lastRotation = details.rotation;
  }

  void _onTransformationDelta(Matrix4 delta, Offset focalPoint) {
    _transformationNotifier.value = delta * _transformationNotifier.value;
  }

  void _onControllerUpdate() {
    if (_isVisible && _currentListenedController != null) {
      _wasPlayingBeforeExit = _currentListenedController!.player.state.playing;
    }
  }

  void _onFullScreenChanged(bool isFullScreen) {
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
      _enterFullScreen();
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
    notifier.setFullScreen(false);
    notifier.setViewMode(PlayerViewMode.inline);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      playerStateProvider.select((s) => s.isFullScreen),
      (previous, next) => _onFullScreenChanged(next),
    );

    final bool showOverlay = _isVisible || _isAnimating;

    final playerState = ref.watch(playerStateProvider);
    final castState = ref.watch(castServiceProvider);
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
      content = const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Initializing player...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    } else {
      content = LayoutBuilder(
        builder: (context, constraints) {
          final videoWidth = playerState.videoWidth;
          final videoHeight = playerState.videoHeight;
          final isVideoReady =
              videoWidth != null && videoHeight != null && videoHeight > 0;
          final aspectRatio = isVideoReady ? videoWidth / videoHeight : 16 / 9;

          if (playerState.isBuffering && !_showBufferingSpinner) {
            _bufferingDisplayTimer ??= Timer(
              const Duration(milliseconds: 500),
              () {
                if (mounted) setState(() => _showBufferingSpinner = true);
              },
            );
          } else if (!playerState.isBuffering && _showBufferingSpinner) {
            _bufferingDisplayTimer?.cancel();
            _bufferingDisplayTimer = null;
            Future.microtask(() {
              if (mounted) setState(() => _showBufferingSpinner = false);
            });
          } else if (!playerState.isBuffering) {
            _bufferingDisplayTimer?.cancel();
            _bufferingDisplayTimer = null;
          }

          final showLoadingIndicator =
              _showBufferingSpinner ||
              (!isVideoReady && !playerState.isPlaying);

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black,
                  child: castState.isCasting
                      ? Image.network(
                          appendApiKey(
                            scene.paths.screenshot ?? '',
                            ref.read(serverApiKeyProvider),
                          ),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.cast,
                                  size: 64,
                                  color: Colors.white24,
                                ),
                              ),
                        )
                      : TransformableVideoSurface(
                          fontSize: playerState.subtitleFontSize,
                          textAlign: _subtitleTextAlign(
                            playerState.subtitleTextAlignment,
                          ),
                          bottomRatio: playerState.subtitlePositionBottomRatio,
                          constraints: constraints,
                          controller: controller,
                          aspectRatio: aspectRatio,
                          transformationNotifier: _transformationNotifier,
                          fit: (aspectRatio - 1.0).abs() < 0.01
                              ? BoxFit.fill
                              : BoxFit.contain,
                        ),
                ),
              ),
              if (showLoadingIndicator && !castState.isCasting)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              if (castState.isCasting)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cast_connected,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Casting to ${castState.activeSession?.device.name ?? 'Device'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: NativeVideoControls(
                    controller: controller,
                    useDoubleTapSeek: playerState.useDoubleTapSeek,
                    enableNativePip: playerState.enableNativePip,
                    onFullScreenToggle: _toggleFullScreen,
                    scene: scene,
                    onScaleStart: _onScaleStart,
                    onScaleUpdate: _onScaleUpdate,
                    onTransformationDelta: _onTransformationDelta,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return IgnorePointer(
      ignoring: !showOverlay,
      child: Visibility(
        visible: showOverlay,
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
