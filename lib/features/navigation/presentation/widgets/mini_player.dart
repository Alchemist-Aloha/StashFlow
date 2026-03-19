import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../scenes/presentation/providers/video_player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerStateProvider);
    final activeScene = playerState.activeScene;
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    if (activeScene == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/scene/${activeScene.id}'),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: Border(top: BorderSide(color: Colors.grey[800]!, width: 0.5)),
        ),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                activeScene.paths.screenshot ?? '',
                headers: mediaHeaders,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.movie),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeScene.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    activeScene.studioName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(playerStateProvider.notifier).togglePlayPause(),
              icon: Icon(
                playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => ref.read(playerStateProvider.notifier).stop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
