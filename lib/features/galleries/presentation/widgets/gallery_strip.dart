import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/gallery.dart';
import 'gallery_card.dart';

class GalleryStrip extends ConsumerWidget {
  const GalleryStrip({
    super.key,
    required this.galleries,
    this.itemWidth = 220,
    this.onTap,
  });

  final List<Gallery> galleries;
  final double itemWidth;
  final void Function(Gallery)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveItemWidth = itemWidth * context.dimensions.fontSizeFactor;

    if (galleries.isEmpty) {
      return const SizedBox.shrink();
    }

    final int kPrefetchDistance = StashImage.defaultPrefetchDistance;

    final contentPadding = context.dimensions.spacingMedium;
    final separatorWidth = context.dimensions.spacingSmall;
    final stride = effectiveItemWidth + separatorWidth;

    // Initial prefetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialCount = galleries.length < kPrefetchDistance
          ? galleries.length
          : kPrefetchDistance;
      for (var i = 0; i < initialCount; i++) {
        StashImage.prefetch(
          context,
          imageUrl:
              galleries[i].coverPath ?? '/gallery/${galleries[i].id}/thumbnail',
          memCacheWidth: (effectiveItemWidth * 2).toInt(),
        );
      }
    });

    return SizedBox(
      height:
          effectiveItemWidth * (9 / 16) +
          (80 * context.dimensions.fontSizeFactor),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis != Axis.horizontal ||
              galleries.isEmpty) {
            return false;
          }

          final offset = notification.metrics.pixels;
          final visibleIndex = ((offset + contentPadding) / stride)
              .floor()
              .clamp(0, galleries.length - 1);

          for (var i = 1; i <= kPrefetchDistance; i++) {
            final ahead = visibleIndex + i;
            if (ahead < galleries.length) {
              StashImage.prefetch(
                context,
                imageUrl:
                    galleries[ahead].coverPath ??
                    '/gallery/${galleries[ahead].id}/thumbnail',
                memCacheWidth: (effectiveItemWidth * 2).toInt(),
              );
            }
            final behind = visibleIndex - i;
            if (behind >= 0) {
              StashImage.prefetch(
                context,
                imageUrl:
                    galleries[behind].coverPath ??
                    '/gallery/${galleries[behind].id}/thumbnail',
                memCacheWidth: (effectiveItemWidth * 2).toInt(),
              );
            }
          }
          return false;
        },
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: context.dimensions.spacingMedium,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: galleries.length,
          separatorBuilder: (_, _) =>
              SizedBox(width: context.dimensions.spacingSmall),
          itemBuilder: (context, index) {
            final gallery = galleries[index];

            return SizedBox(
              width: effectiveItemWidth,
              child: GalleryCard(
                gallery: gallery,
                isGrid: true,
                onTap: onTap != null ? () => onTap!(gallery) : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
