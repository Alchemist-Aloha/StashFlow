import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../providers/performer_media_provider.dart';
import '../providers/performer_details_provider.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/media_strip.dart';
import '../../../../core/presentation/theme/app_theme.dart';

import '../../../scenes/presentation/providers/scene_list_provider.dart';

class PerformerDetailsPage extends ConsumerWidget {
  final String performerId;
  const PerformerDetailsPage({required this.performerId, super.key});

  Future<void> _openRandomScene(BuildContext context, WidgetRef ref) async {
    final randomScene = await ref.read(sceneListProvider.notifier).getRandomScene(performerId: performerId);
    if (!context.mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No scenes available for this performer')),
      );
      return;
    }

    context.push('/scene/${randomScene.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performerAsync = ref.watch(performerDetailsProvider(performerId));
    final mediaAsync = ref.watch(performerMediaProvider(performerId));
    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Random scene with this performer',
            onPressed: () => _openRandomScene(context, ref),
          ),
        ],
      ),
      body: performerAsync.when(
        data: (performer) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: performer.imagePath != null
                      ? DecorationImage(
                          image: NetworkImage(
                            performer.imagePath!,
                            headers: mediaHeaders,
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: context.colors.surfaceVariant,
                ),
                child: performer.imagePath == null
                    ? Icon(Icons.person, size: 100, color: context.colors.onSurfaceVariant.withOpacity(0.5))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performer.name,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                    if (performer.disambiguation != null)
                      Text(
                        performer.disambiguation!,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: context.colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    Wrap(
                      spacing: AppTheme.spacingSmall,
                      runSpacing: AppTheme.spacingSmall,
                      children: [
                        if (performer.gender != null) _buildChip(context, performer.gender!),
                        if (performer.birthdate != null) _buildChip(context, performer.birthdate!),
                        if (performer.country != null) _buildChip(context, performer.country!),
                        if (performer.ethnicity != null) _buildChip(context, performer.ethnicity!),
                        if (performer.heightCm != null) _buildChip(context, '${performer.heightCm} cm'),
                        if (performer.eyeColor != null) _buildChip(context, performer.eyeColor!),
                        if (performer.hairColor != null) _buildChip(context, performer.hairColor!),
                      ],
                    ),
                    const Divider(height: 32, color: Colors.grey),
                    SectionHeader(
                      title: 'Media',
                      onViewAll: () => context.push('/performer/${performer.id}/media'),
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
                    const Divider(height: 32, color: Colors.grey),
                    const SectionHeader(title: 'Details'),
                    Text(
                      performer.details ?? 'No details available.',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colors.onSurface.withOpacity(0.8),
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
    if (label.isEmpty) return const SizedBox.shrink();
    return Chip(
      label: Text(label, style: context.textTheme.bodySmall),
      backgroundColor: context.colors.surfaceVariant,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
