import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_filter.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_saved_filter_config.dart';

void main() {
  group('SceneSavedFilterConfig', () {
    test('builds server input from current search, sort, and scene filter', () {
      final config = SceneSavedFilterConfig(
        name: 'Favorites',
        searchQuery: 'studio search',
        sort: 'rating',
        descending: true,
        filter: const SceneFilter(
          title: StringCriterion(value: 'Example'),
          rating100: IntCriterion(
            value: 80,
            modifier: CriterionModifier.greaterThan,
          ),
          tags: HierarchicalMultiCriterion(
            value: ['7', '9'],
            excludes: ['11'],
            depth: 2,
          ),
          organized: true,
          oCounter: IntCriterion(value: 2),
          phashDistance: PhashCriterion(value: 'abc123', distance: 4),
          duplicated: MultiCriterion(value: ['phash', 'title']),
          productionDate: DateCriterion(value: '2026-09-01'),
          folder: HierarchicalMultiCriterion(value: ['folder-1'], depth: 1),
          performerFavorite: true,
          isMissing: 'studio',
          stashIdEndpoint: StashIdCriterion(
            endpoint: 'https://stashdb.org/graphql',
            stashId: 'stash-1',
          ),
          customFields: [
            CustomFieldCriterion(field: 'source', value: ['archive']),
          ],
        ),
        perPage: 60,
      );

      final input = config.toSaveInput();
      final objectFilter = input['object_filter'] as Map<String, dynamic>;
      final findFilter = input['find_filter'] as Map<String, dynamic>;

      expect(input['name'], 'Favorites');
      expect(input['mode'], 'SCENES');
      expect(findFilter['q'], 'studio search');
      expect(findFilter['sort'], 'rating');
      expect(findFilter['direction'], 'DESC');
      expect(findFilter['per_page'], 60);
      expect(objectFilter['rating100'], {
        'value': {'value': 80},
        'modifier': 'GREATER_THAN',
      });
      expect(objectFilter['tags'], {
        'modifier': 'INCLUDES',
        'value': {
          'items': [
            {'id': '7', 'label': '7'},
            {'id': '9', 'label': '9'},
          ],
          'excluded': [
            {'id': '11', 'label': '11'},
          ],
          'depth': 2,
        },
      });
      expect(objectFilter['organized'], {
        'value': 'true',
        'modifier': 'EQUALS',
      });
      expect(objectFilter['o_counter'], {
        'value': {'value': 2},
        'modifier': 'EQUALS',
      });
      expect(objectFilter, isNot(contains('oCounter')));
      expect(objectFilter['phash_distance'], {
        'modifier': 'EQUALS',
        'value': {'value': 'abc123', 'distance': 4},
      });
      expect(objectFilter['duplicated'], {
        'modifier': 'EQUALS',
        'value': {'phash': true, 'title': true},
      });
      expect(
        ((objectFilter['production_date'] as Map<String, dynamic>)['value']
            as Map<String, dynamic>)['value'],
        '2026-09-01',
      );
      expect(
        ((objectFilter['folder'] as Map<String, dynamic>)['value']
            as Map<String, dynamic>)['items'],
        [
          {'id': 'folder-1', 'label': 'folder-1'},
        ],
      );
      expect(
        (objectFilter['performer_favorite'] as Map<String, dynamic>)['value'],
        'true',
      );
      expect(
        (objectFilter['is_missing'] as Map<String, dynamic>)['value'],
        'studio',
      );
      expect(objectFilter['stash_id_endpoint'], {
        'modifier': 'EQUALS',
        'value': {
          'endpoint': 'https://stashdb.org/graphql',
          'stashID': 'stash-1',
        },
      });
      expect(objectFilter['custom_fields'], [
        {
          'field': 'source',
          'value': ['archive'],
          'modifier': 'EQUALS',
        },
      ]);
      expect(input['ui_options'], isA<Map<String, dynamic>>());
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
          'o_counter': {
            'value': {'value': 4},
            'modifier': 'GREATER_THAN',
          },
          'last_played_at': {
            'value': {'value': '2025-01-01'},
            'modifier': 'NOT_NULL',
          },
          'performers': {
            'value': ['3'],
            'modifier': 'INCLUDES',
          },
          'tags': {
            'value': {
              'items': [
                {'id': '7', 'label': 'Tag'},
              ],
              'excluded': [
                {'id': '9', 'label': 'Excluded tag'},
              ],
              'depth': 3,
            },
            'modifier': 'INCLUDES',
          },
          'galleries': {
            'value': [
              {'id': '5', 'label': 'Gallery'},
            ],
            'modifier': 'INCLUDES',
          },
          'phash_distance': {
            'value': {'value': 'abc123', 'distance': 4},
            'modifier': 'EQUALS',
          },
          'duplicated': {
            'value': {'phash': true, 'title': true, 'url': false},
            'modifier': 'EQUALS',
          },
          'production_date': {
            'value': {'value': '2026-09-01'},
            'modifier': 'EQUALS',
          },
          'folder': {
            'value': {
              'items': [
                {'id': 'folder-1', 'label': 'Folder'},
              ],
              'excluded': <dynamic>[],
              'depth': 1,
            },
            'modifier': 'INCLUDES',
          },
          'stash_id_endpoint': {
            'value': {
              'endpoint': 'https://stashdb.org/graphql',
              'stashID': 'stash-1',
            },
            'modifier': 'EQUALS',
          },
          'custom_fields': [
            {
              'field': 'source',
              'value': ['archive'],
              'modifier': 'EQUALS',
            },
          ],
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
      expect(config.filter.tags?.value, ['7']);
      expect(config.filter.tags?.excludes, ['9']);
      expect(config.filter.tags?.depth, 3);
      expect(config.filter.galleries?.value, ['5']);
      expect(config.filter.phashDistance?.value, 'abc123');
      expect(config.filter.phashDistance?.distance, 4);
      expect(config.filter.duplicated?.value, ['phash', 'title']);
      expect(config.filter.productionDate?.value, '2026-09-01');
      expect(config.filter.folder?.value, ['folder-1']);
      expect(config.filter.stashIdEndpoint?.stashId, 'stash-1');
      expect(config.filter.customFields.single.field, 'source');
    });

    test('loads official Stash numeric ranges and null criteria', () {
      final config = SceneSavedFilterConfig.fromServerPayload(
        id: '15',
        name: 'Numeric ranges',
        objectFilter: {
          'duration': {
            'value': {'value': 60, 'value2': 120},
            'modifier': 'BETWEEN',
          },
          'rating100': {'value': <String, dynamic>{}, 'modifier': 'NOT_NULL'},
        },
      );

      expect(
        config.filter.duration,
        const IntCriterion(
          value: 60,
          value2: 120,
          modifier: CriterionModifier.between,
        ),
      );
      expect(
        config.filter.rating100,
        const IntCriterion(value: 0, modifier: CriterionModifier.notNull),
      );
    });

    test('normalizes official boolean criterion maps without crashing', () {
      final config = SceneSavedFilterConfig.fromServerPayload(
        id: '13',
        name: 'Boolean criteria',
        objectFilter: {
          'organized': {'value': 'true', 'modifier': 'EQUALS'},
          'interactive': {'value': 'false', 'modifier': 'EQUALS'},
          'has_markers': {'value': 'true', 'modifier': 'EQUALS'},
          'is_missing': {'value': 'title', 'modifier': 'EQUALS'},
        },
      );

      expect(config.filter.organized, true);
      expect(config.filter.interactive, false);
      expect(config.filter.hasMarkers, true);
      expect(config.filter.isMissing, 'title');
    });

    test('normalizes single-value multi criteria from server payload', () {
      final config = SceneSavedFilterConfig.fromServerPayload(
        id: '14',
        name: 'Single tag',
        objectFilter: {
          'tags': {'value': '7', 'modifier': 'INCLUDES'},
          'performers': {'value': 9, 'modifier': 'INCLUDES'},
        },
      );

      expect(config.filter.tags?.value, ['7']);
      expect(config.filter.performers?.value, ['9']);
    });
  });
}
