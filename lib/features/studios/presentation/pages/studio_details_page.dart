import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';

import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../providers/studio_media_provider.dart';
import '../providers/studio_details_provider.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/media_strip.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../providers/studio_list_provider.dart';

class StudioDetailsPage extends ConsumerWidget {
  final String studioId;

  const StudioDetailsPage({required this.studioId, super.key});

  Future<void> _openRandomStudio(BuildContext context, WidgetRef ref) async {
    final randomStudio = await ref
        .read(studioListProvider.notifier)
        .getRandomStudio(useCurrentFilter: true, excludeStudioId: studioId);
    if (!context.mounted) return;

    if (randomStudio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No studios available for random navigation'),
        ),
      );
      return;
    }

    context.push('/studios/studio/${randomStudio.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioAsync = ref.watch(studioDetailsProvider(studioId));
    final mediaAsync = ref.watch(studioMediaProvider(studioId));
    final mediaHeaders = ref.watch(mediaHeadersProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Studio Details')),
      floatingActionButton: randomNavigationEnabled
          ? FloatingActionButton.small(
              onPressed: () => _openRandomStudio(context, ref),
              tooltip: 'Random studio',
              child: const Icon(Icons.casino_outlined),
            )
          : null,
      body: studioAsync.when(
        data: (studio) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (studio.imagePath != null &&
                  studio.imagePath!.trim().isNotEmpty)
                FutureBuilder<bool>(
                  future: () async {
                    final path = studio.imagePath!.trim();
                    try {
                      // Check cache first for a valid file
                      final info = await StashImage.cacheManager
                          .getFileFromCache(path);
                      if (info != null) {
                        final file = info.file;
                        if (await file.exists()) {
                          final bytes = await file.readAsBytes();
                          if (bytes.lengthInBytes < 64) return false;
                          try {
                            await ui.instantiateImageCodec(bytes);
                            return true;
                          } catch (_) {
                            // corrupted cached file; remove and attempt re-download
                            await StashImage.cacheManager.removeFile(path);
                            // try prefetch and recheck
                          }
                        }
                      }

                      // Attempt to prefetch and validate again
                      try {
                        await StashImage.prefetch(
                          context,
                          imageUrl: path,
                          headers: mediaHeaders,
                          memCacheWidth: 800,
                        );
                      } catch (_) {}

                      final info2 = await StashImage.cacheManager
                          .getFileFromCache(path);
                      if (info2 == null) return false;
                      final file2 = info2.file;
                      if (!await file2.exists()) return false;
                      final bytes2 = await file2.readAsBytes();
                      if (bytes2.lengthInBytes < 64) return false;
                      try {
                        await ui.instantiateImageCodec(bytes2);
                        return true;
                      } catch (_) {
                        await StashImage.cacheManager.removeFile(path);
                        return false;
                      }
                    } catch (_) {
                      return false;
                    }
                  }(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox.shrink();
                    }
                    if (snapshot.hasData && snapshot.data == true) {
                      return Container(
                        height: 240,
                        width: double.infinity,
                        color: context.colors.surfaceVariant,
                        child: StashImage(
                          imageUrl: studio.imagePath!,
                          fit: BoxFit.contain,
                          memCacheWidth: 800,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            studio.name,
                            style: context.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.colors.onSurface,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          icon: Icon(
                            studio.favorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          tooltip: studio.favorite
                              ? 'Remove favorite'
                              : 'Add favorite',
                          onPressed: () async {
                            try {
                              await ref
                                  .read(studioRepositoryProvider)
                                  .setStudioFavorite(
                                    studio.id,
                                    !studio.favorite,
                                  );
                              ref.invalidate(studioDetailsProvider(studio.id));
                              ref.invalidate(studioListProvider);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to update favorite: $e',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: [
                        _buildChip(context, '${studio.sceneCount} scenes'),
                        _buildChip(
                          context,
                          '${studio.performerCount} performers',
                        ),
                        _buildChip(context, '${studio.imageCount} images'),
                        _buildChip(context, '${studio.galleryCount} galleries'),
                        if (studio.rating100 != null)
                          _buildChip(
                            context,
                            'Rating: ${(studio.rating100! / 20).toStringAsFixed(1)}',
                          ),
                      ],
                    ),
                    if (studio.details != null &&
                        studio.details!.trim().isNotEmpty) ...[
                      Divider(
                        height: 32,
                        color: context.colors.outline.withValues(alpha: 0.2),
                      ),
                      const SectionHeader(title: 'Details'),
                      Text(
                        studio.details!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                    ],
                    Divider(
                      height: 32,
                      color: context.colors.outline.withValues(alpha: 0.2),
                    ),
                    SectionHeader(
                      title: 'Media',
                      onViewAll: () =>
                          context.push('/studios/studio/${studio.id}/media'),
                    ),
                    mediaAsync.when(
                      data: (mediaItems) {
                        final shuffledItems = [...mediaItems]
                          ..shuffle(Random(studio.id.hashCode));
                        return MediaStrip(
                          items: shuffledItems
                              .map(
                                (item) => MediaStripItem(
                                  id: item.sceneId,
                                  title: item.title,
                                  thumbnailUrl: item.thumbnailUrl,
                                  onTap: () => context.push(
                                    '/scenes/scene/${item.sceneId}',
                                  ),
                                ),
                              )
                              .toList(),
                          headers: mediaHeaders,
                        );
                      },
                      loading: () => const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Text(
                        'Failed to load media: $err',
                        style: TextStyle(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Chip(
      label: Text(label, style: context.textTheme.bodySmall),
      backgroundColor: context.colors.surfaceVariant,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
