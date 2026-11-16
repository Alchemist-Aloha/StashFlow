import 'dart:async';

import '../widgets/performer_placeholder.dart';

import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/l10n_extensions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../galleries/presentation/gallery_location.dart';

import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/presentation/widgets/rating_control.dart';
import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../../domain/entities/performer.dart';
import '../providers/performer_details_provider.dart';
import '../../../galleries/presentation/providers/entity_gallery_filter_scope.dart';

import '../../../../core/presentation/widgets/entity_links_section.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/detail_page_scroll_view.dart';
import '../../../../core/presentation/providers/related_entities_provider.dart';
import '../../../../core/presentation/widgets/meta_row.dart';
import '../../../../core/presentation/widgets/related_entities.dart';
import '../../../../core/presentation/widgets/frosted_app_bar.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/section_panel.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';

import '../providers/performer_list_provider.dart';

import 'package:stash_app_flutter/features/scenes/presentation/providers/playback_queue_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/scene_strip.dart';
import 'package:stash_app_flutter/features/galleries/presentation/widgets/gallery_strip.dart';

import '../../../../core/utils/app_log_store.dart';

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
    } on FormatException catch (error, stackTrace) {
      AppLogStore.instance.addError(
        'calculateAge',
        error,
        stackTrace,
        source: 'performer_details_page',
      );
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
              onPressed: () => _openRandomPerformer(context, ref),
              tooltip: context.l10n.random_performer,
              child: const Icon(Icons.casino_outlined),
            )
          : null,
      body: performerAsync.when(
        data: (performer) {
          final age = _calculateAge(performer.birthdate);
          return RefreshIndicator(
            edgeOffset: topInset,
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
            child: DetailPageScrollView(
              padding: EdgeInsets.only(
                top: topInset,
                bottom: MediaQuery.paddingOf(context).bottom,
              ),
              header: Container(
                height: 300,
                width: double.infinity,
                color: context.colors.surfaceVariant,
                child: StashImage(
                  imageUrl: performer.imagePath,
                  placeholderAsset: performerPlaceholderAsset(
                    performer.id,
                    performer.gender,
                  ),
                  fit: BoxFit.contain,
                  memCacheWidth: 600,
                ),
              ),
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
                        } on Object catch (e, stackTrace) {
                          AppLogStore.instance.addError(
                            'build',
                            e,
                            stackTrace,
                            source: 'performer_details_page',
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
                        } on Object catch (error, stackTrace) {
                          AppLogStore.instance.addError(
                            'build',
                            error,
                            stackTrace,
                            source: 'performer_details_page',
                          );
                          // This operation also reports invalid results through StateError.
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.details_failed_update_rating(
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
                          children: List.generate(performer.tagNames.length, (
                            index,
                          ) {
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
                          }),
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
                      children: [EntityLinksSection(urls: performer.urls)],
                    ),
                  ),
                ],
                if (_attributes(context, performer) case final attributes
                    when attributes.isNotEmpty ||
                        (performer.details?.trim().isNotEmpty ?? false)) ...[
                  _buildSectionContainer(
                    context,
                    _PerformerDetailsSection(
                      key: ValueKey(performer.id),
                      attributes: attributes,
                      details: performer.details ?? '',
                    ),
                  ),
                ],
                if (mediaAsync.maybeWhen(
                  data: (scenes) => scenes.isNotEmpty,
                  orElse: () => true,
                ))
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
                            return Padding(
                              padding: EdgeInsets.only(
                                top: context.dimensions.spacingMedium,
                              ),
                              child: SceneStrip(
                                scenes: scenes,
                                queueId: PlaybackQueueIds.performerStrip(
                                  performer.id,
                                ),
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
                              '/performers/performer/${performer.id}/galleries',
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
                    context.l10n.details_failed_load_galleries(err.toString()),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ),
                for (final (kind, title, icon) in [
                  (
                    RelatedEntityKind.groups,
                    context.l10n.groups_title,
                    Icons.group_work,
                  ),
                  (
                    RelatedEntityKind.performers,
                    context.l10n.details_appears_with,
                    Icons.person_outline,
                  ),
                ])
                  RelatedEntitiesSection(
                    title: title,
                    fallbackIcon: icon,
                    collapsedCount: kind == RelatedEntityKind.performers
                        ? 5
                        : null,
                    query: (
                      kind: kind,
                      owner: RelatedEntityOwner.performer,
                      id: performer.id,
                    ),
                  ),
              ],
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

  /// Labelled performer attributes that are set, in the web UI's order.
  List<(String, String)> _attributes(
    BuildContext context,
    Performer performer,
  ) {
    final l10n = context.l10n;
    String? text(String? value) =>
        value == null || value.trim().isEmpty ? null : value.trim();
    final circumcised = switch (performer.circumcised) {
      'CUT' => l10n.performers_circumcised_cut,
      'UNCUT' => l10n.performers_circumcised_uncut,
      final other => text(other),
    };
    return [
      for (final (label, value) in [
        (l10n.performers_field_career_start, text(performer.careerStart)),
        (l10n.performers_field_career_end, text(performer.careerEnd)),
        (l10n.performers_field_deathdate, text(performer.deathDate)),
        (l10n.performers_field_weight_kg, performer.weight?.toString()),
        (l10n.performers_field_measurements, text(performer.measurements)),
        (l10n.performers_field_fake_tits, text(performer.fakeTits)),
        (
          l10n.performers_field_penis_length,
          performer.penisLength == null ? null : '${performer.penisLength} cm',
        ),
        (l10n.performers_circumcised, circumcised),
        (l10n.performers_field_tattoos, text(performer.tattoos)),
        (l10n.performers_field_piercings, text(performer.piercings)),
        (l10n.performers_field_o_counter, performer.oCounter?.toString()),
        (
          l10n.common_stash_id,
          text(
            performer.stashIds
                .map((id) => '${id.stashId}\n${id.endpoint}')
                .join('\n'),
          ),
        ),
        (
          l10n.filter_custom_fields,
          text(
            performer.customFields.entries
                .map((field) => '${field.key}: ${field.value}')
                .join('\n'),
          ),
        ),
      ])
        if (value != null) (label, value),
    ];
  }

  Widget _buildChip(BuildContext context, String label) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Chip(
      label: Text(label, style: context.textTheme.bodySmall),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _PerformerDetailsSection extends StatefulWidget {
  const _PerformerDetailsSection({
    required this.attributes,
    required this.details,
    super.key,
  });

  final List<(String, String)> attributes;
  final String details;

  @override
  State<_PerformerDetailsSection> createState() =>
      _PerformerDetailsSectionState();
}

class _PerformerDetailsSectionState extends State<_PerformerDetailsSection> {
  static const _collapsedRows = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final attributes = widget.attributes;
    final details = widget.details.trim();
    final remainingLines = _collapsedRows - attributes.length;
    final style = context.textTheme.bodyMedium?.copyWith(
      color: context.colors.onSurfaceVariant,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        var collapsible = attributes.length > _collapsedRows;
        if (details.isNotEmpty) {
          if (remainingLines <= 0) {
            collapsible = true;
          } else {
            final painter = TextPainter(
              text: TextSpan(text: details, style: style),
              maxLines: remainingLines,
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
            )..layout(maxWidth: constraints.maxWidth);
            collapsible = painter.didExceedMaxLines;
            painter.dispose();
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              key: const Key('performer_details_header'),
              title: context.l10n.common_details,
              padding: EdgeInsets.zero,
              onViewAll: collapsible
                  ? () => setState(() => _showAll = !_showAll)
                  : null,
              actionLabel: _showAll
                  ? context.l10n.details_show_less
                  : context.l10n.details_show_more,
            ),
            SizedBox(height: context.dimensions.spacingSmall),
            for (final (label, value)
                in _showAll ? attributes : attributes.take(_collapsedRows))
              MetaRow(label: label, value: value, selectable: true),
            if (details.isNotEmpty && (_showAll || remainingLines > 0))
              Text(
                details,
                maxLines: _showAll ? null : remainingLines,
                overflow: _showAll ? null : TextOverflow.ellipsis,
                style: style,
              ),
          ],
        );
      },
    );
  }
}
