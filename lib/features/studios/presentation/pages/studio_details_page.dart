import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/widgets/rating_control.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../providers/studio_details_provider.dart';
import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';
import '../../../images/presentation/providers/image_list_provider.dart';

import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/section_panel.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../providers/studio_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_strip.dart';
import '../../domain/entities/studio.dart';

class StudioDetailsPage extends ConsumerWidget {
  final String studioId;
  const StudioDetailsPage({required this.studioId, super.key});

  Widget _buildSectionContainer(BuildContext context, Widget child) {
    return SectionPanel(
      margin: EdgeInsets.only(bottom: context.dimensions.spacingMedium),
      child: child,
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

    unawaited(context.push('/studios/studio/${randomStudio.id}'));
  }

  Future<void> _updateRating(
    BuildContext context,
    WidgetRef ref,
    Studio studio,
    int rating,
  ) async {
    try {
      final repository = ref.read(studioRepositoryProvider);
      await repository.updateStudio(
        id: studio.id,
        input: {'rating100': rating},
      );
      await repository.getStudioById(studio.id, refresh: true);
      if (!context.mounted) return;
      ref.invalidate(studioDetailsProvider(studio.id));
      ref.invalidate(studioListProvider);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.details_failed_update_rating('$error')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studioAsync = ref.watch(studioDetailsProvider(studioId));
    final mediaAsync = ref.watch(
      entityMediaPreviewProvider(EntityMediaFilterKind.studio, studioId),
    );
    final galleriesAsync = ref.watch(
      entityGalleryPreviewProvider(EntityGalleryFilterKind.studio, studioId),
    );
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    return Scaffold(
      appBar: AppBar(),
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
              ref.invalidate(
                entityMediaPreviewProvider(
                  EntityMediaFilterKind.studio,
                  studioId,
                ),
              );
              ref.invalidate(
                entityGalleryPreviewProvider(
                  EntityGalleryFilterKind.studio,
                  studioId,
                ),
              );
              await Future.wait([
                ref.read(studioDetailsProvider(studioId).future),
                ref.read(
                  entityMediaPreviewProvider(
                    EntityMediaFilterKind.studio,
                    studioId,
                  ).future,
                ),
                ref.read(
                  entityGalleryPreviewProvider(
                    EntityGalleryFilterKind.studio,
                    studioId,
                  ).future,
                ),
              ]);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              // Content passes behind the frosted mini player; this inset keeps
              // the last rows reachable while the player is visible.
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
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
                    padding: EdgeInsets.all(context.dimensions.spacingMedium),
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
                          ],
                        ),
                        SizedBox(height: context.dimensions.spacingSmall),
                        Row(
                          key: const Key('studio_actions'),
                          children: [
                            IconButton(
                              key: const Key('studio_action_favorite'),
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
                                          context.l10n
                                              .details_failed_update_favorite(
                                                e.toString(),
                                              ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            SizedBox(width: context.dimensions.spacingSmall),
                            RatingButton(
                              key: const Key('studio_action_rating'),
                              rating100: studio.rating100,
                              onRatingSelected: (rating) =>
                                  _updateRating(context, ref, studio, rating),
                            ),
                            SizedBox(width: context.dimensions.spacingSmall),
                            IconButton(
                              key: const Key('studio_action_edit'),
                              tooltip: context.l10n.common_edit,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => context.push(
                                '/studios/studio/${studio.id}/edit',
                                extra: studio,
                              ),
                            ),
                          ],
                        ),
                        if (studio.details != null &&
                            studio.details!.trim().isNotEmpty) ...[
                          SizedBox(height: context.dimensions.spacingMedium),
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
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (studio.parentStudio != null ||
                            studio.childStudios.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingMedium),
                          _buildHierarchySection(context, studio),
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
                                    queueId: PlaybackQueueIds.studioStrip(
                                      studio.id,
                                    ),
                                    onTap: (scene) => context.push(
                                      '/scenes/scene/${scene.id}',
                                      extra: true,
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
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.onSurfaceVariant,
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
                                      unawaited(
                                        context.push('/galleries/images'),
                                      );
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
                              color: context.colors.onSurfaceVariant,
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
        error: (err, stack) => ErrorStateView(
          message: context.l10n.common_error(err.toString()),
          onRetry: () => ref.invalidate(studioDetailsProvider(studioId)),
        ),
      ),
    );
  }

  Widget _buildHierarchySection(BuildContext context, Studio studio) {
    return _buildSectionContainer(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: context.l10n.studio_hierarchy_title,
            padding: EdgeInsets.zero,
          ),
          if (studio.parentStudio case final parent?) ...[
            SizedBox(height: context.dimensions.spacingSmall),
            Text(
              context.l10n.studio_parent_title,
              style: context.textTheme.labelLarge,
            ),
            _StudioRelationshipTile(studio: parent),
          ],
          if (studio.childStudios.isNotEmpty) ...[
            SizedBox(height: context.dimensions.spacingSmall),
            Text(
              context.l10n.studio_children_title,
              style: context.textTheme.labelLarge,
            ),
            ...studio.childStudios.map(
              (child) => _StudioRelationshipTile(studio: child),
            ),
          ],
        ],
      ),
    );
  }
}

class _StudioRelationshipTile extends StatelessWidget {
  const _StudioRelationshipTile({required this.studio});

  final StudioRelationship studio;

  @override
  Widget build(BuildContext context) {
    final hasImage =
        studio.imagePath?.isNotEmpty == true &&
        !studio.imagePath!.contains('default=true');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: hasImage
            ? ClipOval(
                child: StashImage(
                  imageUrl: studio.imagePath!,
                  width: 40 * context.dimensions.fontSizeFactor,
                  height: 40 * context.dimensions.fontSizeFactor,
                  fit: BoxFit.cover,
                  memCacheWidth: 120,
                ),
              )
            : const Icon(Icons.business_outlined),
      ),
      title: Text(studio.name),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push('/studios/studio/${studio.id}'),
    );
  }
}
