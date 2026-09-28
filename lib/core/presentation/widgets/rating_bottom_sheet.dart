import 'package:flutter/material.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'bottom_sheet_panel_chrome.dart';
import 'rating_control.dart';

/// Entity details with a compact entry point to the shared rating dialog.
class RatingBottomSheet extends StatelessWidget {
  /// The current rating (0-100).
  final int initialRating;

  /// The title of the bottom sheet.
  final String title;

  /// Optional subtitle shown below the title in the details layout.
  final String? subtitle;

  /// Callback when a rating is selected (0-100).
  final ValueChanged<int> onRatingSelected;

  final Widget? detailsWidget;

  const RatingBottomSheet({
    required this.initialRating,
    required this.onRatingSelected,
    required this.title,
    this.subtitle,
    this.detailsWidget,
    super.key,
  });

  /// Shows the rating bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required int initialRating,
    required ValueChanged<int> onRatingSelected,
    String? title,
    String? subtitle,
    Widget? detailsWidget,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final sheet = RatingBottomSheet(
      initialRating: initialRating,
      onRatingSelected: onRatingSelected,
      title: title ?? l10n.common_rate,
      subtitle: subtitle,
      detailsWidget: detailsWidget,
    );
    return showFrostedPanelBottomSheet<void>(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      builder: (_) => sheet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dims = context.dimensions;
    return SafeArea(
      top: false,
      child: FrostedPanel(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusExtraLarge),
        ),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(dims.spacingLarge),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: dims.spacingSmall),
                        Text(
                          subtitle!,
                          style: context.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: l10n.common_close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: dims.spacingMedium),
            _buildRatingControl(context),
            if (detailsWidget != null) ...[
              SizedBox(height: dims.spacingMedium),
              detailsWidget!,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRatingControl(BuildContext context) {
    return Center(
      child: RatingButton(
        rating100: initialRating,
        onRatingSelected: (rating) {
          Navigator.of(context).pop();
          onRatingSelected(rating);
        },
      ),
    );
  }
}
