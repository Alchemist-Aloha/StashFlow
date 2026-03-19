import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../providers/scene_list_provider.dart';
import '../providers/scene_details_provider.dart';
import '../widgets/scene_video_player.dart';

class SceneDetailsPage extends ConsumerWidget {
  final String sceneId;
  const SceneDetailsPage({required this.sceneId, super.key});

  Future<void> _openRandomScene(BuildContext context, WidgetRef ref) async {
    final randomScene = await ref
        .read(sceneListProvider.notifier)
        .getRandomScene();
    if (!context.mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No scenes available for random navigation'),
        ),
      );
      return;
    }

    context.push('/scene/${randomScene.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sceneAsync = ref.watch(sceneDetailsProvider(sceneId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scene Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Random scene',
            onPressed: () => _openRandomScene(context, ref),
          ),
        ],
      ),
      body: sceneAsync.when(
        data: (scene) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SceneVideoPlayer(scene: scene),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scene.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${scene.studioName ?? "Unknown Studio"} • ${scene.date.year}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Divider(height: 32, color: Colors.grey),
                    if (scene.details != null && scene.details!.isNotEmpty) ...[
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scene.details!,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const Divider(height: 32, color: Colors.grey),
                    ],
                    const Text(
                      'Performers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: scene.performerNames.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            const CircleAvatar(child: Icon(Icons.person)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                scene.performerNames[index],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                if (index < scene.performerIds.length) {
                                  context.push(
                                    '/performer/${scene.performerIds[index]}',
                                  );
                                }
                              },
                              child: const Text('Detail'),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateView(
          message: 'Failed to load scene details.\n$err',
          onRetry: () => ref.refresh(sceneDetailsProvider(sceneId)),
        ),
      ),
    );
  }
}
