import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/scene.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../providers/playback_queue_provider.dart';
import '../providers/player_playlist_paging.dart';

class PlaylistFloatingPanel extends ConsumerStatefulWidget {
  const PlaylistFloatingPanel({super.key});

  static void show(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Playlist',
      barrierColor: colorScheme.scrim.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const Center(child: PlaylistFloatingPanel());
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = Curves.easeOutBack.transform(anim1.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(opacity: anim1.value, child: child),
        );
      },
    );
  }

  @override
  ConsumerState<PlaylistFloatingPanel> createState() =>
      _PlaylistFloatingPanelState();
}

class _PlaylistFloatingPanelState extends ConsumerState<PlaylistFloatingPanel> {
  late final ScrollController _scrollController;
  bool _isPaging = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_maybeLoadMore)
      ..dispose();
    super.dispose();
  }

  Future<void> _maybeLoadMore() async {
    if (_isPaging || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels > 240) return;

    final queueId = ref.read(playbackQueueProvider).activeQueueId;
    setState(() => _isPaging = true);
    try {
      await maybeLoadNextPlaylistPage(ref, queueId);
    } finally {
      if (mounted) setState(() => _isPaging = false);
    }
  }

  void _openScene(String queueId, int index, String sceneId) {
    ref.read(playbackQueueProvider.notifier).setIndex(index, queueId: queueId);
    Navigator.of(context).pop();
    context.push('/scenes/scene/$sceneId', extra: true);
  }

  @override
  Widget build(BuildContext context) {
    final queueState = ref.watch(playbackQueueProvider);
    final queueId = queueState.activeQueueId;
    final scenes = queueState.sequence;
    final currentIndex = queueState.currentIndex;
    final dims = context.dimensions;
    final colorScheme = Theme.of(context).colorScheme;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Container(
        width: 360 * dims.fontSizeFactor,
        height: 520 * dims.fontSizeFactor,
        margin: EdgeInsets.all(dims.spacingLarge),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PlaylistHeader(count: scenes.length),
              Expanded(
                child: scenes.isEmpty
                    ? Center(
                        child: Text(
                          'No playlist items',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          dims.spacingMedium,
                          dims.spacingSmall,
                          dims.spacingMedium,
                          dims.spacingSmall,
                        ),
                        itemCount: scenes.length + (_isPaging ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= scenes.length) {
                            return Padding(
                              padding: EdgeInsets.all(dims.spacingMedium),
                              child: const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }

                          final scene = scenes[index];
                          final isActive = index == currentIndex;
                          return _PlaylistItem(
                            scene: scene,
                            index: index,
                            isActive: isActive,
                            onTap: () => _openScene(queueId, index, scene.id),
                          );
                        },
                      ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  dims.spacingMedium,
                  0,
                  dims.spacingMedium,
                  dims.spacingMedium,
                ),
                child: Text(
                  playlistPagingTargetForQueueId(queueId).supportsPaging
                      ? 'Scroll to load more'
                      : 'Queue follows the current source',
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        dims.spacingMedium * 1.5,
        dims.spacingMedium * 1.5,
        dims.spacingMedium,
        dims.spacingSmall,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(dims.spacingSmall),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              Icons.queue_music_rounded,
              color: colorScheme.primary,
              size: 24 * dims.fontSizeFactor,
            ),
          ),
          SizedBox(width: dims.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Playlist',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$count items',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: context.l10n.common_close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _PlaylistItem extends ConsumerWidget {
  const _PlaylistItem({
    required this.scene,
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  final Scene scene;
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final dims = context.dimensions;

    return Padding(
      padding: EdgeInsets.only(bottom: dims.spacingSmall),
      child: Material(
        color: isActive
            ? colorScheme.primaryContainer.withValues(alpha: 0.4)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(dims.spacingSmall),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  child: SizedBox(
                    width: 88,
                    height: 52,
                    child: StashImage(
                      imageUrl: scene.paths.screenshot,
                      fit: BoxFit.cover,
                      memCacheWidth: 240,
                    ),
                  ),
                ),
                SizedBox(width: dims.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${scene.displayTitle}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if ((scene.studioName ?? '').isNotEmpty) ...[
                        SizedBox(height: dims.spacingSmall * 0.5),
                        Text(
                          scene.studioName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.labelMedium?.copyWith(
                            color: isActive
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: dims.spacingSmall),
                Icon(
                  isActive
                      ? Icons.play_circle_fill_rounded
                      : Icons.chevron_right_rounded,
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
