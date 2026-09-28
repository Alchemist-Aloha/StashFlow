import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/widgets/rating_bottom_sheet.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/image.dart' as entity;
import '../providers/image_list_provider.dart';
import 'image_details_bottom_sheet.dart';

class ImageCard extends ConsumerWidget {
  const ImageCard.skeleton({
    this.onTap,
    this.memCacheWidth,
    this.focusNode,
    super.key,
  }) : image = const entity.Image(
         id: 'skeleton',
         title: 'Loading',
         rating100: null,
         date: null,
         urls: [],
         files: [entity.ImageFile(width: 1, height: 1, path: '')],
         paths: entity.ImagePaths(thumbnail: '', preview: '', image: ''),
       );

  const ImageCard({
    required this.image,
    this.onTap,
    this.memCacheWidth,
    this.focusNode,
    super.key,
  });

  final entity.Image image;
  final VoidCallback? onTap;
  final int? memCacheWidth;

  /// Optional focus node used to restore keyboard focus after fullscreen.
  final FocusNode? focusNode;

  Future<void> _showDetails(BuildContext context, WidgetRef ref) async {
    await RatingBottomSheet.show(
      context,
      initialRating: image.rating100 ?? 0,
      title: context.l10n.details_image,
      subtitle: ImageDetailsContent.displayTitle(image),
      detailsWidget: ImageDetailsContent(image: image),
      onRatingSelected: (rating) async {
        try {
          await ref
              .read(imageRepositoryProvider)
              .updateImageRating(image.id, rating);
          ref
              .read(imageListProvider.notifier)
              .updateImageInList(image.copyWith(rating100: rating));
        } catch (error) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.details_failed_update_rating(error.toString()),
              ),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double aspectRatio =
        (image.files.isNotEmpty &&
            image.files.first.width > 0 &&
            image.files.first.height > 0)
        ? image.files.first.width.toDouble() /
              image.files.first.height.toDouble()
        : 1.0;

    return Skeletonizer(
      enabled: image.id == 'skeleton',
      effect: const ShimmerEffect(duration: Duration(seconds: 2)),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          focusNode: focusNode,
          onTap: onTap ?? () => context.push('/galleries/images/${image.id}'),
          onLongPress: image.id == 'skeleton'
              ? null
              : () => _showDetails(context, ref),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: AspectRatio(
              aspectRatio: aspectRatio.clamp(0.5, 2.0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  StashImage(
                    imageUrl: image.paths.thumbnail ?? image.paths.preview,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    memCacheWidth: memCacheWidth,
                  ),
                  if (image.rating100 != null && image.rating100! > 0)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSmall,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: context.colors.ratingColor,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              (image.rating100! / 20).toStringAsFixed(1),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}
