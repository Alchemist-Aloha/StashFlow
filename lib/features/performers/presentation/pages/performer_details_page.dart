import 'dart:async';

import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/widgets/rating_control.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../providers/performer_details_provider.dart';
import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';
import 'package:stash_app_flutter/features/images/presentation/providers/image_list_provider.dart';

import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/section_panel.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_strip.dart';

class PerformerDetailsPage extends ConsumerWidget {
  final String performerId;
  const PerformerDetailsPage({required this.performerId, super.key});

  Widget _buildSectionContainer(BuildContext context, Widget child) {
    return SectionPanel(
      margin: EdgeInsets.only(bottom: context.dimensions.spacingMedium),
      child: child,
    );
  }

  Future<void> _openRandomPerformer(BuildContext context, WidgetRef ref) async {
    final randomPerformer = await ref
        .read(performerListProvider.notifier)
        .getRandomPerformer(excludePerformerId: performerId);
    if (!context.mounted) return;

    if (randomPerformer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.performers_no_random)),
      );
      return;
    }

    unawaited(context.push('/performers/performer/${randomPerformer.id}'));
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
    final mediaAsync = ref.watch(
      entityMediaPreviewProvider(EntityMediaFilterKind.performer, performerId),
    );
    final galleriesAsync = ref.watch(
      entityGalleryPreviewProvider(
        EntityGalleryFilterKind.performer,
        performerId,
      ),
    );
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    return Scaffold(
      appBar: AppBar(),
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
              ref.invalidate(
                entityMediaPreviewProvider(
                  EntityMediaFilterKind.performer,
                  performerId,
                ),
              );
              ref.invalidate(
                entityGalleryPreviewProvider(
                  EntityGalleryFilterKind.performer,
                  performerId,
                ),
              );
              await Future.wait([
                ref.read(performerDetailsProvider(performerId).future),
                ref.read(
                  entityMediaPreviewProvider(
                    EntityMediaFilterKind.performer,
                    performerId,
                  ).future,
                ),
                ref.read(
                  entityGalleryPreviewProvider(
                    EntityGalleryFilterKind.performer,
                    performerId,
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
                    padding: EdgeInsets.all(context.dimensions.spacingMedium),
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
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        if (performer.aliasList.isNotEmpty) ...[
                          SizedBox(height: context.dimensions.spacingSmall / 2),
                          Text(
                            performer.aliasList.join(', '),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppTheme.spacingSmall),
                        Wrap(
                          spacing: context.dimensions.spacingSmall,
                          runSpacing: context.dimensions.spacingSmall,
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
                        SizedBox(height: context.dimensions.spacingSmall),
                        Row(
                          key: const Key('performer_actions'),
                          children: [
                            IconButton(
                              key: const Key('performer_action_favorite'),
                              icon: Icon(
                                performer.favorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                              ),
                              tooltip: performer.favorite
                                  ? context.l10n.common_remove_favorite
                                  : context.l10n.common_add_favorite,
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
                              key: const Key('performer_action_rating'),
                              rating100: performer.rating100,
                              onRatingSelected: (rating) async {
                                try {
                                  final repository = ref.read(
                                    performerRepositoryProvider,
                                  );
                                  await repository.updatePerformer(
                                    id: performer.id,
                                    input: {'rating100': rating},
                                  );
                                  await repository.getPerformerById(
                                    performer.id,
                                    refresh: true,
                                  );
                                  if (!context.mounted) return;
                                  ref.invalidate(
                                    performerDetailsProvider(performer.id),
                                  );
                                  ref.invalidate(performerListProvider);
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        context.l10n
                                            .details_failed_update_rating(
                                              '$error',
                                            ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(width: context.dimensions.spacingSmall),
                            IconButton(
                              key: const Key('performer_action_edit'),
                              tooltip: context.l10n.common_edit,
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => context.push(
                                '/performers/performer/${performer.id}/edit',
                                extra: performer,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: context.dimensions.spacingMedium),
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
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () {
                                          if (index < performer.tagIds.length) {
                                            unawaited(
                                              context.push(
                                                '/tags/tag/${performer.tagIds[index]}',
                                              ),
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
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            } else {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      context.l10n.common_error(
                                                        url,
                                                      ),
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
                                                style: context
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: context
                                                          .colors
                                                          .primary,
                                                      decoration: TextDecoration
                                                          .underline,
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
                                    color: context.colors.onSurfaceVariant,
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
                                    queueId: PlaybackQueueIds.performerStrip(
                                      performer.id,
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
                            context.l10n.details_failed_load_galleries(
                              err.toString(),
                            ),
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
          onRetry: () => ref.invalidate(performerDetailsProvider(performerId)),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Chip(
      label: Text(label, style: context.textTheme.bodySmall),
      visualDensity: VisualDensity.compact,
    );
  }
}
