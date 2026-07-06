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
      ),
    );

    final input = config.toSaveInput();

    expect(input['mode'], 'GROUPS');
    expect(input['find_filter']['direction'], 'ASC');
    expect(input['object_filter']['is_missing'], 'director');
    expect(input['object_filter']['sub_group_count']['value'], 2);
    expect(
      input['object_filter']['sub_group_count']['modifier'],
      'GREATER_THAN',
    );
  });
}
