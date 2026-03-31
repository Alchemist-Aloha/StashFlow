import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../providers/tag_media_provider.dart';
import '../providers/tag_details_provider.dart';
import '../providers/tag_galleries_provider.dart';
import '../../../images/presentation/providers/image_list_provider.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/media_strip.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../providers/tag_list_provider.dart';

class TagDetailsPage extends ConsumerWidget {
  final String tagId;
  const TagDetailsPage({required this.tagId, super.key});

  Future<void> _openRandomTag(BuildContext context, WidgetRef ref) async {
    final randomTag = await ref
        .read(tagListProvider.notifier)
        .getRandomTag(excludeTagId: tagId);
    if (!context.mounted) return;

    if (randomTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tags available for random navigation'),
        ),
      );
      return;
    }

    context.push('/tags/tag/${randomTag.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagAsync = ref.watch(tagDetailsProvider(tagId));
    final mediaAsync = ref.watch(tagMediaProvider(tagId));
    final galleriesAsync = ref.watch(tagGalleriesProvider(tagId));
    final mediaHeaders = ref.watch(mediaHeadersProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tag Details')),
      floatingActionButton: randomNavigationEnabled
          ? FloatingActionButton.small(
              onPressed: () => _openRandomTag(context, ref),
              tooltip: 'Random tag',
              child: const Icon(Icons.casino_outlined),
            )
          : null,
      body: tagAsync.when(
        data: (tag) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tagDetailsProvider(tagId));
              ref.invalidate(tagMediaProvider(tagId));
              ref.invalidate(tagGalleriesProvider(tagId));
              await Future.wait([
                ref.read(tagDetailsProvider(tagId).future),
                ref.read(tagMediaProvider(tagId).future),
                ref.read(tagGalleriesProvider(tagId).future),
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
                    child: tag.imagePath != null
                        ? StashImage(
                            imageUrl: tag.imagePath!,
                            fit: BoxFit.contain,
                            memCacheWidth: 600,
                          )
                        : Icon(
                            Icons.local_offer,
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
                          tag.name,
                          style: context.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.colors.onSurface,
                          ),
                        ),
                        if (tag.description != null &&
                            tag.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingMedium),
                          Text(
                            tag.description!,
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
                            '/tags/tag/${tag.id}/media',
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
                              ..shuffle(Random(tag.id.hashCode));
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
                                    '/tags/tag/${tag.id}/galleries',
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
                                                  imageFilterStateProvider.notifier,
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
