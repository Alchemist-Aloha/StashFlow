import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/galleries/domain/entities/gallery_saved_filter_config.dart';

void main() {
  test('GallerySavedFilterConfig restores gallery snake_case fields', () {
    final config = GallerySavedFilterConfig.fromServerPayload(
      id: '8',
      name: 'Zip galleries',
      findFilter: {'sort': 'path', 'direction': 'DESC'},
      objectFilter: {
        'is_zip': {'value': 'true', 'modifier': 'EQUALS'},
        'image_count': {
          'value': {'value': 10},
          'modifier': 'GREATER_THAN',
        },
        'scenes': {
          'value': [
            {'id': 'scene-1', 'label': 'Scene'},
          ],
          'modifier': 'INCLUDES',
        },
        'code': {'value': 'GAL-1', 'modifier': 'EQUALS'},
        'photographer': {'value': 'Alice', 'modifier': 'EQUALS'},
        'parent_folder': {
          'value': {
            'items': [
              {'id': 'folder-1', 'label': 'Folder'},
            ],
            'excluded': <dynamic>[],
            'depth': 1,
          },
          'modifier': 'INCLUDES',
        },
        'is_missing': {'value': 'rating', 'modifier': 'EQUALS'},
        'custom_fields': [
          {
            'field': 'source',
            'value': ['archive'],
            'modifier': 'EQUALS',
          },
        ],
      },
    );

    expect(config.id, '8');
    expect(config.descending, true);
    expect(config.filter.isZip, true);
    expect(config.filter.scenes?.value, ['scene-1']);
    expect(config.filter.code?.value, 'GAL-1');
    expect(config.filter.photographer?.value, 'Alice');
    expect(config.filter.parentFolder?.value, ['folder-1']);
    expect(config.filter.isMissing, 'rating');
    expect(config.filter.customFields.single.field, 'source');
    expect(
      config.filter.imageCount,
      const IntCriterion(value: 10, modifier: CriterionModifier.greaterThan),
    );

    final saved = config.toSaveInput()['object_filter'] as Map<String, dynamic>;
    expect((saved['is_zip'] as Map<String, dynamic>)['value'], 'true');
    expect((saved['scenes'] as Map<String, dynamic>)['value'], [
      {'id': 'scene-1', 'label': 'scene-1'},
    ]);
  });
}
