import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';
import '../../data/graphql/stats_repository.dart';
import '../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class StatsFloatingPanel extends ConsumerWidget {
  const StatsFloatingPanel({super.key});

  static void show(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Stats',
      barrierColor: colorScheme.scrim.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const Center(
          child: StatsFloatingPanel(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(
            opacity: anim1.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(serverStatsProvider);
    final l10n = AppLocalizations.of(context)!;
    final dims = context.dimensions;
    final colorScheme = Theme.of(context).colorScheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: 340 * dims.fontSizeFactor,
        margin: EdgeInsets.all(dims.spacingLarge),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
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
          borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, dims, colorScheme),
              Flexible(
                child: statsAsync.when(
                  data: (stats) => _buildStatsList(context, stats, dims, l10n),
                  loading: () => Padding(
                    padding: EdgeInsets.all(dims.spacingLarge * 2),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Padding(
                    padding: EdgeInsets.all(dims.spacingLarge),
                    child: Text(
                      'Error: $err',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ),
              ),
              _buildFooter(context, dims, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppDimensions dims, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        dims.spacingMedium * 1.5,
        dims.spacingMedium * 1.5,
        dims.spacingMedium,
        dims.spacingSmall,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(dims.spacingSmall),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: colorScheme.primary,
              size: 24 * dims.fontSizeFactor,
            ),
          ),
          SizedBox(width: dims.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.stats_library_stats,
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.stats_stash_glance,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.close_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AppDimensions dims, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(dims.spacingMedium),
      child: FilledButton.tonalIcon(
        onPressed: () => ref.invalidate(serverStatsProvider),
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: Text(AppLocalizations.of(context)!.stats_refresh_statistics),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsList(
    BuildContext context,
    StatsResult stats,
    AppDimensions dims,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(
        horizontal: dims.spacingMedium,
        vertical: dims.spacingSmall,
      ),
      children: [
        _buildSectionTitle(context, l10n.stats_content),
        _StatItem(
          icon: Icons.movie_filter_rounded,
          label: l10n.stats_scenes,
          value: '${stats.sceneCount}',
          subtitle: _formatBytes(stats.scenesSize),
        ),
        _StatItem(
          icon: Icons.photo_library_rounded,
          label: l10n.images_title,
          value: '${stats.imageCount}',
          subtitle: _formatBytes(stats.imagesSize),
        ),
        _StatItem(
          icon: Icons.auto_stories_rounded,
          label: l10n.stats_galleries,
          value: '${stats.galleryCount}',
        ),
        SizedBox(height: dims.spacingSmall),
        _buildSectionTitle(context, l10n.stats_organization),
        _StatItem(
          icon: Icons.face_retouching_natural_rounded,
          label: l10n.stats_performers,
          value: '${stats.performerCount}',
        ),
        _StatItem(
          icon: Icons.storefront_rounded,
          label: l10n.stats_studios,
          value: '${stats.studioCount}',
        ),
        _StatItem(
          icon: Icons.workspaces_rounded,
          label: l10n.stats_groups,
          value: '${stats.groupCount}',
        ),
        _StatItem(
          icon: Icons.local_offer_rounded,
          label: l10n.stats_tags,
          value: '${stats.tagCount}',
        ),
        SizedBox(height: dims.spacingSmall),
        _buildSectionTitle(context, l10n.stats_activity),
        _StatItem(
          icon: Icons.play_lesson_rounded,
          label: l10n.stats_total_plays,
          value: '${stats.totalPlayCount}',
          subtitle: l10n.stats_unique_items(stats.scenesPlayed),
        ),
        _StatItem(
          icon: Icons.favorite_rounded,
          label: l10n.stats_total_o_count,
          value: '${stats.totalOCount}',
          color: colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final dims = context.dimensions;
    return Padding(
      padding: EdgeInsets.only(
        left: dims.spacingSmall,
        bottom: dims.spacingSmall,
        top: dims.spacingSmall,
      ),
      child: Text(
        title.toUpperCase(),
        style: context.textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatBytes(double bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    int unit = 0;
    double size = bytes;
    while (size >= 1024 && unit < suffixes.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(2)} ${suffixes[unit]}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: dims.spacingSmall),
      child: Container(
        padding: EdgeInsets.all(dims.spacingMedium),
        decoration: BoxDecoration(
          color: colorScheme.surface.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22 * dims.fontSizeFactor,
              color: color ?? colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: dims.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              value,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: color ?? colorScheme.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
