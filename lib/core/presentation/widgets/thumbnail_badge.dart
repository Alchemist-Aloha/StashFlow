import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Rounded translucent label drawn over a card thumbnail corner.
///
/// Shared by scene, gallery, and image cards; each caller owns its corner
/// placement while the badge owns the scaled metadata treatment.
class ThumbnailBadge extends StatelessWidget {
  const ThumbnailBadge({
    required this.label,
    required this.compact,
    this.icon,
    this.iconColor = Colors.white,
    this.iconSize,
    this.bold = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    super.key,
  });

  /// Star rating badge on the 0–100 server scale, shown as 0.0–5.0.
  ThumbnailBadge.rating(
    BuildContext context, {
    required int rating100,
    required this.compact,
    super.key,
  }) : label = (rating100 / 20).toStringAsFixed(1),
       icon = Icons.star,
       iconColor = context.colors.ratingColor,
       iconSize = compact ? 10 : 14,
       bold = true,
       padding = EdgeInsets.symmetric(
         horizontal: compact ? 4 : 6,
         vertical: compact ? 1 : 2,
       );

  final String label;

  /// Grid cards use smaller text and icons than list cards.
  final bool compact;
  final IconData? icon;
  final Color iconColor;

  /// Unscaled icon size; defaults to 10 (compact) or 12.
  final double? iconSize;
  final bool bold;

  /// Padding at UI scale 1, scaled once when rendered.
  final EdgeInsetsGeometry padding;

  /// Scaled inset of a badge from its thumbnail corner.
  static double inset(BuildContext context, {required bool compact}) =>
      context.dimensions.spacingSmall * (compact ? 0.5 : 1);

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final style =
        (compact ? context.textTheme.labelSmall : context.textTheme.labelMedium)
            ?.copyWith(
              color: Colors.white,
              fontWeight: bold ? FontWeight.bold : null,
            );
    final icon = this.icon;
    return Container(
      padding: padding * dims.fontSizeFactor,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: iconColor,
              size: (iconSize ?? (compact ? 10 : 12)) * dims.fontSizeFactor,
            ),
            SizedBox(width: dims.spacingSmall / (compact ? 4 : 2)),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }
}
