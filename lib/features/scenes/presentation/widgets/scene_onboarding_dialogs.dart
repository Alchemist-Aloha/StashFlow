import 'package:material_ui/material_ui.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/one_time_tip_dialog.dart';
import '../../../../core/utils/l10n_extensions.dart';

/// Shows the one-time scene view mode chooser.
///
/// Resolves to `true` for Feed, `false` for Grid, or `null` when dismissed.
Future<bool?> showSceneViewModeDialog(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) => const SceneViewModeDialog(),
);

/// Shows the one-time scene grid gesture tip.
Future<void> showSceneGridTip(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => OneTimeTipDialog(
    title: context.l10n.onboarding_grid_title,
    hints: [
      (
        icon: Icons.touch_app_outlined,
        text: context.l10n.onboarding_grid_long_press,
      ),
    ],
  ),
);

/// Shows the one-time feed gesture tip.
Future<void> showSceneFeedTip(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => OneTimeTipDialog(
    title: context.l10n.onboarding_feed_title,
    hints: [
      (
        icon: Icons.fast_forward_rounded,
        text: context.l10n.onboarding_feed_long_press,
      ),
      (
        icon: Icons.visibility_off_outlined,
        text: context.l10n.onboarding_feed_title_tap,
      ),
      (
        icon: Icons.keyboard_arrow_up_rounded,
        text: context.l10n.onboarding_feed_chevron,
      ),
    ],
  ),
);

/// Shows the one-time scene details tip with the seek method choice.
///
/// Resolves to `true` for double-tap seeking, `false` for dragging, or `null`
/// when dismissed.
Future<bool?> showSceneDetailsTip(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) {
    final l10n = context.l10n;
    return OneTimeTipDialog(
      title: l10n.onboarding_details_title,
      hints: [
        (icon: Icons.swipe_outlined, text: l10n.onboarding_details_swipe_title),
        (
          icon: Icons.fast_forward_outlined,
          text: l10n.onboarding_details_seek_label,
        ),
      ],
      choices: [
        TipChoice(
          key: const Key('scene-seek-double-tap'),
          label: l10n.settings_playback_seek_double_tap_label,
          description: l10n.settings_playback_seek_double_tap,
          visual: const TipChoiceIcon(Icons.touch_app_outlined),
          onTap: () => Navigator.of(context).pop(true),
        ),
        TipChoice(
          key: const Key('scene-seek-drag'),
          label: l10n.settings_playback_seek_drag_label,
          description: l10n.settings_playback_seek_drag,
          visual: const TipChoiceIcon(Icons.linear_scale_rounded),
          onTap: () => Navigator.of(context).pop(false),
        ),
      ],
      footnote: l10n.onboarding_playback_settings_hint,
    );
  },
);

/// Lets a new user pick between the grid and feed scene layouts.
class SceneViewModeDialog extends StatelessWidget {
  const SceneViewModeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return OneTimeTipDialog(
      title: l10n.scene_view_mode_prompt_title,
      choices: [
        TipChoice(
          key: const Key('scene-view-mode-grid'),
          label: l10n.settings_interface_layout_grid,
          description: l10n.scene_view_mode_prompt_grid_desc,
          visual: const _Sketch(_GridSketch()),
          onTap: () => Navigator.of(context).pop(false),
        ),
        TipChoice(
          key: const Key('scene-view-mode-feed'),
          label: l10n.settings_interface_layout_tiktok,
          description: l10n.scene_view_mode_prompt_feed_desc,
          visual: const _Sketch(_FeedSketch()),
          onTap: () => Navigator.of(context).pop(true),
        ),
      ],
      footnote: l10n.scene_view_mode_prompt_settings_hint,
    );
  }
}

/// Sizes a phone sketch relative to its choice tile.
class _Sketch extends StatelessWidget {
  const _Sketch(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      FractionallySizedBox(widthFactor: 0.7, child: child);
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
