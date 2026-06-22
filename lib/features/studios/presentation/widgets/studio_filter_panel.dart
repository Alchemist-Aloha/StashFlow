import 'package:flutter/material.dart';
import '../../../../core/utils/l10n_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/studio_filter.dart';
import '../../../../core/domain/entities/criterion.dart';
import '../providers/studio_list_provider.dart';
import '../../../../core/presentation/theme/app_theme.dart';
import '../../../../core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import '../../../../core/presentation/widgets/filter_widgets.dart';
import '../../../scenes/presentation/widgets/entity_picker.dart';
import '../../domain/entities/studio.dart';
import '../../../tags/domain/entities/tag.dart';
import '../../../../core/domain/entities/filter_options.dart';

class StudioFilterPanel extends ConsumerStatefulWidget {
  const StudioFilterPanel({super.key});

  @override
  ConsumerState<StudioFilterPanel> createState() => _StudioFilterPanelState();
}

class _StudioFilterPanelState extends ConsumerState<StudioFilterPanel> {
  late StudioFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(studioFilterStateProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.studios_filter_title,
      onReset: () {
        setState(() {
          _tempFilter = StudioFilter.empty();
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
      onApply: () =>
          ref.read(studioFilterStateProvider.notifier).update(_tempFilter),
      onSaveDefault: () async {
        ref.read(studioFilterStateProvider.notifier).update(_tempFilter);
        await ref.read(studioFilterStateProvider.notifier).saveAsDefault();
      },
      saveDefaultSuccessMessage: context.l10n.studios_filter_saved,
    );
  }

  Widget _buildGeneralSection() {
    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [
        _buildBooleanFilter(
          'Favorite',
          _tempFilter.favorite,
          (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(favorite: val)),
        ),
        _buildRatingFilter(),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: context.l10n.filter_group_metadata,
      children: [
        StringCriterionInput(
          label: context.l10n.studios_field_name,
          value: _tempFilter.name,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(name: val)),
        ),
        StringCriterionInput(
          label: context.l10n.studios_field_details,
          value: _tempFilter.details,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(details: val)),
        ),
        StringCriterionInput(
          label: context.l10n.studios_field_aliases,
          value: _tempFilter.aliases,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(aliases: val)),
        ),
        StringCriterionInput(
          label: context.l10n.studios_field_url,
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
          'Parent Studios',
          'studio',
          _tempFilter.parentStudios,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              parentStudios: val as HierarchicalMultiCriterion?,
            ),
          ),
          true,
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
        IntCriterionInput(
          label: context.l10n.studios_field_tag_count,
          value: _tempFilter.tagCount,
          onChanged: (val) =>
              setState(() => _tempFilter = _tempFilter.copyWith(tagCount: val)),
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: context.l10n.filter_group_system,
      children: [
        _buildBooleanFilter(
          'Is Missing',
          _tempFilter.isMissing,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(isMissing: val),
          ),
        ),
        _buildBooleanFilter(
          'Ignore Auto Tag',
          _tempFilter.ignoreAutoTag,
          (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(ignoreAutoTag: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_scene_count,
          value: _tempFilter.sceneCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(sceneCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_image_count,
          value: _tempFilter.imageCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(imageCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_gallery_count,
          value: _tempFilter.galleryCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(galleryCount: val),
          ),
        ),
        IntCriterionInput(
          label: context.l10n.studios_field_sub_studio_count,
          value: _tempFilter.childCount,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(childCount: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.studios_field_created_at,
          value: _tempFilter.createdAt,
          onChanged: (val) => setState(
            () => _tempFilter = _tempFilter.copyWith(createdAt: val),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.studios_field_updated_at,
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
          spacing: context.dimensions.spacingSmall / 2,
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
              selected:
                  OrganizedFilter.fromBool(_tempFilter.organized) == option,
              onSelected: (selected) {
                if (selected) {
                  setState(
                    () => _tempFilter = _tempFilter.copyWith(
                      organized: option.toBool(),
                    ),
                  );
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
    if (entity is Tag) return entity.id;
    throw StateError('Unsupported studio filter entity: ${entity.runtimeType}');
  }
}
