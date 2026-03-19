import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/graphql/media_headers_provider.dart';
import '../providers/studio_media_provider.dart';
import '../providers/studio_details_provider.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/media_strip.dart';
import '../../../../core/presentation/theme/app_theme.dart';

import '../../../scenes/presentation/providers/scene_list_provider.dart';

class StudioDetailsPage extends ConsumerWidget {
  final String studioId;

  const StudioDetailsPage({required this.studioId, super.key});

  Future<void> _openRandomScene(BuildContext context, WidgetRef ref) async {
    final randomScene = await ref.read(sceneListProvider.notifier).getRandomScene(studioId: studioId);
    if (!context.mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scenes available for this studio')),
      );
      return;
    }

    context.push('/scene/${randomScene.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioAsync = ref.watch(studioDetailsProvider(studioId));
    final mediaAsync = ref.watch(studioMediaProvider(studioId));
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Random scene from this studio',
            onPressed: () => _openRandomScene(context, ref),
          ),
        ],
      ),
      body: studioAsync.when(
        data: (studio) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 240,
                width: double.infinity,
                color: context.colors.surfaceVariant,
                child: studio.imagePath != null && studio.imagePath!.isNotEmpty
                    ? Image.network(
                        studio.imagePath!,
                        headers: mediaHeaders,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.apartment,
                            size: 72,
                            color: context.colors.onSurfaceVariant.withOpacity(0.5),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.apartment,
                          size: 72,
                          color: context.colors.onSurfaceVariant.withOpacity(0.5),
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
                    const SizedBox(height: AppTheme.spacingMedium),
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: [
                        _buildChip(context, '${studio.sceneCount} scenes'),
                        _buildChip(context, '${studio.performerCount} performers'),
                        _buildChip(context, '${studio.imageCount} images'),
                        _buildChip(context, '${studio.galleryCount} galleries'),
                        if (studio.rating100 != null)
                          _buildChip(context, 'Rating: ${(studio.rating100! / 20).toStringAsFixed(1)}'),
                      ],
                    ),
                    const Divider(height: 32, color: Colors.grey),
                    SectionHeader(
                      title: 'Media',
                      onViewAll: () => context.push('/studio/${studio.id}/media'),
                    ),
                    mediaAsync.when(
                      data: (mediaItems) => MediaStrip(
                        items: mediaItems
                            .map((item) => MediaStripItem(
                                  id: item.sceneId,
                                  title: item.title,
                                  thumbnailUrl: item.thumbnailUrl,
                                  onTap: () => context.push('/scene/${item.sceneId}'),
                                ))
                            .toList(),
                        headers: mediaHeaders,
                      ),
                      loading: () => const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (err, stack) => Text(
                        'Failed to load media: $err',
                        style: TextStyle(color: context.colors.onSurface.withOpacity(0.7)),
                      ),
                    ),
                    if (studio.details != null && studio.details!.isNotEmpty) ...[
                      const Divider(height: 32, color: Colors.grey),
                      const SectionHeader(title: 'Details'),
                      Text(
                        studio.details!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
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
