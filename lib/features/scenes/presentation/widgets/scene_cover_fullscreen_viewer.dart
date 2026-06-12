import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/utils/l10n_extensions.dart';

typedef SceneCoverImageBuilder =
    Widget Function(BuildContext context, String imageUrl);

class SceneCoverFullscreenViewer extends StatefulWidget {
  const SceneCoverFullscreenViewer({
    required this.imageUrl,
    this.transformationController,
    this.imageBuilder,
    super.key,
  });

  final String imageUrl;
  final TransformationController? transformationController;
  final SceneCoverImageBuilder? imageBuilder;

  @override
  State<SceneCoverFullscreenViewer> createState() =>
      _SceneCoverFullscreenViewerState();
}

class _SceneCoverFullscreenViewerState
    extends State<SceneCoverFullscreenViewer> {
  static const double _doubleTapScale = 2.5;

  late final TransformationController _transformationController =
      widget.transformationController ?? TransformationController();
  late final bool _ownsTransformationController =
      widget.transformationController == null;
  Offset _doubleTapPosition = Offset.zero;

  @override
  void dispose() {
    if (_ownsTransformationController) {
      _transformationController.dispose();
    }
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapPosition = details.localPosition;
  }

  void _handleDoubleTap() {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    if (currentScale > 1.01) {
      _transformationController.value = Matrix4.identity();
      return;
    }

    _transformationController.value = Matrix4.identity()
      ..translateByDouble(
        -_doubleTapPosition.dx * (_doubleTapScale - 1),
        -_doubleTapPosition.dy * (_doubleTapScale - 1),
        0,
        1,
      )
      ..scaleByDouble(_doubleTapScale, _doubleTapScale, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('scene_cover_fullscreen_viewer'),
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            key: const Key('scene_cover_fullscreen_zoom_surface'),
            behavior: HitTestBehavior.opaque,
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 1,
              maxScale: 4,
              panEnabled: true,
              scaleEnabled: true,
              child: SizedBox.expand(
                child:
                    widget.imageBuilder?.call(context, widget.imageUrl) ??
                    StashImage(
                      imageUrl: widget.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                    ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              minimum: const EdgeInsets.all(12),
              child: IconButton.filledTonal(
                key: const Key('scene_cover_fullscreen_exit_button'),
                tooltip: context.l10n.common_exit_fullscreen,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.fullscreen_exit_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
