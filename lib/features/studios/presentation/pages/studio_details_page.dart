import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../providers/studio_media_provider.dart';
import '../providers/studio_details_provider.dart';
import '../providers/studio_galleries_provider.dart';
import '../../../images/presentation/providers/image_list_provider.dart';

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
        .getRandomStudio(excludeStudioId: studioId);
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
    final galleriesAsync = ref.watch(studioGalleriesProvider(studioId));
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
        data: (studio) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studioDetailsProvider(studioId));
              ref.invalidate(studioMediaProvider(studioId));
              ref.invalidate(studioGalleriesProvider(studioId));
              await Future.wait([
                ref.read(studioDetailsProvider(studioId).future),
                ref.read(studioMediaProvider(studioId).future),
                ref.read(studioGalleriesProvider(studioId).future),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: context.colors.surfaceVariant,
                    child: studio.imagePath != null
                        ? StashImage(
                            imageUrl: studio.imagePath!,
                            fit: BoxFit.contain,
                            memCacheWidth: 600,
                          )
                        : Icon(
                            Icons.business,
                            size: 80,
                            color: context.colors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          studio.name,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        if (studio.details != null &&
                            studio.details!.trim().isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingMedium),
                          Text(
                            studio.details!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                        const Divider(height: 32, color: Colors.grey),
                        SectionHeader(
                          title: 'Media',
                          onViewAll: () => context.push(
                            '/studios/studio/${studio.id}/media',
                          ),
                        ),
                        mediaAsync.when(
                          data: (mediaItems) {
                            if (mediaItems.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: AppTheme.spacingSmall,
                                ),
                                child: Text(
                                  'No media found',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }
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
                        galleriesAsync.when(
                          data: (galleryItems) {
                            if (galleryItems.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppTheme.spacingMedium),
                                SectionHeader(
                                  title: 'Galleries',
                                  onViewAll: () => context.push(
                                    '/studios/studio/${studio.id}/galleries',
                                  ),
                                ),
                                MediaStrip(
                                  items: galleryItems
                                      .map(
                                        (item) => MediaStripItem(
                                          id: item.galleryId,
                                          title: item.title,
                                          thumbnailUrl: item.thumbnailUrl,
                                          onTap: () {
                                            ref
                                                .read(
                                                  imageFilterStateProvider
                                                      .notifier,
                                                )
                                                .setGalleryId(item.galleryId);
                                            context.push('/galleries/images');
                                          },
                                        ),
                                      )
                                      .toList(),
                                  headers: mediaHeaders,
                                ),
                              ],
                            );
                          },
                          loading: () => const SizedBox(
                            height: 100,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (err, stack) => Text(
                            'Failed to load galleries: $err',
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
