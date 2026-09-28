import 'package:flutter/material.dart';

import '../../../../../core/presentation/widgets/frosted_surface.dart';

/// A centered overlay widget that provides visual feedback for video player gestures.
///
/// Displays an icon and a text label (e.g., speed or volume level) with smooth
/// entrance and exit animations.
class PlayerGestureFeedback extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool visible;

  const PlayerGestureFeedback({
    required this.icon,
    required this.label,
    required this.visible,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: visible ? 1.0 : 0.8,
          duration: const Duration(milliseconds: 250),
          curve: Curves.elasticOut,
          child: Center(
            child: FrostedSurface(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              borderRadius: BorderRadius.circular(16),
              // The glass capsule carries legibility over the video, which is
              // why the label no longer needs its own drop shadow.
              tint: Colors.black.withValues(alpha: 0.55),
              border: Border.all(color: Colors.white.withAlpha(23)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
