import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../domain/entities/scene.dart';
import 'scene_card.dart';

class SceneStrip extends ConsumerWidget {
  const SceneStrip({
    super.key,
    required this.scenes,
    this.itemWidth = 220,
    this.onTap,
  });

  final List<Scene> scenes;
  final double itemWidth;
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
        child: ListView.separated(
          padding: EdgeInsets.symmetric(
            horizontal: context.dimensions.spacingMedium,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: scenes.length,
          separatorBuilder: (_, _) =>
              SizedBox(width: context.dimensions.spacingSmall),
          itemBuilder: (context, index) {
            final scene = scenes[index];

            return SizedBox(
              width: effectiveItemWidth,
              child: SceneCard(
                scene: scene,
                isGrid: true,
                showPerformers: false,
                useHero: false,
                onTap: onTap != null ? () => onTap!(scene) : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
