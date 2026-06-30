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
        'is_zip': true,
        'image_count': {'value': 10, 'modifier': 'GREATER_THAN'},
      },
    );

    expect(config.id, '8');
    expect(config.descending, true);
    expect(config.filter.isZip, true);
    expect(
      config.filter.imageCount,
      const IntCriterion(value: 10, modifier: CriterionModifier.greaterThan),
    );
  });
}
