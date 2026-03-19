import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../domain/entities/scene.dart';

import '../providers/playback_queue_provider.dart';

class SceneCard extends ConsumerWidget {
  final Scene scene;
  final bool isGrid;
  final VoidCallback? onTap;

  const SceneCard({
    required this.scene,
    this.isGrid = false,
    this.onTap,
    super.key,
  });

  void _showMenu(BuildContext context, WidgetRef ref) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        const PopupMenuItem(
          value: 'add_to_queue',
          child: ListTile(
            leading: Icon(Icons.queue_play_next),
            title: Text('Add to queue'),
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'add_to_queue') {
        ref.read(playbackQueueProvider.notifier).add(scene);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added "${scene.title}" to queue')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    if (isGrid) {
      return _buildGridCard(context, ref, mediaHeaders);
    }
    return _buildListCard(context, ref, mediaHeaders);
  }

  Widget _buildListCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> mediaHeaders,
  ) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showMenu(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Image.network(
                  scene.paths.screenshot ??
                      'https://via.placeholder.com/320x180',
                  headers: mediaHeaders,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(Icons.movie, color: Colors.white, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    color: Colors.black.withAlpha(200),
                    child: const Text(
                      '00:00', // TODO: Add duration to Scene entity
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scene.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${scene.studioName ?? "Unknown Studio"} • ${scene.date.year}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showMenu(context, ref),
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, String> mediaHeaders,
  ) {
    return InkWell(
      onTap: onTap,
      onLongPress: () => _showMenu(context, ref),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              scene.paths.screenshot ?? 'https://via.placeholder.com/320x180',
              headers: mediaHeaders,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(Icons.movie, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scene.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        scene.studioName ?? 'Unknown Studio',
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _showMenu(context, ref),
                  icon: const Icon(
                    Icons.more_vert,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
