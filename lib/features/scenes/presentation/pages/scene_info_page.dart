import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import 'package:stash_app_flutter/core/presentation/widgets/stash_image.dart';
import '../../domain/entities/scene.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../providers/scene_details_provider.dart';
import '../widgets/scene_info_media_section.dart';

class SceneInfoPage extends ConsumerStatefulWidget {
  const SceneInfoPage({required this.scene, super.key});

  final Scene scene;

  @override
  ConsumerState<SceneInfoPage> createState() => _SceneInfoPageState();
}

class _SceneInfoPageState extends ConsumerState<SceneInfoPage> {
  final ValueNotifier<bool> _showAllTags = ValueNotifier<bool>(false);

  void _closeAndNavigate(String route) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(route);
  }

  String _formatDuration(double? seconds) {
    if (seconds == null) return '--:--';
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatBytes(int? bytes) {
    if (bytes == null || bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    var size = bytes.toDouble();
    var unit = 0;
    while (size >= 1024 && unit < suffixes.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(unit == 0 ? 0 : 2)} ${suffixes[unit]}';
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
    final hasDetails = (scene.details ?? '').trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: FrostedPanel(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.details_scene,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (SceneInfoMediaSection.isVisibleFor(scene)) ...[
              SceneInfoMediaSection(scene: scene),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  text: scene.date.toIso8601String().split('T').first,
                ),
                _InfoChip(
                  icon: Icons.timelapse_rounded,
                  text: _formatDuration(file?.duration),
                ),
                _InfoChip(
                  icon: Icons.play_arrow_rounded,
                  text: '${scene.playCount}',
                ),
                _InfoChip(
                  icon: Icons.favorite_rounded,
                  text: '${scene.oCounter}',
                ),
                _InfoChip(
                  icon: Icons.star_rounded,
                  text: scene.rating100 != null ? '${scene.rating100}' : '--',
                ),
                if (scene.organized)
                  _InfoChip(
                    icon: Icons.check_circle_rounded,
                    text: context.l10n.organized_title,
                  ),
                if (scene.interactive)
                  _InfoChip(
                    icon: Icons.touch_app_rounded,
                    text: context.l10n.interactive_title,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if ((scene.studioName ?? '').trim().isNotEmpty)
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
                        title: Text(
                          performerName.isNotEmpty
                              ? performerName
                              : context.l10n.common_unknown,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap:
                            performerId != null && performerId.trim().isNotEmpty
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
                            onPressed: tagId != null && tagId.trim().isNotEmpty
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
                  _MetaRow(label: context.l10n.scene_info_id, value: scene.id),
                  _MetaRow(
                    label: context.l10n.scene_info_original_file_path,
                    value: scene.path?.trim().isNotEmpty == true
                        ? scene.path!
                        : '--',
                    selectable: true,
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_resume_time,
                    value: _formatDuration(scene.resumeTime),
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_play_duration,
                    value: _formatDuration(scene.playDuration),
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_urls,
                    value: scene.urls.isNotEmpty ? scene.urls.join('\n') : '--',
                    selectable: true,
                  ),
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
                  _MetaRow(
                    label: context.l10n.scene_info_resolution,
                    value: file?.width != null && file?.height != null
                        ? '${file!.width} x ${file.height}'
                        : '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_bitrate,
                    value: file?.bitRate != null
                        ? _formatBytes(file!.bitRate)
                        : '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_frame_rate,
                    value: file?.frameRate != null
                        ? '${file!.frameRate!.toStringAsFixed(2)} fps'
                        : '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_format,
                    value: file?.format ?? '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_video_codec,
                    value: file?.videoCodec ?? '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_audio_codec,
                    value: file?.audioCodec ?? '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_stream,
                    value: scene.paths.stream ?? '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_preview,
                    value: scene.paths.preview ?? '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_screenshot,
                    value: scene.paths.screenshot ?? '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_caption,
                    value: scene.paths.caption ?? '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_vtt,
                    value: scene.paths.vtt ?? '--',
                  ),
                  _MetaRow(
                    label: context.l10n.scene_info_sprite,
                    value: scene.paths.sprite ?? '--',
                  ),
                ],
              ),
            ),
          ],
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) ...[trailing!],
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 128,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: selectable
                ? SelectableText(value, style: theme.textTheme.bodySmall)
                : Text(value, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
