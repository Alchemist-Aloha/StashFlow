import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/l10n_extensions.dart';

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
          final isWide = constraints.maxWidth >= 1000;
          final horizontalPadding = isWide ? 24.0 : 12.0;
          final controls = controlsBuilder(isWide);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  12,
                  horizontalPadding,
                  0,
                ),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            width: 340,
                            child: SingleChildScrollView(child: controls),
                          ),
                          const SizedBox(width: 20),
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
                          const SizedBox(height: 12),
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
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.tune_rounded, color: colors.primary),
                  const SizedBox(width: 12),
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
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
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
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: colors.onSecondaryContainer),
          ),
        ),
        const SizedBox(width: 12),
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
    return Center(
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: context.l10n.previous_page,
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  context.l10n.scene_deduplication_page_count(page, totalPages),
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
    return Center(
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: colors.primary),
              const SizedBox(height: 12),
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
