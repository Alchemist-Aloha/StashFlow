import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../../../studios/presentation/providers/studio_media_provider.dart';
import '../providers/scene_details_provider.dart';
import '../providers/scene_list_provider.dart';
import '../providers/video_player_provider.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../setup/presentation/providers/scrape_customization_provider.dart';
import '../../domain/entities/scene.dart';
import '../widgets/scene_video_player.dart';
import '../widgets/scene_strip.dart';

/// A detailed view for a single scene,
///
/// This page displays:
/// * A video player ([SceneVideoPlayer]) at the top.
/// * Scene metadata (title, studio, date, performers, tags).
/// * Related media strips (scenes from the same studio, performers, etc.).
/// * Direct file information.
///
/// It also handles sophisticated navigation logic:
/// * Listens to [playerStateProvider] to auto-navigate to the next scene when the current one ends.
/// * Pops the immersive fullscreen view automatically when playback transitions to a new scene.

bool shouldRouteToNextScene(
  String currentPageSceneId,
  Scene? previousActiveScene,
  String? lastKnownActiveSceneId,
  Scene? nextScene,
) {
  final previousId = previousActiveScene?.id ?? lastKnownActiveSceneId;
  return nextScene != null &&
      nextScene.id != currentPageSceneId &&
      previousId == currentPageSceneId;
}

class SceneDetailsPage extends ConsumerStatefulWidget {
  final String sceneId;
  const SceneDetailsPage({required this.sceneId, super.key});

  @override
  ConsumerState<SceneDetailsPage> createState() => _SceneDetailsPageState();
}

class _SceneDetailsPageState extends ConsumerState<SceneDetailsPage> {
  static const _collapsedDetailsLines = 6;
  static const _collapsedTagRowsHeight = 84.0;
  static const _collapsedPerformerRows = 2;

  bool _detailsExpanded = false;
  bool _tagsExpanded = false;
  bool _performersExpanded = false;
  String? _lastKnownActiveSceneId;

  bool _isRandomSortActive() {
    return ref.read(sceneSortProvider).sort == 'random';
  }

  void _invalidateSceneListUnlessRandom() {
    if (_isRandomSortActive()) {
      AppLogStore.instance.add(
        'SceneDetailsPage [${widget.sceneId}] preserving random list order (skip scene list invalidation)',
        source: 'SceneDetailsPage',
      );
      return;
    }
    ref.invalidate(sceneListProvider);
  }

