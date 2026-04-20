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

  const RatingBottomSheet({
    required this.initialRating,
    required this.onRatingSelected,
    required this.title,
    super.key,
  });

  /// Shows the rating bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required int initialRating,
    required ValueChanged<int> onRatingSelected,
    String? title,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => RatingBottomSheet(
        initialRating: initialRating,
        onRatingSelected: onRatingSelected,
        title: title ?? l10n.common_rate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final starValue = (index + 1) * 20;
                final isSelected = initialRating >= starValue;
                return IconButton(
                  tooltip: 'Star',
                  icon: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    size: 48,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    onRatingSelected(starValue);
                    Navigator.pop(context);
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                onRatingSelected(0);
                Navigator.pop(context);
              },
              child: Text(l10n.common_clear_rating),
            ),
          ],
        ),
      ),
    );
  }
}
