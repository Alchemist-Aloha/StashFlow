import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/studio_media_provider.dart';

class StudioMediaGridPage extends ConsumerWidget {
  final String studioId;

  const StudioMediaGridPage({required this.studioId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(studioMediaGridProvider(studioId));

    return Scaffold(
      appBar: AppBar(title: const Text('All Studio Media')),
      body: mediaAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No media available.'));
          }

          final int kPrefetchDistance = StashImage.defaultPrefetchDistance;
          final padding = 12.0;
          const crossAxisCount = 2;
          const crossAxisSpacing = 10.0;
          const mainAxisSpacing = 10.0;
          final availableWidth =
              MediaQuery.of(context).size.width - padding * 2;
          final itemWidth =
              (availableWidth - crossAxisSpacing) / crossAxisCount;
          final itemHeight = itemWidth * (12 / 16);

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
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 300) {
                ref
                    .read(studioMediaGridProvider(studioId).notifier)
                    .fetchNextPage();
              }

              final offset = scrollInfo.metrics.pixels;
              final stride = itemHeight + mainAxisSpacing;
              final visibleRow = ((offset) / stride).floor().clamp(
                0,
                (items.length - 1),
              );
              final visibleIndex = (visibleRow * crossAxisCount).clamp(
                0,
                items.length - 1,
              );

              for (var i = 1; i <= kPrefetchDistance; i++) {
                final ahead = visibleIndex + i;
                if (ahead < items.length) {
                  StashImage.prefetch(
                    context,
                    imageUrl: items[ahead].thumbnailUrl,
                    headers: null,
                    memCacheWidth: (itemWidth * 2).toInt(),
                  );
                }
                final behind = visibleIndex - i;
                if (behind >= 0) {
                  StashImage.prefetch(
                    context,
                    imageUrl: items[behind].thumbnailUrl,
                    headers: null,
                    memCacheWidth: (itemWidth * 2).toInt(),
                  );
                }
              }

              return false;
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
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
                          memCacheWidth: 480,
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
