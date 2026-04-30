import 'package:flutter/material.dart';

/// A widget that provides a shimmering skeleton effect for its child.
///
/// This is used to create placeholder layouts during data loading, improving
/// the perceived performance of the application.
class Skeleton extends StatefulWidget {
  final Widget child;
  const Skeleton({required this.child, super.key});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Base colors for the shimmer effect, adjusted for theme.
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            final double progress = _controller.value;
            // Move the gradient from left to right across the widget bounds.
            final double center = progress * 2 - 0.5;
            
            return LinearGradient(
              begin: const Alignment(-1.0, 0),
              end: const Alignment(1.0, 0),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (center - 0.3).clamp(0.0, 1.0),
                center.clamp(0.0, 1.0),
                (center + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
