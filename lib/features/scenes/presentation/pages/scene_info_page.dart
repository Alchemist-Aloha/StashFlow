import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../domain/entities/scene.dart';

/// Bottom sheet content for scene quick actions, inspired by filter panel UX.
class SceneInfoSheet extends ConsumerWidget {
  const SceneInfoSheet({required this.scene, super.key});

  final Scene scene;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioName = scene.studioName?.trim();
    final hasStudio = studioName != null && studioName.isNotEmpty;
    final performerCount = scene.performerNames.length;

    final theme = Theme.of(context);
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.65,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Scene details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Studio & Performers',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(
                                Icons.business,
                                color: theme.colorScheme.primary,
                              ),
                              title: const Text('Studio'),
                              subtitle: Text(studioName ?? 'Unknown'),
                              enabled: hasStudio && scene.studioId != null,
                              trailing: const Icon(Icons.chevron_right),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: hasStudio && scene.studioId != null
                                  ? () {
                                      context.push(
                                        '/studios/studio/${scene.studioId}',
                                      );
                                    }
                                  : null,
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.group,
                                color: theme.colorScheme.secondary,
                              ),
                              title: const Text('Performers'),
                              subtitle: Text(
                                performerCount > 0
                                    ? '$performerCount performer(s)'
                                    : 'No performers listed',
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (performerCount > 0) ...[
                        const SizedBox(height: 8),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: performerCount,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final performerName = scene.performerNames[index]
                                  .trim();
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
                                            theme.colorScheme.surfaceVariant,
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                              performerImagePath!,
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
                                    performerId != null &&
                                        performerId.trim().isNotEmpty
                                    ? () {
                                        context.push(
                                          '/performers/performer/$performerId',
                                        );
                                      }
                                    : null,
                              );
                            },
                          ),
                        ),
                      ],
                    ],
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
