import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/graphql/media_headers_provider.dart';
import '../providers/tag_media_provider.dart';
import '../providers/tag_details_provider.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/media_strip.dart';
import '../../../../core/presentation/theme/app_theme.dart';

import '../providers/tag_list_provider.dart';

class TagDetailsPage extends ConsumerWidget {
  final String tagId;

  const TagDetailsPage({required this.tagId, super.key});

  Future<void> _openRandomTag(BuildContext context, WidgetRef ref) async {
    final randomTag = await ref
        .read(tagListProvider.notifier)
        .getRandomTag(useCurrentFilter: true, excludeTagId: tagId);
    if (!context.mounted) return;

    if (randomTag == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tags available for random navigation'),
        ),
      );
      return;
    }

    context.push('/tag/${randomTag.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagAsync = ref.watch(tagDetailsProvider(tagId));
    final mediaAsync = ref.watch(tagMediaProvider(tagId));
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tag Details')),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _openRandomTag(context, ref),
        tooltip: 'Random tag',
        child: const Icon(Icons.casino_outlined),
      ),
      body: tagAsync.when(
        data: (tag) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    const SizedBox(height: AppTheme.spacingMedium),
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: [
                        _buildChip(context, '${tag.sceneCount} scenes'),
                        _buildChip(context, '${tag.performerCount} performers'),
                        _buildChip(context, '${tag.imageCount} images'),
                        _buildChip(context, '${tag.galleryCount} galleries'),
                      ],
                    ),
                    if (tag.description != null &&
                        tag.description!.trim().isNotEmpty) ...[
                      const Divider(height: 32, color: Colors.grey),
                      const SectionHeader(title: 'Description'),
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
                      onViewAll: () => context.push('/tag/${tag.id}/media'),
                    ),
                    mediaAsync.when(
                      data: (mediaItems) {
                        final shuffledItems = [...mediaItems]
                          ..shuffle(Random());
                        return MediaStrip(
                          items: shuffledItems
                              .map(
                                (item) => MediaStripItem(
                                  id: item.sceneId,
                                  title: item.title,
                                  thumbnailUrl: item.thumbnailUrl,
                                  onTap: () =>
                                      context.push('/scene/${item.sceneId}'),
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
