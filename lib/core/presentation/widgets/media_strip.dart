import 'package:flutter/material.dart';
import '../../utils/l10n_extensions.dart';
import '../theme/app_theme.dart';
import 'stash_image.dart';

class MediaStripItem {
  const MediaStripItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.onTap,
  });

  final String id;
  final String title;
  final String thumbnailUrl;
  final VoidCallback onTap;
}

class MediaStrip extends StatelessWidget {
  const MediaStrip({
    super.key,
    required this.items,
    this.height = 160,
    this.itemWidth = 200,
    this.headers,
  });

  final List<MediaStripItem> items;
  final double height;
  final double itemWidth;
  final Map<String, String>? headers;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height * context.dimensions.fontSizeFactor;
    final effectiveItemWidth = itemWidth * context.dimensions.fontSizeFactor;

    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.dimensions.spacingMedium),
        child: Text(context.l10n.common_no_media),
      );
    }

    final int kPrefetchDistance = StashImage.defaultPrefetchDistance;

    // Initial prefetch for the first visible range so items off-screen
    // are warmed before the user scrolls. Also compute stride to account
    // for separators and padding so visible index calculation matches layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialCount = items.length < kPrefetchDistance
          ? items.length
          : kPrefetchDistance;
      for (var i = 0; i < initialCount; i++) {
        StashImage.prefetch(
          context,
          imageUrl: items[i].thumbnailUrl,
          headers: headers,
          memCacheWidth: (effectiveItemWidth * 2).toInt(),
        );
      }
    });

    return SizedBox(
      height: effectiveHeight,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis != Axis.horizontal || items.isEmpty) {
            return false;
          }

          final offset = notification.metrics.pixels;
          // Account for left padding and separator width to compute the item stride.
          final contentPadding = context.dimensions.spacingMedium;
          final separatorWidth = context.dimensions.spacingSmall;
          final stride = effectiveItemWidth + separatorWidth;
          final visibleIndex = ((offset + contentPadding) / stride)
              .floor()
              .clamp(0, items.length - 1);

          for (var i = 1; i <= kPrefetchDistance; i++) {
            final ahead = visibleIndex + i;
            if (ahead < items.length) {
              StashImage.prefetch(
                context,
                imageUrl: items[ahead].thumbnailUrl,
                headers: headers,
                memCacheWidth: (effectiveItemWidth * 2).toInt(),
              );
            }
            final behind = visibleIndex - i;
            if (behind >= 0) {
              StashImage.prefetch(
                context,
                imageUrl: items[behind].thumbnailUrl,
                headers: headers,
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
          itemCount: items.length,
          separatorBuilder: (_, _) =>
              SizedBox(width: context.dimensions.spacingSmall),
          itemBuilder: (context, index) {
            final item = items[index];

            // Remove the redundant addPostFrameCallback that was triggering
            // a full-size un-optimized prefetch dynamically as items built.
            // The initial and scroll-based prefetching accurately handle warming
            // the cache with memCacheWidth constraints.

            return RepaintBoundary(
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(
                  AppTheme.radiusMedium * context.dimensions.fontSizeFactor,
                ),
                child: SizedBox(
                  width: effectiveItemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium * context.dimensions.fontSizeFactor,
                        ),
                        child: StashImage(
                          imageUrl: item.thumbnailUrl,
                          width: effectiveItemWidth,
                          height: effectiveItemWidth * (9 / 16),
                          fit: BoxFit.cover,
                          memCacheWidth: (effectiveItemWidth * 2).toInt(),
                        ),
                      ),
                      SizedBox(height: context.dimensions.spacingSmall),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
