import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../../../core/presentation/theme/app_theme.dart';

/// Shared appearance for server subtitles and on-device captions.
SubtitleViewConfiguration subtitlePresentation(
  BuildContext context, {
  required double fontSize,
  required TextAlign textAlign,
  required double bottomPadding,
}) => SubtitleViewConfiguration(
  textAlign: textAlign,
  // Override media-kit's viewport-based shrinking to match Flutter captions.
  textScaler: MediaQuery.textScalerOf(context),
  padding: EdgeInsets.fromLTRB(
    context.dimensions.spacingMedium,
    0,
    context.dimensions.spacingMedium,
    bottomPadding,
  ),
  style: TextStyle(
    color: Colors.white.withValues(alpha: 0.75),
    fontSize: fontSize * context.dimensions.fontSizeFactor,
    backgroundColor: Colors.black.withValues(alpha: 0.4),
  ),
);
