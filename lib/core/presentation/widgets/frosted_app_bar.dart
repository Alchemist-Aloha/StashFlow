import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'frosted_surface.dart';

/// An [AppBar] sitting on a frosted backdrop.
///
/// The frost is painted behind the bar instead of inside its `flexibleSpace`,
/// so it takes the bar's real height and the automatic status-bar inset without
/// fighting unbounded layout constraints; the bar itself goes transparent so
/// the glass and the rows scrolling under it are what the header is made of.
///
/// Pass an [AppBar] with a transparent background. Pages using it in
/// `Scaffold.appBar` set `extendBodyBehindAppBar` and give their scroll view a
/// top inset of [topInset] so content starts below the bar and scrolls under it.
class FrostedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FrostedAppBar({
    required this.bar,
    this.tintAlpha = AppTheme.frostedChromeAlpha,
    this.blur = true,
    super.key,
  });

  final AppBar bar;

  /// Surface tint alpha; floating bars use a stronger tint.
  final double tintAlpha;

  /// Whether to blur the backdrop; off while an auto-hide bar is off screen.
  final bool blur;

  @override
  Size get preferredSize => bar.preferredSize;

  /// Height the bar covers from the top of [context]'s screen area, status bar
  /// included. Call it with a context above the bar's [Scaffold].
  double topInset(BuildContext context) =>
      MediaQuery.paddingOf(context).top + preferredSize.height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: FrostedSurface(
            tint: context.colors.surface.withValues(alpha: tintAlpha),
            blurSigma: blur ? AppTheme.frostedBlurSigma : 0,
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withValues(
                  alpha: AppTheme.frostedHairlineAlpha,
                ),
              ),
            ),
            child: const SizedBox.shrink(),
          ),
        ),
        bar,
      ],
    );
  }
}
