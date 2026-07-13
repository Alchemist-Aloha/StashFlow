import 'dart:ui';

import 'package:flutter/material.dart';

import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';

Future<T?> showFrostedPanelBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useRootNavigator = false,
  BoxConstraints? constraints,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: isScrollControlled,
    constraints: constraints,
    backgroundColor: Colors.transparent,
    builder: builder,
  );
}

class FrostedPanel extends StatelessWidget {
  const FrostedPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppTheme.radiusExtraLarge),
    ),
    this.width,
    this.margin,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double? width;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: width,
        margin: margin,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}

class BottomSheetPanelHeader extends StatelessWidget {
  const BottomSheetPanelHeader({super.key, required this.title, this.onReset});

  final String title;
  final VoidCallback? onReset;

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
          if (onReset != null)
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
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

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
