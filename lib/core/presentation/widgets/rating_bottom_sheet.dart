import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// A bottom sheet that allows the user to set a rating (0-5 stars).
class RatingBottomSheet extends StatelessWidget {
  /// The current rating (0-100).
  final int initialRating;

  /// The title of the bottom sheet.
  final String title;

  /// Callback when a rating is selected (0-100).
  final ValueChanged<int> onRatingSelected;

  final Widget? detailsWidget;

  const RatingBottomSheet({
    required this.initialRating,
    required this.onRatingSelected,
    required this.title,
    this.detailsWidget,
    super.key,
  });

  /// Shows the rating bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required int initialRating,
    required ValueChanged<int> onRatingSelected,
    String? title,
    Widget? detailsWidget,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: detailsWidget != null,
      constraints: detailsWidget != null
          ? BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88)
          : null,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RatingBottomSheet(
        initialRating: initialRating,
        onRatingSelected: onRatingSelected,
        title: title ?? l10n.common_rate,
        detailsWidget: detailsWidget,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dims = context.dimensions;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: dims.spacingLarge,
          horizontal: dims.spacingMedium,
        ),
        child: detailsWidget != null
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _buildContent(context, dims, l10n),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildContent(context, dims, l10n),
              ),
      ),
    );
  }

  List<Widget> _buildContent(
    BuildContext context,
    AppDimensions dims,
    AppLocalizations l10n,
  ) {
    return [
      Text(
        title,
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      SizedBox(height: dims.spacingLarge),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final starValue = (index + 1) * 20;
          final isSelected = initialRating >= starValue;
          return IconButton(
            tooltip: context.l10n.common_star,
            icon: Icon(
              isSelected ? Icons.star : Icons.star_border,
              size: 48 * dims.fontSizeFactor,
              color: Colors.amber,
            ),
            onPressed: () {
              onRatingSelected(starValue);
              Navigator.pop(context);
            },
          );
        }),
      ),
      SizedBox(height: dims.spacingMedium),
      TextButton(
        onPressed: () {
          onRatingSelected(0);
          Navigator.pop(context);
        },
        child: Text(l10n.common_clear_rating),
      ),
      if (detailsWidget != null) ...[
        SizedBox(height: dims.spacingMedium),
        detailsWidget!,
      ],
    ];
  }
}
