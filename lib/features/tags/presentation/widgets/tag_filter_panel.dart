import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_widgets.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/features/scenes/presentation/widgets/entity_picker.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag_filter.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';

class TagFilterPanel extends ConsumerStatefulWidget {
  const TagFilterPanel({super.key});

  @override
  ConsumerState<TagFilterPanel> createState() => _TagFilterPanelState();
}

class _TagFilterPanelState extends ConsumerState<TagFilterPanel> {
  late TagFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(tagListFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.tags_filter_title,
      onReset: () => setState(() => _tempFilter = TagFilter.empty()),
      body: Column(
        children: [
          _buildGeneralSection(),
          _buildMetadataSection(),
          _buildRelationshipsSection(),
          _buildUsageSection(),
          _buildSystemSection(),
        ],
      ),
      onApply: () => ref.read(tagListProvider.notifier).setFilter(_tempFilter),
      onSaveDefault: () async {
        ref.read(tagListProvider.notifier).setFilter(_tempFilter);
        await ref.read(tagListFilterProvider.notifier).saveAsDefault();
      },
      saveDefaultSuccessMessage: context.l10n.tags_filter_saved,
    );
  }

  Widget _buildGeneralSection() {
    final missingFields = <(String, String)>[
      ('image', context.l10n.common_image),
      ('aliases', context.l10n.common_aliases),
      ('description', context.l10n.common_description),
      ('stash_id', context.l10n.common_stash_id),
    ];

    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [
        _buildBooleanFilter(
          context.l10n.common_favorite,
          _tempFilter.favorite,
          (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(favorite: value),
          ),
        ),
        _buildBooleanFilter(
          context.l10n.filter_ignore_auto_tag,
          _tempFilter.ignoreAutoTag,
          (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(ignoreAutoTag: value),
          ),
        ),
        FilterField(
          label: context.l10n.auto_missing_field,
          children: [
            FilterDropdown<String?>(
              value: _tempFilter.isMissingField,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(context.l10n.common_none),
                ),
                ...missingFields.map(
                  (entry) => DropdownMenuItem<String?>(
                    value: entry.$1,
                    child: Text(entry.$2),
                  ),
                ),
              ],
              onChanged: (value) => setState(
                () => _tempFilter = _tempFilter.copyWith(isMissingField: value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return FilterSection(
      title: context.l10n.filter_group_metadata,
      children: [
        StringCriterionInput(
          label: context.l10n.performers_field_name,
          value: _tempFilter.name,
          onChanged: (value) =>
              setState(() => _tempFilter = _tempFilter.copyWith(name: value)),
        ),
        StringCriterionInput(
          label: context.l10n.tags_field_sort_name,
          value: _tempFilter.sortName,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(sortName: value),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.common_aliases,
          value: _tempFilter.aliases,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(aliases: value),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.common_description,
          value: _tempFilter.description,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(description: value),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipsSection() {
    return FilterSection(
      title: context.l10n.filter_group_library,
      children: [
        _buildTagFilter(
          context.l10n.tags_field_parent_tags,
          _tempFilter.parents,
          (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(parents: value),
          ),
        ),
        _buildTagFilter(
          context.l10n.tags_field_child_tags,
          _tempFilter.children,
          (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(children: value),
          ),
        ),
      ],
    );
  }

  Widget _buildUsageSection() {
    return FilterSection(
      title: context.l10n.filter_group_usage,
      children: [
        _countInput(context.l10n.sort_scene_count, _tempFilter.sceneCount, (
          value,
        ) {
          _tempFilter = _tempFilter.copyWith(sceneCount: value);
        }),
        _countInput(context.l10n.sort_images_count, _tempFilter.imageCount, (
          value,
        ) {
          _tempFilter = _tempFilter.copyWith(imageCount: value);
        }),
        _countInput(
          context.l10n.sort_galleries_count,
          _tempFilter.galleryCount,
          (value) {
            _tempFilter = _tempFilter.copyWith(galleryCount: value);
          },
        ),
        _countInput(
          context.l10n.sort_performers_count,
          _tempFilter.performerCount,
          (value) {
            _tempFilter = _tempFilter.copyWith(performerCount: value);
          },
        ),
        _countInput(context.l10n.sort_studios_count, _tempFilter.studioCount, (
          value,
        ) {
          _tempFilter = _tempFilter.copyWith(studioCount: value);
        }),
        _countInput(context.l10n.sort_groups_count, _tempFilter.groupCount, (
          value,
        ) {
          _tempFilter = _tempFilter.copyWith(groupCount: value);
        }),
        _countInput(context.l10n.sort_marker_count, _tempFilter.markerCount, (
          value,
        ) {
          _tempFilter = _tempFilter.copyWith(markerCount: value);
        }),
        _countInput(
          context.l10n.tags_field_parent_count,
          _tempFilter.parentCount,
          (value) {
            _tempFilter = _tempFilter.copyWith(parentCount: value);
          },
        ),
        _countInput(
          context.l10n.tags_field_child_count,
          _tempFilter.childCount,
          (value) {
            _tempFilter = _tempFilter.copyWith(childCount: value);
          },
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: context.l10n.filter_group_system,
      children: [
        StashIdCriterionInput(
          value: _tempFilter.stashIdEndpoint,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(stashIdEndpoint: value),
          ),
        ),
        CustomFieldsCriterionInput(
          value: _tempFilter.customFields,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(customFields: value),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.sort_created_at,
          value: _tempFilter.createdAt,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(createdAt: value),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.sort_updated_at,
          value: _tempFilter.updatedAt,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(updatedAt: value),
          ),
        ),
      ],
    );
  }

  Widget _countInput(
    String label,
    IntCriterion? value,
    ValueChanged<IntCriterion?> update,
  ) {
    return IntCriterionInput(
      label: label,
      value: value,
      onChanged: (next) => setState(() => update(next)),
    );
  }

  Widget _buildBooleanFilter(
    String label,
    bool? value,
    ValueChanged<bool?> onChanged,
  ) {
    return FilterField(
      label: label,
      children: [
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

  Widget _buildTagFilter(
    String label,
    HierarchicalMultiCriterion? criterion,
    ValueChanged<HierarchicalMultiCriterion?> onChanged,
  ) {
    final selectedIds = criterion?.value ?? <String>[];
    final modifier = criterion?.modifier ?? CriterionModifier.includes;

    return SelectionCriterionInput(
      label: label,
      selectedIds: selectedIds,
      modifier: modifier,
      onModifierChanged: (next) => onChanged(
        HierarchicalMultiCriterion(value: selectedIds, modifier: next),
      ),
      onAddPressed: () async {
        final result = await showDialog<List<Tag>>(
          context: context,
          builder: (context) => EntityPicker<Tag>(
            title: context.l10n.common_select(label),
            providerType: 'tag',
            multiSelect: true,
            initialSelection: selectedIds,
          ),
        );
        if (result == null) return;
        final ids = result.map((tag) => tag.id).toList();
        onChanged(
          ids.isEmpty
              ? null
              : HierarchicalMultiCriterion(value: ids, modifier: modifier),
        );
      },
      onRemoveId: (id) {
        final ids = List<String>.from(selectedIds)..remove(id);
        onChanged(
          ids.isEmpty
              ? null
              : HierarchicalMultiCriterion(value: ids, modifier: modifier),
        );
      },
    );
  }
}
