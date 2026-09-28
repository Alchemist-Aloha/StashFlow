import 'package:flutter/material.dart';

import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/bottom_sheet_panel_chrome.dart';
import '../../../../core/presentation/widgets/section_panel.dart';
import '../../../../core/presentation/widgets/studio_performer_info_sections.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../domain/entities/image.dart' as entity;

/// Displays image metadata in the shared frosted details-sheet layout.
class ImageDetailsBottomSheet extends StatelessWidget {
  const ImageDetailsBottomSheet({required this.image, super.key});

  final entity.Image image;

  /// Opens image metadata without rating controls.
  static Future<void> show(BuildContext context, entity.Image image) {
    return showFrostedPanelBottomSheet<void>(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      builder: (_) => ImageDetailsBottomSheet(image: image),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dims = context.dimensions;
    return SafeArea(
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
    );
  }
}

/// Metadata sections shared by the information-only and rating sheets.
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
              _MetaRow(label: context.l10n.images_field_id, value: image.id),
              _MetaRow(
                label: context.l10n.common_date,
                value: image.date ?? '--',
              ),
              _MetaRow(
                label: context.l10n.images_field_url,
                value: image.urls.isEmpty ? '--' : image.urls.join('\n'),
                selectable: true,
              ),
            ],
          ),
        ),
        SizedBox(height: dims.spacingMedium),
        _SectionCard(
          title: context.l10n.scene_info_technical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MetaRow(
                label: context.l10n.common_resolution,
                value: file == null ? '--' : '${file.width} x ${file.height}',
              ),
              _MetaRow(
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
            width: 128 * dims.fontSizeFactor,
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
