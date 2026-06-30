import 'package:flutter/material.dart';
import 'dart:math';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../../../scenes/presentation/providers/entity_media_filter_scope.dart';
import '../../../scenes/presentation/providers/playback_queue_provider.dart';
import '../../../scenes/presentation/widgets/scene_strip.dart';
import '../providers/group_details_provider.dart';

class GroupDetailsPage extends ConsumerWidget {
  final String groupId;

  const GroupDetailsPage({required this.groupId, super.key});

  Widget _buildSectionContainer(BuildContext context, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailsProvider(groupId));
    final mediaAsync = ref.watch(
      entityMediaPreviewProvider(EntityMediaFilterKind.group, groupId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.details_group)),
      body: groupAsync.when(
        data: (group) => RefreshIndicator(
          onRefresh: () async {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  color: context.colors.surfaceVariant,
                  child: Center(
                    child: Icon(
                      Icons.group_work,
                      size: 72,
                      color: context.colors.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
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
                      const SizedBox(height: AppTheme.spacingMedium),
                      Wrap(
                        spacing: AppTheme.spacingSmall,
                        runSpacing: AppTheme.spacingSmall,
                        children: [
                          if (group.date != null)
                            _buildChip(context, group.date!),
                          if (group.director != null &&
                              group.director!.isNotEmpty)
                            _buildChip(context, group.director!),
                          if (group.rating100 != null)
                            _buildChip(
                              context,
                              (group.rating100! / 20).toStringAsFixed(1),
                              icon: Icons.star,
                              iconColor: context.colors.ratingColor,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),
                      if (group.synopsis != null &&
                          group.synopsis!.isNotEmpty) ...[
                        _buildSectionContainer(
                          context,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionHeader(
                                title: context.l10n.details_synopsis,
                                padding: EdgeInsets.zero,
                              ),
                              const SizedBox(height: AppTheme.spacingSmall),
                              Text(
                                group.synopsis!,
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
                                '/groups/group/${group.id}/media',
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            mediaAsync.when(
                              data: (scenes) {
                                if (scenes.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.all(
                                      AppTheme.spacingSmall,
                                    ),
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
                                final List<Scene> sceneList = scenes;
                                final shuffledItems = sceneList.toList()
                                  ..shuffle(Random(group.id.hashCode));
                                return SceneStrip(
                                  scenes: shuffledItems,
                                  queueId: PlaybackQueueIds.groupStrip(
                                    group.id,
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
              size: 16,
              color: iconColor ?? context.colors.onSurfaceVariant,
            )
          : null,
      label: Text(label, style: context.textTheme.bodySmall),
      backgroundColor: context.colors.surfaceVariant,
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}
