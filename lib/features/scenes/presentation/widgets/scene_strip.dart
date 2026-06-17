import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/scene.dart';
import '../providers/playback_queue_provider.dart';
import 'scene_card.dart';

class SceneStrip extends ConsumerWidget {
  const SceneStrip({
    super.key,
    required this.scenes,
    this.itemWidth = 220,
    this.queueId,
    this.onTap,
  });

  final List<Scene> scenes;
  final double itemWidth;
  final String? queueId;
  final void Function(Scene)? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveItemWidth = itemWidth * context.dimensions.fontSizeFactor;

    if (scenes.isEmpty) {
      return const SizedBox.shrink();
    }

    final int kPrefetchDistance = StashImage.defaultPrefetchDistance;

    final contentPadding = context.dimensions.spacingMedium;
    final separatorWidth = context.dimensions.spacingSmall;
    final stride = effectiveItemWidth + separatorWidth;

    // Initial prefetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final initialCount = scenes.length < kPrefetchDistance
          ? scenes.length
          : kPrefetchDistance;
      for (var i = 0; i < initialCount; i++) {
        StashImage.prefetch(
          context,
          imageUrl: scenes[i].paths.screenshot,
          memCacheWidth: (effectiveItemWidth * 2).toInt(),
        );
      }
    });

    var lastVisibleIndex = -1;

    return SizedBox(
      height:
          effectiveItemWidth * (9 / 16) +
          (80 *
              context
                  .dimensions
                  .fontSizeFactor), // Estimate height based on SceneCard needs
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis != Axis.horizontal || scenes.isEmpty) {
            return false;
          }

          final offset = notification.metrics.pixels;
          final visibleIndex = ((offset + contentPadding) / stride)
              .floor()
              .clamp(0, scenes.length - 1);

          // ⚡ Bolt: Skip redundant prefetching if the visible index hasn't changed.
          // Scroll events fire rapidly; throttling by index prevents repeated
          // loop iterations and hash lookups on every single frame.
          if (visibleIndex == lastVisibleIndex) return false;
          lastVisibleIndex = visibleIndex;

          for (var i = 1; i <= kPrefetchDistance; i++) {
            final ahead = visibleIndex + i;
            if (ahead < scenes.length) {
              StashImage.prefetch(
                context,
                imageUrl: scenes[ahead].paths.screenshot,
                memCacheWidth: (effectiveItemWidth * 2).toInt(),
              );
            }
            final behind = visibleIndex - i;
            if (behind >= 0) {
              StashImage.prefetch(
                context,
                imageUrl: scenes[behind].paths.screenshot,
                memCacheWidth: (effectiveItemWidth * 2).toInt(),
              );
            }
          }
          return false;
        },
        child: Scrollbar(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: context.dimensions.spacingMedium,
            ),
            scrollDirection: Axis.horizontal,
            itemExtent: stride,
            itemCount: scenes.length,
            itemBuilder: (context, index) {
              final scene = scenes[index];

              return Padding(
                padding: EdgeInsets.only(
                  right: index == scenes.length - 1 ? 0 : separatorWidth,
                ),
                child: SizedBox(
                  width: effectiveItemWidth,
                  child: SceneCard(
                    scene: scene,
                    isGrid: true,
                    showPerformers: false,
                    useHero: false,
                    onTap: queueId != null || onTap != null
                        ? () {
                            final playbackQueueId = queueId;
                            if (playbackQueueId != null) {
                              ref
                                  .read(playbackQueueProvider.notifier)
                                  .setSequence(
                                    scenes,
                                    index,
                                    queueId: playbackQueueId,
                                  );
                            }
                            onTap?.call(scene);
                          }
                        : null,
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
