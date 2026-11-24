import 'package:material_ui/material_ui.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/meta_row.dart';
import '../../../../core/presentation/widgets/related_entities.dart';
import '../../../galleries/presentation/gallery_location.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/presentation/widgets/section_panel.dart';
import '../../../../core/presentation/widgets/studio_performer_info_sections.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../../../core/utils/format_bytes.dart';
import '../../domain/entities/image.dart' as entity;

/// Displays image metadata in the shared frosted details-sheet layout.
class ImageDetailsBottomSheet extends StatelessWidget {
  const ImageDetailsBottomSheet({required this.image, super.key});

  final entity.Image image;

  /// Opens image metadata without rating controls.
  static Future<void> show(BuildContext context, entity.Image image) {
    return showMediaDetailsBottomSheet(
      context: context,
      builder: (_) => ImageDetailsBottomSheet(image: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    return SelectionArea(
      child: SafeArea(
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
                          context.l10n.details_image,
                          style: context.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: dims.spacingSmall),
                        Text(
                          ImageDetailsContent.displayTitle(image),
                          style: context.textTheme.bodyMedium,
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
              SizedBox(height: dims.spacingMedium),
              ImageDetailsContent(image: image),
            ],
          ),
        ),
      ),
    );
  }
}

/// Metadata sections used by image details sheets.
class ImageDetailsContent extends StatelessWidget {
  const ImageDetailsContent({required this.image, super.key});

  final entity.Image image;

  /// Returns the image title, filename, or stable ID for display.
  static String displayTitle(entity.Image image) {
    final title = image.title?.trim();
    if (title?.isNotEmpty == true) return title!;
    if (image.files.isNotEmpty) {
      final path = image.files.first.path;
      final segments = path.replaceAll('\\', '/').split('/');
      final filename = segments.lastWhere(
        (segment) => segment.isNotEmpty,
        orElse: () => path,
      );
      if (filename.isNotEmpty) return filename;
    }
    return image.id;
  }

  /// A gallery's title, else its zip or folder name, else its ID.
  static String _galleryName(entity.ImageGallery gallery) {
    if (gallery.title.trim().isNotEmpty) return gallery.title.trim();
    final name = gallery.path
        ?.replaceAll('\\', '/')
        .split('/')
        .lastWhere((segment) => segment.isNotEmpty, orElse: () => '');
    return name?.isNotEmpty == true ? name! : gallery.id;
  }

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    final file = image.files.isNotEmpty ? image.files.first : null;
    return Column(
      children: [
        if (StudioPerformerInfoSections.isVisible(
          studioName: image.studioName,
          performerNames: image.performerNames,
        )) ...[
          StudioPerformerInfoSections(
            studioId: image.studioId,
            studioName: image.studioName,
            performerIds: image.performerIds,
            performerNames: image.performerNames,
            performerImagePaths: image.performerImagePaths,
          ),
          SizedBox(height: dims.spacingMedium),
        ],
        _SectionCard(
          title: context.l10n.common_details,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetaRow(label: context.l10n.images_field_id, value: image.id),
              MetaRow(
                label: context.l10n.common_date,
                value: image.date ?? '--',
              ),
              MetaRow(
                label: context.l10n.images_field_url,
                value: image.urls.isEmpty ? '--' : image.urls.join('\n'),
                selectable: true,
              ),
              for (final (label, value) in [
                (context.l10n.scenes_field_code, image.code),
                (context.l10n.gallery_photographer_title, image.photographer),
                (
                  context.l10n.images_field_o_counter,
                  image.oCounter?.toString(),
                ),
              ])
                if (value != null && value.trim().isNotEmpty)
                  MetaRow(label: label, value: value, selectable: true),
              MetaRow(
                label: context.l10n.common_organized,
                value: image.organized
                    ? context.l10n.common_yes
                    : context.l10n.common_no,
              ),
              if (image.details?.trim().isNotEmpty ?? false) ...[
                SizedBox(height: dims.spacingSmall),
                Text(image.details!, style: context.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (image.tags.isNotEmpty) ...[
          SizedBox(height: dims.spacingMedium),
          _SectionCard(
            title: context.l10n.details_tags,
            child: EntityLinkChips(
              closesSheet: true,
              links: [
                for (final tag in image.tags)
                  (label: tag.name, route: '/tags/tag/${tag.id}'),
              ],
            ),
          ),
        ],
        if (image.galleries.isNotEmpty) ...[
          SizedBox(height: dims.spacingMedium),
          _SectionCard(
            title: context.l10n.galleries_title,
            child: Column(
              children: [
                for (final gallery in image.galleries)
                  RelatedEntityTile(
                    title: _galleryName(gallery),
                    route: galleryLocation(context, gallery.id),
                    fallbackIcon: Icons.photo_library_outlined,
                    closesSheet: true,
                  ),
              ],
            ),
          ),
        ],
        SizedBox(height: dims.spacingMedium),
        _SectionCard(
          title: context.l10n.scene_info_technical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MetaRow(
                label: context.l10n.common_resolution,
                value: file == null ? '--' : '${file.width} x ${file.height}',
              ),
              MetaRow(
                label: context.l10n.sort_filesize,
                value: file?.size != null ? formatBytes(file!.size!) : '--',
              ),
              MetaRow(
                label: context.l10n.scene_info_original_file_path,
                value: file?.path.isNotEmpty == true ? file!.path : '--',
                selectable: true,
              ),
            ],
          ),
        ),
      ],
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