  Future<void> _openRandomScene(BuildContext context) async {
    final randomScene = await ref
        .read(sceneListProvider.notifier)
        .getRandomScene(useCurrentFilter: true, excludeSceneId: widget.sceneId);
    if (!context.mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.scenes_no_random)));
      return;
    }

    context.push('/scenes/scene/${randomScene.id}');
  }

  String _formatDuration(double? seconds) {
    if (seconds == null) return '00:00';
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(playerStateProvider, (previous, next) {
      final nextScene = next.activeScene;
      final previousActiveSceneId =
          previous?.activeScene?.id ?? _lastKnownActiveSceneId;

      // Navigate to next scene if provider indicates we just moved from the current scene
      if (shouldRouteToNextScene(
        widget.sceneId,
        previous?.activeScene,
        _lastKnownActiveSceneId,
        nextScene,
      )) {
        AppLogStore.instance.add(
          'SceneDetailsPage [${widget.sceneId}] navigating to next scene: ${nextScene?.id}',
          source: 'SceneDetailsPage',
        );

        if (nextScene != null) {
          context.pushReplacement('/scenes/scene/${nextScene.id}');
        }
      }

      // Keep the most recent active scene ID in case the provider emits a transient null state
      if (nextScene?.id != null) {
        _lastKnownActiveSceneId = nextScene!.id;
      } else if (previousActiveSceneId != null) {
        _lastKnownActiveSceneId = previousActiveSceneId;
      }
    });

    final sceneAsync = ref.watch(sceneDetailsProvider(widget.sceneId));
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);
    final scrapeEnabled = ref.watch(scrapeEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.details_scene),
        actions: [
          if (scrapeEnabled)
            sceneAsync.maybeWhen(
              data: (scene) => IconButton(
                tooltip: context.l10n.common_edit,
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.push(
                  '/scenes/scene/${scene.id}/edit',
                  extra: scene,
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      floatingActionButton: randomNavigationEnabled
          ? sceneAsync.maybeWhen(
              data: (_) => FloatingActionButton.small(
                onPressed: () => _openRandomScene(context),
                tooltip: context.l10n.random_scene,
                child: const Icon(Icons.casino_outlined),
              ),
              orElse: () => null,
            )
          : null,
      body: sceneAsync.when(
        data: (scene) {
          final useTwoColumns = !Responsive.isMobile(context);

          if (useTwoColumns) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(sceneDetailsProvider(widget.sceneId));
                return ref.read(sceneDetailsProvider(widget.sceneId).future);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Video, Title, Info, Details (61.8%)
                  Expanded(
                    flex: 618,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SceneVideoPlayer(scene: scene),
                          Padding(
                            padding: const EdgeInsets.all(
                              AppTheme.spacingMedium,
                            ),
                            child: _buildMainInfo(
                              context,
                              scene,
                              scrapeEnabled,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Divider
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: context.colors.outline.withValues(alpha: 0.1),
                  ),
                  // Right Column: Tags, Performers, More from Studio (38.2%)
                  Expanded(
                    flex: 382,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTagsSection(context, scene),
                          _buildPerformersSection(context, scene),
                          _buildMoreFromStudioSection(context, scene),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Mobile View (Default Column)
          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(sceneRepositoryProvider)
                  .getSceneById(widget.sceneId, refresh: true);
              ref.invalidate(sceneDetailsProvider(widget.sceneId));
              return ref.read(sceneDetailsProvider(widget.sceneId).future);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SceneVideoPlayer(scene: scene),
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMainInfo(context, scene, scrapeEnabled),
                        _buildTagsSection(context, scene),
                        _buildPerformersSection(context, scene),
                        _buildMoreFromStudioSection(context, scene),
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
          onRetry: () => ref.refresh(sceneDetailsProvider(widget.sceneId)),
        ),
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context, Scene scene, bool scrapeEnabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(context, scene),
        const SizedBox(height: 6),
        _buildStudioAndDate(context, scene),
        const SizedBox(height: 10),
        _buildTechnicalMetadata(context, scene),
        const SizedBox(height: 16),
        _buildActions(context, scene, scrapeEnabled),
        Divider(
          height: 32,
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
        _buildDetails(context, scene),
      ],
    );
  }

  Widget _buildTitle(BuildContext context, Scene scene) {
    return Text(
      scene.displayTitle,
      style: context.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.colors.onSurface,
      ),
    );
  }

  Widget _buildStudioAndDate(BuildContext context, Scene scene) {
    final canOpenStudio =
        scene.studioId != null && (scene.studioName ?? '').trim().isNotEmpty;

    return Row(
      children: [
        if (scene.studioName != null)
          GestureDetector(
            onTap: canOpenStudio
                ? () => context.push('/studios/studio/${scene.studioId}')
                : null,
            child: Text(
              scene.studioName!,
              style: context.textTheme.titleMedium?.copyWith(
                color: canOpenStudio
                    ? context.colors.primary
                    : context.colors.onSurface,
                fontWeight: FontWeight.w500,
                decoration: canOpenStudio
                    ? TextDecoration.underline
                    : TextDecoration.none,
              ),
            ),
          ),
        if (scene.studioName != null)
          Text(
            ' • ',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        Text(
          scene.date.year.toString(),
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalMetadata(BuildContext context, Scene scene) {
    final primaryFile = scene.files.isNotEmpty ? scene.files.first : null;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (primaryFile?.duration != null)
          _buildChip(
            context,
            _formatDuration(primaryFile!.duration),
            icon: Icons.timer,
          ),
        if (primaryFile?.width != null && primaryFile?.height != null)
          _buildChip(
            context,
            '${primaryFile!.width}x${primaryFile.height}',
            icon: Icons.fullscreen,
          ),
        if (primaryFile?.frameRate != null)
          _buildChip(
            context,
            '${primaryFile!.frameRate!.toStringAsFixed(2)} fps',
            icon: Icons.slow_motion_video,
          ),
        if (primaryFile?.bitRate != null)
          _buildChip(
            context,
            '${(primaryFile!.bitRate! / 1000000).toStringAsFixed(2)} Mbps',
            icon: Icons.speed,
          ),
        _buildChip(
          context,
          context.l10n.nPlays(scene.playCount),
          icon: Icons.play_arrow,
        ),
        if (scene.playDuration != null && scene.playDuration! > 0)
          _buildChip(
            context,
            _formatDuration(scene.playDuration),
            icon: Icons.timer_outlined,
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Scene scene, bool scrapeEnabled) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: () async {
              final currentRating = scene.rating100 ?? 0;
              final newRating = (currentRating == i * 20) ? 0 : i * 20;

              try {
                await ref
                    .read(sceneRepositoryProvider)
                    .updateSceneRating(scene.id, newRating);
                await ref
                    .read(sceneRepositoryProvider)
                    .getSceneById(scene.id, refresh: true);
                ref.invalidate(sceneDetailsProvider(scene.id));
                _invalidateSceneListUnlessRandom();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.details_failed_update_rating(e.toString()),
                      ),
                    ),
                  );
                }
              }
            },
            child: Icon(
              (scene.rating100 ?? 0) >= i * 20 ? Icons.star : Icons.star_border,
              color: context.colors.ratingColor,
              size: 28,
            ),
          ),
        if (scene.rating100 != null && scene.rating100! > 0)
          Text(
            (scene.rating100! / 20).toStringAsFixed(1),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        FilledButton.tonalIcon(
          onPressed: () async {
            try {
              await ref
                  .read(sceneRepositoryProvider)
                  .incrementSceneOCounter(scene.id);
              await ref
                  .read(sceneRepositoryProvider)
                  .getSceneById(scene.id, refresh: true);
              ref.invalidate(sceneDetailsProvider(scene.id));
              _invalidateSceneListUnlessRandom();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.l10n.details_o_count_incremented),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.details_failed_increment_o_count(
                        e.toString(),
                      ),
                    ),
                  ),
                );
              }
            }
          },
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(0, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          ),
          icon: const Icon(Icons.water_drop_outlined),
          label: Text('${scene.oCounter}'),
        ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context, Scene scene) {
    final detailsText = (scene.details ?? '').trim();
    if (detailsText.isEmpty) return const SizedBox.shrink();

    final canExpandDetails =
        detailsText.length > 260 || detailsText.contains('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.common_details,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (canExpandDetails)
              TextButton(
                onPressed: () {
                  setState(() => _detailsExpanded = !_detailsExpanded);
                },
                child: Text(
                  _detailsExpanded
                      ? context.l10n.details_show_less
                      : context.l10n.details_show_more,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          detailsText,
          maxLines: _detailsExpanded ? null : _collapsedDetailsLines,
          overflow: _detailsExpanded ? null : TextOverflow.ellipsis,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.8),
          ),
        ),
        Divider(
          height: 32,
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context, Scene scene) {
    final tagIndexes = <int>[];
    for (var i = 0; i < scene.tagNames.length; i++) {
      if (scene.tagNames[i].trim().isNotEmpty) {
        tagIndexes.add(i);
      }
    }
    final hasTags = tagIndexes.isNotEmpty;
    final canExpandTags = tagIndexes.length > 6;

    if (!hasTags) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.details_tags,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (canExpandTags)
              TextButton(
                onPressed: () {
                  setState(() => _tagsExpanded = !_tagsExpanded);
                },
                child: Text(
                  _tagsExpanded
                      ? context.l10n.details_show_less
                      : context.l10n.details_show_more,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: ConstrainedBox(
            constraints: _tagsExpanded
                ? const BoxConstraints()
                : const BoxConstraints(maxHeight: _collapsedTagRowsHeight),
            child: ClipRect(
              child: Wrap(
                spacing: AppTheme.spacingSmall,
                runSpacing: AppTheme.spacingSmall,
                children: [
                  for (final index in tagIndexes)
                    ActionChip(
                      label: Text(
                        scene.tagNames[index],
                        style: context.textTheme.bodySmall,
                      ),
                      backgroundColor: context.colors.surfaceVariant,
                      side: BorderSide.none,
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        if (index < scene.tagIds.length) {
                          context.push('/tags/tag/${scene.tagIds[index]}');
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        Divider(
          height: 32,
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildPerformersSection(BuildContext context, Scene scene) {
    final performerIndexes = <int>[];
    for (var i = 0; i < scene.performerNames.length; i++) {
      if (scene.performerNames[i].trim().isNotEmpty) {
        performerIndexes.add(i);
      }
    }
    final hasPerformers = performerIndexes.isNotEmpty;
    final canExpandPerformers =
        performerIndexes.length > _collapsedPerformerRows;

    if (!hasPerformers) return const SizedBox.shrink();

    final mediaHeaders = ref.watch(mediaHeadersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              context.l10n.performers_title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
            ),
            const Spacer(),
            if (canExpandPerformers)
              TextButton(
                onPressed: () {
                  setState(() => _performersExpanded = !_performersExpanded);
                },
                child: Text(
                  _performersExpanded
                      ? context.l10n.details_show_less
                      : context.l10n.details_show_more,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _performersExpanded
              ? performerIndexes.length
              : min(_collapsedPerformerRows, performerIndexes.length),
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppTheme.spacingSmall),
          itemBuilder: (context, index) {
            final performerIndex = performerIndexes[index];
            final performerName = scene.performerNames[performerIndex].trim();
            final performerImagePath =
                performerIndex < scene.performerImagePaths.length
                ? scene.performerImagePaths[performerIndex]
                : null;
            final hasImage =
                performerImagePath != null &&
                performerImagePath.trim().isNotEmpty &&
                !performerImagePath.contains('default=true');

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: hasImage
                  ? CircleAvatar(
                      backgroundColor: context.colors.surfaceVariant,
                      foregroundImage: StashImage.provider(
                        ref,
                        performerImagePath,
                        headers: mediaHeaders,
                      ),
                      child: const Icon(Icons.person),
                    )
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(performerName, style: context.textTheme.bodyLarge),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (performerIndex < scene.performerIds.length) {
                  context.push(
                    '/performers/performer/${scene.performerIds[performerIndex]}',
                  );
                }
              },
            );
          },
        ),
        Divider(
          height: 32,
          color: context.colors.outline.withValues(alpha: 0.2),
        ),
      ],
    );
  }

  Widget _buildMoreFromStudioSection(BuildContext context, Scene scene) {
    if (scene.studioId == null) return const SizedBox.shrink();

    final canOpenStudio =
        scene.studioId != null && (scene.studioName ?? '').trim().isNotEmpty;
    final studioMediaAsync = ref.watch(studioMediaProvider(scene.studioId!));

    return studioMediaAsync.when(
      data: (scenes) {
        final List<Scene> sceneList = scenes;
        final filtered =
            sceneList.where((item) => item.id != scene.id).toList()
              ..shuffle(Random(scene.id.hashCode));

        if (filtered.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: context.l10n.details_more_from_studio,
              onViewAll: canOpenStudio
                  ? () =>
                        context.push('/studios/studio/${scene.studioId}/media')
                  : null,
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            SceneStrip(
              scenes: filtered,
              onTap: (selectedScene) =>
                  context.push('/scenes/scene/${selectedScene.id}'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
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
