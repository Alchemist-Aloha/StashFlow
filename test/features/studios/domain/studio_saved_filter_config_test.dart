import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/studios/domain/entities/studio_saved_filter_config.dart';

void main() {
  test('StudioSavedFilterConfig loads snake_case server payloads', () {
    final config = StudioSavedFilterConfig.fromServerPayload(
      id: '12',
      name: 'Organized studios',
      findFilter: {'q': 'studio', 'sort': 'name', 'direction': 'ASC'},
      objectFilter: {
        'organized': {'value': 'true', 'modifier': 'EQUALS'},
        'child_count': {
          'value': {'value': 2},
          'modifier': 'GREATER_THAN',
        },
        'parents': {
          'value': [
            {'id': 'studio-1', 'label': 'Parent studio'},
          ],
          'modifier': 'INCLUDES',
        },
        'tags': {
          'value': {
            'items': [
              {'id': 'tag-1', 'label': 'Tag'},
            ],
            'excluded': <Object?>[],
            'depth': 2,
          },
          'modifier': 'INCLUDES',
        },
      },
    );

    expect(config.id, '12');
    expect(config.searchQuery, 'studio');
    expect(config.sort, 'name');
    expect(config.descending, false);
    expect(config.filter.organized, true);
    expect(config.filter.parentStudios?.value, ['studio-1']);
    expect(config.filter.tags?.value, ['tag-1']);
    expect(config.filter.tags?.depth, 2);
    expect(
      config.filter.childCount,
      const IntCriterion(value: 2, modifier: CriterionModifier.greaterThan),
    );

    final saved = config.toSaveInput()['object_filter'] as Map<String, dynamic>;
    expect((saved['organized'] as Map<String, dynamic>)['value'], 'true');
    expect((saved['parents'] as Map<String, dynamic>)['value'], [
      {'id': 'studio-1', 'label': 'studio-1'},
    ]);
  });
}
