import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_marker.dart';
import 'package:stash_app_flutter/features/scenes/domain/entities/scene_marker_saved_filter_config.dart';

void main() {
  test('scene marker saved filter saves official mode and server keys', () {
    final config = SceneMarkerSavedFilterConfig(
      name: 'Markers preset',
      searchQuery: 'beat',
      sort: 'seconds',
      descending: false,
      filter: const SceneMarkerFilter(
        tags: HierarchicalMultiCriterion(value: ['tag-1']),
        sceneTags: HierarchicalMultiCriterion(value: ['scene-tag-1']),
        scenes: MultiCriterion(value: ['scene-1']),
        duration: IntCriterion(
          value: 30,
          modifier: CriterionModifier.greaterThan,
        ),
        sceneDate: DateCriterion(value: '2024-06-01'),
      ),
    );

    final input = config.toSaveInput();
    final findFilter = input['find_filter'] as Map<String, dynamic>;
    final objectFilter = input['object_filter'] as Map<String, dynamic>;

    expect(input['mode'], 'SCENE_MARKERS');
    expect(input['name'], 'Markers preset');
    expect(findFilter['q'], 'beat');
    expect(findFilter['sort'], 'seconds');
    expect(findFilter['direction'], 'ASC');
    expect(
      ((objectFilter['tags'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['items'],
      [
        {'id': 'tag-1', 'label': 'tag-1'},
      ],
    );
    expect(
      ((objectFilter['scene_tags'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['items'],
      [
        {'id': 'scene-tag-1', 'label': 'scene-tag-1'},
      ],
    );
    expect((objectFilter['scenes'] as Map<String, dynamic>)['value'], [
      {'id': 'scene-1', 'label': 'scene-1'},
    ]);
    expect(
      ((objectFilter['duration'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['value'],
      30,
    );
    expect(
      ((objectFilter['scene_date'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['value'],
      '2024-06-01',
    );
  });

  test('scene marker saved filter loads server keys into local filter', () {
    final config = SceneMarkerSavedFilterConfig.fromServerPayload(
      id: 'preset-1',
      name: 'Server preset',
      findFilter: {
        'q': 'beat',
        'sort': 'scene_updated_at',
        'direction': 'DESC',
      },
      objectFilter: {
        'scene_tags': {
          'value': {
            'items': [
              {'id': 'scene-tag-1', 'label': 'Scene tag'},
            ],
            'excluded': <Object?>[],
            'depth': 1,
          },
          'modifier': 'INCLUDES',
        },
        'scene_updated_at': {
          'value': {'value': '2024-06-01'},
          'modifier': 'GREATER_THAN',
        },
      },
    );

    expect(config.id, 'preset-1');
    expect(config.searchQuery, 'beat');
    expect(config.sort, 'scene_updated_at');
    expect(config.descending, isTrue);
    expect(config.filter.sceneTags?.value, ['scene-tag-1']);
    expect(config.filter.sceneTags?.depth, 1);
    expect(config.filter.sceneUpdatedAt?.value, '2024-06-01');
    expect(
      config.filter.sceneUpdatedAt?.modifier,
      CriterionModifier.greaterThan,
    );
  });
}
