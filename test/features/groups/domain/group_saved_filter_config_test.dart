import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group_filter.dart';
import 'package:stash_app_flutter/features/groups/domain/entities/group_saved_filter_config.dart';

void main() {
  test('GroupSavedFilterConfig stores group filters as server payload', () {
    final config = GroupSavedFilterConfig(
      name: 'Missing directors',
      searchQuery: 'group',
      sort: 'name',
      descending: false,
      filter: const GroupFilter(
        isMissingField: 'director',
        subGroupCount: IntCriterion(
          value: 2,
          modifier: CriterionModifier.greaterThan,
        ),
        containingGroups: HierarchicalMultiCriterion(
          value: ['group-2'],
          excludes: ['group-3'],
          depth: -1,
        ),
        performers: MultiCriterion(
          value: ['performer-1'],
          excludes: ['performer-2'],
        ),
        createdAt: DateCriterion(
          value: '2026-01-01',
          value2: '2026-01-31',
          modifier: CriterionModifier.between,
        ),
      ),
    );

    final input = config.toSaveInput();
    final objectFilter = input['object_filter'] as Map<String, dynamic>;
    final findFilter = input['find_filter'] as Map<String, dynamic>;

    expect(input['mode'], 'GROUPS');
    expect(findFilter['direction'], 'ASC');
    expect(
      (objectFilter['is_missing'] as Map<String, dynamic>)['value'],
      'director',
    );
    expect(
      ((objectFilter['sub_group_count'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['value'],
      2,
    );
    expect(
      ((objectFilter['containing_groups'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['items'],
      [
        {'id': 'group-2', 'label': 'group-2'},
      ],
    );
    expect(
      ((objectFilter['performers'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['excluded'],
      [
        {'id': 'performer-2', 'label': 'performer-2'},
      ],
    );
    expect(objectFilter['created_at'], {
      'value': {'value': '2026-01-01', 'value2': '2026-01-31'},
      'modifier': 'BETWEEN',
    });
    expect(
      (objectFilter['sub_group_count'] as Map<String, dynamic>)['modifier'],
      'GREATER_THAN',
    );

    final loaded = GroupSavedFilterConfig.fromServerPayload(
      id: '1',
      name: 'Missing directors',
      objectFilter: objectFilter,
    );
    expect(loaded.filter.isMissingField, 'director');
    expect(loaded.filter.containingGroups?.value, ['group-2']);
    expect(loaded.filter.containingGroups?.excludes, ['group-3']);
    expect(loaded.filter.containingGroups?.depth, -1);
    expect(loaded.filter.performers?.value, ['performer-1']);
    expect(loaded.filter.performers?.excludes, ['performer-2']);
  });
}
