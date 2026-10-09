import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag_saved_filter_config.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag_filter.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

void main() {
  test('TagSavedFilterConfig stores favorites-only as server favorite', () {
    final config = TagSavedFilterConfig(
      name: 'Favorite tags',
      searchQuery: 'fav',
      sort: 'name',
      descending: false,
      filter: const TagFilter(
        favorite: true,
        ignoreAutoTag: false,
        isMissingField: 'description',
        sortName: StringCriterion(value: 'sort'),
        parentCount: IntCriterion(value: 2),
        parents: HierarchicalMultiCriterion(value: ['parent-1']),
      ),
    );

    final input = config.toSaveInput();
    final objectFilter = input['object_filter'] as Map<String, dynamic>;
    final findFilter = input['find_filter'] as Map<String, dynamic>;

    expect(input['mode'], 'TAGS');
    expect(findFilter['direction'], 'ASC');
    expect((objectFilter['favorite'] as Map<String, dynamic>)['value'], 'true');
    expect(
      (objectFilter['ignore_auto_tag'] as Map<String, dynamic>)['value'],
      'false',
    );
    expect(
      (objectFilter['is_missing'] as Map<String, dynamic>)['value'],
      'description',
    );
    expect(
      (objectFilter['sort_name'] as Map<String, dynamic>)['value'],
      'sort',
    );
    expect(
      ((objectFilter['parent_count'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['value'],
      2,
    );
    expect(
      ((objectFilter['parents'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['items'],
      [
        {'id': 'parent-1', 'label': 'parent-1'},
      ],
    );

    final loaded = TagSavedFilterConfig.fromServerPayload(
      id: '1',
      name: 'Favorite tags',
      objectFilter: objectFilter,
    );
    expect(loaded.filter.favorite, isTrue);
    expect(loaded.filter.ignoreAutoTag, isFalse);
    expect(loaded.filter.isMissingField, 'description');
    expect(loaded.filter.parents?.value, ['parent-1']);
  });
}
