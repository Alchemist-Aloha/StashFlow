import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'stash_image.dart';

/// A generic card widget for grid layouts.
///
/// This component provides a consistent visual style for grid items,
/// including a 16:9 thumbnail, title, optional subtitle, and badge.
class GridCard extends StatelessWidget {
  const GridCard({
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.onTap,
    this.badge,
    this.isGrid = true,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  });

  /// The primary title shown below the image.
  final String title;

  /// An optional secondary description shown below the title.
  final String? subtitle;

  /// The URL for the thumbnail image.
  final String? imageUrl;

  /// Callback triggered when the card is tapped.
  final VoidCallback? onTap;

  /// An optional label shown in a badge over the image.
  final String? badge;

  /// Whether to display in a compact grid format or a wide list format.
  final bool isGrid;

  /// Optional memory cache width for image optimization.
  final int? memCacheWidth;

  /// Optional memory cache height for image optimization.
  final int? memCacheHeight;

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
  }

  Widget _buildGridCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  StashImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: memCacheWidth,
                    memCacheHeight: memCacheHeight,
                  ),
                  if (badge != null)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge!,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  StashImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: memCacheWidth,
                    memCacheHeight: memCacheHeight,
                  ),
                  if (badge != null)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          badge!,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
