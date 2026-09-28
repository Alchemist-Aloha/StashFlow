import 'package:flutter/material.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.actionLabel,
    this.padding,
  });

  final String title;
  final VoidCallback? onViewAll;

  /// Label for the trailing action. Defaults to the shared "View all" string;
  /// passing one lets a caller reuse this header for a disclosure ("Show more")
  /// instead of hand-rolling a second header style.
  final String? actionLabel;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: context.dimensions.spacingMedium,
            vertical: context.dimensions.spacingSmall,
          ),
      child: Row(
        children: [
          Text(
            title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.onSurface,
            ),
          ),
          const Spacer(),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(
                actionLabel ?? AppLocalizations.of(context)!.common_view_all,
              ),
            ),
        ],
      ),
    );
  }
}
