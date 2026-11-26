import 'package:material_ui/material_ui.dart';

import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';
import 'frosted_surface.dart';

Future<T?> showFrostedPanelBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  BoxConstraints? constraints,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    constraints: constraints,
    backgroundColor: Colors.transparent,
    builder: builder,
  );
}

/// Opens media details in the same navigator as filter and sort sheets.
Future<void> showMediaDetailsBottomSheet({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showFrostedPanelBottomSheet<void>(
    context: context,
    builder: (context) => LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.88),
        child: builder(context),
      ),
    ),
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

    return FrostedSurface(
      width: width,
      margin: margin,
      borderRadius: borderRadius,
      tint: colorScheme.surfaceContainerHigh,
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(
          alpha: AppTheme.frostedHairlineAlpha,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.4),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      child: child,
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

/// The pinned top of a media details sheet: heading, item title, and close.
///
/// Place it above the sheet's scrolling list so it stays visible.
class DetailsSheetHeader extends StatelessWidget {
  const DetailsSheetHeader({
    super.key,
    required this.heading,
    required this.title,
    required this.onClose,
    this.onVerticalDrag,
  });

  final String heading;
  final String title;
  final VoidCallback onClose;

  /// Receives vertical drag deltas, e.g. to move an embedding panel.
  final ValueChanged<double>? onVerticalDrag;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final header = Padding(
      padding: EdgeInsets.fromLTRB(
        dims.spacingLarge,
        dims.spacingLarge,
        dims.spacingLarge,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  heading,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: dims.spacingSmall),
                Text(
                  title,
                  style: context.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: context.l10n.common_close,
            onPressed: onClose,
          ),
        ],
      ),
    );
    final onDrag = onVerticalDrag;
    if (onDrag == null) return header;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
      child: header,
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
          if (onSecondary != null) ...[
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
        ],
      ),
    );
  }
}
