import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer_filter.dart';
import 'package:stash_app_flutter/features/performers/domain/entities/performer_saved_filter_config.dart';

void main() {
  test(
    'PerformerSavedFilterConfig saves performer mode and filter payload',
    () {
      final config = PerformerSavedFilterConfig(
        name: 'Favorites',
        searchQuery: 'alice',
        sort: 'rating',
        descending: true,
        filter: const PerformerFilter(
          favorite: true,
          rating100: IntCriterion(value: 80),
        ),
      );

      final input = config.toSaveInput();

      expect(input['mode'], 'PERFORMERS');
      expect(input['find_filter']['q'], 'alice');
      expect(input['find_filter']['sort'], 'rating');
      expect(input['find_filter']['direction'], 'DESC');
      expect(input['object_filter']['filter_favorites'], true);
      expect(input['object_filter']['rating100']['value'], 80);
    },
  );
}
