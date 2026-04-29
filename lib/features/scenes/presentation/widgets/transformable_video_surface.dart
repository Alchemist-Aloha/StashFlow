import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

class TransformableVideoSurface extends StatefulWidget {
  const TransformableVideoSurface({
    required this.controller,
    required this.aspectRatio,
    this.transformationNotifier,
    this.fit = BoxFit.contain,
    super.key,
  });

  final VideoController controller;
  final double aspectRatio;
  final BoxFit fit;
  
  /// Optional notifier to sync transformations from external gesture detectors.
  final ValueNotifier<Matrix4>? transformationNotifier;

  @override
  State<TransformableVideoSurface> createState() => _TransformableVideoSurfaceState();
}

class _TransformableVideoSurfaceState extends State<TransformableVideoSurface> {
  late Matrix4 _transformationMatrix;

  @override
  void initState() {
    super.initState();
    _transformationMatrix = widget.transformationNotifier?.value ?? Matrix4.identity();
    widget.transformationNotifier?.addListener(_onTransformationChanged);
  }

  @override
  void didUpdateWidget(TransformableVideoSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transformationNotifier != widget.transformationNotifier) {
      oldWidget.transformationNotifier?.removeListener(_onTransformationChanged);
      widget.transformationNotifier?.addListener(_onTransformationChanged);
      if (widget.transformationNotifier != null) {
        _transformationMatrix = widget.transformationNotifier!.value;
      }
    }
  }

  @override
  void dispose() {
    widget.transformationNotifier?.removeListener(_onTransformationChanged);
    super.dispose();
  }

  void _onTransformationChanged() {
    if (mounted) {
      setState(() {
        _transformationMatrix = widget.transformationNotifier!.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Video(
      controller: widget.controller,
      controls: NoVideoControls, // or just don't pass if default is no controls
    );

    if (widget.fit == BoxFit.fill) {
      content = SizedBox.expand(child: content);
    } else if (widget.fit == BoxFit.cover) {
      content = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: widget.controller.player.state.width?.toDouble() ?? 100.0,
            height: widget.controller.player.state.height?.toDouble() ?? 100.0,
            child: content,
          ),
        ),
      );
    } else {
      content = Center(
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: content,
        ),
      );
    }

    return ClipRect(
      child: Transform(
        transform: _transformationMatrix,
        child: content,
      ),
    );
  }
}
