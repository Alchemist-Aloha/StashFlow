import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/rating_bottom_sheet.dart';
import '../providers/gallery_list_provider.dart';
import '../../domain/entities/gallery.dart';
import '../providers/gallery_details_provider.dart';

/// A card widget that displays a summary of a [Gallery].
class GalleryCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (isGrid) {
      return _buildGridCard(context, ref);
    }
    return _buildListCard(context, ref);
  }

  Future<void> _showRating(BuildContext context, WidgetRef ref) async {
    await RatingBottomSheet.show(
      context,
      initialRating: gallery.rating100 ?? 0,
      title: 'Rate ${gallery.displayName}',
      onRatingSelected: (rating) async {
        try {
          await ref.read(galleryRepositoryProvider).updateGalleryRating(
                gallery.id,
                rating,
              );

          // Fetch fresh data for the specific gallery to ensure UI is in sync
          final updatedGallery = await ref
              .read(galleryRepositoryProvider)
              .getGalleryById(gallery.id, refresh: true);

          // Update the list state with the new info to avoid full reshuffle
          ref
              .read(galleryListProvider.notifier)
              .updateGalleryInList(updatedGallery);

          // If anyone else is watching this specific gallery's details, update them
          ref.invalidate(galleryDetailsProvider(gallery.id));
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to update rating: $e')),
            );
          }
        }
      },
    );
  }

  Widget _buildListCard(BuildContext context, WidgetRef ref) {
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
                  if (gallery.rating100 != null && gallery.rating100! > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (gallery.rating100! / 20).toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                  onPressed: () => _showRating(context, ref),
                  icon: const Icon(Icons.more_vert, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, WidgetRef ref) {
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
                  if (gallery.rating100 != null && gallery.rating100! > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(200),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (gallery.rating100! / 20).toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                InkWell(
                  onTap: () => _showRating(context, ref),
                  child: const Icon(Icons.more_vert, size: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
