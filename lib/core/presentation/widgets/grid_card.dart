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

  @override
  Widget build(BuildContext context) {
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
                    memCacheWidth: 400,
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
                          color: context.colors.primary.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge!,
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colors.onPrimary,
                            fontWeight: FontWeight.bold,
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: context.colors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: context.colors.onSurface.withValues(alpha: 0.75),
                      fontSize: 10,
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
}
