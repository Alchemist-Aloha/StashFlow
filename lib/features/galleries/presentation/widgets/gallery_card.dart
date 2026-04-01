import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/gallery.dart';

/// A card widget that displays a summary of a [Gallery].
class GalleryCard extends StatelessWidget {
  const GalleryCard({
    required this.gallery,
    this.isGrid = true,
    this.onTap,
    this.thumbnailUrl,
    this.memCacheWidth,
    super.key,
  });

  /// The gallery data to display.
  final Gallery gallery;

  /// Whether to display in a compact grid format or a wide list format.
  final bool isGrid;

  /// Callback triggered when the card is tapped.
  final VoidCallback? onTap;

  /// The URL for the thumbnail image.
  final String? thumbnailUrl;

  /// Optional memory cache width for image optimization.
  final int? memCacheWidth;

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return _buildGridCard(context);
    }
    return _buildListCard(context);
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
                children: [
                  StashImage(
                    imageUrl: thumbnailUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: memCacheWidth,
                  ),
                  if (gallery.imageCount != null && gallery.imageCount! > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${gallery.imageCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gallery.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: context.colors.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if ((gallery.details != null &&
                              gallery.details!.isNotEmpty) ||
                          gallery.date != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (gallery.details != null &&
                                gallery.details!.isNotEmpty)
                              gallery.details,
                            if (gallery.date != null)
                              gallery.date!.split('-').first,
                          ].join(' • '),
                          style: TextStyle(
                            color: context.colors.onSurface.withValues(
                              alpha: 0.75,
                            ),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                children: [
                  StashImage(
                    imageUrl: thumbnailUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: memCacheWidth,
                  ),
                  if (gallery.imageCount != null && gallery.imageCount! > 0)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '${gallery.imageCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gallery.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: context.colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (gallery.details != null &&
                          gallery.details!.isNotEmpty)
                        Text(
                          gallery.details!,
                          style: TextStyle(
                            color: context.colors.onSurface.withValues(
                              alpha: 0.75,
                            ),
                            fontSize: 9,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
