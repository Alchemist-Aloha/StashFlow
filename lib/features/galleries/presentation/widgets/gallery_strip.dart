import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/gallery.dart';
import 'gallery_card.dart';

class GalleryStrip extends ConsumerStatefulWidget {
  const GalleryStrip({super.key, required this.galleries, this.onTap});

  final List<Gallery> galleries;
  final void Function(Gallery)? onTap;

  @override
  ConsumerState<GalleryStrip> createState() => _GalleryStripState();
}

class _GalleryStripState extends ConsumerState<GalleryStrip> {
  final ScrollController _scrollController = ScrollController();
  int _lastVisibleIndex = -1;

  @override
  void initState() {
    super.initState();
    _scheduleInitialPrefetch();
  }

  @override
  void didUpdateWidget(GalleryStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.galleries, widget.galleries)) {
      _lastVisibleIndex = -1;
      _scheduleInitialPrefetch();
    }
  }

  void _scheduleInitialPrefetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final galleries = widget.galleries;
      final effectiveItemWidth = 220 * context.dimensions.fontSizeFactor;
      final initialCount = galleries.length < StashImage.defaultPrefetchDistance
          ? galleries.length
          : StashImage.defaultPrefetchDistance;
      for (var i = 0; i < initialCount; i++) {
        StashImage.prefetch(
          context,
          imageUrl:
              galleries[i].coverPath ?? '/gallery/${galleries[i].id}/thumbnail',
          memCacheWidth: (effectiveItemWidth * 2).toInt(),
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galleries = widget.galleries;
    final onTap = widget.onTap;
    final effectiveItemWidth = 220 * context.dimensions.fontSizeFactor;

    if (galleries.isEmpty) {
      return const SizedBox.shrink();
    }

    final int kPrefetchDistance = StashImage.defaultPrefetchDistance;

    final contentPadding = context.dimensions.spacingMedium;
    final separatorWidth = context.dimensions.spacingSmall;
    final stride = effectiveItemWidth + separatorWidth;

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

          // ⚡ Bolt: Skip redundant prefetching if the visible index hasn't changed.
          // Scroll events fire rapidly; throttling by index prevents repeated
          // loop iterations and hash lookups on every single frame.
          if (visibleIndex == _lastVisibleIndex) return false;
          _lastVisibleIndex = visibleIndex;

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
        child: Scrollbar(
          controller: _scrollController,
          interactive: true,
          thumbVisibility: true,
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(
              horizontal: context.dimensions.spacingMedium,
            ),
            scrollDirection: Axis.horizontal,
            itemExtent: stride,
            itemCount: galleries.length,
            itemBuilder: (context, index) {
              final gallery = galleries[index];

              return Padding(
                padding: EdgeInsets.only(
                  right: index == galleries.length - 1 ? 0 : separatorWidth,
                ),
                child: SizedBox(
                  width: effectiveItemWidth,
                  child: GalleryCard(
                    gallery: gallery,
                    isGrid: true,
                    onTap: onTap == null ? null : () => onTap(gallery),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
