import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';

/// Shared shell for scene tool pages such as the tagger and deduplicator.
///
/// Wide layouts keep the configuration in a scrollable side column; compact
/// layouts collapse it into a card above the results.
class SceneToolLayout extends StatelessWidget {
  const SceneToolLayout({
    required this.controlsBuilder,
    required this.results,
    required this.configExpanded,
    required this.onToggleConfig,
    required this.compactConfigHeightFactor,
    super.key,
  });

  /// Builds the configuration; `isWide` is true for the side-column layout.
  final Widget Function(bool isWide) controlsBuilder;
  final Widget results;
  final bool configExpanded;
  final VoidCallback onToggleConfig;

  /// Fraction of the available height the expanded compact card may use.
  final double compactConfigHeightFactor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dims = context.dimensions;
          final isWide = constraints.maxWidth >= 1000 * dims.fontSizeFactor;
          final horizontalPadding = isWide
              ? dims.spacingLarge
              : dims.spacingSmall * 1.5;
          final controls = controlsBuilder(isWide);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  dims.spacingSmall * 1.5,
                  horizontalPadding,
                  0,
                ),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 340 * dims.fontSizeFactor,
                            child: SingleChildScrollView(child: controls),
                          ),
                          SizedBox(
                            width: dims.spacingMedium + dims.spacingSmall / 2,
                          ),
                          Expanded(child: results),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _CompactConfiguration(
                            expanded: configExpanded,
                            maxBodyHeight:
                                constraints.maxHeight *
                                compactConfigHeightFactor,
                            onToggle: onToggleConfig,
                            child: controls,
                          ),
                          SizedBox(height: dims.spacingSmall * 1.5),
                          Expanded(child: results),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactConfiguration extends StatelessWidget {
  const _CompactConfiguration({
    required this.expanded,
    required this.maxBodyHeight,
    required this.onToggle,
    required this.child,
  });

  final bool expanded;
  final double maxBodyHeight;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dims = context.dimensions;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dims.spacingMedium,
                vertical: dims.spacingSmall * 1.5,
              ),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, color: colors.primary),
                  SizedBox(width: dims.spacingSmall * 1.5),
                  Expanded(
                    child: Text(
                      context.l10n.configuration,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxBodyHeight),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  dims.spacingSmall,
                  0,
                  dims.spacingSmall,
                  dims.spacingSmall,
                ),
                child: child,
              ),
            ),
            crossFadeState: expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

/// Icon tile, title, and optional count badge heading a tool panel.
class SceneToolPanelHeading extends StatelessWidget {
  const SceneToolPanelHeading({
    required this.icon,
    required this.title,
    this.badge,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dims = context.dimensions;
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Padding(
            padding: EdgeInsets.all(dims.spacingSmall),
            child: Icon(
              icon,
              size: 20 * dims.fontSizeFactor,
              color: colors.onSecondaryContainer,
            ),
          ),
        ),
        SizedBox(width: dims.spacingSmall * 1.5),
        Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
        if (badge != null)
          Badge(
            label: Text(badge!),
            backgroundColor: colors.secondary,
            textColor: colors.onSecondary,
          ),
      ],
    );
  }
}

/// Previous / "page X of Y" / next pill for client-paged tool results.
class SceneToolPaginationBar extends StatelessWidget {
  const SceneToolPaginationBar({
    required this.page,
    required this.totalPages,
    required this.onPrevious,
    required this.onNext,
    super.key,
  });

  final int page;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dims = context.dimensions;
    return Center(
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dims.spacingSmall * 0.75,
            vertical: dims.spacingSmall / 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: context.l10n.previous_page,
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: dims.spacingSmall),
                  child: Text(
                    context.l10n.scene_deduplication_page_count(
                      page,
                      totalPages,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.next_page,
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Centered card shown when a tool has no results.
class SceneToolEmptyResults extends StatelessWidget {
  const SceneToolEmptyResults({
    required this.icon,
    required this.message,
    super.key,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final dims = context.dimensions;
    return Center(
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dims.spacingMedium * 2,
            vertical: dims.spacingLarge + dims.spacingSmall / 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48 * dims.fontSizeFactor, color: colors.primary),
              SizedBox(height: dims.spacingSmall * 1.5),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
