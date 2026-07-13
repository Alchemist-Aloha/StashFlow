import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../../../core/data/graphql/graphql_client.dart';
import '../../../../core/data/graphql/url_resolver.dart';
import '../../../../core/data/services/cast_service.dart';
import '../../domain/entities/scene.dart';
import '../providers/video_player_provider.dart';
import 'native_video_controls.dart';
import 'transformable_video_surface.dart';

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

class PlayerSurface extends ConsumerStatefulWidget {
  const PlayerSurface({
    required this.scene,
    required this.controller,
    required this.onFullScreenToggle,
    this.onInlineBack,
    this.onRandomScene,
    this.fit = BoxFit.contain,
    this.squareFit = BoxFit.contain,
    this.showControls = true,
    super.key,
  });

  final Scene scene;
  final VideoController controller;
  final VoidCallback onFullScreenToggle;
  final VoidCallback? onInlineBack;
  final VoidCallback? onRandomScene;
  final BoxFit fit;
  final BoxFit squareFit;
  final bool showControls;

  @override
  ConsumerState<PlayerSurface> createState() => _PlayerSurfaceState();
}

class _PlayerSurfaceState extends ConsumerState<PlayerSurface> {
  Timer? _bufferingDisplayTimer;
  bool _showBufferingSpinner = false;

  final ValueNotifier<Matrix4> _transformationNotifier = ValueNotifier(
    Matrix4.identity(),
  );
  double _lastScale = 1.0;
  double _lastRotation = 0.0;

  @override
  void dispose() {
    _bufferingDisplayTimer?.cancel();
    _transformationNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayerSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scene.id != widget.scene.id ||
        oldWidget.controller != widget.controller) {
      _bufferingDisplayTimer?.cancel();
      _bufferingDisplayTimer = null;
      _showBufferingSpinner = false;
      _transformationNotifier.value = Matrix4.identity();
      _lastScale = 1.0;
      _lastRotation = 0.0;
    }
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

  bool _updateAndReadLoadingState(GlobalPlayerState playerState) {
    final videoWidth = playerState.videoWidth;
    final videoHeight = playerState.videoHeight;
    final isVideoReady =
        videoWidth != null && videoHeight != null && videoHeight > 0;

    if (playerState.isBuffering && !_showBufferingSpinner) {
      _bufferingDisplayTimer ??= Timer(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _showBufferingSpinner = true);
      });
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

    return _showBufferingSpinner || (!isVideoReady && !playerState.isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerStateProvider);
    final castState = ref.watch(castServiceProvider);

    final videoWidth = playerState.videoWidth;
    final videoHeight = playerState.videoHeight;
    final isVideoReady =
        videoWidth != null && videoHeight != null && videoHeight > 0;
    final aspectRatio = isVideoReady ? videoWidth / videoHeight : 16 / 9;
    final fit = (aspectRatio - 1.0).abs() < 0.01
        ? widget.squareFit
        : widget.fit;
    final showLoadingIndicator = _updateAndReadLoadingState(playerState);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: castState.isCasting
                    ? Image.network(
                        excludeFromSemantics: true,
                        appendApiKey(
                          widget.scene.paths.screenshot ?? '',
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
                        controller: widget.controller,
                        aspectRatio: aspectRatio,
                        transformationNotifier: _transformationNotifier,
                        fit: fit,
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
            if (widget.showControls && castState.isCasting)
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
                          context.l10n.cast_casting_to(
                            castState.activeSession?.device.name ??
                                context.l10n.cast_device,
                          ),
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
            if (widget.showControls)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: NativeVideoControls(
                    controller: widget.controller,
                    useDoubleTapSeek: playerState.useDoubleTapSeek,
                    enableNativePip: playerState.enableNativePip,
                    onFullScreenToggle: widget.onFullScreenToggle,
                    onInlineBack: widget.onInlineBack,
                    onRandomScene: widget.onRandomScene,
                    scene: widget.scene,
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
}
