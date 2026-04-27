import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';
import '../../domain/entities/scene.dart';
import '../../../../core/utils/l10n_extensions.dart';

class SceneInfoPage extends ConsumerWidget {
  const SceneInfoPage({required this.scene, super.key});

  final Scene scene;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    // Bottom-sheet / dialog friendly content (no Scaffold) so it can be shown
    // inside a modal bottom sheet without expanding to full screen.
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.details_scene,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: context.l10n.common_close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (scene.details != null && scene.details!.isNotEmpty) ...[
              Text(
                context.l10n.common_details,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(scene.details!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 24),
            ],
            if (scene.performerNames.isNotEmpty) ...[
              Text(
                context.l10n.performers_title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scene.performerNames.length,
                itemBuilder: (context, index) {
                  final performerName = scene.performerNames[index];
                  final performerId = index < scene.performerIds.length
                      ? scene.performerIds[index]
                      : null;
                  final performerImagePath =
                      index < scene.performerImagePaths.length
                      ? scene.performerImagePaths[index]
                      : null;
                  final hasImage =
                      performerImagePath != null &&
                      performerImagePath.trim().isNotEmpty &&
                      !performerImagePath.contains('default=true');

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: hasImage
                        ? CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            foregroundImage: StashImage.provider(
                              ref,
                              performerImagePath,
                              headers: mediaHeaders,
                            ),
                            child: const Icon(Icons.person),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(
                      performerName.isNotEmpty
                          ? performerName
                          : context.l10n.common_unknown,
                      style: theme.textTheme.bodyLarge,
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: performerId != null && performerId.trim().isNotEmpty
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
