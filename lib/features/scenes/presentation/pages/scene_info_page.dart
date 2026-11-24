import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';

import '../../../../core/presentation/widgets/meta_row.dart';

import 'package:stash_app_flutter/core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';

import '../../domain/entities/scene.dart';
import '../../../../core/presentation/widgets/section_panel.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/format_duration.dart';
import '../../../../core/utils/format_bytes.dart';
import '../providers/scene_details_provider.dart';
import '../widgets/scene_info_media_section.dart';
import '../widgets/scene_performer_title.dart';

class SceneInfoPage extends ConsumerStatefulWidget {
  const SceneInfoPage({required this.scene, this.onClose, super.key});

  final Scene scene;

  /// Embedded hosts close the panel here; null pops the modal sheet route.
  final VoidCallback? onClose;

  @override
  ConsumerState<SceneInfoPage> createState() => _SceneInfoPageState();
}

class _SceneInfoPageState extends ConsumerState<SceneInfoPage> {
  final ValueNotifier<bool> _showAllTags = ValueNotifier<bool>(false);

  void _close() {
    final onClose = widget.onClose;
    onClose == null ? Navigator.of(context).pop() : onClose();
  }

  void _closeAndNavigate(String route) {
    final router = GoRouter.of(context);
    _close();
    unawaited(router.push(route));
  }

  String _formatDuration(double? seconds) =>
      seconds == null ? '--:--' : formatClockDuration(seconds);

