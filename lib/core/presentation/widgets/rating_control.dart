import 'package:flutter/material.dart';

import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';

/// Compact rating entry point. Ratings use the server's 0–100 scale.
///
/// [onPressed] supports surfaces with additional rating targets; otherwise the
/// shared dialog returns a confirmed choice through [onRatingSelected].
class RatingButton extends StatelessWidget {
  const RatingButton({
    super.key,
    this.rating100,
    this.onPressed,
    this.onRatingSelected,
    this.style,
    this.showValue = true,
  });

  final int? rating100;
  final VoidCallback? onPressed;
  final ValueChanged<int>? onRatingSelected;
  final ButtonStyle? style;

  /// Media overlays may display the score separately below the button.
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final rating = (rating100 ?? 0).clamp(0, 100);
    return IconButton(
      tooltip:
          '${context.l10n.common_rate} · '
          '${context.l10n.images_rating((rating / 20).toStringAsFixed(2))}',
      style: style,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            rating > 0 ? Icons.star_rounded : Icons.star_border_rounded,
            color: context.colors.ratingColor,
            size: 24 * context.dimensions.fontSizeFactor,
          ),
          if (showValue && rating > 0) ...[
            SizedBox(width: context.dimensions.spacingSmall / 2),
            Text(
              (rating / 20).toStringAsFixed(rating % 20 == 0 ? 0 : 2),
              style: context.textTheme.labelLarge,
            ),
          ],
        ],
      ),
      onPressed:
          onPressed ??
          (onRatingSelected == null
              ? null
              : () => RatingDialog.show(
                  context,
                  initialRating: rating,
                  onRatingSelected: onRatingSelected!,
                )),
    );
  }
}

/// Shared controlled rating editor, including fractional ratings and clearing.
/// The owner decides when to persist [onChanged] values.
class RatingPicker extends StatelessWidget {
  const RatingPicker({
    super.key,
    required this.rating100,
    required this.onChanged,
  });

  final int rating100;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final rating = rating100.clamp(0, 100);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.images_rating((rating / 20).toStringAsFixed(2))),
        SizedBox(height: dims.spacingSmall),
        Wrap(
          alignment: WrapAlignment.center,
          children: List.generate(5, (index) {
            final value = (index + 1) * 20;
            return IconButton(
              tooltip: context.l10n.scene_rating_stars(index + 1),
              icon: Icon(
                rating >= value ? Icons.star : Icons.star_border,
                color: context.colors.ratingColor,
                size: 32 * dims.fontSizeFactor,
              ),
              onPressed: () => onChanged(value),
            );
          }),
        ),
        Slider(
          value: rating.toDouble(),
          max: 100,
          divisions: 20,
          label: (rating / 20).toStringAsFixed(2),
          semanticFormatterCallback: (value) =>
              context.l10n.images_rating((value / 20).toStringAsFixed(2)),
          onChanged: (value) => onChanged(value.round()),
        ),
        TextButton(
          onPressed: () => onChanged(0),
          child: Text(context.l10n.common_clear_rating),
        ),
      ],
    );
  }
}

/// Popup rating editor. Dismissing it leaves the confirmed rating unchanged.
class RatingDialog {
  static Future<void> show(
    BuildContext context, {
    required int initialRating,
    required ValueChanged<int> onRatingSelected,
    String? title,
    String? subtitle,
    Widget? detailsWidget,
  }) async {
    var rating = initialRating.clamp(0, 100);
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          scrollable: true,
          title: Text(title ?? context.l10n.common_rate),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (subtitle != null) ...[
                Text(subtitle),
                SizedBox(height: context.dimensions.spacingMedium),
              ],
              RatingPicker(
                rating100: rating,
                onChanged: (value) => setDialogState(() => rating = value),
              ),
              if (detailsWidget != null) ...[
                SizedBox(height: context.dimensions.spacingMedium),
                detailsWidget,
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(rating),
              child: Text(context.l10n.common_apply),
            ),
          ],
        ),
      ),
    );
    if (result != null && context.mounted) onRatingSelected(result);
  }
}
