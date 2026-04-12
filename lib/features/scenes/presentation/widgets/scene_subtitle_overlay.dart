import 'package:flutter/material.dart';

/// Renders subtitle text with explicit multiline centering and
/// bottom-ratio positioning inside a [Stack].
class SceneSubtitleOverlay extends StatelessWidget {
  const SceneSubtitleOverlay({
    required this.text,
    required this.constraints,
    required this.bottomRatio,
    required this.fontSize,
    this.textAlign = TextAlign.center,
    this.horizontalAlignment = Alignment.center,
    this.horizontalPadding = 16,
    this.maxWidthFactor = 0.9,
    super.key,
  });

  final String text;
  final BoxConstraints constraints;
  final double bottomRatio;
  final double fontSize;
  final TextAlign textAlign;
  final Alignment horizontalAlignment;
  final double horizontalPadding;
  final double maxWidthFactor;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: constraints.maxHeight * bottomRatio,
      left: horizontalPadding,
      right: horizontalPadding,
      child: IgnorePointer(
        child: Align(
          alignment: horizontalAlignment,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * maxWidthFactor,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                child: Text(
                  text,
                  textAlign: textAlign,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
