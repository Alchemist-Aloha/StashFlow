import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/graphql/media_headers_provider.dart';
import '../providers/performer_media_provider.dart';
import '../providers/performer_details_provider.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/media_strip.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../providers/performer_list_provider.dart';

class PerformerDetailsPage extends ConsumerWidget {
  final String performerId;
  const PerformerDetailsPage({required this.performerId, super.key});

  Future<void> _openRandomPerformer(BuildContext context, WidgetRef ref) async {
    final randomPerformer = await ref
        .read(performerListProvider.notifier)
        .getRandomPerformer(
          useCurrentFilter: true,
          excludePerformerId: performerId,
        );
    if (!context.mounted) return;

    if (randomPerformer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No performers available for random navigation'),
        ),
      );
      return;
    }

    context.push('/performers/performer/${randomPerformer.id}');
  }

  int? _calculateAge(String? birthdate) {
    if (birthdate == null || birthdate.isEmpty) return null;
    try {
      final bdate = DateTime.parse(birthdate);
      final today = DateTime.now();
      var age = today.year - bdate.year;
      if (today.month < bdate.month ||
          (today.month == bdate.month && today.day < bdate.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final performerAsync = ref.watch(performerDetailsProvider(performerId));
    final mediaAsync = ref.watch(performerMediaProvider(performerId));
    final mediaHeaders = ref.watch(mediaHeadersProvider);
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Performer Details')),
      floatingActionButton: randomNavigationEnabled
          ? FloatingActionButton.small(
              onPressed: () => _openRandomPerformer(context, ref),
              tooltip: 'Random performer',
              child: const Icon(Icons.casino_outlined),
            )
          : null,
      body: performerAsync.when(
        data: (performer) {
          final age = _calculateAge(performer.birthdate);
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  color: context.colors.surfaceVariant,
                  child: performer.imagePath != null
                      ? Image.network(
                          performer.imagePath!,
                          headers: mediaHeaders,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person,
                            size: 100,
                            color: context.colors.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 100,
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
                            color: context.colors.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      if (performer.aliasList.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacingSmall),
                        Text(
                          'Aliases: ${performer.aliasList.join(', ')}',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colors.onSurface.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacingMedium),
                      Wrap(
                        spacing: AppTheme.spacingSmall,
                        runSpacing: AppTheme.spacingSmall,
                        children: [
                          if (performer.gender != null)
                            _buildChip(context, performer.gender!),
                          if (age != null)
                            _buildChip(context, '$age years old'),
                          if (performer.birthdate != null)
                            _buildChip(context, performer.birthdate!),
                          if (performer.country != null)
                            _buildChip(context, performer.country!),
                          if (performer.ethnicity != null)
                            _buildChip(context, performer.ethnicity!),
                          if (performer.heightCm != null)
                            _buildChip(context, '${performer.heightCm} cm'),
                          if (performer.eyeColor != null)
                            _buildChip(context, performer.eyeColor!),
                          if (performer.hairColor != null)
                            _buildChip(context, performer.hairColor!),
                        ],
                      ),
                      if (performer.tagNames.isNotEmpty) ...[
                        const Divider(height: 32, color: Colors.grey),
                        const SectionHeader(
                          title: 'Tags',
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Wrap(
                          spacing: AppTheme.spacingSmall,
                          runSpacing: AppTheme.spacingSmall,
                          children: List.generate(performer.tagNames.length, (
                            index,
                          ) {
                            return ActionChip(
                              label: Text(
                                performer.tagNames[index],
                                style: context.textTheme.bodySmall,
                              ),
                              backgroundColor: context.colors.surfaceVariant,
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                if (index < performer.tagIds.length) {
                                  context.push(
                                    '/tag/${performer.tagIds[index]}',
                                  );
                                }
                              },
                            );
                          }),
                        ),
                      ],
                      if (performer.urls.isNotEmpty) ...[
                        const Divider(height: 32, color: Colors.grey),
                        const SectionHeader(
                          title: 'Links',
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: AppTheme.spacingSmall),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: performer.urls.map((url) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppTheme.spacingSmall,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link,
                                    size: 16,
                                    color: context.colors.primary,
                                  ),
                                  const SizedBox(width: AppTheme.spacingSmall),
                                  Expanded(
                                    child: Text(
                                      url,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: context.colors.primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      if (performer.details != null &&
                          performer.details!.trim().isNotEmpty) ...[
                        const Divider(height: 32, color: Colors.grey),
                        const SectionHeader(title: 'Details'),
                        Text(
                          performer.details!,
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
                          '/performers/performer/${performer.id}/media',
                        ),
                      ),
                      mediaAsync.when(
                        data: (mediaItems) {
                          final shuffledItems = [...mediaItems]
                            ..shuffle(Random(performer.id.hashCode));
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
          );
        },
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
