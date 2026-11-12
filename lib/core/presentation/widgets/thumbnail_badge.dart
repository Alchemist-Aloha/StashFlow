import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Rounded translucent label drawn over a card thumbnail corner.
///
/// Scene and gallery cards share it so their metadata reads the same:
/// rating top-right, counts and lengths along the bottom.
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

  /// Defaults to 10 (compact) or 12.
  final double? iconSize;
  final bool bold;
  final EdgeInsetsGeometry padding;

  /// Inset of a badge from its thumbnail corner.
  static double inset({required bool compact}) => compact ? 4 : 8;

  @override
  Widget build(BuildContext context) {
    final style =
        (compact ? context.textTheme.labelSmall : context.textTheme.labelMedium)
            ?.copyWith(
              color: Colors.white,
              fontWeight: bold ? FontWeight.bold : null,
            );
    final icon = this.icon;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: iconColor, size: iconSize ?? (compact ? 10 : 12)),
            SizedBox(width: compact ? 2 : 4),
          ],
          Text(label, style: style),
        ],
      ),
    );
  }
}
