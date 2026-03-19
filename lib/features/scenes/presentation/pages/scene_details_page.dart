import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../providers/scene_list_provider.dart';
import '../providers/scene_details_provider.dart';
import '../widgets/scene_video_player.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/theme/app_theme.dart';

import '../providers/playback_queue_provider.dart';

class SceneDetailsPage extends ConsumerWidget {
  final String sceneId;
  const SceneDetailsPage({required this.sceneId, super.key});

  Future<void> _openRandomScene(BuildContext context, WidgetRef ref) async {
    final randomScene = await ref.read(sceneListProvider.notifier).getRandomScene(useCurrentFilter: true);
    if (!context.mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scenes available for random navigation')),
      );
      return;
    }

    context.push('/scene/${randomScene.id}');
  }

  String _formatDuration(double? seconds) {
    if (seconds == null) return '00:00';
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sceneAsync = ref.watch(sceneDetailsProvider(sceneId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scene Details'),
        actions: [
          sceneAsync.when(
            data: (scene) => IconButton(
              icon: const Icon(Icons.queue_play_next),
              tooltip: 'Add to queue',
              onPressed: () {
                ref.read(playbackQueueProvider.notifier).add(scene);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added "${scene.title}" to queue')),
                );
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Random scene',
            onPressed: () => _openRandomScene(context, ref),
          ),
        ],
      ),
      body: sceneAsync.when(
        data: (scene) {
          final primaryFile = scene.files.isNotEmpty ? scene.files.first : null;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SceneVideoPlayer(scene: scene),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scene.title,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSmall),
                      Row(
                        children: [
                          if (scene.studioName != null)
                            Text(
                              scene.studioName!,
                              style: context.textTheme.titleMedium?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (scene.studioName != null)
                            Text(
                              ' • ',
                              style: TextStyle(color: context.colors.onSurface.withOpacity(0.5)),
                            ),
                          Text(
                            scene.date.year.toString(),
                            style: context.textTheme.titleMedium?.copyWith(
                              color: context.colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      Wrap(
                        spacing: AppTheme.spacingSmall,
                        runSpacing: AppTheme.spacingSmall,
                        children: [
                          if (primaryFile?.duration != null)
                            _buildChip(context, _formatDuration(primaryFile!.duration), icon: Icons.timer),
                          if (primaryFile?.width != null && primaryFile?.height != null)
                            _buildChip(context, '${primaryFile!.width}x${primaryFile.height}', icon: Icons.fullscreen),
                          if (primaryFile?.frameRate != null)
                            _buildChip(context, '${primaryFile!.frameRate!.toStringAsFixed(2)} fps', icon: Icons.slow_motion_video),
                          if (primaryFile?.bitRate != null)
                            _buildChip(context, '${(primaryFile!.bitRate! / 1000000).toStringAsFixed(2)} Mbps', icon: Icons.speed),
                          if (scene.rating100 != null)
                            _buildChip(
                              context,
                              'Rating: ${(scene.rating100! / 20).toStringAsFixed(1)}',
                              icon: Icons.star,
                              iconColor: context.colors.ratingColor,
                            ),
                          _buildChip(context, '${scene.playCount} plays', icon: Icons.play_arrow),
                        ],
                      ),
                      const Divider(height: 32, color: Colors.grey),
                      if (scene.details != null && scene.details!.isNotEmpty) ...[
                        const SectionHeader(title: 'Details', padding: EdgeInsets.zero),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          scene.details!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurface.withOpacity(0.8),
                          ),
                        ),
                        const Divider(height: 32, color: Colors.grey),
                      ],
                      const SectionHeader(title: 'Performers', padding: EdgeInsets.zero),
                      const SizedBox(height: AppTheme.spacingSmall),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: scene.performerNames.length,
                        separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingSmall),
                        itemBuilder: (context, index) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(
                              scene.performerNames[index],
                              style: context.textTheme.bodyLarge,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              if (index < scene.performerIds.length) {
                                context.push('/performer/${scene.performerIds[index]}');
                              }
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateView(
          message: 'Failed to load scene details.\n$err',
          onRetry: () => ref.refresh(sceneDetailsProvider(sceneId)),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, {IconData? icon, Color? iconColor}) {
    return Chip(
      avatar: icon != null ? Icon(icon, size: 16, color: iconColor ?? context.colors.onSurfaceVariant) : null,
      label: Text(label, style: context.textTheme.bodySmall),
      backgroundColor: context.colors.surfaceVariant,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
