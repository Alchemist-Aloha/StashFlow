import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/marquee_text.dart';
import '../../../scenes/domain/entities/scene_title_utils.dart';
import '../../../scenes/presentation/providers/video_player_provider.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeScene = ref.watch(
      playerStateProvider.select((s) => s.activeScene),
    );
    final isPlaying = ref.watch(playerStateProvider.select((s) => s.isPlaying));

    if (activeScene == null) return const SizedBox.shrink();

    final displayTitle = activeScene.displayTitle;

    return GestureDetector(
      onTap: () => context.push('/scenes/scene/${activeScene.id}'),
      child: Container(
        height: 66, // Increased height by 10% (from 60)
        decoration: BoxDecoration(
          color: context.colors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: RepaintBoundary(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: StashImage(
                      imageUrl: activeScene.paths.screenshot ?? '',
                      fit: BoxFit.cover,
                      memCacheWidth: 320,
                    ),
                  ),
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
                        color: context.colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isPlaying ? 'Pause' : 'Play',
                onPressed: () =>
                    ref.read(playerStateProvider.notifier).togglePlayPause(),
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: context.colors.onSurface,
                ),
              ),
              IconButton(
                tooltip: context.l10n.common_close,
                onPressed: () => ref.read(playerStateProvider.notifier).stop(),
                icon: Icon(Icons.close, color: context.colors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
