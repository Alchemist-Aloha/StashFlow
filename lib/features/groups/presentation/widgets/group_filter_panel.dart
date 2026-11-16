import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_widgets.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group_filter.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag.dart';

class GroupFilterPanel extends ConsumerStatefulWidget {
  const GroupFilterPanel({super.key});

  @override
  ConsumerState<GroupFilterPanel> createState() => _GroupFilterPanelState();
}

class _GroupFilterPanelState extends ConsumerState<GroupFilterPanel> {
  late GroupFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(groupListFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.common_filter,
      onReset: () => setState(() => _tempFilter = GroupFilter.empty()),
      body: Column(
        children: [
          _buildGeneralSection(),
          _buildMetadataSection(),
          _buildLibrarySection(),
          _buildRelationshipsSection(),
          _buildUsageSection(),
          _buildSystemSection(),
        ],
      ),
      onApply: () =>
          ref.read(groupListProvider.notifier).setFilter(_tempFilter),
      onSaveDefault: () async {
        ref.read(groupListProvider.notifier).setFilter(_tempFilter);
        await ref.read(groupListFilterProvider.notifier).saveAsDefault();
      },
    );
  }

  Widget _buildGeneralSection() {
    final missingFields = <(String, String)>[
      ('aliases', context.l10n.common_aliases),
      ('description', context.l10n.common_description),
      ('director', context.l10n.scenes_field_director),
      ('date', context.l10n.common_date),
      ('url', context.l10n.common_url),
      ('rating', context.l10n.common_rating),
      ('studio', context.l10n.studios_title),
      ('performers', context.l10n.performers_title),
      ('tags', context.l10n.tags_title),
      ('front_image', context.l10n.groups_field_front_image),
      ('back_image', context.l10n.groups_field_back_image),
      ('scenes', context.l10n.scenes_title),
    ];

    return FilterSection(
      title: context.l10n.filter_group_general,
      initiallyExpanded: true,
      children: [
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
        IntCriterionInput(
          label: context.l10n.common_rating,
          value: _tempFilter.rating100,
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
          label: context.l10n.performers_field_name,
          value: _tempFilter.name,
          onChanged: (value) =>
              setState(() => _tempFilter = _tempFilter.copyWith(name: value)),
        ),
        StringCriterionInput(
          label: context.l10n.scenes_field_director,
          value: _tempFilter.director,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(director: value),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.details_synopsis,
          value: _tempFilter.synopsis,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(synopsis: value),
          ),
        ),
        StringCriterionInput(
          label: context.l10n.common_url,
          value: _tempFilter.url,
          onChanged: (value) =>
              setState(() => _tempFilter = _tempFilter.copyWith(url: value)),
        ),
        IntCriterionInput(
          label: context.l10n.duration_title,
          value: _tempFilter.duration,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(duration: value),
          ),
        ),
        DateCriterionInput(
          label: context.l10n.common_date,
          value: _tempFilter.date,
          onChanged: (value) =>
              setState(() => _tempFilter = _tempFilter.copyWith(date: value)),
        ),
      ],
    );
  }

  Widget _buildLibrarySection() {
    return FilterSection(
      title: context.l10n.filter_group_library,
      children: [
        EntityCriterionInput<Studio>(
          label: context.l10n.studios_title,
          providerType: 'studio',
          criterion: _tempFilter.studios,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              studios: value as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
        EntityCriterionInput<Performer>(
          label: context.l10n.performers_title,
          providerType: 'performer',
          criterion: _tempFilter.performers,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              performers: value as MultiCriterion?,
            ),
          ),
        ),
        EntityCriterionInput<Tag>(
          label: context.l10n.tags_title,
          providerType: 'tag',
          criterion: _tempFilter.tags,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              tags: value as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
      ],
    );
  }

  Widget _buildRelationshipsSection() {
    return FilterSection(
      title: context.l10n.groups_title,
      children: [
        EntityCriterionInput<Group>(
          label: context.l10n.groups_field_containing_groups,
          providerType: 'group',
          criterion: _tempFilter.containingGroups,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              containingGroups: value as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
        EntityCriterionInput<Group>(
          label: context.l10n.groups_field_sub_groups,
          providerType: 'group',
          criterion: _tempFilter.subGroups,
          onChanged: (value) => setState(
            () => _tempFilter = _tempFilter.copyWith(
              subGroups: value as HierarchicalMultiCriterion?,
            ),
          ),
          isHierarchical: true,
        ),
      ],
    );
  }

  Widget _buildUsageSection() {
    return FilterSection(
      title: context.l10n.filter_group_usage,
      children: [
        _countInput(context.l10n.sort_o_counter, _tempFilter.oCounter, (value) {
          _tempFilter = _tempFilter.copyWith(oCounter: value);
        }),
        _countInput(context.l10n.sort_tag_count, _tempFilter.tagCount, (value) {
          _tempFilter = _tempFilter.copyWith(tagCount: value);
        }),
        _countInput(context.l10n.sort_scene_count, _tempFilter.sceneCount, (
          value,
        ) {
          _tempFilter = _tempFilter.copyWith(sceneCount: value);
        }),
        _countInput(
          context.l10n.groups_field_containing_group_count,
          _tempFilter.containingGroupCount,
          (value) {
            _tempFilter = _tempFilter.copyWith(containingGroupCount: value);
          },
        ),
        _countInput(
          context.l10n.sub_group_count_title,
          _tempFilter.subGroupCount,
          (value) {
            _tempFilter = _tempFilter.copyWith(subGroupCount: value);
          },
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return FilterSection(
      title: context.l10n.filter_group_system,
      children: [
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
}
