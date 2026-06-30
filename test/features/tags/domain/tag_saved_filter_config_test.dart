import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/features/tags/domain/entities/tag_saved_filter_config.dart';

void main() {
  test('TagSavedFilterConfig stores favorites-only as server favorite', () {
    final config = TagSavedFilterConfig(
      name: 'Favorite tags',
      searchQuery: 'fav',
      sort: 'name',
      descending: false,
      favorite: true,
    );

    final input = config.toSaveInput();

    expect(input['mode'], 'TAGS');
    expect(input['find_filter']['direction'], 'ASC');
    expect(input['object_filter']['favorite'], true);
  });
}
