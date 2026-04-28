import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';
import '../../data/graphql/stats_repository.dart';
import '../theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class StatsFloatingPanel extends ConsumerWidget {
  const StatsFloatingPanel({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Stats',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return const Center(
          child: StatsFloatingPanel(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: anim1,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(serverStatsProvider);
    final l10n = AppLocalizations.of(context)!;
    final dims = context.dimensions;

    return Container(
      width: 320 * dims.fontSizeFactor,
      margin: EdgeInsets.all(dims.spacingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(dims.spacingMedium),
              child: Row(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24 * dims.fontSizeFactor,
                  ),
                  SizedBox(width: dims.spacingSmall),
                  Expanded(
                    child: Text(
                      'Server Statistics',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: statsAsync.when(
                data: (stats) => _buildStatsList(context, stats, dims, l10n),
                loading: () => Padding(
                  padding: EdgeInsets.all(dims.spacingLarge),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => Padding(
                  padding: EdgeInsets.all(dims.spacingLarge),
                  child: Text('Error: $err'),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(dims.spacingSmall),
              child: TextButton(
                onPressed: () => ref.invalidate(serverStatsProvider),
                child: const Text('Refresh'),
              ),
            ),
          ],
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
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(vertical: dims.spacingSmall),
      children: [
        _StatItem(
          icon: Icons.movie_outlined,
          label: 'Scenes',
          value: '${stats.sceneCount}',
          subtitle: _formatBytes(stats.scenesSize),
        ),
        _StatItem(
          icon: Icons.image_outlined,
          label: 'Images',
          value: '${stats.imageCount}',
          subtitle: _formatBytes(stats.imagesSize),
        ),
        _StatItem(
          icon: Icons.collections_outlined,
          label: 'Galleries',
          value: '${stats.galleryCount}',
        ),
        _StatItem(
          icon: Icons.people_outline,
          label: 'Performers',
          value: '${stats.performerCount}',
        ),
        _StatItem(
          icon: Icons.business_outlined,
          label: 'Studios',
          value: '${stats.studioCount}',
        ),
        _StatItem(
          icon: Icons.folder_open_outlined,
          label: 'Groups',
          value: '${stats.groupCount}',
        ),
        _StatItem(
          icon: Icons.label_outline,
          label: 'Tags',
          value: '${stats.tagCount}',
        ),
        const Divider(),
        _StatItem(
          icon: Icons.play_circle_outline,
          label: 'Total Plays',
          value: '${stats.totalPlayCount}',
          subtitle: '${stats.scenesPlayed} unique scenes',
        ),
        _StatItem(
          icon: Icons.favorite_border,
          label: 'Total O-Count',
          value: '${stats.totalOCount}',
        ),
      ],
    );
  }

  String _formatBytes(double bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    // Simple log logic or loop
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

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dims.spacingMedium,
        vertical: dims.spacingSmall / 2,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20 * dims.fontSizeFactor, color: context.colors.onSurfaceVariant),
          SizedBox(width: dims.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.textTheme.bodyMedium),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
