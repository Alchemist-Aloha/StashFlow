import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../providers/studio_media_provider.dart';

class StudioMediaGridPage extends ConsumerWidget {
  final String studioId;

  const StudioMediaGridPage({required this.studioId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaAsync = ref.watch(studioMediaGridProvider(studioId));
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('All Studio Media')),
      body: mediaAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No media available.'));
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 300) {
                ref
                    .read(studioMediaGridProvider(studioId).notifier)
                    .fetchNextPage();
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
                  onTap: () => context.push('/scene/${item.sceneId}'),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.thumbnailUrl,
                          headers: mediaHeaders,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.movie,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            color: Colors.black.withAlpha(170),
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