  /// Formats a server timestamp in the local time zone and locale.
  String? _formatTimestamp(BuildContext context, String? raw) {
    final parsed = raw == null ? null : DateTime.tryParse(raw)?.toLocal();
    if (parsed == null) return raw;
    final localizations = MaterialLocalizations.of(context);
    return '${localizations.formatMediumDate(parsed)} '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(parsed))}';
  }

  @override
  void dispose() {
    _showAllTags.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sceneAsync = ref.watch(sceneDetailsProvider(widget.scene.id));
    final scene = sceneAsync.maybeWhen(
      data: (value) => value,
      orElse: () => widget.scene,
    );
    final theme = Theme.of(context);
    final mediaHeaders = ref.watch(mediaHeadersProvider);
    final file = scene.files.isNotEmpty ? scene.files.first : null;
    final date = scene.date;
    final rating = scene.rating100;
    final hasDetails = (scene.details ?? '').trim().isNotEmpty;
    return SelectionArea(
      child: SafeArea(
        top: false,
        child: FrostedPanel(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusExtraLarge),
          ),
          child: ListView(
            padding: EdgeInsets.all(context.dimensions.spacingLarge),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.details_scene,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: context.dimensions.spacingSmall / 2),
                        Text(
                          scene.title,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    tooltip: context.l10n.common_close,
                    onPressed: _close,
                  ),
                ],
              ),
              if (SceneInfoMediaSection.isVisibleFor(scene)) ...[
                SizedBox(height: context.dimensions.spacingSmall * 1.5),
                SceneInfoMediaSection(scene: scene),
              ],
              if ((scene.studioName ?? '').trim().isNotEmpty) ...[
                SizedBox(height: context.dimensions.spacingSmall * 1.5),
                _SectionCard(
                  title: context.l10n.studios_title,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(scene.studioName!),
                    subtitle: scene.studioId != null
                        ? Text(context.l10n.scene_studio_id(scene.studioId!))
                        : null,
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap:
                        scene.studioId != null &&
                            scene.studioId!.trim().isNotEmpty
                        ? () => _closeAndNavigate(
                            '/studios/studio/${scene.studioId}',
                          )
                        : null,
                  ),
                ),
              ],
              if (scene.performerNames.isNotEmpty) ...[
                const SizedBox(height: 12),
                RepaintBoundary(
                  child: _SectionCard(
                    title: context.l10n.performers_title,
                    child: Column(
                      children: List.generate(scene.performerNames.length, (
                        index,
                      ) {
                        final performerName = scene.performerNames[index];
                        final performerId = index < scene.performerIds.length
                            ? scene.performerIds[index]
                            : null;
                        final performerImagePath =
                            index < scene.performerImagePaths.length
                            ? scene.performerImagePaths[index]
                            : null;
                        final performerBirthdate =
                            index < scene.performerBirthdates.length
                            ? scene.performerBirthdates[index]
                            : null;
                        final hasImage =
                            performerImagePath != null &&
                            performerImagePath.trim().isNotEmpty &&
                            !performerImagePath.contains('default=true');
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          minLeadingWidth: 36,
                          leading: hasImage
                              ? CircleAvatar(
                                  radius: 14,
                                  backgroundColor:
                                      theme.colorScheme.surfaceContainerHighest,
                                  foregroundImage: StashImage.provider(
                                    ref,
                                    performerImagePath,
                                    headers: mediaHeaders,
                                  ),
                                  child: const Icon(Icons.person, size: 14),
                                )
                              : const CircleAvatar(
                                  radius: 14,
                                  child: Icon(Icons.person, size: 14),
                                ),
                          title: ScenePerformerTitle(
                            performerName: performerName.isNotEmpty
                                ? performerName
                                : context.l10n.common_unknown,
                            sceneDate: scene.date,
                            birthdate: performerBirthdate,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap:
                              performerId != null &&
                                  performerId.trim().isNotEmpty
                              ? () => _closeAndNavigate(
                                  '/performers/performer/$performerId',
                                )
                              : null,
                        );
                      }),
                    ),
                  ),
                ),
              ],
              if (scene.tagNames.isNotEmpty) ...[
                const SizedBox(height: 12),
                RepaintBoundary(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _showAllTags,
                    builder: (context, showAllTags, _) {
                      final allTagCount = scene.tagNames.length;
                      final visibleTagCount = showAllTags
                          ? allTagCount
                          : allTagCount.clamp(0, 12);
                      return _SectionCard(
                        title: context.l10n.details_tags,
                        trailing: scene.tagNames.length > 12
                            ? TextButton(
                                onPressed: () =>
                                    _showAllTags.value = !showAllTags,
                                child: Text(
                                  showAllTags
                                      ? context.l10n.details_show_less
                                      : context.l10n.details_show_more,
                                ),
                              )
                            : null,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(visibleTagCount, (index) {
                            final tagName = scene.tagNames[index];
                            final tagId = index < scene.tagIds.length
                                ? scene.tagIds[index]
                                : null;
                            return ActionChip(
                              label: Text(tagName),
                              onPressed:
                                  tagId != null && tagId.trim().isNotEmpty
                                  ? () => _closeAndNavigate('/tags/tag/$tagId')
                                  : null,
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _SectionCard(
                title: context.l10n.common_details,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MetaRow(label: context.l10n.scene_info_id, value: scene.id),
                    if (date != null)
                      MetaRow(
                        label: context.l10n.common_release_date,
                        value: date.toIso8601String().split('T').first,
                      ),
                    MetaRow(
                      label: context.l10n.scene_info_original_file_path,
                      value: scene.path?.trim().isNotEmpty == true
                          ? scene.path!
                          : '--',
                      selectable: true,
                    ),
                    MetaRow(
                      label: context.l10n.common_rating,
                      value: rating == null ? '--' : '$rating / 100',
                    ),
                    MetaRow(
                      label: context.l10n.sort_o_count,
                      value: '${scene.oCounter}',
                    ),
                    MetaRow(
                      label: context.l10n.sort_play_count,
                      value: '${scene.playCount}',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_resume_time,
                      value: _formatDuration(scene.resumeTime),
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_play_duration,
                      value: _formatDuration(scene.playDuration),
                    ),
                    if (scene.organized)
                      MetaRow(
                        label: context.l10n.organized_title,
                        value: context.l10n.common_yes,
                      ),
                    if (scene.interactive)
                      MetaRow(
                        label: context.l10n.interactive_title,
                        value: context.l10n.common_yes,
                      ),
                    MetaRow(
                      label: context.l10n.scene_info_urls,
                      value: scene.urls.isNotEmpty
                          ? scene.urls.join('\n')
                          : '--',
                      selectable: true,
                    ),
                    for (final (label, value) in [
                      (context.l10n.scenes_field_code, scene.code),
                      (context.l10n.scenes_field_director, scene.director),
                      (
                        context.l10n.scenes_field_last_played_at,
                        _formatTimestamp(context, scene.lastPlayedAt),
                      ),
                      (
                        context.l10n.sort_created_at,
                        _formatTimestamp(context, scene.createdAt),
                      ),
                      (
                        context.l10n.sort_updated_at,
                        _formatTimestamp(context, scene.updatedAt),
                      ),
                      if (scene.stashIds.isNotEmpty)
                        (
                          context.l10n.common_stash_id,
                          scene.stashIds
                              .map((id) => '${id.stashId}\n${id.endpoint}')
                              .join('\n'),
                        ),
                      if (scene.customFields.isNotEmpty)
                        (
                          context.l10n.filter_custom_fields,
                          scene.customFields.entries
                              .map((field) => '${field.key}: ${field.value}')
                              .join('\n'),
                        ),
                    ])
                      if (value != null && value.trim().isNotEmpty)
                        MetaRow(label: label, value: value, selectable: true),
                    if (hasDetails) ...[
                      const SizedBox(height: 8),
                      SelectableText(
                        scene.details!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: context.l10n.scene_info_technical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MetaRow(
                      label: context.l10n.duration_title,
                      value: _formatDuration(file?.duration),
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_resolution,
                      value: file?.width != null && file?.height != null
                          ? '${file!.width} x ${file.height}'
                          : '--',
                    ),
                    MetaRow(
                      label: context.l10n.sort_filesize,
                      value: file?.size != null
                          ? formatBytes(file!.size!)
                          : '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_bitrate,
                      value: file?.bitRate != null
                          ? formatBytes(file!.bitRate!)
                          : '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_frame_rate,
                      value: file?.frameRate != null
                          ? '${file!.frameRate!.toStringAsFixed(2)} fps'
                          : '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_format,
                      value: file?.format ?? '--',
                    ),
                    for (final fingerprint
                        in file?.fingerprints ?? const <Fingerprint>[])
                      MetaRow(
                        label: fingerprint.type.toUpperCase(),
                        value: fingerprint.value,
                        selectable: true,
                      ),
                    MetaRow(
                      label: context.l10n.scene_info_video_codec,
                      value: file?.videoCodec ?? '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_audio_codec,
                      value: file?.audioCodec ?? '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_stream,
                      value: scene.paths.stream ?? '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_preview,
                      value: scene.paths.preview ?? '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_screenshot,
                      value: scene.paths.screenshot ?? '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_caption,
                      value: scene.paths.caption ?? '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_vtt,
                      value: scene.paths.vtt ?? '--',
                    ),
                    MetaRow(
                      label: context.l10n.scene_info_sprite,
                      value: scene.paths.sprite ?? '--',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) =>
      SectionPanel(title: title, titleTrailing: trailing, child: child);
}
