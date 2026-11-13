import 'package:flutter_test/flutter_test.dart';
import 'package:stash_app_flutter/core/data/graphql/criterion_mapping.dart';
import 'package:stash_app_flutter/core/domain/entities/criterion.dart';

void main() {
  group('mapDuplicationCriterion', () {
    test('sends only the selected duplication fields', () {
      expect(
        mapDuplicationCriterion(const MultiCriterion(value: ['title', 'url']))!
            .toJson(),
        {'title': true, 'url': true},
      );
    });

    test('maps every web UI duplication field', () {
      expect(
        mapDuplicationCriterion(
          const MultiCriterion(value: ['phash', 'stash_id', 'title', 'url']),
        )!.toJson(),
        {'phash': true, 'stash_id': true, 'title': true, 'url': true},
      );
    });

    test('omits an empty selection', () {
      expect(mapDuplicationCriterion(null), isNull);
      expect(mapDuplicationCriterion(const MultiCriterion(value: [])), isNull);
    });
  });
}
