import 'package:flutter/material.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
    this.padding,
  });

  final String title;
  final VoidCallback? onViewAll;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
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
              child: Text(AppLocalizations.of(context)!.common_view_all),
            ),
        ],
      ),
    );
  }
}
