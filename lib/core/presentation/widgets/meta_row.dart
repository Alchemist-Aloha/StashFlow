import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// A label/value row for details sheets: a font-scaled label column capped at
/// half the available width, beside a wrapping value.
class MetaRow extends StatelessWidget {
  const MetaRow({
    super.key,
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    return Padding(
      padding: EdgeInsets.only(bottom: dims.spacingSmall),
      child: LayoutBuilder(
        builder: (context, constraints) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: math.min(
                128 * dims.fontSizeFactor,
                constraints.maxWidth / 2,
              ),
              child: Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: selectable
                  ? SelectableText(value, style: context.textTheme.bodySmall)
                  : Text(value, style: context.textTheme.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
