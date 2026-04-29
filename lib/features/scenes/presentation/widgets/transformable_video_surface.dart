import 'package:flutter/material.dart';
import '../../../../core/presentation/video/app_video_controller.dart';
import '../../../../core/presentation/video/app_video_surface.dart';

class TransformableVideoSurface extends StatefulWidget {
  const TransformableVideoSurface({
    required this.controller,
    required this.aspectRatio,
    this.transformationNotifier,
    this.fit = BoxFit.contain,
    super.key,
  });

  final AppVideoController controller;
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
    Widget content = AppVideoSurface(controller: widget.controller);

    if (widget.fit == BoxFit.fill) {
      content = SizedBox.expand(child: content);
    } else if (widget.fit == BoxFit.cover) {
      content = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.hardEdge,
          child: SizedBox(
            width: widget.controller.value.size.width,
            height: widget.controller.value.size.height,
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
