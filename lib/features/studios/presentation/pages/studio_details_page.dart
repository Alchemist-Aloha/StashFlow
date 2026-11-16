import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../galleries/presentation/gallery_location.dart';
import '../../../../core/presentation/providers/related_entities_provider.dart';
import '../../../../core/presentation/widgets/entity_links_section.dart';
import '../../../../core/presentation/widgets/meta_row.dart';
import '../../../../core/presentation/widgets/related_entities.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/widgets/rating_control.dart';
import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../providers/studio_details_provider.dart';
import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';

import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/detail_page_scroll_view.dart';
import '../../../../core/presentation/widgets/frosted_app_bar.dart';
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
import '../../../../core/utils/app_log_store.dart';

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
    } on Object catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'updateRating',
        error,
        stackTrace,
        source: 'studio_details_page',
      );
      // This operation also reports invalid results through StateError.
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

    // Content scrolls under the frosted bar from a fixed top inset.
    final appBar = FrostedAppBar(
      bar: AppBar(backgroundColor: Colors.transparent),
    );
    final topInset = appBar.topInset(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
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
            edgeOffset: topInset,
            onRefresh: () async {
              // Bypass the GraphQL cache so the details provider reloads fresh data.
              await ref
                  .read(studioRepositoryProvider)
                  .getStudioById(studioId, refresh: true);
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
            child: DetailPageScrollView(
              padding: EdgeInsets.only(
                top: topInset,
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              header:
                  studio.imagePath != null &&
                      studio.imagePath!.isNotEmpty &&
                      !studio.imagePath!.contains('default=true')
                  ? Container(
                      height: 200,
                      width: double.infinity,
                      color: context.colors.surfaceVariant,
                      child: StashImage(
                        imageUrl: studio.imagePath!,
                        fit: BoxFit.contain,
                        memCacheWidth: 600,
                      ),
                    )
                  : null,
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
                              .setStudioFavorite(studio.id, !studio.favorite);
                          ref.invalidate(studioDetailsProvider(studio.id));
                          ref.invalidate(studioListProvider);
                        } on Object catch (e, stackTrace) {
                          AppLogStore.instance.addError(
                            'build',
                            e,
                            stackTrace,
                            source: 'studio_details_page',
                          );
                          // This operation also reports invalid results through StateError.
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  context.l10n.details_failed_update_favorite(
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
                if (studio.aliases.isNotEmpty) ...[
                  SizedBox(height: context.dimensions.spacingSmall),
                  MetaRow(
                    label: context.l10n.common_aliases,
                    value: studio.aliases.join(', '),
                  ),
                ],
                if (studio.tags.isNotEmpty) ...[
                  SizedBox(height: context.dimensions.spacingMedium),
                  _buildSectionContainer(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: context.l10n.details_tags,
                          padding: EdgeInsets.zero,
                        ),
                        SizedBox(height: context.dimensions.spacingSmall),
                        EntityLinkChips(
                          links: [
                            for (final tag in studio.tags)
                              (label: tag.name, route: '/tags/tag/${tag.id}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                if (studio.urls.isNotEmpty)
                  _buildSectionContainer(
                    context,
                    // The server may repeat a URL; list each once.
                    EntityLinksSection(urls: studio.urls.toSet().toList()),
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
                        SizedBox(height: context.dimensions.spacingSmall),
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
                  SizedBox(height: context.dimensions.spacingMedium),
                  _buildHierarchySection(context, studio),
                ],
                SizedBox(height: context.dimensions.spacingMedium),
                _buildSectionContainer(
                  context,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: context.l10n.details_media,
                        onViewAll: () =>
                            context.push('/studios/studio/${studio.id}/media'),
                        padding: EdgeInsets.zero,
                      ),
                      mediaAsync.when(
                        data: (scenes) {
                          if (scenes.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(
                                top: context.dimensions.spacingSmall,
                              ),
                              child: Text(
                                context.l10n.common_no_media_found,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colors.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: EdgeInsets.only(
                              top: context.dimensions.spacingMedium,
                            ),
                            child: SceneStrip(
                              scenes: scenes,
                              queueId: PlaybackQueueIds.studioStrip(studio.id),
                              onTap: (scene) => context.push(
                                '/scenes/scene/${scene.id}',
                                extra: true,
                              ),
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
                          SizedBox(height: context.dimensions.spacingMedium),
                          GalleryStrip(
                            galleries: galleries,
                            onTap: (gallery) {
                              unawaited(
                                context.push(
                                  galleryLocation(context, gallery.id),
                                ),
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
                for (final (kind, title, icon) in [
                  (
                    RelatedEntityKind.performers,
                    context.l10n.performers_title,
                    Icons.person_outline,
                  ),
                  (
                    RelatedEntityKind.groups,
                    context.l10n.groups_title,
                    Icons.group_work,
                  ),
                ])
                  RelatedEntitiesSection(
                    title: title,
                    fallbackIcon: icon,
                    query: (
                      kind: kind,
                      owner: RelatedEntityOwner.studio,
                      id: studio.id,
                    ),
                  ),
              ],
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
            _relationshipTile(parent),
          ],
          if (studio.childStudios.isNotEmpty) ...[
            SizedBox(height: context.dimensions.spacingSmall),
            Text(
              context.l10n.studio_children_title,
              style: context.textTheme.labelLarge,
            ),
            ...studio.childStudios.map(_relationshipTile),
          ],
        ],
      ),
    );
  }
}

Widget _relationshipTile(StudioRelationship studio) => RelatedEntityTile(
  title: studio.name,
  route: '/studios/studio/${studio.id}',
  imagePath: studio.imagePath,
  fallbackIcon: Icons.business_outlined,
);
