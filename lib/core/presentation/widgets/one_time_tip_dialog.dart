import 'package:material_ui/material_ui.dart';

import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';

/// One gesture hint row in a [OneTimeTipDialog].
typedef TipHint = ({IconData icon, String text});

/// Shared layout for first-run tips and choices (see `OneTimeTip`).
///
/// Shows a title, optional gesture [hints], optional [choices], and a
/// [footnote]. Tip-only dialogs get a "Got it" button; dialogs with [choices]
/// close when a choice is tapped, so they omit it.
class OneTimeTipDialog extends StatelessWidget {
  const OneTimeTipDialog({
    required this.title,
    this.hints = const [],
    this.choices = const [],
    this.footnote,
    super.key,
  });

  final String title;
  final List<TipHint> hints;
  final List<Widget> choices;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final colors = Theme.of(context).colorScheme;
    // A plain Dialog: AlertDialog measures intrinsic widths, which sketches
    // built with LayoutBuilder cannot report.
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(dims.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: context.textTheme.headlineSmall),
              ),
              for (final hint in hints) ...[
                SizedBox(height: dims.spacingMedium),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      hint.icon,
                      size: 24 * dims.fontSizeFactor,
                      color: colors.primary,
                    ),
                    SizedBox(width: dims.spacingMedium),
                    Expanded(
                      child: Text(
                        hint.text,
                        style: context.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
              if (choices.isNotEmpty) ...[
                SizedBox(height: dims.spacingLarge),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < choices.length; i++) ...[
                      if (i > 0) SizedBox(width: dims.spacingMedium),
                      Expanded(child: choices[i]),
                    ],
                  ],
                ),
              ],
              if (footnote != null) ...[
                SizedBox(height: dims.spacingMedium),
                Text(
                  footnote!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
              if (choices.isEmpty) ...[
                SizedBox(height: dims.spacingMedium),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.l10n.onboarding_got_it),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable choice tile for [OneTimeTipDialog.choices].
class TipChoice extends StatelessWidget {
  const TipChoice({
    required this.label,
    required this.onTap,
    this.description,
    this.visual,
    super.key,
  });

  final String label;
  final String? description;

  /// Decorative illustration; [label] and [description] carry the meaning.
  final Widget? visual;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(dims.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (visual != null) ...[
                ExcludeSemantics(child: Center(child: visual)),
                SizedBox(height: dims.spacingSmall * 1.5),
              ],
              Text(
                label,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (description != null) ...[
                SizedBox(height: dims.spacingSmall / 2),
                Text(
                  description!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A large icon used as a [TipChoice.visual].
class TipChoiceIcon extends StatelessWidget {
  const TipChoiceIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Icon(
    icon,
    size: 40 * context.dimensions.fontSizeFactor,
    color: Theme.of(context).colorScheme.primary,
  );
}
