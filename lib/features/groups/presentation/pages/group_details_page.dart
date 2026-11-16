import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/l10n_extensions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/entity_links_section.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/meta_row.dart';
import '../../../../core/presentation/widgets/related_entities.dart';
import '../../../../core/utils/format_duration.dart';
import '../../domain/entities/group.dart';
import '../widgets/group_cover.dart';
import '../../../../core/presentation/widgets/frosted_app_bar.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/section_panel.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../../../scenes/presentation/providers/playback_queue_provider.dart';
import '../../../scenes/presentation/widgets/scene_strip.dart';
import '../providers/group_details_provider.dart';
import '../providers/group_list_provider.dart';

class GroupDetailsPage extends ConsumerWidget {
  final String groupId;

  const GroupDetailsPage({required this.groupId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dims = context.dimensions;
    final sectionMargin = EdgeInsets.only(bottom: dims.spacingMedium);
    final groupAsync = ref.watch(groupDetailsProvider(groupId));
    final mediaAsync = ref.watch(
      entityMediaPreviewProvider(EntityMediaFilterKind.group, groupId),
    );

    // Content scrolls under the frosted bar from a fixed top inset.
    final appBar = FrostedAppBar(
      bar: AppBar(
        title: Text(context.l10n.details_group),
        backgroundColor: Colors.transparent,
      ),
    );
    final topInset = appBar.topInset(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: groupAsync.when(
        data: (group) => RefreshIndicator(
          edgeOffset: topInset,
          onRefresh: () async {
            // Bypass the GraphQL cache so the details provider reloads fresh data.
            await ref
                .read(groupRepositoryProvider)
                .getGroupById(groupId, refresh: true);
            ref.invalidate(groupDetailsProvider(groupId));
            ref.invalidate(
              entityMediaPreviewProvider(EntityMediaFilterKind.group, groupId),
            );
            await Future.wait([
              ref.read(groupDetailsProvider(groupId).future),
              ref.read(
                entityMediaPreviewProvider(
                  EntityMediaFilterKind.group,
                  groupId,
                ).future,
              ),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            // Content passes behind the frosted mini player; this inset keeps
            // the last rows reachable while the player is visible.
            padding: EdgeInsets.only(
              top: topInset,
              bottom: MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _GroupCovers(group: group),
                Padding(
                  padding: EdgeInsets.all(dims.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name.isEmpty
                            ? context.l10n.groups_untitled
                            : group.name,
                        style: context.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.colors.onSurface,
                        ),
                      ),
                      SizedBox(height: dims.spacingMedium),
                      Wrap(
                        spacing: dims.spacingSmall,
                        runSpacing: dims.spacingSmall,
                        children: [
                          if (group.date != null)
                            _buildChip(context, group.date!),
                          if (group.director != null &&
                              group.director!.isNotEmpty)
                            _buildChip(context, group.director!),
                          if (group.duration case final duration?
                              when duration > 0)
                            _buildChip(
                              context,
                              formatClockDuration(duration),
                              icon: Icons.timer_outlined,
                            ),
                          if (group.rating100 != null)
                            _buildChip(
                              context,
                              (group.rating100! / 20).toStringAsFixed(1),
                              icon: Icons.star,
                              iconColor: context.colors.ratingColor,
                            ),
                        ],
                      ),
                      if (group.aliases case final aliases?
                          when aliases.trim().isNotEmpty) ...[
                        SizedBox(height: dims.spacingSmall),
                        MetaRow(
                          label: context.l10n.common_aliases,
                          value: aliases,
                        ),
                      ],
                      if (group.studioId case final studioId?)
                        RelatedEntityTile(
                          title: group.studioName ?? studioId,
                          route: '/studios/studio/$studioId',
                          imagePath: group.studioImagePath,
                          fallbackIcon: Icons.business_outlined,
                        ),
                      SizedBox(height: dims.spacingMedium),
                      if (group.tags.isNotEmpty)
                        SectionPanel(
                          margin: sectionMargin,
                          title: context.l10n.details_tags,
                          child: EntityLinkChips(
                            links: [
                              for (final tag in group.tags)
                                (label: tag.name, route: '/tags/tag/${tag.id}'),
                            ],
                          ),
                        ),
                      if (group.synopsis != null &&
                          group.synopsis!.isNotEmpty) ...[
                        SectionPanel(
                          margin: sectionMargin,
                          title: context.l10n.details_synopsis,
                          child: Text(
                            group.synopsis!,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                      if (group.urls.isNotEmpty)
                        SectionPanel(
                          margin: sectionMargin,
                          child: EntityLinksSection(urls: group.urls),
                        ),
                      for (final (title, relations) in [
                        (
                          context.l10n.groups_field_containing_groups,
                          group.containingGroups,
                        ),
                        (context.l10n.groups_field_sub_groups, group.subGroups),
                      ])
                        if (relations.isNotEmpty)
                          SectionPanel(
                            margin: sectionMargin,
                            title: title,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final relation in relations)
                                  RelatedEntityTile(
                                    title: relation.name.isEmpty
                                        ? context.l10n.groups_untitled
                                        : relation.name,
                                    subtitle: relation.description,
                                    route: '/groups/group/${relation.id}',
                                    imagePath: relation.imagePath,
                                    fallbackIcon: Icons.group_work,
                                  ),
                              ],
                            ),
                          ),
                      SizedBox(height: dims.spacingMedium),
                      SectionPanel(
                        margin: sectionMargin,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: context.l10n.details_media,
                              onViewAll: () => context.push(
                                '/groups/group/${group.id}/media',
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            mediaAsync.when(
                              data: (scenes) {
                                if (scenes.isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.all(dims.spacingSmall),
                                    child: Text(
                                      context.l10n.common_no_media_found,
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color:
                                                context.colors.onSurfaceVariant,
                                          ),
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: EdgeInsets.only(
                                    top: dims.spacingMedium,
                                  ),
                                  child: SceneStrip(
                                    scenes: scenes,
                                    queueId: PlaybackQueueIds.groupStrip(
                                      group.id,
                                    ),
                                    onTap: (scene) => context.push(
                                      '/scenes/scene/${scene.id}',
                                      extra: true,
                                    ),
                                  ),
                                );
                              },
                              loading: () => SizedBox(
                                height: 100 * dims.fontSizeFactor,
                                child: const Center(
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateView(
          message: context.l10n.common_error(err.toString()),
          onRetry: () => ref.refresh(groupDetailsProvider(groupId)),
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context,
    String label, {
    IconData? icon,
    Color? iconColor,
  }) {
    return Chip(
      avatar: icon != null
          ? Icon(
              icon,
              size: 16 * context.dimensions.fontSizeFactor,
              color: iconColor ?? context.colors.onSurfaceVariant,
            )
          : null,
      label: Text(label, style: context.textTheme.bodySmall),
      visualDensity: VisualDensity.compact,
    );
  }
}

/// Front cover, plus the back cover beside it when the group has one.
class _GroupCovers extends StatelessWidget {
  const _GroupCovers({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final height = 240.0 * context.dimensions.fontSizeFactor;
    final width = height * 2 / 3;
    final cacheWidth = (width * MediaQuery.devicePixelRatioOf(context)).ceil();
    final paths = [
      group.frontImagePath,
      if (GroupCover.hasCover(group.backImagePath)) group.backImagePath,
    ];
    return Container(
      height: height,
      width: double.infinity,
      color: context.colors.surfaceVariant,
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.dimensions.spacingSmall,
        children: [
          for (final path in paths)
            Flexible(
              child: GroupCover(
                imagePath: path,
                width: width,
                height: height,
                memCacheWidth: cacheWidth,
              ),
            ),
        ],
      ),
    );
  }
}
