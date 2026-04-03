import 'package:flutter/material.dart';
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
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
        child: Text('No media available.'),
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
          memCacheWidth: (itemWidth * 2).toInt(),
        );
      }
    });

    return SizedBox(
      height: height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis != Axis.horizontal || items.isEmpty) {
            return false;
          }

          final offset = notification.metrics.pixels;
          // Account for left padding and separator width to compute the item stride.
          final contentPadding = AppTheme.spacingMedium;
          final separatorWidth = AppTheme.spacingSmall;
          final stride = itemWidth + separatorWidth;
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
                memCacheWidth: (itemWidth * 2).toInt(),
              );
            }
            final behind = visibleIndex - i;
            if (behind >= 0) {
              StashImage.prefetch(
                context,
                imageUrl: items[behind].thumbnailUrl,
                headers: headers,
                memCacheWidth: (itemWidth * 2).toInt(),
              );
            }
          }
          return false;
        },
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMedium,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) =>
              const SizedBox(width: AppTheme.spacingSmall),
          itemBuilder: (context, index) {
            final item = items[index];

            // Remove the redundant addPostFrameCallback that was triggering
            // a full-size un-optimized prefetch dynamically as items built.
            // The initial and scroll-based prefetching accurately handle warming
            // the cache with memCacheWidth constraints.

            return RepaintBoundary(
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                child: SizedBox(
                  width: itemWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                        child: StashImage(
                          imageUrl: item.thumbnailUrl,
                          width: itemWidth,
                          height: itemWidth * (9 / 16),
                          fit: BoxFit.cover,
                          memCacheWidth: (itemWidth * 2).toInt(),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
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
