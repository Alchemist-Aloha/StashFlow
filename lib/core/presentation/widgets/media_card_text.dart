import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import '../../utils/l10n_extensions.dart';

/// Title, studio, optional performer row, and metadata action shared by cards.
///
/// Uses the same dimensions as [MediaCardText.stripItemHeight] so horizontal
/// strips reserve enough room for text and the action's minimum touch target.
class MediaCardMetadata extends StatelessWidget {
  const MediaCardMetadata({
    required this.title,
    required this.subtitle,
    required this.onMore,
    this.performers,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onMore;
  final Widget? performers;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final actionSize = MediaCardText._actionSize(context);
    return Padding(
      padding: MediaCardText._padding(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: MediaCardText.title(context),
                  maxLines: MediaCardText.titleMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: MediaCardText._titleGap(context)),
                Text(
                  subtitle,
                  style: MediaCardText.subtitle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (performers != null) ...[
                  SizedBox(height: dims.spacingSmall / 2),
                  performers!,
                ],
              ],
            ),
          ),
          SizedBox.square(
            dimension: actionSize,
            child: IconButton(
              tooltip: context.l10n.common_more,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: BoxConstraints.tightFor(
                width: actionSize,
                height: actionSize,
              ),
              onPressed: onMore,
              icon: Icon(Icons.more_vert, size: 16 * dims.fontSizeFactor),
            ),
          ),
        ],
      ),
    );
  }
}

/// Text styles and row sizing shared by grid scene and gallery cards.
///
/// Horizontal strips need a fixed row height; measuring it from these same
/// styles keeps the row matched to the cards at every UI and text scale.
abstract final class MediaCardText {
  static const titleMaxLines = 2;
  static EdgeInsets _padding(BuildContext context) => EdgeInsets.symmetric(
    horizontal: context.dimensions.spacingSmall,
    vertical: context.dimensions.spacingSmall / 2,
  );

  static double _titleGap(BuildContext context) =>
      context.dimensions.spacingSmall / 4;

  static double _actionSize(BuildContext context) =>
      math.max(kMinInteractiveDimension, context.dimensions.buttonHeight);

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
        _titleGap(context) +
        lineHeight(subtitle(context));
    return (width * 9 / 16 +
            extra +
            _padding(context).vertical +
            math.max(text, _actionSize(context)))
        .ceilToDouble();
  }
}
