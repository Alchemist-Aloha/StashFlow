import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/presentation/widgets/section_panel.dart';
import '../../../../core/presentation/widgets/studio_performer_info_sections.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/gallery.dart';

/// Displays complete gallery metadata in the shared frosted details sheet.
class GalleryDetailsBottomSheet extends StatelessWidget {
  const GalleryDetailsBottomSheet({required this.gallery, super.key});

  final Gallery gallery;

  /// Opens the gallery metadata sheet.
  static Future<void> show(BuildContext context, Gallery gallery) {
    return showFrostedPanelBottomSheet<void>(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      builder: (_) => GalleryDetailsBottomSheet(gallery: gallery),
    );
  }

  void _closeAndNavigate(BuildContext context, String route) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    unawaited(router.push(route));
  }

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    return SelectionArea(
      child: SafeArea(
        key: const Key('gallery_details_sheet'),
        top: false,
        child: FrostedPanel(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusExtraLarge),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(dims.spacingLarge),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.details_gallery,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: dims.spacingSmall),
                        Text(
                          gallery.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.common_close,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SizedBox(height: dims.spacingMedium),
              if (StudioPerformerInfoSections.isVisible(
                studioName: gallery.studioName,
                performerNames: gallery.performerNames,
              )) ...[
                StudioPerformerInfoSections(
                  studioId: gallery.studioId,
                  studioName: gallery.studioName,
                  performerIds: gallery.performerIds,
                  performerNames: gallery.performerNames,
                  performerImagePaths: gallery.performerImagePaths,
                ),
                SizedBox(height: dims.spacingMedium),
              ],
              if (gallery.tagNames.isNotEmpty) ...[
                _SectionCard(
                  title: context.l10n.details_tags,
                  child: Wrap(
                    spacing: dims.spacingSmall,
                    runSpacing: dims.spacingSmall,
                    children: List.generate(
                      gallery.tagNames.length,
                      (index) => ActionChip(
                        label: Text(gallery.tagNames[index]),
                        onPressed: index < gallery.tagIds.length
                            ? () => _closeAndNavigate(
                                context,
                                '/tags/tag/${gallery.tagIds[index]}',
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: dims.spacingMedium),
              ],
              _SectionCard(
                title: context.l10n.common_details,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MetaRow(
                      label: context.l10n.galleries_field_id,
                      value: gallery.id,
                    ),
                    if (gallery.path?.trim().isNotEmpty == true)
                      _MetaRow(
                        label: context.l10n.galleries_field_path,
                        value: gallery.path!,
                        selectable: true,
                      ),
                    if (gallery.code?.trim().isNotEmpty == true)
                      _MetaRow(
                        label: context.l10n.gallery_code_title,
                        value: gallery.code!,
                      ),
                    if (gallery.photographer?.trim().isNotEmpty == true)
                      _MetaRow(
                        label: context.l10n.gallery_photographer_title,
                        value: gallery.photographer!,
                      ),
                    _MetaRow(
                      label: context.l10n.common_date,
                      value: gallery.date?.trim().isNotEmpty == true
                          ? gallery.date!
                          : '--',
                    ),
                    _MetaRow(
                      label: context.l10n.galleries_field_image_count,
                      value: '${gallery.imageCount ?? 0}',
                    ),
                    if (gallery.rating100 != null)
                      _MetaRow(
                        label: context.l10n.common_rating,
                        value: (gallery.rating100! / 20).toStringAsFixed(1),
                      ),
                    if (gallery.organized != null)
                      _MetaRow(
                        label: context.l10n.common_organized,
                        value: gallery.organized!
                            ? context.l10n.common_yes
                            : context.l10n.common_no,
                      ),
                    if (gallery.urls.isNotEmpty)
                      _MetaRow(
                        label: context.l10n.common_url,
                        value: gallery.urls.join('\n'),
                        selectable: true,
                      ),
                    if (gallery.createdAt?.trim().isNotEmpty == true)
                      _MetaRow(
                        label: context.l10n.sort_created_at,
                        value: gallery.createdAt!,
                      ),
                    if (gallery.updatedAt?.trim().isNotEmpty == true)
                      _MetaRow(
                        label: context.l10n.sort_updated_at,
                        value: gallery.updatedAt!,
                      ),
                    if (gallery.details?.trim().isNotEmpty == true) ...[
                      SizedBox(height: dims.spacingSmall),
                      SelectableText(gallery.details!.trim()),
                    ],
                  ],
                ),
              ),
              if (gallery.coverPath?.trim().isNotEmpty == true ||
                  (gallery.coverWidth != null &&
                      gallery.coverHeight != null)) ...[
                SizedBox(height: dims.spacingMedium),
                _SectionCard(
                  title: context.l10n.scene_info_technical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (gallery.coverWidth != null &&
                          gallery.coverHeight != null)
                        _MetaRow(
                          label: context.l10n.common_resolution,
                          value:
                              '${gallery.coverWidth} x ${gallery.coverHeight}',
                        ),
                      if (gallery.coverPath?.trim().isNotEmpty == true)
                        _MetaRow(
                          label: context.l10n.scene_info_screenshot,
                          value: gallery.coverPath!,
                          selectable: true,
                        ),
                    ],
                  ),
                ),
              ],
              if (gallery.filePaths.isNotEmpty) ...[
                SizedBox(height: dims.spacingMedium),
                _SectionCard(
                  title: context.l10n.files,
                  child: SelectableText(gallery.filePaths.join('\n')),
                ),
              ],
              if (gallery.chapters.isNotEmpty) ...[
                SizedBox(height: dims.spacingMedium),
                _SectionCard(
                  title: context.l10n.gallery_chapters_title,
                  child: Column(
                    children: gallery.chapters
                        .map(
                          (chapter) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.bookmark_outline_rounded),
                            title: Text(chapter.title),
                            subtitle: Text(
                              context.l10n.gallery_chapter_image(
                                chapter.imageIndex,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SectionPanel(title: title, child: child);
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
    final dims = context.dimensions;
    return Padding(
      padding: EdgeInsets.only(bottom: dims.spacingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: dims.buttonHeight * 2.5,
            child: Text(
              label,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: selectable
                ? SelectableText(value, style: context.textTheme.bodySmall)
                : Text(value, style: context.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
