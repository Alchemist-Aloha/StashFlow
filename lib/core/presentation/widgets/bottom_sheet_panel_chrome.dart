import 'package:flutter/material.dart';

import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';

class BottomSheetPanelHeader extends StatelessWidget {
  const BottomSheetPanelHeader({
    super.key,
    required this.title,
    required this.onReset,
  });

  final String title;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dimensions.spacingLarge),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: onReset,
            child: Text(context.l10n.common_reset),
          ),
        ],
      ),
    );
  }
}

class BottomSheetPanelActions extends StatelessWidget {
  const BottomSheetPanelActions({
    super.key,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.dimensions.spacingLarge),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onPrimary,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.onPrimary,
                padding: EdgeInsets.symmetric(
                  vertical: context.dimensions.spacingMedium,
                ),
              ),
              child: Text(primaryLabel),
            ),
          ),
          SizedBox(height: context.dimensions.spacingSmall),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onSecondary,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: context.dimensions.spacingMedium,
                ),
              ),
              child: Text(secondaryLabel),
            ),
          ),
        ],
      ),
    );
  }
}
