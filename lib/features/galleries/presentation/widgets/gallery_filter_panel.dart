import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/gallery_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/gallery_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../scenes/presentation/widgets/entity_picker.dart';
import '../../../studios/domain/entities/studio.dart';
import '../../../performers/domain/entities/performer.dart';
import '../../../tags/domain/entities/tag.dart';
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
      children: [_buildRatingFilter()],
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
        DateCriterionInput(
          label: context.l10n.galleries_field_date,
          value: _tempFilter.date,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(date: val)),
        ),
        IntCriterionInput(
          label: context.l10n.galleries_field_performer_age,
          value: _tempFilter.performerAge,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerAge: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.galleries_field_performer_count,
          value: _tempFilter.performerCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(performerCount: val),
          ),
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
        _buildOrganizedFilter(),
        _buildEntityFilter<Studio>(
          'Studios',
          'studio',
          _tempFilter.studios,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              studios: val as HierarchicalMultiCriterion?,
            ),
          ),
          true,
        ),
        _buildEntityFilter<Performer>(
          'Performers',
          'performer',
          _tempFilter.performers,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              performers: val as MultiCriterion?,
            ),
          ),
          false,
        ),
        _buildEntityFilter<Tag>(
          'Tags',
          'tag',
          _tempFilter.tags,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              tags: val as HierarchicalMultiCriterion?,
            ),
          ),
          true,
        ),
        _buildEntityFilter<Tag>(
          'Performer Tags',
          'tag',
          _tempFilter.performerTags,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              performerTags: val as HierarchicalMultiCriterion?,
            ),
          ),
          true,
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
        _buildBooleanFilter(
          'Is Missing',
          _tempFilter.isMissing,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(isMissing: val),
          ),
        ),
        _buildBooleanFilter(
          'Is Zip',
          _tempFilter.isZip,
          (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(isZip: val)),
        ),
        _buildBooleanFilter(
          'Has Chapters',
          _tempFilter.hasChapters,
          (val) => setState(
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
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.galleries_min_rating,
          style: context.textTheme.labelLarge,
        ),
        Wrap(
          spacing: 4,
          children: [
            for (var stars = 0; stars <= 5; stars++)
              ChoiceChip(
                label: stars == 0
                    ? Text(context.l10n.common_any)
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$stars'),
                          SizedBox(width: context.dimensions.spacingSmall / 2),
                          Icon(
                            Icons.star,
                            size: 16 * context.dimensions.fontSizeFactor,
                          ),
                        ],
                      ),
                selected:
                    (stars == 0 && _tempFilter.rating100 == null) ||
                    (stars > 0 &&
                        _tempFilter.rating100?.value == (stars - 1) * 20 &&
                        _tempFilter.rating100?.modifier ==
                            CriterionModifier.greaterThan),
                onSelected: (_) {
                  setState(() {
                    if (stars == 0) {
                      _tempFilter = _tempFilter.copyWith(rating100: null);
                    } else {
                      _tempFilter = _tempFilter.copyWith(
                        rating100: IntCriterion(
                          value: (stars - 1) * 20,
                          modifier: CriterionModifier.greaterThan,
                        ),
                      );
                    }
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrganizedFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.common_organized,
          style: context.textTheme.labelLarge,
        ),
        Wrap(
          spacing: context.dimensions.spacingSmall,
          children: OrganizedFilter.values.map((option) {
            return ChoiceChip(
              label: Text(option.name.toUpperCase()),
              selected: _tempOrganized == option,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _tempOrganized = option);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBooleanFilter(
    String label,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.labelLarge),
        Wrap(
          spacing: context.dimensions.spacingSmall,
          children: [
            ChoiceChip(
              label: Text(context.l10n.common_any),
              selected: value == null,
              onSelected: (selected) {
                if (selected) onChanged(null);
              },
            ),
            ChoiceChip(
              label: Text(context.l10n.common_yes),
              selected: value == true,
              onSelected: (selected) {
                if (selected) onChanged(true);
              },
            ),
            ChoiceChip(
              label: Text(context.l10n.common_no),
              selected: value == false,
              onSelected: (selected) {
                if (selected) onChanged(false);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntityFilter<T>(
    String label,
    String providerType,
    dynamic criterion,
    ValueChanged<dynamic> onChanged,
    bool isHierarchical,
  ) {
    final List<String> selectedIds = criterion?.value ?? [];
    final modifier = criterion?.modifier ?? CriterionModifier.includes;

    return SelectionCriterionInput(
      label: label,
      selectedIds: selectedIds,
      modifier: modifier,
      onModifierChanged: (next) {
        onChanged(
          _buildEntityCriterion(
            ids: selectedIds,
            modifier: next,
            isHierarchical: isHierarchical,
          ),
        );
      },
      onAddPressed: () async {
        final result = await showDialog<List<T>>(
          context: context,
          builder: (context) => EntityPicker<T>(
            title: context.l10n.common_select(label),
            providerType: providerType,
            multiSelect: true,
            initialSelection: selectedIds,
          ),
        );
        if (result == null) return;

        final ids = result.map((entity) => _extractEntityId(entity)).toList();
        if (ids.isEmpty) {
          onChanged(null);
          return;
        }

        onChanged(
          _buildEntityCriterion(
            ids: ids,
            modifier: modifier,
            isHierarchical: isHierarchical,
          ),
        );
      },
      onRemoveId: (id) {
        final newList = List<String>.from(selectedIds)..remove(id);
        if (newList.isEmpty) {
          onChanged(null);
          return;
        }

        onChanged(
          _buildEntityCriterion(
            ids: newList,
            modifier: modifier,
            isHierarchical: isHierarchical,
          ),
        );
      },
    );
  }

  dynamic _buildEntityCriterion({
    required List<String> ids,
    required CriterionModifier modifier,
    required bool isHierarchical,
  }) {
    if (isHierarchical) {
      return HierarchicalMultiCriterion(value: ids, modifier: modifier);
    }
    return MultiCriterion(value: ids, modifier: modifier);
  }

  String _extractEntityId(Object? entity) {
    if (entity is Studio) return entity.id;
    if (entity is Performer) return entity.id;
    if (entity is Tag) return entity.id;
    throw StateError(
      'Unsupported gallery filter entity: ${entity.runtimeType}',
    );
  }
}
