import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../providers/studio_media_provider.dart';
import '../providers/studio_details_provider.dart';
import '../providers/studio_galleries_provider.dart';
import '../../../images/presentation/providers/image_list_provider.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../providers/studio_list_provider.dart';
import '../../../setup/presentation/providers/scrape_customization_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_strip.dart';

class StudioDetailsPage extends ConsumerWidget {
  final String studioId;
  const StudioDetailsPage({required this.studioId, super.key});

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

  Future<void> _openRandomStudio(BuildContext context, WidgetRef ref) async {
    final randomStudio = await ref
        .read(studioListProvider.notifier)
        .getRandomStudio(excludeStudioId: studioId);
    if (!context.mounted) return;

    if (randomStudio == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.studios_no_random)));
      return;
    }

    context.push('/studios/studio/${randomStudio.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioAsync = ref.watch(studioDetailsProvider(studioId));
    final mediaAsync = ref.watch(studioMediaProvider(studioId));
    final galleriesAsync = ref.watch(studioGalleriesProvider(studioId));
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final scrapeEnabled = ref.watch(scrapeEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.details_studio),
        actions: [
          if (scrapeEnabled)
            studioAsync.maybeWhen(
              data: (studio) => IconButton(
                tooltip: context.l10n.common_edit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(
                  '/studios/studio/${studio.id}/edit',
                  extra: studio,
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      floatingActionButton: randomNavigationEnabled
          ? FloatingActionButton.small(
              onPressed: () => _openRandomStudio(context, ref),
              tooltip: context.l10n.random_studio,
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
                  if (studio.imagePath != null &&
                      studio.imagePath!.isNotEmpty &&
                      !studio.imagePath!.contains('default=true'))
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: context.colors.surfaceVariant,
                      child: StashImage(
                        imageUrl: studio.imagePath!,
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
                                studio.name,
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(
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
                                  ? context.l10n.common_remove_favorite
                                  : context.l10n.common_add_favorite,
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(studioRepositoryProvider)
                                      .setStudioFavorite(
                                        studio.id,
                                        !studio.favorite,
                                      );
                                  ref.invalidate(
                                    studioDetailsProvider(studio.id),
                                  );
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
                        if (studio.details != null &&
                            studio.details!.trim().isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingMedium),
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
                                  studio.details!,
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
                        const SizedBox(height: AppTheme.spacingMedium),
                        _buildSectionContainer(
                          context,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(
                                title: context.l10n.details_media,
                                onViewAll: () => context.push(
                                  '/studios/studio/${studio.id}/media',
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
                                    ..shuffle(Random(studio.id.hashCode));
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
                                      '/studios/studio/${studio.id}/galleries',
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
                            context.l10n.common_error(err.toString()),
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
}
