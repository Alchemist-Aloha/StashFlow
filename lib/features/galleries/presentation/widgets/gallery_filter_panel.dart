import 'package:material_ui/material_ui.dart';

import '../../../../core/utils/l10n_extensions.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gallery_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/gallery_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../scenes/domain/entities/scene.dart';
import '../../../../core/domain/entities/filter_options.dart';

class GalleryFilterPanel extends ConsumerStatefulWidget {
  const GalleryFilterPanel({
    super.key,
    this.initialFilter,
    this.initialOrganized,
    this.onApply,
    this.onSaveDefault,
    this.saveSuccessMessage,
  });

  final GalleryFilter? initialFilter;
  final OrganizedFilter? initialOrganized;
  final void Function(GalleryFilter filter, OrganizedFilter organized)? onApply;
  final Future<void> Function(GalleryFilter filter, OrganizedFilter organized)?
  onSaveDefault;
  final String? saveSuccessMessage;

  @override
  ConsumerState<GalleryFilterPanel> createState() => _GalleryFilterPanelState();
}

class _GalleryFilterPanelState extends ConsumerState<GalleryFilterPanel> {
  late GalleryFilter _tempFilter;
  late OrganizedFilter _tempOrganized;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.initialFilter ?? ref.read(galleryFilterStateProvider);
    _tempOrganized =
        widget.initialOrganized ?? ref.read(galleryOrganizedOnlyProvider);
  }

  void _applyFilter() {
    final onApply = widget.onApply;
    if (onApply != null) {
      onApply(_tempFilter, _tempOrganized);
      return;
    }

    ref.read(galleryFilterStateProvider.notifier).update(_tempFilter);
    ref.read(galleryOrganizedOnlyProvider.notifier).set(_tempOrganized);
  }

  Future<void> _saveDefaultFilter() async {
    final onSaveDefault = widget.onSaveDefault;
    if (onSaveDefault != null) {
      await onSaveDefault(_tempFilter, _tempOrganized);
      return;
    }

    _applyFilter();
    await Future.wait([
      ref.read(galleryFilterStateProvider.notifier).saveAsDefault(),
      ref.read(galleryOrganizedOnlyProvider.notifier).saveAsDefault(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.galleries_filter_title,
      onReset: () {
        setState(() {
          _tempFilter = GalleryFilter.empty();
          _tempOrganized = OrganizedFilter.all;
        });
      },
      body: Column(
        children: [
          _buildGeneralSection(),
          _buildMetadataSection(),
          _buildLibrarySection(),
          _buildPerformerSection(),
          _buildMediaInfoSection(),
          _buildSystemSection(),
        ],
      ),
      onApply: _applyFilter,
      onSaveDefault: _saveDefaultFilter,
      saveDefaultSuccessMessage:
          widget.saveSuccessMessage ?? context.l10n.galleries_filter_saved,
    );
  }

  Widget _buildGeneralSection() {
    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [
        RatingCriterionInput(
          criterion: _tempFilter.rating100,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(rating100: value),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: context.l10n.filter_group_metadata,
      children: [
        StringCriterionInput(
          label: context.l10n.galleries_field_title,
          value: _tempFilter.title,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(title: val)),
        ),
        StringCriterionInput(
          label: context.l10n.galleries_field_details,
          value: _tempFilter.details,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_code,
          value: _tempFilter.code,
          onChanged: (value) =>
              setState(() => _tempFilter = _tempFilter.copyWith(code: value)),
        ),
        StringCriterionInput(
          label: context.l10n.filter_photographer,
          value: _tempFilter.photographer,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(photographer: value),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.galleries_field_date,
          value: _tempFilter.date,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(date: val)),
        ),
        IntCriterionInput(
          label: context.l10n.galleries_field_tag_count,
          value: _tempFilter.tagCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
        StringCriterionInput(
          label: context.l10n.galleries_field_url,
          value: _tempFilter.url,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(url: val)),
        ),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return FilterSection(
      title: context.l10n.filter_group_library,
      children: [
        BooleanCriterionInput(
          label: context.l10n.common_organized,
          value: _tempOrganized.toBool(),
          onChanged: (value) =>
              setState(() => _tempOrganized = OrganizedFilter.fromBool(value)),
        ),
        HierarchicalIdCriterionInput(
          label: context.l10n.filter_folder,
          value: _tempFilter.parentFolder,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(parentFolder: value),
          ),
        ),
        EntityCriterionInput<Studio>(
          label: context.l10n.studios_title,
          providerType: 'studio',
          criterion: _tempFilter.studios,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              studios: val as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
        EntityCriterionInput<Tag>(
          label: context.l10n.tags_title,
          providerType: 'tag',
          criterion: _tempFilter.tags,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              tags: val as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
        EntityCriterionInput<Scene>(
          label: context.l10n.scenes_title,
          providerType: 'scene',
          criterion: _tempFilter.scenes,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              scenes: val as MultiCriterion?,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformerSection() {
    return FilterSection(
      title: context.l10n.filter_group_performer,
      children: [
        EntityCriterionInput<Performer>(
          label: context.l10n.performers_title,
          providerType: 'performer',
          criterion: _tempFilter.performers,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              performers: val as MultiCriterion?,
            ),
          ),
        ),
        EntityCriterionInput<Tag>(
          label: context.l10n.tags_title,
          providerType: 'tag',
          criterion: _tempFilter.performerTags,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              performerTags: val as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
        IntCriterionInput(
          label: context.l10n.galleries_field_performer_count,
          value: _tempFilter.performerCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.galleries_field_performer_age,
          value: _tempFilter.performerAge,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerAge: val),
          ),
        ),
        BooleanCriterionInput(
          label: context.l10n.common_favorites_only,
          value: _tempFilter.performerFavorite,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerFavorite: val),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaInfoSection() {
    const resolutions = [
      '144p',
      '240p',
      '360p',
      '480p',
      '540p',
      '720p',
      '1080p',
      '1440p',
      '1920p',
      '2160p',
      '4320p',
    ];

    return FilterSection(
      title: context.l10n.filter_group_media_info,
      children: [
        FilterField(
          label: context.l10n.common_resolution,
          children: [
            Wrap(
              spacing: context.dimensions.spacingSmall / 2,
              children: resolutions.map((resolution) {
                final isSelected =
                    _tempFilter.averageResolution?.value.contains(resolution) ??
                    false;
                return FilterChip(
                  label: Text(resolution),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final current = List<String>.from(
                        _tempFilter.averageResolution?.value ?? [],
                      );
                      if (selected) {
                        current.add(resolution);
                      } else {
                        current.remove(resolution);
                      }
                      _tempFilter = _tempFilter.copyWith(
                        averageResolution: current.isEmpty
                            ? null
                            : MultiCriterion(value: current),
                      );
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: context.l10n.filter_group_system,
      children: [
        IntCriterionInput(
          label: context.l10n.galleries_field_id,
          value: _tempFilter.id,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(id: val)),
        ),
        StringCriterionInput(
          label: context.l10n.galleries_field_path,
          value: _tempFilter.path,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(path: val)),
        ),
        StringCriterionInput(
          label: context.l10n.galleries_field_checksum,
          value: _tempFilter.checksum,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(checksum: val)),
        ),
        MissingFieldCriterionInput(
          value: _tempFilter.isMissing,
          fields: const [
            'title',
            'code',
            'details',
            'photographer',
            'url',
            'date',
            'rating',
            'cover',
            'studio',
            'performers',
            'tags',
            'scenes',
          ],
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(isMissing: value),
          ),
        ),
        BooleanCriterionInput(
          label: 'Is Zip',
          value: _tempFilter.isZip,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(isZip: val)),
        ),
        BooleanCriterionInput(
          label: 'Has Chapters',
          value: _tempFilter.hasChapters,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(hasChapters: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.galleries_field_image_count,
          value: _tempFilter.imageCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(imageCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.galleries_field_file_count,
          value: _tempFilter.fileCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(fileCount: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.galleries_field_created_at,
          value: _tempFilter.createdAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(createdAt: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.galleries_field_updated_at,
          value: _tempFilter.updatedAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(updatedAt: val),
          ),
        ),
        CustomFieldsCriterionInput(
          value: _tempFilter.customFields,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(customFields: value),
          ),
        ),
      ],
    );
  }
}
