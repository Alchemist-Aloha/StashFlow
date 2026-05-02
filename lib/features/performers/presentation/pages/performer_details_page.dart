import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../providers/performer_media_provider.dart';
import '../providers/performer_details_provider.dart';
import '../providers/performer_galleries_provider.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../providers/performer_list_provider.dart';
import '../../../setup/presentation/providers/scrape_customization_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_strip.dart';

class PerformerDetailsPage extends ConsumerWidget {
  final String performerId;
  const PerformerDetailsPage({required this.performerId, super.key});

  Widget _buildSectionContainer(BuildContext context, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(
        alpha: 0.1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: child,
      ),
    );
  }

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
        SnackBar(content: Text(context.l10n.performers_no_random)),
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
    final galleriesAsync = ref.watch(performerGalleriesProvider(performerId));
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final scrapeEnabled = ref.watch(scrapeEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.details_performer),
        actions: [
          if (scrapeEnabled)
            performerAsync.maybeWhen(
              data: (performer) => IconButton(
                tooltip: context.l10n.common_edit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(
                  '/performers/performer/${performer.id}/edit',
                  extra: performer,
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      floatingActionButton: randomNavigationEnabled
          ? FloatingActionButton.small(
              onPressed: () => _openRandomPerformer(context, ref),
              tooltip: context.l10n.random_performer,
              child: const Icon(Icons.casino_outlined),
            )
          : null,
      body: performerAsync.when(
        data: (performer) {
          final age = _calculateAge(performer.birthdate);
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(performerRepositoryProvider)
                  .getPerformerById(performerId, refresh: true);
              ref.invalidate(performerDetailsProvider(performerId));
              ref.invalidate(performerMediaProvider(performerId));
              ref.invalidate(performerGalleriesProvider(performerId));
              await Future.wait([
                ref.read(performerDetailsProvider(performerId).future),
                ref.read(performerMediaProvider(performerId).future),
                ref.read(performerGalleriesProvider(performerId).future),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (performer.imagePath != null &&
                      performer.imagePath!.isNotEmpty &&
                      !performer.imagePath!.contains('default=true'))
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: context.colors.surfaceVariant,
                      child: StashImage(
                        imageUrl: performer.imagePath!,
                        fit: BoxFit.contain,
                        memCacheWidth: 600,
                      ),
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
                                performer.name,
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.onSurface,
                                    ),
                              ),
                            ),
                            IconButton.filledTonal(
                              icon: Icon(
                                performer.favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              tooltip: performer.favorite
                                  ? 'Remove favorite'
                                  : 'Add favorite',
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(performerRepositoryProvider)
                                      .setPerformerFavorite(
                                        performer.id,
                                        !performer.favorite,
                                      );
                                  ref.invalidate(
                                    performerDetailsProvider(performer.id),
                                  );
                                  ref.invalidate(performerListProvider);
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
                            performer.aliasList.join(', '),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacingSmall),
                        Wrap(
                          spacing: AppTheme.spacingSmall,
                          runSpacing: AppTheme.spacingSmall,
                          children: [
                            if (performer.gender != null)
                              _buildChip(context, performer.gender!),
                            if (age != null) _buildChip(context, '$age'),
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
                        const SizedBox(height: AppTheme.spacingSmall),
                        if (performer.tagNames.isNotEmpty) ...[
                          _buildSectionContainer(
                            context,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: context.l10n.details_tags,
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(height: AppTheme.spacingSmall),
                                Wrap(
                                  spacing: AppTheme.spacingSmall,
                                  runSpacing: AppTheme.spacingSmall,
                                  children: List.generate(
                                    performer.tagNames.length,
                                    (index) {
                                      return ActionChip(
                                        label: Text(
                                          performer.tagNames[index],
                                          style: context.textTheme.bodySmall,
                                        ),
                                        backgroundColor:
                                            context.colors.surfaceVariant,
                                        side: BorderSide.none,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          if (index < performer.tagIds.length) {
                                            context.push(
                                              '/tags/tag/${performer.tagIds[index]}',
                                            );
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (performer.urls.isNotEmpty) ...[
                          _buildSectionContainer(
                            context,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: context.l10n.details_links,
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
                                      child: InkWell(
                                        onTap: () async {
                                          final uri = Uri.tryParse(url);
                                          if (uri == null) return;
                                          try {
                                            if (await canLaunchUrl(uri)) {
                                              await launchUrl(
                                                uri,
                                                mode: LaunchMode.externalApplication,
                                              );
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      context.l10n.common_error(url),
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          } catch (e) {
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    context.l10n.common_error(
                                                      e.toString(),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(4),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.link,
                                              size: 16,
                                              color: context.colors.primary,
                                            ),
                                            const SizedBox(
                                              width: AppTheme.spacingSmall,
                                            ),
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
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (performer.details != null &&
                            performer.details!.trim().isNotEmpty) ...[
                          _buildSectionContainer(
                            context,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SectionHeader(
                                  title: context.l10n.common_details,
                                  padding: EdgeInsets.zero,
                                ),
                                const SizedBox(height: AppTheme.spacingSmall),
                                Text(
                                  performer.details!,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.onSurface.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        _buildSectionContainer(
                          context,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(
                                title: context.l10n.details_media,
                                onViewAll: () => context.push(
                                  '/performers/performer/${performer.id}/media',
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              mediaAsync.when(
                                data: (scenes) {
                                  if (scenes.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppTheme.spacingSmall,
                                      ),
                                      child: Text(
                                        context.l10n.common_no_media_found,
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: context
                                                  .colors
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    );
                                  }
                                  final List<Scene> sceneList = scenes;
                                  final shuffledItems = sceneList.toList()
                                    ..shuffle(Random(performer.id.hashCode));
                                  return SceneStrip(
                                    scenes: shuffledItems,
                                    onTap: (scene) => context.push(
                                      '/scenes/scene/${scene.id}',
                                    ),
                                  );
                                },
                                loading: () => const SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (err, stack) => Text(
                                  context.l10n.common_error(err.toString()),
                                  style: context.textTheme.bodyMedium
                                      ?.copyWith(
                                        color: context.colors.onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        galleriesAsync.when(
                          data: (galleries) {
                            if (galleries.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return _buildSectionContainer(
                              context,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SectionHeader(
                                    title: context.l10n.details_galleries,
                                    onViewAll: () => context.push(
                                      '/performers/performer/${performer.id}/galleries',
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                  GalleryStrip(
                                    galleries: galleries,
                                    onTap: (gallery) {
                                      ref
                                          .read(
                                            imageFilterStateProvider.notifier,
                                          )
                                          .setGalleryId(gallery.id);
                                      context.push('/galleries/images');
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            height: 100,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (err, stack) => Text(
                            'Failed to load galleries: $err',
                            style: context.textTheme.bodyMedium?.copyWith(
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
        error: (err, stack) =>
            Center(child: Text(context.l10n.common_error(err.toString()))),
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
