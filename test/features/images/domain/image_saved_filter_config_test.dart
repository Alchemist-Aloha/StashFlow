import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_filter.dart';
import 'package:stash_app_flutter/features/images/domain/entities/image_saved_filter_config.dart';

void main() {
  test('ImageSavedFilterConfig keeps organized state in object_filter', () {
    final config = ImageSavedFilterConfig(
      name: 'Organized images',
      searchQuery: 'cover',
      sort: 'path',
      descending: false,
      filter: const ImageFilter(
        organized: true,
        performerCount: IntCriterion(value: 2),
        studios: HierarchicalMultiCriterion(value: ['studio-1']),
        galleries: MultiCriterion(value: ['gallery-1']),
        code: StringCriterion(value: 'IMG-1'),
        photographer: StringCriterion(value: 'Alice'),
        phashDistance: PhashCriterion(value: 'abc', distance: 3),
        folder: HierarchicalMultiCriterion(value: ['folder-1']),
        isMissing: 'rating',
        customFields: [
          CustomFieldCriterion(field: 'source', value: ['archive']),
        ],
      ),
    );

    final input = config.toSaveInput();
    final objectFilter = input['object_filter'] as Map<String, dynamic>;

    expect(input['mode'], 'IMAGES');
    expect(
      (objectFilter['organized'] as Map<String, dynamic>)['value'],
      'true',
    );
    expect(
      ((objectFilter['performer_count'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['value'],
      2,
    );
    expect(
      ((objectFilter['studios'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['items'],
      [
        {'id': 'studio-1', 'label': 'studio-1'},
      ],
    );
    expect((objectFilter['galleries'] as Map<String, dynamic>)['value'], [
      {'id': 'gallery-1', 'label': 'gallery-1'},
    ]);
    expect((objectFilter['code'] as Map<String, dynamic>)['value'], 'IMG-1');
    expect(
      (objectFilter['photographer'] as Map<String, dynamic>)['value'],
      'Alice',
    );
    expect(
      ((objectFilter['phash_distance'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['distance'],
      3,
    );
    expect(
      ((objectFilter['folder'] as Map<String, dynamic>)['value']
          as Map<String, dynamic>)['items'],
      [
        {'id': 'folder-1', 'label': 'folder-1'},
      ],
    );
    expect(
      (objectFilter['is_missing'] as Map<String, dynamic>)['value'],
      'rating',
    );
    expect(
      (objectFilter['custom_fields'] as List)
          .cast<Map<String, dynamic>>()
          .single['field'],
      'source',
    );

    final loaded = ImageSavedFilterConfig.fromServerPayload(
      id: '1',
      name: 'Organized images',
      objectFilter: objectFilter,
    );
    expect(loaded.filter.organized, isTrue);
    expect(loaded.filter.studios?.value, ['studio-1']);
    expect(loaded.filter.galleries?.value, ['gallery-1']);
    expect(loaded.filter.phashDistance?.distance, 3);
    expect(loaded.filter.folder?.value, ['folder-1']);
    expect(loaded.filter.isMissing, 'rating');
    expect(loaded.filter.customFields.single.field, 'source');
  });
}
