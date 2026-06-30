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
      ),
    );

    final input = config.toSaveInput();

    expect(input['mode'], 'IMAGES');
    expect(input['object_filter']['organized'], true);
    expect(input['object_filter']['performer_count']['value'], 2);
  });
}
