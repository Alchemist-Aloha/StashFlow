import 'package:flutter/material.dart';
import '../../../../../core/presentation/theme/app_theme.dart';

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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(160),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: Colors.white.withAlpha(40),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                    shadows: const [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black26,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black26,
                          offset: Offset(0, 2),
                        ),
                      ],
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
