import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/graphql/schema.graphql.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_saved_filter_config.dart';

void main() {
  group('SceneSavedFilterConfig', () {
    test('builds server input from current search, sort, and scene filter', () {
      final config = SceneSavedFilterConfig.current(
        name: 'Favorites',
        searchQuery: 'studio search',
        sort: 'rating',
        descending: true,
        filter: const SceneFilter(
          rating100: IntCriterion(
            value: 80,
            modifier: CriterionModifier.greaterThan,
          ),
          tags: HierarchicalMultiCriterion(value: ['7', '9']),
          organized: true,
          oCounter: IntCriterion(value: 2),
        ),
        perPage: 60,
      );

      final input = config.toSaveInput();

      expect(input.name, 'Favorites');
      expect(input.mode, Enum$FilterMode.SCENES);
      expect(input.find_filter?.q, 'studio search');
      expect(input.find_filter?.sort, 'rating');
      expect(input.find_filter?.direction, Enum$SortDirectionEnum.DESC);
      expect(input.find_filter?.per_page, 60);
      expect(input.object_filter, contains('"rating100"'));
      expect(input.object_filter, contains('"tags"'));
      expect(input.object_filter, contains('"organized":true'));
      expect(input.object_filter, contains('"o_counter"'));
      expect(input.object_filter, isNot(contains('"oCounter"')));
    });

    test('loads official Stash scene filter and sort from server payload', () {
      final config = SceneSavedFilterConfig.fromServerPayload(
        id: '12',
        name: 'Recent landscape',
        findFilter: {
          'q': 'landscape',
          'sort': 'date',
          'direction': 'ASC',
          'per_page': 45,
        },
        objectFilter: {
          'organized': false,
          'path': {'value': '/media', 'modifier': 'INCLUDES'},
          'o_counter': {'value': 4, 'modifier': 'GREATER_THAN'},
          'last_played_at': {'value': '2025-01-01', 'modifier': 'NOT_NULL'},
          'performers': {
            'value': ['3'],
            'modifier': 'INCLUDES',
          },
        },
      );

      expect(config.id, '12');
      expect(config.name, 'Recent landscape');
      expect(config.searchQuery, 'landscape');
      expect(config.sort, 'date');
      expect(config.descending, false);
      expect(config.perPage, 45);
      expect(config.filter.organized, false);
      expect(config.filter.path?.value, '/media');
      expect(config.filter.oCounter?.value, 4);
      expect(config.filter.lastPlayedAt?.value, '2025-01-01');
      expect(config.filter.performers?.value, ['3']);
    });
  });
}
