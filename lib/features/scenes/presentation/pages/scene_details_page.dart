import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/data/graphql/media_headers_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/utils/app_log_store.dart';
import '../../../../core/presentation/widgets/error_state_view.dart';
import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/presentation/widgets/stash_image.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/scene_title_utils.dart';
import '../providers/entity_media_filter_scope.dart';
import '../providers/scene_details_provider.dart';
import '../providers/scene_list_provider.dart';
import '../providers/playback_queue_provider.dart';
import '../providers/scene_random_navigation_provider.dart';
import '../providers/video_player_provider.dart';
import 'scene_info_page.dart';
import '../../data/repositories/stream_resolver.dart';
import '../../../setup/presentation/providers/navigation_customization_provider.dart';
import '../../../../core/presentation/providers/layout_settings_provider.dart';
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
/// * Listens to [playerStateProvider] via top-level ShellPage to auto-navigate to the next scene when the current one ends.
/// Pops the immersive fullscreen view automatically when playback transitions to a new scene.

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

enum _SceneDeleteMode { metadataOnly, files }

class SceneDetailsPage extends ConsumerStatefulWidget {
  final String sceneId;
  final bool autoPlayOnMount;
  const SceneDetailsPage({
    required this.sceneId,
    this.autoPlayOnMount = false,
    super.key,
  });

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
  late bool _showTechnicalMetadata;

  final GlobalKey _playerKey = GlobalKey();

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
        .read(sceneRandomNavigationControllerProvider)
        .getRandomScene(excludeSceneId: widget.sceneId);
    if (!context.mounted) return;

