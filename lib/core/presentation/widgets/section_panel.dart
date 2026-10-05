import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The system's in-flow grouped-block recipe, declared once.
///
/// A section panel groups related content that sits *in* the page: a detail
/// page's rating controls and metadata, a bottom sheet's info block, a settings
/// group. It is deliberately not a card in the media sense — media cards are
/// artwork-first and tinted with the accent container, while a panel is a quiet
/// neutral block whose lift comes from the tonal ladder
/// (`surfaceContainerHighest` on the base surface), never from a shadow.
///
/// The panel owns the recipe so radius, fill, padding, and the title voice stay
/// identical wherever a grouped block appears. Callers supply content, an
/// optional title, and an optional trailing action; they do not supply styling.
class SectionPanel extends StatelessWidget {
  const SectionPanel({
    required this.child,
    this.title,
    this.titleTrailing,
    this.padding,
    this.margin,
    this.onTap,
    this.onHighlightChanged,
    super.key,
  });

  /// The grouped content.
  final Widget child;

  /// Optional heading, rendered in the system's section-header voice so a
  /// panel heading and a standalone [SectionHeader] cannot drift apart.
  final String? title;

  /// Optional trailing action beside [title] — the "View all" or "Show more"
  /// affordance.
  final Widget? titleTrailing;

  /// Content padding. Defaults to [AppDimensions.spacingMedium] on all sides.
  final EdgeInsetsGeometry? padding;

  /// Outer margin, for panels that need to separate from their neighbours.
  final EdgeInsetsGeometry? margin;

  /// Makes the whole panel a single tap target with the standard ripple,
  /// bounded by the panel radius.
  final VoidCallback? onTap;

  /// Press-state callback for a tappable panel, so a caller can animate the
  /// panel without re-implementing its chrome.
  final ValueChanged<bool>? onHighlightChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dims = context.dimensions;
    final radius = BorderRadius.circular(AppTheme.radiusLarge);

    final body = Padding(
      padding: padding ?? EdgeInsets.all(dims.spacingMedium),
      // A headerless panel must pass bounded height through to scrollables.
      child: title == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title!,
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      ?titleTrailing,
                    ],
                  ),
                  SizedBox(height: dims.spacingSmall),
                ],
                child,
              ],
            ),
    );

    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: colors.cardBackground,
        borderRadius: radius,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null
            ? body
            : InkWell(
                onTap: onTap,
                onHighlightChanged: onHighlightChanged,
                child: body,
              ),
      ),
    );
  }
}
