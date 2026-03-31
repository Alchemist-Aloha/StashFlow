import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/grid_card.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../domain/entities/gallery.dart';

/// A card widget that displays a summary of a [Gallery].
///
/// It supports two layout modes: Grid (compact) and List (full-width).
class GalleryCard extends StatelessWidget {
  const GalleryCard({
    required this.gallery,
    this.isGrid = true,
    this.onTap,
    this.thumbnailUrl,
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
                    memCacheWidth: 640,
                  ),
                  if (gallery.imageCount != null && gallery.imageCount! > 0)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${gallery.imageCount} images',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
            padding: const EdgeInsets.all(12.0),
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
                const SizedBox(height: 4),
                Text(
                  (gallery.details?.isNotEmpty == true)
                      ? gallery.details!
                      : '${gallery.imageCount ?? 0} images',
                  style: TextStyle(
                    color: context.colors.onSurface.withValues(alpha: 0.75),
                    fontSize: 12,
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

  Widget _buildGridCard(BuildContext context) {
    return GridCard(
      title: gallery.displayName,
      subtitle:
          (gallery.details?.isNotEmpty == true)
              ? gallery.details
              : '${gallery.imageCount ?? 0} images',
      imageUrl: thumbnailUrl,
      onTap: onTap,
      badge:
          (gallery.imageCount != null && gallery.imageCount! > 0)
              ? '${gallery.imageCount}'
              : null,
    );
  }
}
