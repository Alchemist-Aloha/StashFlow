import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/marquee_text.dart';
import '../../../scenes/domain/entities/scene_title_utils.dart';
import '../../../scenes/presentation/providers/video_player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScene = ref.watch(playerStateProvider.select((s) => s.activeScene));
    final isPlaying = ref.watch(playerStateProvider.select((s) => s.isPlaying));
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    if (activeScene == null) return const SizedBox.shrink();

    final displayTitle = activeScene.displayTitle;

    return GestureDetector(
      onTap: () => context.push('/scenes/scene/${activeScene.id}'),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(
            top: BorderSide(
              color: context.colors.outline.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                activeScene.paths.screenshot ?? '',
                headers: mediaHeaders,
                fit: BoxFit.cover,
                cacheWidth: 320,
                errorBuilder: (c, e, s) => const Icon(Icons.movie),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MarqueeText(
                    text: displayTitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurface,
                    ),
                  ),
                  Text(
                    activeScene.studioName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurface.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  ref.read(playerStateProvider.notifier).togglePlayPause(),
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: context.colors.onSurface,
              ),
            ),
            IconButton(
              onPressed: () => ref.read(playerStateProvider.notifier).stop(),
              icon: Icon(Icons.close, color: context.colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
