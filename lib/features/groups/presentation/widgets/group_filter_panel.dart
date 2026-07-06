import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_bottom_sheet_scaffold.dart';
import 'package:stash_app_flutter/core/presentation/widgets/filter_widgets.dart';
import 'package:stash_app_flutter/core/utils/l10n_extensions.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group_filter.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';

class GroupFilterPanel extends ConsumerStatefulWidget {
  const GroupFilterPanel({super.key});

  @override
  ConsumerState<GroupFilterPanel> createState() => _GroupFilterPanelState();
}

class _GroupFilterPanelState extends ConsumerState<GroupFilterPanel> {
  late GroupFilter _tempFilter;

  static const _missingFieldOptions = <String, String>{
    'director': 'Director',
    'synopsis': 'Synopsis',
    'date': 'Date',
    'url': 'URL',
  };

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(groupListFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    return FilterBottomSheetScaffold(
      title: context.l10n.common_filter,
      onReset: () {
        setState(() {
          _tempFilter = GroupFilter.empty();
        });
      },
      body: Column(
        children: [
          FilterSection(
            title: context.l10n.filter_group_general,
            initiallyExpanded: true,
            children: [
              DropdownButtonFormField<String?>(
                initialValue: _tempFilter.isMissingField,
                decoration: InputDecoration(
                  labelText: context.l10n.auto_missing_field,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(context.l10n.common_none),
                  ),
                  ..._missingFieldOptions.entries.map(
                    (entry) => DropdownMenuItem<String?>(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(
                      isMissingField: value,
                      clearIsMissingField: value == null,
                    );
                  });
                },
              ),
              IntCriterionInput(
                label: context.l10n.sub_group_count_title,
                value: _tempFilter.subGroupCount,
                onChanged: (value) {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(
                      subGroupCount: value,
                      clearSubGroupCount: value == null,
                    );
                  });
                },
              ),
              IntCriterionInput(
                label: context.l10n.sort_scene_count,
                value: _tempFilter.sceneCount,
                onChanged: (value) {
                  setState(() {
                    _tempFilter = _tempFilter.copyWith(
                      sceneCount: value,
                      clearSceneCount: value == null,
                    );
                  });
                },
              ),
            ],
          ),
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
}
