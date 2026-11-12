import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Text styles and row sizing shared by grid scene and gallery cards.
///
/// Horizontal strips need a fixed row height; measuring it from these same
/// styles keeps the row matched to the cards at every UI and text scale.
abstract final class MediaCardText {
  static const titleMaxLines = 2;
  static const _textPadding = 8.0; // EdgeInsets.symmetric(vertical: 4)
  static const _titleGap = 2.0;
  static const _actionSize = 32.0;

  static TextStyle? title(BuildContext context) =>
      context.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: context.dimensions.cardTitleFontSize,
      );

  static TextStyle? subtitle(BuildContext context) => context
      .textTheme
      .labelSmall
      ?.copyWith(color: context.colors.primary, fontWeight: FontWeight.bold);

  /// Height of a grid card [width] wide with a 16:9 thumbnail, a full
  /// two-line title and the subtitle line, plus [extra] (e.g. a progress bar).
  static double stripItemHeight(
    BuildContext context,
    double width, {
    double extra = 0,
  }) {
    final scaler = MediaQuery.textScalerOf(context);
    // Text merges its style into the ambient default, so measure the same way.
    final base = DefaultTextStyle.of(context).style;
    double lineHeight(TextStyle? style) {
      final painter = TextPainter(
        text: TextSpan(text: ' ', style: base.merge(style)),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      final height = painter.height;
      painter.dispose();
      return height;
    }

    final text =
        lineHeight(title(context)) * titleMaxLines +
        _titleGap +
        lineHeight(subtitle(context));
    return (width * 9 / 16 + extra + _textPadding + math.max(text, _actionSize))
        .ceilToDouble();
  }
}
