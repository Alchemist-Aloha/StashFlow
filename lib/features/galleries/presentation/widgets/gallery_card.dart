import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/rating_bottom_sheet.dart';
import '../providers/gallery_list_provider.dart';
import '../../domain/entities/gallery.dart';
import '../providers/gallery_details_provider.dart';

/// A card widget that displays a summary of a [Gallery].
class GalleryCard extends ConsumerWidget {
  const GalleryCard.skeleton({
    required this.isGrid,
    this.useMasonry = false,
    this.onTap,
    this.thumbnailUrl,
    this.memCacheWidth,
    this.memCacheHeight,
    super.key,
  }) : gallery = const Gallery(id: 'skeleton', title: 'Loading'),
       skeletonize = true;

  const GalleryCard({
    required this.gallery,
    this.isGrid = true,
    this.useMasonry = false,
    this.onTap,
    this.thumbnailUrl,
    this.memCacheWidth,
    this.memCacheHeight,
    this.skeletonize = false,
    super.key,
  });

  /// The gallery data to display.
  final Gallery gallery;

  /// Whether to display in a compact grid format or a wide list format.
  final bool isGrid;

  /// Whether to use dynamic aspect ratio in grid mode (for masonry layouts).
  final bool useMasonry;

  /// Callback triggered when the card is tapped.
  final VoidCallback? onTap;

  /// The URL for the thumbnail image.
  final String? thumbnailUrl;

  /// Optional memory cache width for image optimization.
  final int? memCacheWidth;

  /// Optional memory cache height for image optimization.
  final int? memCacheHeight;

  /// Whether to render this card using skeleton placeholders.
  final bool skeletonize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double aspectRatio = 16 / 9;
    if (gallery.coverWidth != null &&
        gallery.coverHeight != null &&
        gallery.coverHeight! > 0) {
      aspectRatio = gallery.coverWidth! / gallery.coverHeight!;
    }

    if (isGrid) {
      return _buildGridCard(context, ref, aspectRatio);
    }
    return _buildListCard(context, ref, aspectRatio);
  }

  Future<void> _showRating(BuildContext context, WidgetRef ref) async {
    await RatingBottomSheet.show(
      context,
      initialRating: gallery.rating100 ?? 0,
      title: '${context.l10n.common_rate} ${gallery.displayName}',
      onRatingSelected: (rating) async {
        try {
          await ref
              .read(galleryRepositoryProvider)
              .updateGalleryRating(gallery.id, rating);

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
              SnackBar(
                content: Text(
                  context.l10n.details_failed_update_rating(e.toString()),
                ),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildListCard(
    BuildContext context,
    WidgetRef ref,
    double aspectRatio,
  ) {
    return Skeletonizer(
      enabled: skeletonize,
      child: Material(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(context, aspectRatio.clamp(0.5, 2.5)),
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
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  context.dimensions.cardTitleFontSize *
                                  context.dimensions.fontSizeFactor,
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
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'More',
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
        ),
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    WidgetRef ref,
    double aspectRatio,
  ) {
    return Skeletonizer(
      enabled: skeletonize,
      child: Material(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(
                context,
                useMasonry ? aspectRatio.clamp(0.5, 2.5) : 16 / 9,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  context.dimensions.cardTitleFontSize *
                                  context.dimensions.fontSizeFactor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (gallery.details != null &&
                              gallery.details!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              gallery.details!,
                              style: context.textTheme.labelSmall?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'More',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => _showRating(context, ref),
                      icon: const Icon(Icons.more_vert, size: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, double? aspectRatio) {
    final imageUrl =
        thumbnailUrl ?? gallery.coverPath ?? '/gallery/${gallery.id}/thumbnail';

    final child = Stack(
      fit: aspectRatio != null ? StackFit.expand : StackFit.loose,
      children: [
        StashImage(
          imageUrl: imageUrl,
          width: double.infinity,
          height: aspectRatio != null ? double.infinity : null,
          fit: aspectRatio != null ? BoxFit.cover : BoxFit.contain,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
        ),
        if (gallery.rating100 != null && gallery.rating100! > 0)
          Positioned(
            top: isGrid ? 4 : 8,
            right: isGrid ? 4 : 8,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isGrid ? 4 : 6,
                vertical: isGrid ? 1 : 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(200),
                borderRadius: BorderRadius.circular(isGrid ? 2 : 4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.amber, size: isGrid ? 10 : 14),
                  SizedBox(width: isGrid ? 2 : 4),
                  Text(
                    (gallery.rating100! / 20).toStringAsFixed(1),
                    style:
                        (isGrid
                                ? context.textTheme.labelSmall
                                : context.textTheme.labelMedium)
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                  ),
                ],
              ),
            ),
          ),
        if (gallery.imageCount != null && gallery.imageCount! > 0)
          Positioned(
            bottom: isGrid ? 4 : 8,
            right: isGrid ? 4 : 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(200),
                borderRadius: BorderRadius.circular(2),
              ),
              child: isGrid
                  ? Text(
                      '${gallery.imageCount}',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                      ),
                    )
                  : Row(
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
                          style: context.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
      ],
    );

    return aspectRatio != null
        ? AspectRatio(aspectRatio: aspectRatio, child: child)
        : child;
  }
}