    if (randomScene == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.scenes_no_random)));
      return;
    }

    context.push('/scenes/scene/${randomScene.id}', extra: true);
  }

  void _showSceneDetailsSheet(Scene scene) {
    showFrostedPanelBottomSheet(
      context: context,
      useRootNavigator: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      builder: (context) => SceneInfoPage(scene: scene),
    );
  }

  Future<void> _showDeleteSceneDialog(Scene scene) async {
    var mode = _SceneDeleteMode.metadataOnly;
    var isDeleting = false;

    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              icon: Icon(
                Icons.delete_outline,
                color: dialogContext.colors.error,
              ),
              title: Text(context.l10n.delete_scene),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.delete_scenes_help,
                    style: dialogContext.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Wrap(
                    spacing: AppTheme.spacingSmall,
                    runSpacing: AppTheme.spacingSmall,
                    children: [
                      ChoiceChip(
                        avatar: const Icon(Icons.storage_outlined, size: 18),
                        label: Text(context.l10n.metadata_only),
                        selected: mode == _SceneDeleteMode.metadataOnly,
                        onSelected: isDeleting
                            ? null
                            : (selected) {
                                if (selected) {
                                  setDialogState(
                                    () => mode = _SceneDeleteMode.metadataOnly,
                                  );
                                }
                              },
                      ),
                      ChoiceChip(
                        avatar: const Icon(
                          Icons.folder_delete_outlined,
                          size: 18,
                        ),
                        label: Text(context.l10n.files),
                        selected: mode == _SceneDeleteMode.files,
                        onSelected: isDeleting
                            ? null
                            : (selected) {
                                if (selected) {
                                  setDialogState(
                                    () => mode = _SceneDeleteMode.files,
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    mode == _SceneDeleteMode.metadataOnly
                        ? 'Delete metadata only: remove the scene from the database and keep the media file.'
                        : 'Delete files: remove the scene and delete its media file from storage.',
                    style: dialogContext.textTheme.bodySmall?.copyWith(
                      color: dialogContext.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting
                      ? null
                      : () => Navigator.of(dialogContext).pop(false),
                  child: Text(context.l10n.common_cancel),
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: dialogContext.colors.error,
                    foregroundColor: dialogContext.colors.onError,
                  ),
                  onPressed: isDeleting
                      ? null
                      : () async {
                          setDialogState(() => isDeleting = true);
                          try {
                            await ref
                                .read(sceneRepositoryProvider)
                                .deleteScene(
                                  scene.id,
                                  deleteFile: mode == _SceneDeleteMode.files,
                                  deleteGenerated: true,
                                );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop(true);
                            }
                          } catch (e) {
                            setDialogState(() => isDeleting = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to delete scene: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  icon: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(context.l10n.common_delete),
                ),
              ],
            );
          },
        );
      },
    );

    if (deleted != true || !mounted) return;

    ref.read(playbackQueueProvider.notifier).removeScene(scene.id);
    ref.invalidate(sceneDetailsProvider(scene.id));
    _invalidateSceneListUnlessRandom();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.scene_deleted)));

    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
      return;
    }

    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath != '/') {
      context.go('/scenes');
    }
  }

  Future<void> _showAddMarkerDialog(
    Scene scene, {
    required double markerSeconds,
  }) async {
    final title = await showDialog<String>(
      context: context,
      builder: (_) => _AddMarkerDialog(cancelLabel: context.l10n.common_cancel),
    );
    if (title == null) return;

    final markerTitle = title.trim().isEmpty
        ? '${scene.displayTitle} - ${_formatDuration(markerSeconds)}'
        : title.trim();

    try {
      await ref
          .read(sceneRepositoryProvider)
          .createSceneMarker(
            sceneId: scene.id,
            title: markerTitle,
            seconds: markerSeconds,
            primaryTagId: scene.tagIds.isNotEmpty ? scene.tagIds.first : null,
            tagIds: scene.tagIds.isNotEmpty ? [scene.tagIds.first] : const [],
          );
      await ref.read(sceneDetailsProvider(scene.id).notifier).refresh();
      _invalidateSceneListUnlessRandom();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.scene_details_marker_created)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.scene_details_failed_to_create_marker(e.toString()),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteMarkerDialog({
    required Scene scene,
    required SceneMarker marker,
  }) async {
    final deleted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.delete_outline, color: dialogContext.colors.error),
          title: Text(context.l10n.scene_details_delete_marker_title),
          content: Text(
            context.l10n.scene_details_delete_marker_content(marker.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(context.l10n.common_cancel),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: dialogContext.colors.error,
                foregroundColor: dialogContext.colors.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: Text(context.l10n.common_delete),
            ),
          ],
        );
      },
    );

    if (deleted != true) return;

    try {
      await ref.read(sceneRepositoryProvider).deleteSceneMarker(marker.id);
      await ref.read(sceneDetailsProvider(scene.id).notifier).refresh();
      _invalidateSceneListUnlessRandom();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.scene_details_marker_deleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.scene_details_failed_to_delete_marker(e.toString()),
            ),
          ),
        );
      }
    }
  }

  double _currentMarkerSeconds(Scene scene) {
    final playerState = ref.read(playerStateProvider);
    if (playerState.activeScene?.id != scene.id) return 0;
    final position = playerState.player?.state.position ?? Duration.zero;
    return position.inMilliseconds / 1000.0;
  }

  Future<void> _saveVideoToGallery(Scene scene) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.saving_video),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final resolver = ref.read(streamResolverProvider.notifier);
      final choice = await resolver.resolvePreferredStream(scene);
      final videoUrl = choice?.url ?? scene.paths.stream;

      if (videoUrl == null || videoUrl.isEmpty) {
        throw Exception('No stream URL found');
      }

      if (kIsWeb) return;

      final headers = ref.read(mediaHeadersProvider);

      // Determine base directory
      final bool isLinux = !kIsWeb && Platform.isLinux;
      final Directory baseDir = isLinux
          ? (await getDownloadsDirectory() ?? await getTemporaryDirectory())
          : await getTemporaryDirectory();

      final safeTitle = scene.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final baseFileName =
          'stash_${scene.id}${safeTitle.isNotEmpty ? "_$safeTitle" : ""}';
      final tempPath = '${baseDir.path}/$baseFileName.tmp';

      final response = await Dio().download(
        videoUrl,
        tempPath,
        options: Options(headers: headers),
      );

      final contentType = response.headers.value('content-type');
      String extension = 'mp4';
      if (contentType != null) {
        if (contentType.contains('webm')) {
          extension = 'webm';
        } else if (contentType.contains('mkv') ||
            contentType.contains('x-matroska')) {
          extension = 'mkv';
        } else if (contentType.contains('avi')) {
          extension = 'avi';
        }
      }

      final finalPath = '${baseDir.path}/$baseFileName.$extension';
      final file = File(tempPath);
      if (await file.exists()) {
        final finalFile = File(finalPath);
        if (await finalFile.exists()) {
          await finalFile.delete();
        }
        await file.rename(finalPath);
      }

      // 'gal' only supports Android, iOS, Windows, and macOS.
      if (isLinux) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.common_saved_to(finalPath)),
              action: SnackBarAction(
                label: context.l10n.common_show,
                onPressed: () => launchUrl(Uri.file(baseDir.path)),
              ),
            ),
          );
        }
        return;
      }

      bool hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess(toAlbum: true);
      }
      if (!hasAccess) {
        throw Exception('Gallery access denied');
      }

      try {
        await Gal.putVideo(finalPath, album: 'StashFlow');
      } finally {
        final finalFile = File(finalPath);
        if (await finalFile.exists()) {
          await finalFile.delete();
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.saved_to_album)));
      }
    } on GalException catch (e) {
      final message = switch (e.type) {
        GalExceptionType.accessDenied =>
          'Permission to access the gallery is denied.',
        GalExceptionType.notEnoughSpace => 'Not enough space for storage.',
        GalExceptionType.notSupportedFormat => 'Unsupported file format.',
        GalExceptionType.unexpected => 'An unexpected error has occurred.',
      };
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.gallery_error(message))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.failed_to_save(e.toString()))),
        );
      }
    }
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
  void initState() {
    super.initState();
    _showTechnicalMetadata = !ref.read(hideSceneTechnicalMetadataProvider);
  }

  @override
  Widget build(BuildContext context) {
    final sceneAsync = ref.watch(sceneDetailsProvider(widget.sceneId));
    final randomNavigationEnabled = ref.watch(randomNavigationEnabledProvider);

    return Scaffold(
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
      body: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Subtract 8px margin from the body height to ensure video is fully visible
            final safeMaxHeight = constraints.maxHeight - 8;

            return sceneAsync.when(
              data: (scene) {
                final useTwoColumns = !Responsive.isMobile(context);

                if (useTwoColumns) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(sceneDetailsProvider(widget.sceneId));
                      return ref.read(
                        sceneDetailsProvider(widget.sceneId).future,
                      );
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
                                SceneVideoPlayer(
                                  key: _playerKey,
                                  scene: scene,
                                  autoPlayOnMount: widget.autoPlayOnMount,
                                  maxHeight: safeMaxHeight,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(
                                    AppTheme.spacingMedium,
                                  ),
                                  child: _buildMainInfo(context, scene),
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
                            padding: const EdgeInsets.all(
                              AppTheme.spacingMedium,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTagsSection(context, scene),
                                _buildMarkersSection(context, scene),
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
                    return ref.read(
                      sceneDetailsProvider(widget.sceneId).future,
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SceneVideoPlayer(
                          key: _playerKey,
                          scene: scene,
                          autoPlayOnMount: widget.autoPlayOnMount,
                          maxHeight: safeMaxHeight,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMedium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildMainInfo(context, scene),
                              _buildTagsSection(context, scene),
                              _buildMarkersSection(context, scene),
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
                onRetry: () =>
                    ref.refresh(sceneDetailsProvider(widget.sceneId)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context,
    Widget child, {
    Key? key,
    EdgeInsetsGeometry? padding,
  }) {
    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusExtraLarge),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMedium),
        child: child,
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context, Scene scene) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 768;

        final identity = Column(
          key: const Key('scene_header_identity'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(context, scene, isWide: isWide),
            const SizedBox(height: 6),
            _buildStudioAndDate(context, scene),
            if (_showTechnicalMetadata) const SizedBox(height: 8),
            if (_showTechnicalMetadata)
              SizedBox(
                key: const Key('scene_header_metadata'),
                child: _buildTechnicalMetadata(context, scene),
              ),
          ],
        );
        final controls = SizedBox(
          key: const Key('scene_header_controls'),
          child: _buildActions(context, scene),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: double.infinity, child: identity),
            SizedBox(
              height: _showTechnicalMetadata ? AppTheme.spacingMedium : 6,
            ),
            _buildSectionContainer(
              context,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [SizedBox(width: double.infinity, child: controls)],
              ),
              key: const Key('scene_header_section'),
              padding: _showTechnicalMetadata
                  ? null
                  : const EdgeInsets.fromLTRB(
                      AppTheme.spacingMedium,
                      0,
                      AppTheme.spacingMedium,
                      AppTheme.spacingMedium,
                    ),
            ),
            _buildDetails(context, scene),
          ],
        );
      },
    );
  }

  Widget _buildTitle(
    BuildContext context,
    Scene scene, {
    required bool isWide,
  }) {
    final style = isWide
        ? context.textTheme.headlineMedium
        : context.textTheme.headlineSmall;
    return Text(
      scene.displayTitle,
      style: style?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: isWide ? -0.5 : -0.3,
        color: context.colors.onSurface,
      ),
    );
  }

  Widget _buildStudioAndDate(BuildContext context, Scene scene) {
    final canOpenStudio =
        scene.studioId != null && (scene.studioName ?? '').trim().isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (scene.studioName != null)
                Flexible(
                  child: Semantics(
                    button: canOpenStudio,
                    label: canOpenStudio
                        ? 'Open ${scene.studioName} details'
                        : null,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: canOpenStudio
                            ? () => context.push(
                                '/studios/studio/${scene.studioId}',
                              )
                            : null,
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 1,
                          ),
                          child: Text(
                            scene.studioName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: canOpenStudio
                                  ? context.colors.primary
                                  : context.colors.onSurface,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
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
          ),
        ),
        if (!_showTechnicalMetadata)
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('scene_show_metadata'),
                onPressed: () => setState(() => _showTechnicalMetadata = true),
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.onSurfaceVariant,
                ),
                child: Text(
                  context.l10n.details_show_metadata,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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

  Widget _buildActions(BuildContext context, Scene scene) {
    final ratingControls = Wrap(
      key: const Key('scene_rating_controls'),
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: 0,
          children: [
            for (var i = 1; i <= 5; i++)
              IconButton(
                tooltip: context.l10n.scene_rating_stars(i),
                onPressed: () async {
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
                            context.l10n.details_failed_update_rating(
                              e.toString(),
                            ),
                          ),
                        ),
                      );
                    }
                  }
                },
                icon: Icon(
                  (scene.rating100 ?? 0) >= i * 20
                      ? Icons.star
                      : Icons.star_border,
                  color: context.colors.ratingColor,
                  size: 24,
                ),
              ),
          ],
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
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          icon: const Icon(Icons.water_drop_outlined),
          label: Text('${scene.oCounter}'),
        ),
      ],
    );
    final actionButtons = Wrap(
      key: const Key('scene_action_buttons'),
      spacing: 4,
      runSpacing: 4,
      children: [
        IconButton(
          key: const Key('scene_action_add_marker'),
          tooltip: context.l10n.scene_details_add_marker,
          icon: const Icon(Icons.bookmark_add_outlined),
          onPressed: () => _showAddMarkerDialog(
            scene,
            markerSeconds: _currentMarkerSeconds(scene),
          ),
        ),
        IconButton(
          key: const Key('scene_action_info'),
          tooltip: context.l10n.common_more,
          icon: const Icon(Icons.info_outline_rounded),
          onPressed: () => _showSceneDetailsSheet(scene),
        ),
        if (!kIsWeb)
          IconButton(
            key: const Key('scene_action_download'),
            tooltip: context.l10n.common_download,
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _saveVideoToGallery(scene),
          ),
        IconButton(
          key: const Key('scene_action_edit'),
          tooltip: context.l10n.common_edit,
          icon: const Icon(Icons.edit_outlined),
          onPressed: () =>
              context.push('/scenes/scene/${scene.id}/edit', extra: scene),
        ),
        IconButton(
          key: const Key('scene_action_delete'),
          tooltip: context.l10n.delete_scene,
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showDeleteSceneDialog(scene),
        ),
      ],
    );

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: AppTheme.spacingSmall,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [ratingControls, actionButtons],
    );
  }

  Widget _buildDetails(BuildContext context, Scene scene) {
    final detailsText = (scene.details ?? '').trim();
    if (detailsText.isEmpty) return const SizedBox.shrink();

    final canExpandDetails =
        detailsText.length > 260 || detailsText.contains('\n');

    return _buildSectionContainer(
      context,
      Column(
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
        ],
      ),
      key: const Key('scene_details_section'),
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

    return _buildSectionContainer(
      context,
      Column(
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
        ],
      ),
    );
  }

  Widget _buildMarkersSection(BuildContext context, Scene scene) {
    if (scene.markers.isEmpty) return const SizedBox.shrink();

    final markers = [...scene.markers]
      ..sort((a, b) => a.seconds.compareTo(b.seconds));

    return _buildSectionContainer(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.scenes_page_markers_tooltip,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Column(
            children: [
              for (var i = 0; i < markers.length; i++) ...[
                _buildMarkerTile(context, scene, markers[i]),
                if (i != markers.length - 1)
                  const SizedBox(height: AppTheme.spacingSmall),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerTile(
    BuildContext context,
    Scene scene,
    SceneMarker marker,
  ) {
    final imageUrl = marker.screenshot?.isNotEmpty == true
        ? marker.screenshot
        : marker.preview;
    final tagName = marker.primaryTagName?.trim().isNotEmpty == true
        ? marker.primaryTagName!.trim()
        : marker.tagNames.firstWhere(
            (name) => name.trim().isNotEmpty,
            orElse: () => '',
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: SizedBox(
            width: 96,
            height: 54,
            child: imageUrl?.isNotEmpty == true
                ? StashImage(imageUrl: imageUrl, fit: BoxFit.cover)
                : ColoredBox(
                    color: context.colors.surfaceVariant,
                    child: Icon(
                      Icons.bookmark_outline,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                marker.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatMarkerRange(marker),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              if (tagName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(tagName),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                    backgroundColor: context.colors.surfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          tooltip: context.l10n.scene_details_delete_marker_tooltip(
            marker.title,
          ),
          icon: const Icon(Icons.delete_outline),
          color: context.colors.error,
          onPressed: () =>
              _showDeleteMarkerDialog(scene: scene, marker: marker),
        ),
      ],
    );
  }

  String _formatMarkerRange(SceneMarker marker) {
    final start = _formatDuration(marker.seconds);
    final endSeconds = marker.endSeconds;
    if (endSeconds == null) return start;
    return '$start - ${_formatDuration(endSeconds)}';
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

    return _buildSectionContainer(
      context,
      Column(
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
        ],
      ),
    );
  }

  Widget _buildMoreFromStudioSection(BuildContext context, Scene scene) {
    if (scene.studioId == null) return const SizedBox.shrink();

    final canOpenStudio =
        scene.studioId != null && (scene.studioName ?? '').trim().isNotEmpty;
    final studioMediaAsync = ref.watch(
      entityMediaPreviewProvider(EntityMediaFilterKind.studio, scene.studioId!),
    );

    return studioMediaAsync.when(
      data: (scenes) {
        final List<Scene> sceneList = scenes;
        final filtered = sceneList.where((item) => item.id != scene.id).toList()
          ..shuffle(Random(scene.id.hashCode));

        if (filtered.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildSectionContainer(
          context,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: context.l10n.details_more_from_studio,
                onViewAll: canOpenStudio
                    ? () => context.push(
                        '/studios/studio/${scene.studioId}/media',
                      )
                    : null,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppTheme.spacingSmall),
              SceneStrip(
                scenes: filtered,
                queueId: PlaybackQueueIds.sceneMoreFromStudio(
                  sceneId: scene.id,
                  studioId: scene.studioId!,
                ),
                onTap: (selectedScene) => context.push(
                  '/scenes/scene/${selectedScene.id}',
                  extra: true,
                ),
              ),
            ],
          ),
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

class _AddMarkerDialog extends StatefulWidget {
  const _AddMarkerDialog({required this.cancelLabel});

  final String cancelLabel;

  @override
  State<_AddMarkerDialog> createState() => _AddMarkerDialogState();
}

class _AddMarkerDialogState extends State<_AddMarkerDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.bookmark_add_outlined),
      title: Text(context.l10n.scene_details_add_marker),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: context.l10n.auto_marker_name),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.l10n.scene_details_create_marker),
        ),
      ],
    );
  }
}
