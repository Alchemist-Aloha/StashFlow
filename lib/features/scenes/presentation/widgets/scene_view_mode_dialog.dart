import 'package:material_ui/material_ui.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/l10n_extensions.dart';

/// Shows the one-time scene view mode chooser.
///
/// Resolves to `true` for Feed, `false` for Grid, or `null` when dismissed.
Future<bool?> showSceneViewModeDialog(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) => const SceneViewModeDialog(),
);

/// Lets a new user pick between the grid and feed scene layouts.
class SceneViewModeDialog extends StatelessWidget {
  const SceneViewModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.dimensions.spacingMedium;
    // A plain Dialog: AlertDialog measures intrinsic widths, which the
    // sketches' LayoutBuilder cannot report.
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(context.dimensions.spacingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.scene_view_mode_prompt_title,
                  style: context.textTheme.headlineSmall,
                ),
              ),
              SizedBox(height: context.dimensions.spacingLarge),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ModeOption(
                      key: const Key('scene-view-mode-grid'),
                      label: l10n.settings_interface_layout_grid,
                      description: l10n.scene_view_mode_prompt_grid_desc,
                      sketch: const _GridSketch(),
                      onTap: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  SizedBox(width: spacing),
                  Expanded(
                    child: _ModeOption(
                      key: const Key('scene-view-mode-feed'),
                      label: l10n.settings_interface_layout_tiktok,
                      description: l10n.scene_view_mode_prompt_feed_desc,
                      sketch: const _FeedSketch(),
                      onTap: () => Navigator.of(context).pop(true),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing),
              Text(
                l10n.scene_view_mode_prompt_settings_hint,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.label,
    required this.description,
    required this.sketch,
    required this.onTap,
    super.key,
  });

  final String label;
  final String description;
  final Widget sketch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.dimensions.spacingSmall;
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(context.dimensions.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Decorative: the label and description carry the meaning.
              ExcludeSemantics(
                child: Center(
                  child: FractionallySizedBox(widthFactor: 0.7, child: sketch),
                ),
              ),
              SizedBox(height: spacing * 1.5),
              Text(
                label,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: spacing / 2),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Phone outline shared by both sketches.
class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Padding(padding: const EdgeInsets.all(5), child: child),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({this.opacity = 0.35});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary
              .withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      ),
    );
  }
}

/// Two columns of cards with a caption line under each.
class _GridSketch extends StatelessWidget {
  const _GridSketch();

  @override
  Widget build(BuildContext context) {
    final caption = Theme.of(context).colorScheme.onSurfaceVariant
        .withValues(alpha: 0.4);
    Widget cell() => Padding(
      padding: const EdgeInsets.all(2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: _Block()),
          const SizedBox(height: 2),
          FractionallySizedBox(
            widthFactor: 0.7,
            child: Container(height: 3, color: caption),
          ),
        ],
      ),
    );
    return _PhoneFrame(
      child: Column(
        children: [
          for (var row = 0; row < 3; row++)
            Expanded(
              child: Row(
                children: [
                  Expanded(child: cell()),
                  Expanded(child: cell()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One full-height scene with the next one peeking in below.
class _FeedSketch extends StatelessWidget {
  const _FeedSketch();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _PhoneFrame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final unit = constraints.maxWidth;
          final dot = unit * 0.1;
          return Column(
            children: [
              Expanded(
                flex: 7,
                child: Stack(
                  children: [
                    const Positioned.fill(child: _Block()),
                    Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        size: unit * 0.35,
                        color: colors.primary,
                      ),
                    ),
                    Positioned(
                      right: dot / 2,
                      bottom: dot,
                      child: Column(
                        children: [
                          for (var i = 0; i < 3; i++)
                            Padding(
                              padding: EdgeInsets.only(top: dot / 2),
                              child: Container(
                                width: dot,
                                height: dot,
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: unit * 0.25,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              const Expanded(child: _Block(opacity: 0.15)),
            ],
          );
        },
      ),
    );
  }
}
