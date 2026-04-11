import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import '../../domain/entities/scene.dart';

class SceneInfoPage extends ConsumerWidget {
  const SceneInfoPage({required this.scene, super.key});

  final Scene scene;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Scene Info')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (scene.details != null && scene.details!.isNotEmpty) ...[
              Text(
                'Details',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(scene.details!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
            ],
            if (scene.performerNames.isNotEmpty) ...[
              Text(
                'Performers',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scene.performerNames.length,
                itemBuilder: (context, index) {
                  final performerName = scene.performerNames[index];
                  final performerId =
                      index < scene.performerIds.length
                          ? scene.performerIds[index]
                          : null;
                  final performerImagePath =
                      index < scene.performerImagePaths.length
                          ? scene.performerImagePaths[index]
                          : null;
                  final hasImage =
                      performerImagePath != null &&
                      performerImagePath.trim().isNotEmpty;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: hasImage
                        ? CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            foregroundImage: kIsWeb
                                ? NetworkImage(
                                    performerImagePath,
                                    headers: mediaHeaders,
                                  )
                                : CachedNetworkImageProvider(
                                    performerImagePath,
                                    headers: mediaHeaders,
                                  ),
                            child: const Icon(Icons.person),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                    title: Text(
                      performerName.isNotEmpty
                          ? performerName
                          : 'Unknown Performer',
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap:
                        performerId != null && performerId.trim().isNotEmpty
                            ? () {
                                // Navigate to performer page if needed
                              }
                            : null,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
