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
        'organized': true,
        'child_count': {'value': 2, 'modifier': 'GREATER_THAN'},
      },
    );

    expect(config.id, '12');
    expect(config.searchQuery, 'studio');
    expect(config.sort, 'name');
    expect(config.descending, false);
    expect(config.filter.organized, true);
    expect(
      config.filter.childCount,
      const IntCriterion(value: 2, modifier: CriterionModifier.greaterThan),
    );
  });
}
