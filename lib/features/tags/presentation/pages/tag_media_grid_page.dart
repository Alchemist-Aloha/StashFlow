import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/pagination.dart';
import '../providers/tag_media_provider.dart';

class TagMediaGridPage extends ConsumerWidget {
  final String tagId;

  const TagMediaGridPage({required this.tagId, super.key});

  int _getGridColumnCount(BuildContext context) {
    return Responsive.isMobile(context) ? 2 : 3;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(tagMediaGridProvider(tagId));

    return Scaffold(
      appBar: AppBar(title: const Text('Tag Media')),
      body: mediaAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No media available.'));
          }

          final int kPrefetchDistance = StashImage.defaultPrefetchDistance;
          final padding = 12.0;
          final crossAxisCount = _getGridColumnCount(context);
          const crossAxisSpacing = 10.0;
          const mainAxisSpacing = 10.0;
          final availableWidth =
              MediaQuery.of(context).size.width - padding * 2;
          final itemWidth =
              (availableWidth - (crossAxisSpacing * (crossAxisCount - 1))) /
              crossAxisCount;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            final initialCount = items.length < kPrefetchDistance
                ? items.length
                : kPrefetchDistance;
            for (var i = 0; i < initialCount; i++) {
              StashImage.prefetch(
                context,
                imageUrl: items[i].thumbnailUrl,
                headers: null,
                memCacheWidth: (itemWidth * 2).toInt(),
              );
            }
          });

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (shouldLoadNextPage(scrollInfo.metrics)) {
                ref.read(tagMediaGridProvider(tagId).notifier).fetchNextPage();
              }

              // Prefetch on scroll
              if (scrollInfo is ScrollUpdateNotification) {
                final offset = scrollInfo.metrics.pixels;
                final itemHeight = itemWidth * (12 / 16);
                final stride = itemHeight + mainAxisSpacing;
                final visibleRow = (offset / stride).floor();
                final visibleIndex = visibleRow * crossAxisCount;

                for (var i = 1; i <= kPrefetchDistance; i++) {
                  final ahead = (visibleIndex + i).clamp(0, items.length - 1);
                  StashImage.prefetch(
                    context,
                    imageUrl: items[ahead].thumbnailUrl,
                    memCacheWidth: (itemWidth * 2).toInt(),
                  );
                }
              }

              return false;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 16 / 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return InkWell(
                  onTap: () => context.push('/scenes/scene/${item.sceneId}'),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        StashImage(
                          imageUrl: item.thumbnailUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: (itemWidth * 2).toInt(),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
